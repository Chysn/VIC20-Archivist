;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;                               VICfiction Engine
;
;                            (c) 2022, Jason Justian
;                  
; Assembled with XA
;
; xa -o story_name.bin ./src/VICfiction.asm ./src/StoryName.story.asm
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This software is released under the Creative Commons
; Attribution-NonCommercial 4.0 International
; License. The license should be included with this file.
; If not, please see: 
;
; https://creativecommons.org/licenses/by-nc/4.0/legalcode.txt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* = $2000                       ; Block 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VICFICTION SETTINGS AND LABELS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            
; Engine Memory Locations
VERB_ID     = $00               ; Verb ID
ITEM_ID     = $01               ; Item ID
PATTERN     = $02               ; Pattern (2 bytes) 
INVENTORY   = $a4               ; Inventory (2 bytes) 
CURR_ROOM   = $a6               ; Current room
ACT_SUCCESS = $a7               ; At least one action was successful
ACT_FAILURE = $a8               ; At least one action failed
TEMP        = $a9               ; Temporary values (3 bytes)
FROM_ID     = $ac               ; From ID during transform
TO_ID       = $ad               ; To ID during transform
RM          = $b0               ; Room address (2 bytes)
SCORE       = $b2               ; Score (number of scored items in SCORE_RM)
BUFFER      = $0220             ; Input buffer
SEEN_ROOMS  = $1c00             ; Marked as 1 when entered
TIMERS      = $1c80             ; Room timer countdown values
ITEM_ROOMS  = $1d00             ; RAM storage for item rooms

; Operating System Memory Locations
CASECT      = $0291             ; Disable Commodore case
VIC         = $9000             ; VIC chip offset
VIA1PA1     = $9111             ; VIA NMI Reset
KBSIZE      = $c6               ; Keyboard buffer size

; NMI Restore
NMINV       = $0318             ; Release NMI vector
;-NMINV     = $fffe             ; Development NMI non-vector (uncomment for dev)

; Routines
PRINT       = $cb1e             ; Temporary print
CHRIN       = $ffcf             ; Get input
CHROUT      = $ffd2             ; Character out
PRTFIX      = $ddcd             ; Decimal display routine
  
; Constants
SPACE       = $20               ; Space
LF          = $0d               ; Linefeed
RVS_ON      = $12               ; Reverse on
RVS_OFF     = $92               ; Reverse off
BACKSP      = $9d               ; Backspace
CLRHOME     = $93               ; CLEAR/HOME
CRSRUP      = $91               ; Cursor Up
ED          = $00               ; End of Data
GO_CMD      = 1                 ; Basic Command - GO
LOOK_CMD    = 2                 ;               - LOOK
GET_CMD     = 3                 ;               - GET
DROP_CMD    = 4                 ;               - DROP
INV_CMD     = 5                 ;               - INVENTORY
IS_INVIS    = $01               ; Item Property - Invisible
IS_UNMOVE   = $02               ;               - Unmoveable
IS_PLHOLDER = $04               ;               - Placeholder
IS_CLOCK    = $08               ;               - Clock display
IS_SCORED   = $40               ;               - Is scored
IS_LIGHT    = $80               ;               - Light source
IS_DARK     = $01               ; Room Property - Darkened
HIDE_DIR    = $02               ;               - Hide Directions
EV          = $ff               ; Special action id for triggered action

; RAM Start
; Used as jump to game when loaded from disk
; SYS8192
RAMStart:   jmp NewStory        ; BYPASS CARTRIDGE STUFF

; Initialize
; Used as target of autostart.asm in block 5
Init:       jsr $fd8d           ; Test RAM, initialize VIC chip
            jsr $fd52           ; Restore default I/O vectors
            jsr $fdf9           ; Initialize I/O registers
            jsr $e518           ; Initialize hardware
            jsr $c67a           ; Set some BASIC values, mostly $16
            cli                 ; Clear interrupt flag from ROM jump
            lda #<NewStory      ; Install the custom NMI (restart)
            sta NMINV           ; ,, 
            lda #>NewStory      ; ,,
            sta NMINV+1         ; ,,            
            ; Fall through to New Story

; New Story
NewStory:   bit VIA1PA1         ; Reset NMI
            lda #SCRCOL         ; Set screen color
            sta VIC+$0f         ; ,,
            lda VIC+$05         ; Set lowercase character set
            ora #$02            ; ,,
            sta VIC+$05         ; ,,
            lda #$80            ; Disable Commodore-Shift
            sta CASECT          ; ,,
            ldx #ST_ITEM_L      ; Initialize inventory
            stx INVENTORY       ; ,,
            ldx #ST_ITEM_R      ; ,,
            stx INVENTORY+1     ; ,,
            ldx #0              ; Init for score and for item location copy
            stx SCORE           ; Initialize score
            sty KBSIZE          ; Clear keyboard buffer
-loop:      inx                 ; Copy initial room location data to     
            lda ItemRoom-1,x    ;   RAM, so it can be updated as items are
            sta ITEM_ROOMS-1,x  ;   moved around
            lda Item1-1,x       ; Check for last item
            bne loop            ;   If not the last item, keep going
            ldx #$00            ; Clear both seen rooms (128 bytes) and
            lda #0              ;   timers (128 bytes)
-loop:      sta SEEN_ROOMS,x    ;   ,,
            inx                 ;   ,,
            bne loop            ;   ,,
            lda #<Intro         ; Show intro
            ldy #>Intro         ; ,,
            jsr PrintMsg        ; ,,
            lda #1              ; Initialize starting room
            jsr MoveTo          ;   ,,
            inc SEEN_ROOMS      ;   and mark as seen
            jmp EntryPt         ; Show room name before game starts
                 
; Verb Not Found
; Show an error message, then go back for another command 
Nonsense:   lda BUFFER+1        ; Potentially process a shortcut if
            bne ShowErr         ;   only one character
            lda BUFFER          ; If the player just hit RETURN, then
            cmp #' '            ;   there's no need to show an error
            beq Main            ;   ,,
shortcuts:  jmp ShortGo
ShowErr:    lda #<NoVerbTx      ; Show the error
            ldy #>NoVerbTx      ; ,,
            jsr PrintMsg        ; ,,
            ; Fall through to Main
 
; Main Routine      
Main:       lda #0              ; Clear the action success and failure
            sta ACT_SUCCESS     ;   flags
            sta ACT_FAILURE     ;   ,,
            lda #COL_INPUT      ; Set the color
            jsr CHROUT          ; ,,
            ldx #0              ; X is buffer index
            sta BUFFER          ; Clear the buffer
-loop:      jsr CHRIN           ; KERNAL CHRIN
            cmp #LF             ; Did user press RETURN?
            beq enter           ;   If so, go to end of input
            and #$7f            ; Make case-insensitive
            sta BUFFER,x        ; Store in buffer at the index
            inx                 ; Next character
            cpx #21             ; Prevent buffer overflow
            bcc loop            ; ,,  
enter:      jsr CHROUT          ; Print the RETURN
            lda #0              ; Add the line-ending null
            sta BUFFER,x        ; ,,
            jsr NormCol         ; Set normal color
            ; Fall through to Transcribe

; Transcribe Text Buffer
;   to Verb ID and Item ID
Transcribe: ldx #0              ; Buffer index
            jsr GetPattern      ; Find the first two-character pattern
            jsr GetVerbID       ; Use the pattern to get Verb ID from database
            bcc Nonsense        ; Show an error if verb not found
            jsr GetPattern      ; Find the next two-character pattern
            jsr GetItemID       ; Use the pattern to get Item ID from database
            ; Fall through to Process

; Process Command
; Start with the Action Engine. Look through the Action Database for 
; matching commands and execute them.            
Process:    ldx #$ff            ; Look for actions for this command's verb
next_act:   inx                 ; ,,
            lda ActVerb,x       ; ,,
            bne have_verb       ; After story actions
            jmp BasicAct        ;   do basic actions
have_verb:  cmp VERB_ID         ; ,,
            bne next_act        ; ,,
filter_rm:  lda ActInRoom,x     ; Filter action by room
            beq get_item        ;   If unset, keep going
            cmp CURR_ROOM       ;   If the current room isn't the specified
            bne next_act        ;     room, get next action
get_item:   lda ActItem,x       ; Get the item for this action
            beq item_ok         ;   If the action specifies no item, skip
            cmp ITEM_ID         ; Does the item match the action's item?
            bne next_act        ;   If not, go back for next action            
item_ok:    jsr EvalAction      ; Evaluate the action         
            jmp next_act        ; Get the next action

; Do Event
; Prepare to evaluate a single action (id in X)           
DoEvent:    cpx #0              ; If no action is specified, do nothing
            bne do_event        ; ,,
            rts                 ; ,,
do_event:   lda #0              ; Clear success and failure flags for use
            sta ACT_SUCCESS     ;   by caller
            sta ACT_FAILURE     ;   ,,
            ; Fall through to EvalAction

; Evaluate Action
; X is the Action ID            
EvalAction: jsr NormCol         ; Messages will be normal color
            lda ActInvCon,x     ; Is there an inventory item condition?
            beq inv_ok          ;   If not, it's unconditional
            jsr ItemInv         ; Is the player holding the specified item?
            bcc failure         ;   If not, the action fails
inv_ok:     lda ActRoomCon,x    ; Is there a room item condition?
            beq ch_excl         ;   If not, it's unconditional
            jsr ItemInRm        ; Is the item in the room or in inventory?
            bcc failure         ;   If no, the action fails
ch_excl:    lda ActInvExcl,x    ; Is there an item exclusion?
            beq success         ;   If not, the action is successful
            jsr ItemInv         ;   If so, the action is successful unless
            bcc success         ;     the item is in inventory
failure:    sec                 ; FAILURE!
            ror ACT_FAILURE     ; Set the action failure flag
            bit ACT_SUCCESS     ; If a previous success message was shown,
            bmi next_act        ;   suppress the failure message
            lda ActResTxtH,x    ; Show the failure message for the action
            beq next_act        ;   ,, (If high byte=0, it's a silent failure)
            tay                 ;   ,,
            lda ActResTxtL,x    ;   ,,
            jmp PrintAlt        ;   ,,
success:    sec                 ; SUCCESS!
            ror ACT_SUCCESS     ; Set the action success flag
            lda ActResTxtH,x    ; Show the success message for the action
            beq do_result       ;   ,, (If high byte=0, it's a silent success)
            tay                 ;   ,,
            lda ActResTxtL,x    ;   ,,
            jsr PrintMsg        ;   ,,
do_result:  lda ActFrom,x       ; Now for the result. Get the From ID
            bne is_from         ;   Is there a From ID?
            lda ActTo,x         ; If there's no From ID, is there a To ID?
            bne move_pl         ;   If From=0 and To=ID then move player
game_over:  lda #<GameOverTx    ; If From=0 and To=0 then game over
            ldy #>GameOverTx    ;   Display the Game Over message...
            jsr PrintMsg        ;   ,,
forever:    jmp forever         ; ...Then wait until RESTORE
move_pl:    jmp MoveTo          ; Set current room specified by To ID
is_from:    sta FROM_ID         ; Store the From ID temporarily
            lda ActTo,x         ; A = To ID?
            bne xform           ;   If so, do the transform
            ldy FROM_ID         ; If To=0 then move the item in From ID to
            lda CURR_ROOM       ;   the current room
            sta ITEM_ROOMS-1,y  ;   ,,
            
            sty TEMP            ; TEMP is the Item ID
            
            ldy #0              ; X = Timer ID
-loop:      lda TimerInit,y     ; If TimerInit is 0, that's the end of the
            beq timer_done      ;   timers
            lda TimerItem,y     ; Is this an item timer?
            cmp TEMP            ; Is this a timer for this item?
            bne next_timer      ;   If not, iterate to next timer
            lda TimerInit,y     ;   If so, initialize the timer
            sta TIMERS,y        ;   ,,
next_timer: iny                 ; Get next
            bne loop            ; ,,            
;            lda ItemProp-1,y    ; If an item moved to the current room is
;            and #IS_TRIGGER     ;   a trigger, then set the timer
;            beq not_trig        ;   ,,
;            lda #CLOCK_TR       ;   ,,
;            sta CLOCK           ;   ,,
timer_done: rts                 ; Finish processing this action
xform:      sta TO_ID           ; Transform - Put To where From is
            cmp FROM_ID         ;   If from and to are the same, no transform
            beq eval_r          ;   ,,
            ldy FROM_ID         ;   Get the From item's current location
            lda ITEM_ROOMS-1,y  ;   ,,
            ldy TO_ID           ;   And store it into the To index
            sta ITEM_ROOMS-1,y  ;   ,,
            ldy FROM_ID         ;   Take the To item out of the system by
            lda #0              ;     setting its room to 0
            sta ITEM_ROOMS-1,y  ;     ,,
            lda INVENTORY       ; Is the From item in the left hand?
            cmp FROM_ID         ;   ,,
            bne ch_inv2         ;   If not, check the other hand
            lda TO_ID           ;   Update the item in hand
            sta INVENTORY       ;   ,,
            cmp INVENTORY+1     ; If the same thing is in the other hand,
            bne eval_r          ;   then get rid of it
            lda #0              ;   ,,
            sta INVENTORY+1     ;   ,,
            jmp next_act        ;   Check next action
ch_inv2:    lda INVENTORY+1     ; Is the From item in the right hand?
            cmp FROM_ID         ;   ,,
            bne eval_r          ;   If not, finish evaluation
            lda TO_ID           ;   If so, switch
            sta INVENTORY+1     ;   ,,
            cmp INVENTORY       ; If the same thing is in the other hand
            bne eval_r          ;   then get rid of it
            lda #0              ;   ,,
            sta INVENTORY       ;   ,,
eval_r:     rts                 ; Finish evaluating

; Perform Basic Actions
; After the action processing is complete      
; Built-In Actions include
;   - GO
;   - LOOK
;   - GET
;   - DROP   
;   - INVENTORY
BasicAct:   bit ACT_SUCCESS     ; Bypass the basic actions if one or more
            bmi h_timer         ;   database actions was successful
            lda VERB_ID         ; Get the entered verb
            cmp #GO_CMD         ; Handle GO/MOVE
            bne ch_look         ; ,,
            jmp DoGo            ; ,,
ch_look:    cmp #LOOK_CMD       ; Handle LOOK
            bne ch_get          ; ,,
            jmp DoLook          ; ,,
ch_get:     cmp #GET_CMD        ; Handle GET/TAKE
            bne ch_inv          ; ,,
            jmp DoGet           ; ,,
ch_inv:     cmp #INV_CMD        ; Handle INVENTORY
            bne ch_drop         ; ,,
            jmp ShowInv         ; ,,
ch_drop:    cmp #DROP_CMD       ; Handle DROP
            bne no_cmd          ; ,,
            jmp DoDrop          ; ,,
no_cmd:     bit ACT_FAILURE     ; If there was an action failure, then a failure
            bmi basic_r         ;   message was already shown
            jmp Nonsense        ; Error message if no match
h_timer:    jsr AdvTimers       ; Timer countdown or advance
basic_r:    jmp Main            ; Return to Main main routine

; Do Drop
; Of Item ID
DoDrop:     lda ITEM_ID         ; If no Item ID was found, show an
            beq unknown         ;   error message
            ldy #1              ; Y is the hand index
ch_hand:    lda INVENTORY,y     ; Is the specified item in this hand?
            cmp ITEM_ID         ;   ,,
            beq drop_now        ;   If so, drop it
            dey                 ;   If not, check the other hand
            bpl ch_hand         ;   ,,
unknown:    lda #<NoDropTx      ; The item was not found in inventory, so
            ldy #>NoDropTx      ;   show the "don't have it" message
            jsr PrintRet        ;   ,,
drop_now:   tax                 ; X is the item index
            lda CURR_ROOM       ; Put the item in the current room
            sta ITEM_ROOMS-1,x  ; ,,
            lda #0              ; Remove it from the hand it's in
            sta INVENTORY,y     ; ,,
            jsr ShowScore       ; Show the score if a new item was dropped 
            lda SCORE           ; Have we reached the score target?
            cmp #SCORE_TGT      ; ,,
            bne drop_conf       ; ,,
            ldx #SCORE_ACT      ; If so, trigger the score action
            jsr DoEvent         ; ,,
drop_conf:  jmp Confirm         ; Show the confirmation message
drop_r:     jmp Main            ; Return to Main routine

; Do Look                        
DoLook:     jsr IsLight         ; If this is a dark room, and player has no
            bcs sees_look       ;   light source items, just show the "no light"
ShowNoSee:  lda #<NoLightTx     ;   message
            ldy #>NoLightTx     ;   ,,
            jmp PrintRet        ;   ,,
sees_look:  lda ITEM_ID         ; Get the current Item ID
            bne SingleItem      ; If there's an Item ID, then LOOK at it
            jsr RoomDesc        ; Show room desciption
            jmp Main            
            ; Look at a single item
SingleItem: jsr ItemInRm        ; The LOOK command took an Item ID. Is that item
            bcs in_room         ;   in the current room?
NotHere:    lda #<NotHereTx     ; If the specified item isn't in the room or
            ldy #>NotHereTx     ;   inventory, show a message and go back
            jmp PrintRet        ;   for another command
in_room:    tax                 ; X = specified Item ID
            lda ItemTxtH-1,x    ; Show the description of the item
            tay                 ; ,,
            lda ItemTxtL-1,x    ; ,,
            jsr PrintAlt        ; ,,
            lda ItemProp-1,x    ; If this object is a timer, show its current
            and #IS_CLOCK       ;   value
            beq look_r          ;   ,,
            ldx TimerOffst      ; X is the number of "hours" in the display    
            lda TIMERS          ; Get the timer value
sub_hour:   cmp #60             ; Divide by 60
            bcc lt_hour         ; ,,
            sec                 ; ,,
            sbc #60             ; ,,
            inx                 ; ,,
            bne sub_hour        ; ,,
lt_hour:    pha                 ; Show the hour display (X=low byte)
            lda #0              ; ,,
            jsr PRTFIX          ; ,,
            lda #':'            ; Colon for the timer
            jsr CHROUT          ; ,,
            pla                 ; A is the minutes part
            cmp #10             ; If < 10, pad zero
            bcs show_min        ; ,,
            pha                 ; ,,
            lda #'0'            ; ,,
            jsr CHROUT          ; ,,
            pla                 ; Get back minutes part and transfer
show_min:   tax                 ;   to X for printing
            lda #0              ; High byte is 0 (because value is 0-60)
            jsr PRTFIX          ; Print the number
            jsr Linefeed        ; Finish with linefeed
look_r:     jmp Main            ; Return to Main routine

; Do Go           
DoGo:       ldx #0              ; Starting from the first character,
            jsr GetPattern      ;   skip the first pattern (GO/MOVE)
            jsr GetPattern      ;   and get the second
ShortGo:    ldy #5              ; 5 is room index for North parameter
-loop:      lda Directions,y    ; A is character for direction
            cmp PATTERN         ; Is this the attempted direction?
            beq try_move        ;   If so, try moving that way
            dey                 ; Get next direction
            bpl loop            ;   until done
            bmi invalid         ; Direction name not found
try_move:   lda (RM),y          ; Get the room id at the found index
            beq go_fail         ; Player is going an invalid direction
            jsr MoveTo          ; Set room address (RM) and CURR_ROOM            
EntryPt:    lda #COL_ROOM       ; Always show room name after move
            jsr CHROUT          ; ,,
            jsr Linefeed        ; ,,
            jsr RoomName        ; ,,
            jsr PrintMsg        ; ,,
            bit ACT_SUCCESS     ; If a room action was successful, don't
            bmi go_r            ;   show anything further
ch_first:   ldx CURR_ROOM       ; Is this the first time this room has been
            lda SEEN_ROOMS-1,x  ;   visited?
            bne go_r            ; Already been visitied, so leave
            jsr RoomDesc        ; Show room description
            jmp Main         
invalid:    jmp ShowErr         ; Like Nonsense, but don't look at shortcuts
go_fail:    jsr IsLight         ; Failed to move. If there's light in the room
            bcs sees_path       ;   the player can see that they've moved
            jsr Linefeed        ; If it's dark, simply complain about it
            jmp ShowNoSee       ; ,,
sees_path:  lda #<NoPathTx      ; Show "no path" message and return to Main
            ldy #>NoPathTx      ; ,,
PrintRet:   jsr PrintMsg        ; ,,
go_r:       jmp Main    

; Do Get            
DoGet:      lda ITEM_ID         ; Is there an item to get?
            beq get_fail        ;   If not, say it's not here
            jsr ItemInv         ; Is the item in inventory already?
            bcc ch_in_rm        ; ,,
            lda #<HaveItTx      ; If in inventory, show the "already have it"            
            ldy #>HaveItTx      ;   message
            jmp PrintRet        ;   ,,
ch_in_rm:   jsr ItemInRm        ; If the item is not available to get, then
            bcc get_fail        ;   say it's not here
            tax                 ; X = Item ID
            lda ItemProp-1,x    ; Is this an un-moveable item?
            and #IS_UNMOVE      ; ,,
            bne unmoving        ; ,,
            lda INVENTORY       ; Is the left hand available? If so, pick it
            bne ch_empty        ;   up and store it there
            stx INVENTORY       ;   ,,
            jmp got_it          ;   ,,
ch_empty:   lda INVENTORY+1     ; Otherwise, is the right hand available?
            bne hands_full      ;   If not, show "hands full" message
            stx INVENTORY+1     ;   If so, store it there
got_it:     lda #0              ; Clear the item from the room
            sta ITEM_ROOMS-1,x  ; ,,
Confirm:    lda #<ConfirmTx     ; Confirm the pick up
            ldy #>ConfirmTx     ; ,,
            jmp PrintRet        ; ,,
            ; Print various messages
get_fail:   jmp NotHere
unmoving:   lda #<NoMoveTx
            ldy #>NoMoveTx
            jmp PrintRet
hands_full: lda #<FullTx
            ldy #>FullTx
            jmp PrintRet
     
; Show Inventory       
ShowInv:    lda #COL_ITEM       ; Set inventory color
            jsr CHROUT          ; ,,
            ldy #1              ; Y is the hand index
-loop:      lda INVENTORY,y     ; Look in this hand
            beq nothing         ; If nothing's in it, iterate
            tax                 ; X is the item index
            sty TEMP            ; Stash Y against print subroutine
            lda ItemTxtL-1,x    ; Output the name
            ldy ItemTxtH-1,x    ; ,,
            jsr PrintNoLF       ; ,,
            ldy TEMP            ; Restore Y
nothing:    dey
            bpl loop
            jmp Main    
                                                       
; Get Pattern
;   from the Input Buffer
;   starting at position X  
GetPattern: lda BUFFER,x        ; Trim leading spaces by ignoring them
            inx                 ; ,,
            cmp #SPACE          ; ,,
            beq GetPattern      ; ,,
            sta PATTERN         ; Put the first character into the pattern
            sta PATTERN+1       ; ,,
-loop:      lda BUFFER,x        ; Get subsequent characters until we hit a
            beq pattern_r       ;   space or end of string, storing each in
            cmp #' '            ;   the second pattern byte, which will be
            beq pattern_r       ;   the final character of a verb or item
            sta PATTERN+1       ;   ,,
            inx                 ;   ,,
            lda BUFFER,x        ;   ,,
            beq pattern_r       ;   ,,
            cmp #SPACE          ;   ,,
            bne loop            ;   ,,
pattern_r:  rts

; Get Verb ID
; Go through first and last characters of the verb until
; a match is found, or return with carry clear
; Carry set indicates success, with VerbID set to index
; Verb IDs are 1-indexed
GetVerbID:  ldy #1              ; Verb index
-loop:      lda Verb1-1,y       ; Does the first character match this verb?
            cmp PATTERN         ; ,,
            bne next_verb       ; ,,
            lda VerbL-1,y       ; If so, does the last character match?
            cmp PATTERN+1       ; ,,
            beq verb_found      ; If so, store the verb id (Y), set carry
next_verb:  iny                 ; Otherwise, try the next verb
            cmp #ED             ;   Is this the end of the list?
            bne loop            ;   If not, try next verb
            clc                 ; Set error condition
            rts                 ; At end of list, return with carry clear
verb_found: lda VerbID-1,y      ; Cross-reference VerbID to handle synonyms
            tay                 ; ,,
            sty VERB_ID         ; Set VerbID, set carry, and return
            sec                 ; ,,
            rts                 ; ,,
            
; Is Item In Room?
; Specify Item ID in A  
; Carry set if in room          
ItemInRm:   tay                 ; Y is the Item ID
            lda ITEM_ROOMS-1,y  ; Is the item in the current room?
            cmp CURR_ROOM       ; ,,
            beq yes_in_rm       ; ,,
            tya                 ; Is the item in inventory?
in_inv:     cmp INVENTORY       ; ,, (left hand)
            beq yes_in_rm       ; ,,
            cmp INVENTORY+1     ; ,, (right hand)
            beq yes_in_rm       ; ,,
no_in_rm:   tya                 ; Restore A for caller
            clc                 ; Clear carry (not in room)
            rts
yes_in_rm:  tya                 ; Restore A for caller
            sec                 ; Set carry (in room)
            rts

; Is Item In Inventory
; Specify Item ID in A  
; Carry set if in inventory          
ItemInv:    tay
            jmp in_inv
            
; Get Item ID
; Go through first and last characters of the item until
; a match is found, or return 0 as the ItemID
; Item IDs are 1-indexed
;
; Note that an ItemID of 0 is not necessarily an error. It just means that
; the player specified a verb only, which is often fine.   
GetItemID:  ldy #0              ; Item index
            sty ITEM_ID         ; Default (unfound) Item ID
-loop:      iny                 ; Advance the index
            lda Item1-1,y       ; Get the first character of this item
            beq ch_ph           ; If end of list, return with ItemID at 0
            cmp PATTERN         ; Does the first character match?
            bne loop            ;   If not, try the next item
            lda ItemL-1,y       ; If so, does the second character match?
            cmp PATTERN+1       ;   ,,
            bne loop            ;   If not, try the next item
            sty ITEM_ID         ; Store Item ID provisionally
            tya                 ; Is the item with the found name in the
            jsr ItemInRm        ;   player's current room?
            bcc loop            ;   If not, continue
            sty ITEM_ID         ; Store the specific Item ID if found in room
ch_ph:      ldy ITEM_ID         ; Get the Item ID, if any 
            beq itemid_r        ; ,,
            lda ItemProp-1,y    ; If the item is a placeholder, it will not
            and #IS_PLHOLDER    ;   be used as an Item ID in a command
            beq itemid_r        ;   ,,
            ldy #0
            sty ITEM_ID         ; Item has been found. Set ItemID and return
itemid_r:   rts                 ; ,,

; Move To Room
; Set current room to A and add room parameter address to (RM)
MoveTo:     sta CURR_ROOM
            txa
            pha
            lda #<Rooms         ; Set starting room address
            sta RM              ; ,,
            lda #>Rooms         ; ,,
            sta RM+1            ; ,,
            ldx CURR_ROOM       ; X = room id
            dex                 ; zero-index it
            beq ch_room_t       ; if first room, (RM) is already set
-loop:      lda #9              ; Add 9 for each id
            clc                 ; ,,
            adc RM              ; ,,
            sta RM              ; ,,
            bcc nc1             ; ,,
            inc RM+1            ; ,,
nc1:        dex                 ; ,,
            bne loop            ; Multiply
ch_room_t:  ldx #$ff            ; Check Room Timers. X is the Room Timer ID
-loop:      inx                 ; Advance to next ID 
            lda TimerInit,x     ; Reached the end of Room Timers?
            beq moveto_r        ;   If so, exit
            lda TimerRoom,x     ; Get timer's room
            cmp CURR_ROOM       ; Is player in this room?
            bne loop            ;   If not, get next Room Timer
            ldy CURR_ROOM       ; Does the "seen" status of this room match
            lda SEEN_ROOMS-1,y  ;   the timer's setting?
            cmp TimerSeen,x     ;   ,,
            bne loop            ;   If not, get the next Room Timer
            lda TimerInit,x     ; Initialize the timer countdown
            sta TIMERS,x        ; ,,
            bne loop
moveto_r:   jsr AdvTimers
            pla
            tax
            rts

; Set Room Name
; Set up A and Y for room description display. This should be followed by
; PrintAlt (for name), or PrintMsg (for description)         
RoomName:   jsr IsLight         ; Is the room illuminated?
            bcs sees_name       ; ,,
            jmp ShowNoSee       ; ,,
sees_name:  ldy #7              ; 7 = desc low byte parameter
            lda (RM),y          ; A is low byte
            pha                 ; Push low byte to stack
            iny                 ; 7 = high byte parameter
            lda (RM),y          ; A is high byte
            tay                 ; Y is now high byte (for PrintMsg)
            pla                 ; A is now low byte (for PrintMsg)
            rts
             
; Advance Timers    
; Advance (or coutdown) the Clock, then countdown each set Room Timer
; Timers are advanced when
;   1) The player moves to a new room
;   2) At least one story action was successful during a turn
;      (Cascaded actions on a single turn advance the timer once)     
AdvTimers:  lda TIMERS          ; If the timer is 0, then it's not active
            beq adv_room_t      ;   so check other Timers
            clc                 ; Add to timer
            adc TimerDir        ;   $01 for +1, $ff for -1
            sta TIMERS
            cmp TimerTgt        ; Has clock hit the target?
            bne adv_room_t      ;   If not, check Room Timers
            ldx TimerAct        ; Do the specified timeout action
            jsr DoEvent         ; ,,
adv_room_t: ldx #$00            ; X = Room Timer index (Timer 0 is the Clock)
-loop:      inx                 ; ,,
            lda TimerInit,x     ; Does the timer exist?
            beq timer_r         ;   If not, at end of timers, exit
            lda TIMERS,x        ; Does the timer have a value?
            beq loop            ;   If not, get next timer
            dec TIMERS,x        ; Decrement the timer
            bne loop            ; If it hasn't reached 0, get next timer
            txa                 ; Preserve X against event action
            pha                 ; ,,
            lda TimerAct,x      ; Get Action ID
            tax
            jsr DoEvent         ; Perform the event
            pla
            tax
            jmp loop            ; Get next timer
timer_r:    rts

; Room Description
; Show name, description, item list, directional display, and score
RoomDesc:   jsr IsLight         ; Is the room illuminated?
            bcs sees_desc       ; ,,
            jmp ShowNoSee       ; ,,
sees_desc:  jsr NormCol         ; Otherwise look refers to a whole room
            jsr RoomName        ; Get room information
            jsr PrintAlt        ; ,,
            ldx CURR_ROOM       ; Flag the room as seen
            lda #1              ; ,,
            sta SEEN_ROOMS-1,x  ; ,,
            ; Fall through to ItemDisp

            ; Item display
ItemDisp:   jsr Linefeed
            lda #COL_ITEM       ; Set item color
            jsr CHROUT          ; ,,
            ldx #0              ; X is the item index
next_item:  inx                 ; ,,
            lda Item1-1,x       ; Has the last item been reached?
            beq DirDisp         ;   If so, show directional display
            lda CURR_ROOM                        
            cmp ITEM_ROOMS-1,x  ; Is the indexed item in the current room?
            bne next_item       ;   If not, check next item
            lda ItemProp-1,x    ; The item is in the current room, but is it
            and #IS_INVIS       ;   visible?
            bne next_item       ;   If not, check the next item
            lda ItemTxtL-1,x    ;   ,,
            ldy ItemTxtH-1,x    ;   ,,
            jsr PrintNoLF       ;   ,,
            jmp next_item       ; Go to the next item
            
            ; Directional display
DirDisp:    ldy #6              ; Room properties
            lda (RM),y          ; If directions are hidden, skip
            and #HIDE_DIR       ; ,,
            bne ShowScore       ; ,,
            lda #COL_DIR        ; Set directional display color
            jsr CHROUT          ; ,,
            lda #'('            ; Open paren
            jsr CHROUT          ; ,,
            ldy #5              ; 5 is room index for North parameter
-loop:      lda (RM),y          ; Get room id for room in this direction
            beq next_dir        ; Is there a room that way?
            lda Directions,y    ; If so, get the character
            ora #$80            ;   make it uppercase
            jsr CHROUT          ;   and print it
            lda #','
            jsr CHROUT
next_dir:   dey                 ; Get next direction
            bpl loop            ;   until done            
dir_end:    lda #BACKSP
            jsr CHROUT
            lda #')'            ; Close paren
            jsr CHROUT          ; ,,
            jsr Linefeed        ; Linefeed 
            ; Fall through to ShowScore

; Show Score
ShowScore:  ldx #0              ; X is the item index
            stx SCORE           ; And reset score
            lda CURR_ROOM       ; Score is only shown in the score room
            cmp #SCORE_RM       ; ,,
            bne score_r         ; ,,
-loop:      inx                 ; For each item
            lda Item1-1,x       ;   End of items?
            beq ch_score        ;   ,,
            lda ItemProp-1,x    ;   Is it a scored item?
            and #IS_SCORED      ;   ,,
            beq loop            ;   ,,
            lda ITEM_ROOMS-1,x  ;   Is it dropped in the current room?
            cmp #SCORE_RM       ;   ,,
            bne loop            ;   ,,  
            inc SCORE           ; Increment score if it qualifies  
            bne loop          
ch_score:   ldx SCORE           ; If there's no score, don't display
            beq score_r         ; ,,
            lda #<ScoreTx       ; Print the score text
            ldy #>ScoreTx       ; ,,
            jsr PRINT           ; ,,
            ldx SCORE           ; Use BASIC's PRTFIX to show the decimal score
            lda #0              ; ,, (X is low byte, A is high byte)
            jsr PRTFIX          ; ,,
            lda #'/'            ; Slash for "of"
            jsr CHROUT          ; ,,
            ldx #SCORE_TGT      ; And now show the target score
            lda #0              ; ,,
            jsr PRTFIX          ; ,,        
            jsr Linefeed
score_r:    rts
 
; Is Light
; Is there light in the current room?
; Carry set if yes
IsLight:    ldy #6              ; Get room property
            lda (RM),y          ; ,,
            and #IS_DARK        ; Is this a dark room?
            beq room_light      ;   If not return with cary set
            ldy #1              ; Hand index
-loop:      lda INVENTORY,y     ; Does this hand contain a light source?
            tax                 ; ,,
            lda ItemProp-1,x    ; ,, Get item property
            and #IS_LIGHT       ; ,,
            bne room_light      ; ,,
            dey                 ; Check the other hand
            bpl loop            ; ,,
            clc                 ; No hands had a light source, so clear
            rts                 ;   carry for darkness
room_light: sec                 ; The room is well-illuminated, so set
            rts                 ;   carry for light
            
; Print Alternate Message
; Given the Message address (A, Y), look for the ED+1, then print from there
PrintAlt:   sta PATTERN
            sty PATTERN+1
            ldy #0
-loop:      lda (PATTERN),y
            inc PATTERN
            bne ch_end
            inc PATTERN+1
ch_end:     cmp #0
            bne loop
set_print:  lda PATTERN
            ldy PATTERN+1       
            ; Fall through to PrintMsg

; Print Message 1
; Print the first message at the specified address
PrintMsg:   pha
            tya
            pha
            jsr Linefeed
            pla
            tay
            pla
PrintNoLF:  stx TEMP+2
            jsr PRINT
            cpy #0              ; If nothing was printed, skip the
            beq print_r         ;   line feed
            jsr Linefeed        ; 
print_r:    ldx TEMP+2
            rts
 
; Normal Color Shortcut
NormCol:    lda #COL_NORM
            .byte $3c

; Linefeed Shortcut
Linefeed:   lda #LF
            jmp CHROUT 
