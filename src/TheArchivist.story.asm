;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;                                 The Archivist
;
;                             VICfiction Story File
;                            (c) 2022, Jason Justian
;                  
; Assembled with XA
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
; STORY-SPECIFIC CONFIGURATION SETTINGS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            
; Colors
SCRCOL      = 8                 ; Screen color
COL_INPUT   = 5                 ; Input color
COL_NORM    = 30                ; Text color
COL_ALERT   = 28                ; Alert color
COL_ITEM    = 158               ; Item color
COL_ROOM    = 31                ; Room name color
COL_DIR     = 159               ; Directional display color

; Story Configuration
; When the SCORE_TGT number of items are present in the room id specified
; by SCORE_ROOM, the action id specified in SCORE_ACT is triggered
SCORE_RM    = 1                 ; Score room id
SCORE_TGT   = 5                 ; Target score
SCORE_ACT   = 46                ; Action id when score is achieved

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GAME DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
SaveFile:   .asc "ARCHIVIST.SAV"
EON:        .asc 0              ; Here to determine length of filename

Directions:
            .asc 'DUEWSN'       ; Compass directions
;           .asc 'DUSPAF'        ; Maritime directions

; Inventory
; StartInv - A list of Item IDs the player has at the beginning of the game.
;            Make sure to pad this to 16 items.
; MAX_INV  - A constant specifying the NUMBER of items the player can have,
;            NOT the last inventory index.
StartInv:   .asc 6,0
MAX_INV     = 3

; Text - Game Messages, Errors, etc.
Intro:      .asc CLRHOME,COL_NORM,"yOU ARRIVE AT WORK",LF,"IN THE USUAL WAY, BY"
            .asc LF,"CURSOR. aFTER ALL,",LF,"YOU LIVE IN 1841. yOU",LF
            .asc "ONLY WORK IN 6205.",LF,LF,"yOU STRAIGHTEN YOUR",LF
            .asc "GLASSES AND GLANCE AT",LF,"THE JOB SCREEN.",LF,LF
            .asc "dAMN BUSY DAY AHEAD.",LF,LF,
            .asc 28,"tHE aRCHIVIST",LF,LF
            .asc "2022 jASON jUSTIAN",LF
            .asc "bEIGE mAZE vic lAB",LF,LF
            .asc COL_NORM,"*h hELP",ED
HelpTx:     .asc "bASIC vERBS:",LF,LF,"go/move     get/take",LF
            .asc "look/ex/l    drop/dp",LF,"inventory/i   wait/z",LF,LF,LF
            .asc "sYSTEM cOMMANDS:",LF,LF
            .asc "*s sAVE       *h hELP",LF,"*l lOAD       *q qUIT",LF,LF,LF
            .asc "BEIGEMAZE.COM/VICFIC",LF,ED
ScoreTx:    .asc "qUOTA: ",ED
NoVerbTx:   .asc COL_ALERT,"nO NEED TO DO THAT.",ED
NoDropTx:   .asc COL_ALERT,"yOU DON'T HAVE THAT.",ED
HaveItTx:   .asc COL_ALERT,"yOU ALREADY HAVE IT.",ED
GameOverTx: .asc COL_ALERT,"    - the end -",ED
NotHereTx:  .asc COL_ALERT,"tHAT'S NOT HERE.",ED
UnknownTx:  .asc COL_ALERT,"tHAT'S UNIMPORTANT.",ED
NoPathTx:   .asc COL_ALERT,"cAN'T GO THAT WAY.",ED
NoDirTx:    .asc COL_ALERT,"wHICH WAY?",ED
NoMoveTx:   .asc COL_ALERT,"tHAT WON'T MOVE.",ED
FullTx:     .asc COL_ALERT,"yOU CAN'T CARRY MORE.",ED
NoLightTx:  .asc COL_ALERT,"yOU CAN'T SEE.",ED
ConfirmTx:  .asc COL_ALERT,"ok.",ED

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VERBS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            
; VerbID - Cross-referenced ID list for verb synonyms
; Basic - GO (MovE), LooK (L,EX), GeT (TakE), DroP, InventorY (I), WAIT (Z)
; Game - TALK(7), WIND(8), DIAL(9), SET(2), SWAP(10), BUY(11), CATCH(12)
;        OPEN(13), PANIC(14), ENTER(15), SCAN(16), PLAY(17),
;        ATTACK/KILL/FIGHT(18), CALL(19), SHOW(2), WEAR(20), STEAL(3), RUN(1)
;        EAT(21)
; Verb IDs are 1-indexed
Verb1:      .byte 'G','M','L','L','E','G','T','D','I','I','W','Z'   ; Basic Verbs
            .byte 'T','W','D','R','S','B','C','O','P','E'
            .byte 'S','P','A','K','F','C','S','W','S','R','E',ED
VerbL:      .byte 'O','E','K','L','X','T','E','P','Y','I','T','Z'   ; Basic Verbs
            .byte 'K','D','L','D','P','Y','H','N','C','R'
            .byte 'N','Y','K','L','T','L','W','R','L','N','T'
VerbID:     .byte  1,  1,  2,  2,  2,  3,  3,  4,  5,  5,  6,  6    ; Basic Verbs
            .byte  7,  8,  9,  2, 10, 11, 12, 13, 14, 15
            .byte 16, 17, 18, 18, 18, 19,  2, 20,  3,  1, 21

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ROOMS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            
;    D,U,E,W,S,N specify the Room ID for the room in that direction. 0 if there's
;        nothing that way
;    ActID  - Specifes the Action ID that happens whenever the player walks
;      into this room
;    RmProp - Room properties
;      Bit 0 - The room is dark. The player can't see unless carrying an item
;              with the IS_LIGHT property
;      Bit 1 - Direction Display is suppressed
;      Bit 2 - Timers (except 0) are cleared when this room is entered
; Room IDs are 1-indexed
Rooms:      ; Main Facility (1-3)
            ;     D, U, E, W, S, N, RmProp, DescL, DescH
            .byte 2, 0, 0, 0, 0, 0, 4, <rIntake,>rIntake        ; CLR_TIMERS
            .byte 0, 1, 3, 0, 0, 0, 0, <rOffice,>rOffice
            .byte 0, 0, 0, 2, 0, 0, 0, <rPlaza,>rPlaza
            
            ; Graff House, 1776 (4-8)
            ;     D, U, E, W, S, N, RmProp, DescL, DescH
            .byte 0, 0, 5, 0, 0, 0, 0, <rCorner,>rCorner
            .byte 0, 7, 0, 4, 0, 0, 0, <rFoyer,>rFoyer
            .byte 0, 0, 0, 0, 0, 7, 0, <rJeffRoom,>rJeffRoom
            .byte 5, 0, 0, 0, 6, 8, 0, <rLanding,>rLanding
            .byte 0, 0, 0, 0, 7, 0, 0, <rJeffBed,>rJeffBed
            
            ; Navin Field, 1934 (9-15, 52)
            ;     D, U, E, W, S, N, RmProp, DescL, DescH
            .byte 0, 0, 0, 0, 0,14, 0, <rTBooth,>rTBooth
            .byte 0, 0,11,13,14,52, 0, <rHomeSt,>rHomeSt
            .byte 0, 0, 0,12,10, 0, 0, <rRightF,>rRightF
            .byte 0, 0,11,13,10, 0, 0, <rCenterF,>rCenterF
            .byte 0, 0,12, 0,10, 0, 0, <rLeftF,>rLeftF
            .byte 0, 0, 0, 0, 9,10, 0, <rCorridor,>rCorridor
            .byte 0, 0, 0, 0, 0, 0, 2, <rJail,>rJail
            
            ; Nefertari's Tomb, 1256BC (16-22)
            ;     D, U, E, W, S, N, RmProp, DescL, DescH
            .byte 0, 0,17, 0, 0, 18, 1, <rAnteCh,>rAnteCh
            .byte 0, 0, 0,16, 0, 0 , 1, <rSideCh,>rSideCh
            .byte 19,0, 0, 0, 16,0 , 1, <rRamp,>rRamp
            .byte 0,18,21,20, 0, 22, 1, <rSarcRm,>rSarcRm
            .byte 0,0, 19, 0, 0, 0 , 1, <rWAnnex,>rWAnnex
            .byte 0,0,  0,19, 0, 0 , 1, <rEAnnex,>rEAnnex
            .byte 0,0,  0, 0,19, 0 , 1, <rResOs,>rResOs
            
            ; Smithsonian Repair Center, 2022 (23-33, 53)
            ;     D, U, E, W, S, N, RmProp, DescL, DescH
            .byte 0, 0, 0,24, 0,33 , 0, <rLobby,>rLobby
            .byte 0, 0,23, 0, 0, 0 , 0, <rSecurity,>rSecurity
            .byte 0, 0, 0, 0, 0,24 , 0, <rKeypad,>rKeypad
            .byte 0,27, 0, 0, 0,25 , 0, <rHallway,>rHallway
            .byte 26,0,30, 0,28, 0 , 0, <rHallway,>rHallway
            .byte 0, 0,31, 0, 0,27 , 0, <rRepair,>rRepair
            .byte 0, 0, 0, 0,30, 0 , 0, <rRepair,>rRepair
            .byte 0, 0, 0,27,31,29 , 0, <rHallway,>rHallway
            .byte 0, 0,32,28, 0,30 , 0, <rHallway,>rHallway
            .byte 0, 0, 0,31, 0, 0 , 0, <rRepair,>rRepair
            .byte 0, 0, 0, 0,23, 0 , 0, <rCafe,>rCafe
            
            ; Tehredel, Lan Ges, 3449 (34-51)
            ;     D, U, E, W, S, N, RmProp, DescL, DescH (34-51)
            .byte 0, 35,39,38,41,36, 2, <rCamp,>rCamp
            .byte 34,0,  0, 0, 0, 0, 0, <rLookout,>rLookout
            .byte 0, 0, 37, 0,34,37, 2, <rForest,>rForest
            .byte 0, 0, 37,36,39, 0, 2, <rForest,>rForest
            .byte 0, 0, 40,38,40,36, 2, <rForest,>rForest
            .byte 0, 0, 49,34, 0,37, 2, <rForest,>rForest
            .byte 0, 0,  0, 0, 0,38, 2, <rForest,>rForest
            .byte 0, 0,  0,40,44,34, 2, <rForest,>rForest
            .byte 0, 0, 48, 0,45, 0, 2, <rForest,>rForest
            .byte 0, 0, 40,44, 0, 0, 2, <rForest,>rForest
            .byte 0, 0, 45,43,47,41, 2, <rForest,>rForest
            .byte 0, 0, 46,44,46,42, 2, <rForest,>rForest
            .byte 0, 0, 46,45, 0, 0, 2, <rForest,>rForest
            .byte 0, 0,  0,43, 0,44, 2, <rForest,>rForest
            .byte 0, 0, 50,42, 0, 0 ,0, <rFront,>rFront
            .byte 0, 0, 49,39,49,49, 2, <rForest,>rForest
            .byte 0, 0,  0,48, 0, 0, 0, <rMediTent,>rMediTent
            .byte 0, 0, 51,51,51,51, 2, <rForest,>rForest
            
            ; And, adding a concession stand to Navin Field (52)
            .byte 0, 0,  0, 0,10, 0, 0, <rConces,>rConces
            
            ; And, adding a lock for the keypad room (53)
            .byte 0, 0,  0, 0, 0, 0, 2, <rKeypadL,>rKeypadL

; Room Descriptions
;     The room name is terminated by ED, after which is the room description,
;     also terminated by ED
rIntake:    .asc "iNTAKE rOOM",ED,"tHIS CIRCULAR ROOM IS",LF
            .asc "YOUR HOME BASE AT",LF,"WORK. a SCREEN WRAPS",LF
            .asc "AROUND THE WALL IN",LF,"LIEU OF WINDOWS.",LF,LF
            .asc "tHE CURSOR DOMINATES",LF
            .asc "THE CENTER OF THE",LF,"SPACE. iTS CONSOLE IS",LF
            .asc "ABOUT A METER AWAY.",LF,LF,"a vERTI-tUBE LEADS",LF
            .asc "DOWN TO aDMIN.",ED
rOffice:    .asc "aDMIN oFFICE",ED,"tHIS IS A TYPICAL",LF
            .asc "63RD CENTURY OFFICE,",LF,"IN THAT IT CONTAINS",LF
            .asc "LITTLE. aDMIN WORK",LF
            .asc "NO LONG REQUIRES",LF
            .asc "EQUIPMENT.",LF,LF
            .asc "tHE bOSS IS STANDING",LF,"AGAINST A WALL, EYES",LF
            .asc "CLOSED, HARD AT WORK.",LF,LF
            .asc "a RED SIGN HANGS ON",LF,"THE DOOR TO THE EAST.",ED
rPlaza:     .asc "pLAZA",ED,ED

            ; Graff House, 1776
rCorner:    .asc "cORNER",ED,"tHE CORNER OF 7TH AND",LF,"mARKET sTREET,",LF
            .asc "pHILADELPHIA.",LF,LF,"a NEW HOUSE WITH AN",LF
            .asc "INTRICATE fLEMISH",LF,"BOND BRICK PATTERN",LF
            .asc "ADORNS THE CORNER.",LF,LF,"tHERE'S AN ENTRYWAY",LF
            .asc "ON THE WEST FRONT.",ED
rFoyer:     .asc "fOYER, gRAFF hOUSE",ED,"tHE WHOLE OF gRAFF",LF
            .asc "hOUSE IS CLEARLY",LF,"NEW CONSTRUCTION,",LF
            .asc "LOVINGLY DESIGNED AND",LF,"BUILT BY ITS OCCUPANT",LF
            .asc "AND LANDLORD.",LF,LF
            .asc "tHERE'S A STAIRWAY",LF,"UP, BUT THE REST OF",LF
            .asc "THE HOUSE IS LOCKED",LF
            .asc "OFF.",ED            
rLanding:   .asc "lANDING",ED,"a GRANDFATHER CLOCK",LF,"RESTS AGAINST THE",LF
            .asc "WALL. tHERE ARE ROOMS",LF,"TO THE NORTH AND",LF
            .asc "SOUTH.",ED
rJeffRoom:  .asc "pARLOR",ED,"sOMEBODY IS DOING A",LF,"LOT OF WRITING HERE.",LF
            .asc "pAPERS ARE STREWN",LF,"AROUND, ANYTHING",LF
            .asc "LINEN IS STAINED BY",LF,"INK. a WASTEBASKET",LF
            .asc "BRIMS WITH REJECTED",LF,"DRAFTS READING 'iN",LF
            .asc "cONGRESS.'",ED   
rJeffBed:   .asc "bED cHAMBER",ED,"tHE BED IS CRISPLY",LF
            .asc "MADE AND TINY.",LF,"wHOEVER RENTS THIS",LF
            .asc "ROOM DOESN'T SLEEP",LF,"MUCH.",LF,LF
            .asc "oPPOSITE THE BED,",LF,"THERE'S A WOODEN",LF
            .asc "BUREAU.",ED
rTBooth:    .asc "tICKET bOOTH",ED,"nAVIN fIELD, dETROIT.",LF,LF
            .asc "tHE MARQUEE SAYS:",LF,LF
            .asc "  ",176,192,192,192,192,192,192,192,192,192,192,192
            .asc 192,192,192,174,LF
            .asc "  ",221,"tigers welcome",221,LF
            .asc "  ",221,"  the yankees ",221,LF 
            .asc "  ",173,192,192,192,192,192,192,192,192,192,192,192
            .asc 192,192,192,189,LF,LF
            .asc "a FRECKLY BOY AT THE",LF,"COUNTER IS BARKING,",LF
            .asc "'tICKETS! buy YOUR",LF,"TICKETS HERE!'",ED
rHomeSt:    .asc "hOME pLATE sTANDS",ED,"tHE GREEN OF THE",LF
            .asc "DIAMOND IS SOMETHING",LF,"YOU'LL NEVER FORGET,",LF
            .asc "AS ARE THE SOUNDS OF",LF,"THE BAT AND THE SMELL",LF
            .asc "OF THE ALMONDS.",LF,LF,"lEFT fIELD IS TO THE",LF
            .asc "WEST, AND rIGHT fIELD",LF,"TO THE EAST.",LF,LF
            .asc "a SMALL CONCESSION",LF,"STAND IS NORTH.",ED
rRightF:    .asc "rIGHT fIELD bLEACHERS",ED,"tHE CROWD ROARS.",ED
rCenterF:   .asc "cENTER fIELD sTANDS",ED,"tHE CROWD OUT HERE IS",LF
            .asc "RAUCOUS, EVEN FOR",LF,"dETROIT. yOU'RE",LF
            .asc "ENJOYING THE",LF,"ATMOSPHERE BUT YOU",LF
            .asc "KNOW bAM HIT TO",LF,"RIGHT.",ED
rLeftF:     .asc "lEFT fIELD sTANDS",ED,"eVERYBODY IS",LF
            .asc "ANTICIPATING THE BIG",LF,"MOMENT. kIDS WITH",LF
            .asc "GLOVES PACK THE",LF,"STANDS. yOU KNOW",LF
            .asc "THEY'LL SOON BE SAD",LF,"ABOUT BEING ON THE",LF
            .asc "WRONG SIDE OF THE",LF,"PARK.",ED
rCorridor:  .asc "cORRIDOR",ED,"sTANDS ARE TO THE",LF,"NORTH.",ED
rConces:    .asc "cONCESSION sTAND",ED,"a WOOD STAND WITH AN",LF
            .asc "ORANGE AWNING OFFERS",LF,"COMPLEMENTARY",LF
            .asc "REFRESHMENTS. tAKE",LF,"SOME!",ED
rJail:      .asc "dETROIT jAIL",ED,"tHE CELL IS LIKE",LF
            .asc "1.5M BY 1.5M. iT'S",LF,"SUPER EMBARRASSING.",LF,LF
            .asc "oNE HOPES YOU HAVE",LF,"YOUR REEL.",ED
rAnteCh:    .asc "aNTECHAMBER",ED,"tOMB OF nEFERTARI,",LF
            .asc "vALLEY OF THE qUEENS,",LF,"lUXOR.",LF,LF
            .asc "yOUR IpHONE PROVIDES",LF,"ENOUGH ILLUMINATION",LF
            .asc "FOR YOU TO FIND YOUR",LF,"WAY, AND FOR YOU TO",LF
            .asc "APPRECIATE THE RICH",LF,"COLORED ILLUSTRATIONS",LF
            .asc "THAT COVER THE WALLS.",ED
rSideCh:    .asc "sIDE cHAMBER",ED,"tO THE RIGHT OF THE",LF
            .asc "aNTECHAMBER IS THE",LF,"MUCH SMALLER sIDE",LF
            .asc "cHAMBER. cOLORFUL",LF,"ILLUSTRATIONS COVER",LF
            .asc "EACH WALL,A DIFFERENT",LF,"STYLE ON EVERY",LF
            .asc "SURFACE.",ED
rRamp:      .asc "rAMP",ED,"tHIS DARK, STEEP RAMP",LF,"HEADS DOWN TO A LARGE"
            .asc LF,"CHAMBER.",ED
rSarcRm:    .asc "sARCOPHAGUS rOOM",ED,"tHIS IS THE MAIN",LF
            .asc "BURIAL CHAMBER. iT",LF,"CONTINUES THE WALL TO",LF
            .asc "WALL ILLUSTRATION",LF,"MOTIF. wHILE OTHER",LF
            .asc "ROOMS HOLD TREASURE",LF,"AND OBJECTS FOR THE",LF
            .asc "qUEEN, THIS LARGE",LF,"ROOM CONTAINS ONLY",LF
            .asc "HER SARCOPHAGUS,",LF,"POSITIONED IN THE",LF
            .asc "CENTER.",ED
rWAnnex:    .asc "wESTERN aNNEX",ED,"a SMALL ROOM OFF ONE",LF
            .asc "OF THE CORNERS OF THE",LF,"sARCOPHAGUS rOOM.",ED
rEAnnex:    .asc "eASTERN aNNEX",ED,"a SMALL ROOM OFF ONE",LF
            .asc "OF THE CORNERS OF THE",LF,"sARCOPHAGUS rOOM.",ED
rResOs:     .asc "rESIDENCE OF oSIRIS",ED,"tHIS CEREMONIAL ROOM",LF
            .asc "WAS PROVIDED TO HELP",LF,"nEFERTARI PASS TO THE",LF
            .asc "AFTERLIFE.",ED
rLobby:     .asc "lOBBY",ED,"sMITHSONIAN rEPAIR",LF,"cENTER, wASHINGTON,",LF
            .asc "d.c.",LF,LF,"yOU'VE ALWAYS SHARED",LF,"A KINSHIP WITH THE",LF
            .asc "sMITHSONIAN STAFF,",LF,"RESPECTING THEM AS",LF
            .asc "FELLOW ARCHIVISTS.",LF,LF,"bUT SOMETIMES YOU",LF
            .asc "HAVE TO HEIST THEM.",LF,LF
            .asc "sECURITY IS TO THE",LF
            .asc "WEST, AN OPEN CAFE",LF,"TO THE NORTH.",ED
rSecurity:  .asc "sECURITY rOOM",ED,"yOU'RE NOT SURE HOW",LF
            .asc "YOU'LL GET IN.",LF,LF,"tHERE'S A RETINAL",LF,"SCANNER, AND",LF
            .asc "PERSONNEL ARE",LF,"EXPECTED TO scan",LF,"THEIR EYE. yOU'RE",LF
            .asc "CONFIDENT YOUR EYES",LF,"AREN'T AUTHORIZED.",ED
rKeypad:    .asc "sECURITY rOOM 2",ED,"tHIS ROOM HAS A",LF
            .asc "SECOND AUTH FACTOR.",LF,LF,
            .asc "tHERE'S A BLUE",LF,"TEN-DIGIT KEYPAD WITH",LF
            .asc "A TWO-DIGIT DISPLAY,",LF,"ALONG WITH AN enter",LF,"KEY.",ED
rKeypadL:   .asc "sECURITY rOOM 2",ED
            .asc "tHE KEYPAD HAS",LF,"ROTATED OUT OF VIEW.",LF,LF
            .asc "aN ALARM IS SOUNDING",LF,"OUTSIDE THIS ROOM,",LF
            .asc "AND ALL EXITS ARE",LF,"LOCKED.",ED
rHallway:   .asc "nONDESCRIPT hALLWAY",ED,"eVERY HALLWAY LOOKS",LF
            .asc "FEATURELESS, AND THE",LF,"FLUORESCENT LIGHTS",LF
            .asc "DISTURB.",ED
rRepair:    .asc "rEPAIR rOOM",ED,"tHIS IS ONE OF THE",LF,"ROOMS WHERE THE",LF
            .asc "sMITHSONIAN SENDS",LF,"EXHIBITS FOR REPAIR.",LF
            .asc "a WORKBENCH WITH",LF,"MYRIAD TOOLS LINES",LF
            .asc "THE WALL.",ED
rCafe:      .asc "tINY cAFE",ED,"iT'S NOT MUCH OF A",LF,"CAFE, A SINGLE TABLE",LF
            .asc "AND NOTHING ELSE.",LF,LF,"iT'S MORE OF A BREAK",LF
            .asc "ROOM.",ED
rCamp:      .asc "vANDE eNCAMPMENT",ED,"tEHREDEL, lAN gES.",LF,LF
            .asc "fOREST EXTENDS",LF,"WITHOUT END IN EVERY",LF
            .asc "DIRECTION BEYOND THIS",LF,"CLEARING.",LF,LF
            .asc "tHE rEVOLUTION BEGAN",LF,"TODAY, SO THIS",LF
            .asc "CAMP IS ABANDONED.",LF,"oNLY A lOOKOUT tOWER",LF
            .asc "EXTENDS UP INTO A",LF,"TREE.",ED
rLookout:   .asc "vANDE lOOKOUT",ED,"yOU LOOK TO WHAT YOU",LF
            .asc "THINK IS THE EAST,",LF,"WHERE vANDE'S BAND OF",LF
            .asc "REBELS FIRST ATTACKED",LF,"THE RULING pREW.",LF,LF
            .asc "fROM THIS HEIGHT OF",LF,"30M, YOU SEE ONLY",LF
            .asc "CANOPY.",ED
rForest:    .asc "fOREST",ED,"eVERY TREE LOOKS MORE",LF,"ALIKE THAN THE LAST."
            .asc LF,LF,"yOUR SENSE OF",LF,"DIRECTION, FAMOUSLY",LF
            .asc "KEEN, FAILS YOU IN",LF,"THIS SYLVAN MAZE.",ED
rFront:     .asc "pREW wAR fRONT",ED,"tHE FRONT IS",LF
            .asc "CHATOTIC. yOU KNOW",LF,"THAT vANDE'S FORCES",LF
            .asc "WIN IN FOUR YEARS,",LF,"BUT MORALE SEEMS LOW",LF
            .asc "TODAY. rEBELS MILL",LF,"AROUND TENDING TO",LF
            .asc "WOUNDS AND WEAPONS.",LF,LF,"a mEDI-tENT OPENS TO",LF
            .asc "THE EAST.",ED
rMediTent:  .asc "mEDI-tENT",ED,"aLTHOUGH NOT AS WELL",LF,"EQUIPPED AS IT COULD"
            .asc LF,"BE, THE TECHNOLOGY IN",LF,"THIS TENT MAKES 21ST",LF
            .asc "CENTURY MEDICINE LOOK",LF,"LIKE CLUELESS",LF
            .asc "ALCHEMY.",LF,LF
            .asc "tHE MEDIC HERE IS",LF,"BUSY, AND DOESN'T",LF
            .asc "ACKNOWLEDGE YOUR",LF,"PRESENCE.",ED

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ITEMS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            
;   Item1    - First Character
;   ItemL    - Last Character
;   ItemRoom - Starting Room ID
;   ItemProp - Item Properties
;     Bit 0 = Is invisible (not shown in room, but can be interacted with)
;     Bit 1 = Is un-moveable (cannot move from its room)
;     Bit 2 = Is placeholder (cannot be used as an item)
;     Bit 3 = Is timekeeping device (shows number of action attempts) 
;     Bit 4 = (Future Expansion)
;     Bit 5 = (Future Expansion)
;     Bit 6 = Is scored (counts as 1 point when dropped in score room)
;     Bit 7 = Is light source (rooms with "is dark" can be seen)
;   ItemTxt  - Address of item name and description
;   (The item name is terminated by ED, after which is the item description,
;    also terminated by ED)
; 
; Item IDs are 1-indexed
Item1:      .byte 'C','C','B','R','S','W','1','D','1','I','*','J','B' ; (1-13)
            .byte 'T','C','1','G','*','*','*','1','S','P','I','N','P' ; (14-26)
            .byte 'B','F','S','G','E','2','K','4','G','W','W','W','T' ; (27-39)
            .byte 'T','T','B','T','*','3','G','B','R','M','V','P','H' ; (40-52)
            .byte 'P','D','*','B','B','C','S','P','J','M','F',ED
ItemL:      .byte 'R','E','S','L','N','H','6','K','1','E','*','N','L'
            .byte 'T','N','4','E','*','*','*','C','S','E','S','E','T'
            .byte 'T','S','L','M','E','2','D','2','R','H','H','H','S'
            .byte 'S','S','Y','E','*','9','N','E','S','C','E','R','M'
            .byte 'R','A','*','U','U','K','N','S','S','N','N'
ItemRoom:   .byte  1 , 1,  2 , 2 , 1 , 0,  1 , 6 , 1 ,23 , 6 , 0 , 0
            .byte  0 , 0,  1 ,13 ,11 , 0,  0 , 1 ,19 ,21 , 0 , 21,20
            .byte 21 ,20, 20 , 0 , 0 , 1, 25 , 25,32 ,29 ,28 , 32,29
            .byte 28 ,32,  9 ,33, 33 , 0, 35 , 35,48 ,50 ,50 , 50,50
            .byte  0,  0, 47 , 8,  0 , 7,  2 , 52,52 ,23 ,11
ItemProp:   .byte  3 , 3,  3 , 0,  3 , 8,  3 ,$40, 3 ,$88, 7 , 2 ,$40
            .byte  0 , 0,  3 , 1 , 7 , 7,  7 , 3,  3 , 0 ,35 , 0 , 0
            .byte  0 , 2,$40 , 0 , 0 , 3,  3 , 3,$40 , 3 , 3 , 3 , 0
            .byte  0 , 0,  3 , 3 , 7 , 3,  0 , 0,  3 , 3 , 3 , 3, $40
            .byte  3 , 3,  7 , 3 , 3 ,11,  3 , 0,  0 , 3 , 3
ItemTxtL:   .byte <iCursor,<iConsole,<iBoss,<iReel,<iQuota,<iWatch,<iYear
            .byte <iDesk,<iYear,<iPhone,0,<iJefferson,<iBall,<iTicket
            .byte <iSixpence,<iYear,<iGlove,0,0,0,<iYear,<iSarc,<iPlaque
            .byte <iIllus,<iNecklace,<iPendant,<iBracelet,<iFigurines,<iSandal
            .byte <iGum,<iEye,<iYear,<iKeypad,<iLUE,<iGuitar,<iWB,<iWB,<iWB
            .byte <iT,<iT,<iT,<iBoy,<iTable,0,<iYear,<iGreenTot,<iBlueTot
            .byte <iRebels,<iMedic,<iVande,<iPrinter,<iHelm,<iActPrint,0,0
            .byte <iBureau,<iBureau,<iClock,<iWarnSign,<iPeanuts,<iJacks
            .byte <iMan,<iFan
ItemTxtH:   .byte >iCursor,>iConsole,>iBoss,>iReel,>iQuota,>iWatch,>iYear
            .byte >iDesk,>iYear,>iPhone,0,>iJefferson,>iBall,>iTicket
            .byte >iSixpence,>iYear,>iGlove,0,0,0,>iYear,>iSarc,>iPlaque
            .byte >iIllus,>iNecklace,>iPendant,>iBracelet,>iFigurines,>iSandal
            .byte >iGum,>iEye,>iYear,>iKeypad,>iLUE,>iGuitar,>iWB,>iWB,>iWB
            .byte >iT,>iT,>iT,>iBoy,>iTable,0,>iYear,>iGreenTot,>iBlueTot
            .byte >iRebels,>iMedic,>iVande,>iPrinter,>iHelm,>iActPrint,0,0
            .byte >iBureau,>iBureau,>iClock,>iWarnSign,>iPeanuts,>iJacks
            .byte >iMan,>iFan

; Item Descriptions
iCursor:    .asc ED,"tHE CURSOR EVOKES A",LF
            .asc "STEAM ENGINE STUFFED",LF,"INTO A TUXEDO; FOUR",LF
            .asc "WHITE WHEELS SPIN AT",LF,"VARYING SPEEDS, WITH",LF
            .asc "BLACK VALVES AND",LF,"PIPES EVERYWHERE.",LF,LF
            .asc "tHE bOSS TRIED TO",LF,"EXPLAIN HOW IT WORKS",LF
            .asc "ONCE. hAD TO DO WITH",LF,"BUBBLES. iT GETS YOU",LF
            .asc "FROM WHEN TO WHEN.",ED
iConsole:   .asc ED,"yOU'D IMAGINE THEY'D",LF
            .asc "HAVE FANCIER CONSOLES",LF,"IN THE 63RD CENTURY,",LF
            .asc "BUT THIS CONSOLE IS",LF,"JUST A STAND WITH A",LF
            .asc "ROTARY CONTROL TO",LF,"dial DESTINATIONS",LF
            .asc "FOR THE CURSOR.",LF,LF
            .asc "pROBABLY THE ux dEV",LF,"WANTED TO MAKE YOU",LF
            .asc "COMFORTABLE, AND",LF,"MISSED THE MARK BY",LF
            .asc "FIFTY YEARS.",ED
iBoss:      .asc ED,"tHE bOSS LOOKS LIKE A",LF
            .asc "MIDDLE-AGED WOMAN",LF,"IN A VIOLET LAB COAT,",LF
            .asc "BUT YOU KNOW SHE'S",LF
            .asc "BEEN DOING THIS FOR A",LF,"HUNDRED YEARS.",LF,LF
            .asc "sHE'S WORKING",LF,"MENTALLY AT THE",LF,
            .asc "MOMENT, BUT YOU CAN",LF,"ALWAYS talk TO HER.",ED
iReel:      .asc "tEMPORAL reel",ED,"tHE REEL IS THE",LF
            .asc "REMOTE COUNTERPART OF",LF,"THE CURSOR. iT'S A",LF
            .asc "PALM-SIZED WHEEL WITH",LF,"A PARALLEL SMALLER",LF
            .asc "WHEEL AFFIXED, SOFTLY",LF,"WHIRRING, WITH A DIM",LF
            .asc "PULSING MAUVE LIGHT.",LF,LF
            .asc "yOU OPERATE IT BY",LF,"windING IT.",ED
iQuota:     .asc ED
            .asc "    ",176,192,"dUE tODAY",192,174,LF
            .asc "    ",221,    "  ",190,"1255bc  ",221,LF
            .asc "    ",221,    "  ",190,"1776    ",221,LF
            .asc "    ",221,    "  ",190,"1934    ",221,LF
            .asc "    ",221,    "  ",190,"2022    ",221,LF
            .asc "    ",221,    "  ",190,"3449    ",221,LF
            .asc "    ",173,192,192,192,192,192,192,192,192,192,192,192,189,ED
iWatch:     .asc "pOCKET watch",ED,"18TH cENTURY. a GIFT",LF
            .asc "FROM dAD. oRNATE.",LF,LF,"yOU USUALLY LEAVE IT",LF
            .asc "IN THE iNTAKE rOOM.",LF,ED
iYear:      .asc "jUST A YEAR",ED,"dial THE YEAR INTO",LF,"THE CONSOLE.",ED
iDesk:      .asc "jEFFERSON'S desk",ED,"tHIS IS THE DESK THAT",LF
            .asc "tHOMAS jEFFERSON IS",LF,"USING TO WRITE THE",LF
            .asc "dECLARATION OF",LF,"iNDEPENDENCE. iF IT",LF
            .asc "GOES MISSING, HE'LL",LF,"WRITE IT ON SOMETHING",LF
            .asc "ELSE.",LF,LF,"iF IT SEEMS THERE'S A",LF
            .asc "PARADOX HERE, THAT'S",LF,"cAPEK'S PROBLEM.",ED
iPhone:     .asc "IpHONE",ED,"nOT IN THE LEAST",LF,"ANACHRONISTIC, IT'S",LF
            .asc "A 150MM BY 75MM SLAB",LF,"WITH A BRIGHT SCREEN.",LF,LF
            .asc "tHE LOCK SCREEN",LF,"DEPICTS THE",LF
            .asc "hITCHHIKER'S gUIDE TO",LF,"THE gALAXY LOGO, AND",LF
            .asc "SAYS ", COL_ITEM, "don't panic",COL_NORM,LF,"UNDER THAT."
            .asc LF,LF,"zERO BARS.",LF,LF
            .asc "cLOCK AT TOP READS",ED
iJefferson: .asc "tHOMAS jefferson",ED,"yES, that jEFFERSON.",ED
iBall:      .asc "rUTH'S hOME rUN ball",ED,"bABE rUTH HIT HIS",LF
            .asc "700TH HOME RUN WITH",LF,"THIS BASEBALL.",ED
iTicket:    .asc "bASEBALL ticket",ED,"jULY 14, 1934",LF,"nAVIN fIELD $1.40",LF
            .asc "gENERAL aDMISSION",ED
iSixpence:  .asc "sIXPENCE coin",ED,"aN OLD bRITISH COIN,",LF
            .asc "WORTHLESS NOW.",ED
iGlove:     .asc "bASEBALL glove",ED,"iT'S A TAD SMALL,",LF
            .asc "AS A CHILD'S GLOVE,",LF,"BUT IT SHOULD WORK.",ED
iPlaque:    .asc "iNSCRIBED gOLD plaque",ED,"yOUR ANCIENT eGYPTIAN",LF,
            .asc "IS RUSTY. mAYBE LIKE:",LF,LF,COL_ALERT
            .asc "take no  gold from my",LF,LF,"birthright, lest  its",LF,LF
            .asc "curse snuff the light",LF,LF
            .asc "(silver & bronze too)",LF,LF,COL_NORM
            .asc "eGYPTIAN MUMMY CURSE?",LF,"that CAN'T BE A REAL",LF
            .asc "THING. rIGHT...?",ED
iSarc:      .asc "sARCHOPHAGUS",ED,"nEFERTARI'S FINAL",LF
            .asc "RESTING PLACE IS",LF,"AMAZING, LIKE",LF
            .asc "EVERYTHING HERE.",LF,"sTUNNING ROSE",LF
            .asc "GRANITE, INLAID WITH",LF,"GOLD AND CARNELIAN.",LF
            .asc "tHE qUEEN'S CARVED",LF,"FACE LOOKS SERENELY",LF
            .asc "AT THE CEILING.",ED
iIllus:     .asc "tHEY JUST CAN'T BE",LF,"ADEQUATELY EXPRESSED",LF ; Referenced
            .asc "IN THIS MEDIUM. iF",LF,"YOU'RE STUCK IN THE",LF  ; as action
            .asc "21ST CENTURY, TRY",LF,"gOOGLE.",ED
iNecklace:  .asc "gILDED necklace",ED,"sEVEN PLATES OF",LF
            .asc "PRESSED ROSE GOLD",LF,"ARRANGED ON A WOVEN",LF
            .asc "CHAIN.",ED
iPendant:   .asc "bRONZE pendant",ED,"a SMALL ROUND PENDANT",LF
            .asc "ON A BRONZE CHAIN",LF,"FEATURING THE eYE OF",LF
            .asc "hORUS IN THE CENTER.",ED
iBracelet:  .asc "gOLD fOIL bracelet",ED,"aN 8CM WIDE",LF
            .asc "CYLINDRICAL BRACELET",LF,"ENCIRCLED WITH SUNS",LF
            .asc "IN RELIEF.",ED
iFigurines: .asc "sERVANT figurines",ED,"dOZENS OF PAINTED",LF
            .asc "WOODEN FIGURINES,",LF,"EACH ABOUT 15CM TALL,",LF
            .asc "ARE MADE TO PROVIDE",LF,"FOR THE qUEEN IN HER",LF
            .asc "AFTERLIFE. tHE",LF,"TABLEAU IS",LF,"ATTRACTIVE, BUT TOO",LF
            .asc "BULKY TO CARRY OUT BY",LF
            .asc "HAND.",ED
iSandal:    .asc "nEFERTARI'S sandal",ED,"aN INTRICATE WOVEN",LF
            .asc "PAPYRUS SANDAL.",LF,"wOMENS' SIZE 9.",ED
iGum:       .asc "cHEWED gum",ED,"sMELLS LIKE FRESH",LF,"MINT, BUT STILL",LF
            .asc "PRETTY GROSS.",ED
iEye:       .asc "hUMAN eye",ED,"hAZEL, BUT STILL",LF,"PRETTY GROSS.",ED
iLUE:       .asc ED,"tHE ULTIMATE ANSWER.",ED
iKeypad:    .asc "kEYPAD",ED,"a FADING SIGN SAYS",LF,"'pLEASE enter YOUR",LF
            .asc "2-DIGIT PASSCODE.'",ED
iGuitar:    .asc "pRINCE'S guitar",ED,"yELLOW cLOUD gUITAR.",LF,LF
            .asc "pRINCE HAD THIS",LF,"DISTINCTIVE",LF
            .asc "INSTRUMENT MADE IN",LF,"1983, AND DONATED IT",LF
            .asc "TO THE sMITHSONIAN IN",LF,"1993. tHIS IS THE",LF
            .asc "GUITAR pRINCE USED IN",LF,"THE MOVIE pURPLE",LF
            .asc "rAIN.",ED
iWB:        .asc ED,"tHE WORKBENCH IS",LF,"LARGE AND TIDY.",ED
iT:         .asc "tOOLS",ED,"tHE TOOL KIT CONTAINS",LF,"ALL THE USUAL STUFF,",LF
            .asc "NONE OF WHICH YOU",LF,"NEED.",ED
iBoy:       .asc ED,"hE'S ABOUT 12 YEARS",LF,"OLD WITH SHORT RED",LF
            .asc "HAIR, WEARING A",LF,"tIGERS CAP AND A",LF,"BUTTONED LONG-",LF
            .asc "SLEEVE SHIRT. hE'S",LF,"PRETTY FRIENDLY, BUT",LF
            .asc "HE OBVIOUSLY DOESN'T",LF,"GROK YOUR ARCHAIC",LF
            .asc "APPEARANCE.",ED
iTable:     .asc ED,"a ROUND BISTRO TABLE,",LF
            .asc "WITH A GLASS TILE",LF,"MOSAIC IN THE PATTERN",LF
            .asc "OF A MONARCH",LF,"BUTTERFLY.",ED
iGreenTot:  .asc "green tOTEM",ED,"tHIS WOODEN CARVING",LF
            .asc "OF A TORTOISE IS",LF,"GREEN, FOR ITS FOREST",LF
            .asc "HOME. iT'S 4CM TALL.",ED
iBlueTot:   .asc "blue tOTEM",ED,"tHIS WOODEN CARVING",LF
            .asc "OF A SWIFT IS BLUE,",LF,"FOR ITS SKY HOME.",LF
            .asc "iT'S 9CM TALL.",ED
iRebels:    .asc ED,"vANDE'S rEBELS ARE",LF,"FIGHTING FOR FREEDOM",LF
            .asc "AND EQUALITY AGAINST",LF,"THE TECHNO-REGIME,",LF
            .asc "THE pREW. tHEY'VE",LF,"VOWED TO FOLLOW vANDE",LF
            .asc "TO DEATH OR VICTORY.",ED
iMedic:     .asc ED,"tHE MEDIC IS WORKING",LF,"FEVERISHLY ABOVE A",LF
            .asc "PATIENT THAT YOU",LF,"RECOGNIZE AS THE",LF
            .asc "REBEL LEADER vANDE.",ED
iVande:     .asc ED,"vANDE HAS BEEN",LF,"PIERCED THROUGH THE",LF
            .asc "HEART WITH AN ENERGY",LF,"WEAPON BLAST. yOU",LF
            .asc "KNOW SHE REIGNS BY",LF,"TERROR FOR THE NEXT",LF
            .asc "70 YEARS, BUT TODAY",LF,"SHE LOOKS VULNERABLE",LF
            .asc "AND... MORTAL.",ED
iPrinter:   .asc ED,"tHE HEIGHT OF 35TH",LF
            .asc "CENTURY MEDICINE, THE",LF
            .asc "PRINTER ALLOWS ONE TO",LF,"scan A SOURCE OF dna,",LF
            .asc "AND THEN enter THE",LF,"NAME OF THE ORGAN TO",LF
            .asc "BE GENERATED.",ED
iActPrint:  .asc ED,"tHE ORGAN PRINTER",LF
            .asc "CHIRPS EVERY FEW",LF,"SECONDS, WAITING FOR",LF
            .asc "SOMEONE TO enter AN",LF,"ORGAN TO PRINT.",ED
iHelm:      .asc "vANDE'S helm",ED,"mADE OF PURE",LF,"mERETZKIUM, THE hELM",LF
            .asc "IS A TREASURED",LF,"ARTIFACT OF THE",LF,"rEVOLUTION.",LF,LF
            .asc "iT'S NOT LIKE IT",LF,"HELPED vANDE MUCH,",LF,"ANYWAY.",ED
iBureau:    .asc ED,"tHIS IS A FINE, DARK",LF,"MOHOGANY BUREAU.",LF,LF
            .asc "yOU'VE GOT ONE JUST",LF,"LIKE IT AT HOME THAT",LF,
            .asc "YOU LIBERATED FROM",LF,"nAPOLEON.",LF,LF
            .asc "iT'S NOT LOCKED AND",LF,"WILL open EASILY.",ED
iClock:     .asc ED,"sTANDING A STATELY 3M",LF,"TALL, THIS gERMAN",LF
            .asc "CLOCK'S MOVEMENT CAN",LF,"BE HEARD THROUGHOUT",LF
            .asc "THE QUIET HOME.",LF,LF,"iTS FACE IS COVERED",LF
            .asc "WITH CARVINGS OF",LF,"BIRDS AND READS",ED
iWarnSign:  .asc ED,COL_ALERT,"   bubble to remain",LF,LF,"   unbroken  during"
            .asc LF,LF,"   business   hours",LF,LF,"   alarm will sound",LF,LF
            .asc "   if opened",ED
iPeanuts:   .asc "pEANUTS",ED,"eXTRA-SALTY!",ED
iJacks:     .asc "cRACKER jacks",ED,"a FAVORITE BETWEEN",LF,
            .asc "1896 AND 2220, WHEN",LF,"CORN WENT EXTINCT.",LF,LF
            .asc "iT'S BASICALLY",LF,"POPCORN AND PEANUTS",LF,
            .asc "WITH CARAMEL AND,",LF,"FOR SOME REASON,",LF
            .asc "A TINY METAL HORSE.",ED
iMan:       .asc ED,"hE'S NO LONGER IN",LF,"VIEW. hE HURRIED INTO",LF
            .asc "THE ROOM LABELED",LF,"sECURITY.",ED
iFan:       .asc ED,"tHIS PLACE IS FILLED",LF,"WITH 'EM! aNY",LF
            .asc "SPECIFIC ONE IS LOST",LF,"IN THE PACK.",ED

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; STORY ACTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            
;   ActVerb    - The Verb ID for this action
;   ActItem    - The Item ID for this action. If 0, no item is used.
;   ActInRoom  - The Room ID for this action. If 0, no room is required.
;   ActInvCon  - The player must be holding this Item ID for success in this
;                action. If 0, no item needs to be held.
;   ActRoomCon - The Item ID must be in this room for success in this action.
;                If 0, the action is not conditioned on this item. If both 
;                ActHoldCon and ActRoomCon are non-0, then both conditions must
;                be met for the action to be successful. Note that this item may
;                be in inventory.
;   ActInvExcl - The player must NOT be holding this Item ID for success in this
;                action. If 0, no item is excluded.
;   ActFrom    - If the action is successful, specifies an item that can be
;                changed to another item.
;
;                If 0, then the player will be moved to the Room ID specified 
;                in ActTo
;   ActTo      - If the action is successful, specifies that the item specified
;                in ActFrom will be changed to the item in ActTo. This will
;                happen in any room that the item is in, as well as the player's
;                inventory. 
;
;                ActTo can also specify a Room ID, if bit 7 is set. In this case
;                the ActFrom item will be moved directly to the specified room.
;                If ActFrom is 0, the PLAYER is moved to the specified room.
;
;                If ActTo is 0, the ActFrom item will be moved to the room that
;                the player is currently in.
;
;                If both ActFrom and ActTo are 0, then the success text is 
;                displayed and the game ends.
;
;                If both ActFrom and ActTo are the same non-zero Item ID, only
;                messages will be displayed.
;   ActResTxt  - The address of the success and failure messasges
;                (The success message is terminated by ED, after which is the
;                 failure message, also terminated by ED)
;
; Action IDs are zero-indexed, and the action id $ff (EV) is reserved for
; actions triggered by events (timer target, enters-room, score target)
ActVerb:    .byte 7,8,EV,9,9,3, 3,  7,10, 10,10,EV, 9,11,EV,12,12,12 ; 0-17
            .byte EV, 9,13,2,2,2,2,2,2,2,                            ; 18-27
            .byte 14, 9,16,15,15,EV,17,7, 11,18,EV, 2, 9, 7, 7, 7    ; 28-43
            .byte 16,15,EV,18,18,18,16,16,EV,EV,EV,19,13,13,EV,EV,EV ; 44-60
            .byte 20,20,21,21,15,EV,18,EV,ED                          
ActItem:    .byte 3,4,0, 7,9,8, 8, 12,10,  4, 0, 0,16,14, 0,13,13,13
            .byte 0, 21,22,24,24,24,24,24,24,24
            .byte 0, 32,31,34, 0, 0,35,42, 8, 0, 0,43,45,48,49,50
            .byte 30,31, 0,12,48,42,54, 0, 0, 0, 0, 0,56,56, 0, 0, 0
            .byte 29,52,60,61, 0, 0,63, 0
ActInRoom:  .byte 0,0,0, 0,0,0, 0,  6, 6,  6, 6, 0, 0, 9, 0,11,11,11
            .byte 0,  0, 0,16,17,18,19,20,21,22
            .byte 0,  0,24,25,25, 0, 0, 9, 6, 0, 0,33, 0,48,50,50
            .byte 50,50, 0, 0, 0, 0,50,50,48,48, 0, 0, 8, 8,11, 0, 0
            .byte  0, 0, 0, 0,25,48,11,48
ActInvCon:  .byte 0,4,0, 0,0,0, 0,  0,10,  4, 0, 0, 0,15, 0, 0,17, 0
            .byte 13, 0, 0,0,0,0,0,0,0,0
            .byte 0,  0,31, 0, 0, 0,35,14, 0, 0, 0, 0, 0, 0, 0, 0
            .byte 30,30, 0, 0, 0, 0, 0,0 ,52,52, 0,10, 0, 0, 0, 0, 0
            .byte 29,52,60,61, 0,52, 0,52
ActRoomCon: .byte 3,0,0, 1,1,11,12, 0,12, 12,12, 0, 1, 0, 0,20,19,19
            .byte 0,  1,22,0,0,0,0,0,0,0
            .byte 0,  1, 0, 0, 1, 0, 0, 0,12, 0, 0,44, 1, 0, 0, 0
            .byte 51,53, 0,12,48,42, 0, 1, 4, 0, 0, 0, 0, 0,19, 0, 0
            .byte 0,  0, 0, 0, 0, 0, 0, 0
ActInvExcl: .byte 0,1,0, 0,0,8, 8,  8,  8, 8, 8,14, 0, 0, 0, 0, 0, 0
            .byte 0,  0, 0,0,0, 0,  0,  0, 0, 0
            .byte 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            .byte 0, 31, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,10
            .byte 0,  0, 0, 0, 0, 0, 0, 4
ActFrom:    .byte 1,0,0, 0,0,11,1,  1, 10, 4, 1, 0, 0,15,18,1, 17,19
            .byte 0,  0, 1,1,1, 1,  1,  1, 1, 1
            .byte 1,  0, 0, 0, 1, 1, 1, 1, 1, 1, 0,44, 0, 1, 1, 1
            .byte 51,31, 0, 1, 0, 0, 1, 1, 4, 1, 0, 1,15,56, 1, 1, 0
            .byte 1,  1, 1, 1, 0, 1, 0, 1
ActTo:      .byte 1,1,0, 4,0,12,1,  1,  8, 8, 1,9 , 9,14,19,1, 13,20
            .byte 15,16, 1,1,1,1,1,1,1,1
            .byte 1 ,23,25,26, 1, 1, 1, 1, 1, 1, 0,30,34, 1, 1, 1
            .byte 53, 0, 0, 1, 51,15,1,1,$af, 1, 0, 1, 0,57, 1, 1, 0
            .byte 1,  1, 1, 1,53, 1, 9, 1
ActResTxtL: .byte <aBoss,<aHome,<aDie,<aX,<a1841,<aJeffEnter,<aJeffSay
            .byte <aJeffOffer,<aJeffAcc,<aJeffAcc,<aJeffDecl
            .byte <aNeedTix,<aX,<aBuyTix,<aBallHit,<aMissed,<aTryCatch,0
            .byte <aToJail,<aX,<aOpSarc,<iIllus,<iIllus,<iIllus,<iIllus
            .byte <iIllus,<iIllus,<iIllus,<aPanic,<aX,<aSec,<aSec
            .byte <aSec,<aDrops,<aRiff,<aTBoy,<aBuyDesk,<aViolence,<aEOB
            .byte <aFoundGum,<aX,<aTRebels,<aTMedic,<aTVande,<aPrScan
            .byte <aPrEnter,<aWin,<aAtJeff,<aAtRebels,<aAtBoy,<aScDNA
            .byte <aPrFail,<aStealHelm,0,<aCaught,<aCell,<aRevCoin,0
            .byte <aBallFly,<aAdEntry,<aTrip,<aWear,<aWear,<aYum,<aYum
            .byte <aLockdown,<aComing,<aAtFan,<aStealH2
ActResTxtH: .byte >aBoss,>aHome,>aDie,>aX,>a1841,>aJeffEnter,>aJeffSay
            .byte >aJeffOffer,>aJeffAcc,>aJeffAcc,>aJeffDecl
            .byte >aNeedTix,>aX,>aBuyTix,>aBallHit,>aMissed,>aTryCatch,0
            .byte >aToJail,>aX,>aOpSarc,>iIllus,>iIllus,>iIllus,>iIllus
            .byte >iIllus,>iIllus,>iIllus,>aPanic,>aX,>aSec,>aSec
            .byte >aSec,>aDrops,>aRiff,>aTBoy,>aBuyDesk,>aViolence,>aEOB
            .byte >aFoundGum,>aX,>aTRebels,>aTMedic,>aTVande,>aPrScan
            .byte >aPrEnter,>aWin,>aAtJeff,>aAtRebels,>aAtBoy,>aScDNA
            .byte >aPrFail,>aStealHelm,0,>aCaught,>aCell,>aRevCoin,0
            .byte >aBallFly,>aAdEntry,>aTrip,>aWear,>aWear,>aYum,>aYum
            .byte >aLockdown,>aComing,>aAtFan,>aStealH2
            
; Action Results
DIAG:       .asc "aCTION success",ED,"aCTION failure",ED
aBoss:      .asc "'hAVE A GREAT DAY.",LF,LF,"'cAPEK COLLECTS YOUR",LF
            .asc "iNTAKE AT 17:00. yOU",LF,"JUST NEED TO drop",LF,
            .asc "ASSETS UPSTAIRS.",LF,LF,"'aND DON'T FORGET",LF
            .asc "YOUR REEL!'",ED,"sHE'S NOT HERE.",ED
aHome:      .asc CLRHOME,"bEING REELED BACK IS",LF,"ALWAYS DISCONCERTING.",LF,LF
            .asc "iT'S LIKE RIDING A",LF,"ROLLER COASTER WHILE",LF
            .asc "WEARING A vr HEADSET",LF,"OF A DIFFERENT ROLLER",LF
            .asc "COASTER.",LF,LF,"tHE SENSATION LASTS",LF
            .asc "ONLY A MOMENT AND",LF,"YOU'RE BACK TO YOUR",LF
            .asc "iNTAKE rOOM.",ED,ED
            .asc "yOU DO NOT HAVE A",LF,"TEMPORAL REEL.",ED
aDie:       .asc "tHE bOSS RUSHES TO",LF
            .asc "TACKLE YOU BUT IT'S",LF,"TOO LATE. yOU NOTICE",LF
            .asc "A MAGNIFICENT FUTURE",LF,"CITYSCAPE FOR ONLY A",LF
            .asc "MOMENT BEFORE THE",LF,"bUBBLE COLLAPSES",LF
            .asc "AROUND YOU AND YOU",LF,"STOP EXISTING.",ED,ED
aX:         .asc CLRHOME,"yOU DIAL THE YEAR ON",LF,"THE CONSOLE.",LF,LF
            .asc "tHE CURSOR'S WHEELS",LF,"SPIN FASTER. yOU FEEL",LF
            .asc "A HOT LOUD RUSH OF",LF,"AIR LIKE A LOCOMOTIVE",LF
            .asc "IS GOING THROUGH YOUR",LF,"CHEST.",LF,LF
            .asc "yOUR SURROUNDINGS",LF,"HAVE CHANGED...",ED
            .asc "tHERE'S NO CURSOR.",ED
a1841:      .asc "tHE CURSOR ROARS YOU",LF,"BACK HOME. yOU SMELL",LF
            .asc "THE FAMILIAR SMELLS",LF,"OF YOUR COMFORTING",LF
            .asc "HEARTH AND RELAX...",LF,LF
            .asc "...bUT THEN YOU",LF,"THINK OF THE CURSOR",LF
            .asc "IN YOUR DEN. tHE bOSS",LF
            .asc "WON'T BE HAPPY",LF,"ABOUT YOUR LEAVING",LF
            .asc "EARLY.",LF,LF,"tOMORROW'S GOING TO",LF
            .asc "BE A DAMN BUSY DAY.",ED,"tHERE'S NO CURSOR.",ED
aJeffEnter: .asc "jUST AS YOU TAKE THE",LF,"LITTLE DESK, A TALL",LF
            .asc "MAN EMERGES FROM",LF,"BEHIND AND WRESTS IT",LF
            .asc "FROM YOUR HANDS.",ED,ED
aJeffSay:   .asc "'i DON'T THINK THIS",LF,"BELONGS TO YOU,'",LF
            .asc "jEFFERSON FROWNS.",ED,ED
aJeffOffer: .asc "'i INVENTED THIS DESK",LF,"AND i'M NOT GOING TO",LF
            .asc "LET YOU TAKE IT.",LF,LF,"'bUT... yOU LOOK LIKE",LF
            .asc "SOMEONE WITH ACCESS",LF,"TO FUTURISTIC THINGS.",LF,LF
            .asc "'iF YOU BRING ME",LF,"SOMETHING INSANELY",LF
            .asc "GREAT FROM THE",LF,"FUTURE, i SHALL swap",LF
            .asc "MY MOST EXCELLENT",LF,"DESK FOR IT!'",ED            
            .asc "'oUR BUSINESS IS",LF
            .asc "CONCLUDED. i BID YOU",LF,"GOOD DAY.'",ED
aJeffDecl:  .asc "'i HAVE ABSOLUTELY NO",LF,"INTEREST IN THAT.'",ED
            .asc "nOBODY TO SWAP WITH!",ED
aJeffAcc:   .asc "'wHAT A MARVELOUS",LF,"THING! i DARESAY WE",LF
            .asc "HAVE A DEAL.",LF,LF,"'i'LL HAVE A TABLE",LF
            .asc "BROUGHT UP SO i CAN",LF,"FINISH THIS OTHER",LF
            .asc "PROJECT.'",LF,LF
            .asc "jEFFERSON HANDS YOU",LF,"HIS DESK WITH A BOW.",ED,ED
aNeedTix:   .asc "tHE BOY AT THE TICKET",LF,"COUNTER STOPS YOU.",LF,LF
            .asc "'yOU NEED TO buy A",LF,"TICKET TO GET IN!'",ED
            .asc "'yOU BETTER GET TO",LF,"YOUR SEAT!'",ED
aBuyTix:    .asc "'tHAT'S SOME FUNNY",LF,"LOOKIN' MONEY, BUT i",LF
            .asc "GUESS IT SPENDS THE",LF,"SAME. hERE'S YOUR",LF
            .asc "TICKET.'",ED,"'tHESE TICKETS COST",LF
            .asc "MONEY!' THE BOY SAYS.",ED
aBallHit:   .asc COL_ALERT,"yOU HEAR THE CRACK",LF,"OF rUTH'S BAT AND",LF
            .asc "SEE THE BALL FLYING",LF,"TOWARD RIGHT FIELD.",ED
            .asc "tHE GAME GOES ON.",ED
aMissed:    .asc "tHE MOMENT'S PASSED.",LF,"lET IT GO.",ED,ED
aTryCatch:  .asc "wITH A SATISFYING",LF,"thud, THE BALL PLANTS",LF
            .asc "ITSELF IN THE",LF,"PILFERED GLOVE. fANS",LF
            .asc "EYE YOU SUSPICIOUSLY.",LF,LF,"yOU... BETTER GET OUT",LF
            .asc "OF HERE.",ED
            .asc "yOU TRY TO CATCH THE",LF,"BALL WITH YOUR BARE",LF
            .asc "HANDS, BUT IT'S A",LF,"DISASTER.",LF,LF,
            .asc "iT BOUNCES INTO THE",LF
            .asc "GLOVE OF A FAN, WHO",LF,"RUNS OFF LAUGHING.",ED
aToJail:    .asc "a LITTLE KID CRIES",LF,"AND POINTS AT YOU,",LF
            .asc "'sTOLE MY GLOVE!'",LF,LF,"cROWD DISAPPROVES,",LF
            .asc "AND SO DO dETROIT'S",LF,"fINEST...",ED,ED
aOpSarc:    .asc "dID YOU MISS THE BIT",LF,"ABOUT THE GRANITE?",LF
            .asc "tHE LID ALONE WEIGHS",LF,"SEVERAL THOUSAND KG,",LF
            .asc "AND IT'S NOT WHAT",LF,"YOU'RE HERE FOR.",ED,ED
aPanic:     .asc "nOT SURPRISED.",ED,ED
aSec:       .asc "a GREEN LIGHT BLINKS",LF,"SILENTLY, AND THE",LF
            .asc "DOOR CLICKS SOFTLY",LF,"OPEN. yOU PASS",LF
            .asc "THROUGH IT.",ED
            .asc "a RED LIGHT BLINKS.",ED
aDrops:     .asc COL_ALERT,"a BALDING MAN IN A",LF,"SUIT RUSHES FROM A",LF
            .asc "CAFETERIA, LATE FOR",LF,"SOMETHING. aS HE",LF
            .asc "ENTERS THE sECURITY",LF,"rOOM, HE DOESN'T",LF
            .asc "NOTICE HIS IpHONE",LF,"FALLING FROM HIS",LF
            .asc "POCKET.",ED,ED
aRiff:      .asc "yOU'RE NO pAGANINI,",LF,"BUT YOU CAN SHRED",LF
            .asc "LIKE IT'S 6199.",ED,"yOU HAVE NO GUITAR.",ED
aTBoy:      .asc "'eNJOY THE GAME!'",ED,"'bAMBINO COULD REACH",LF
            .asc "HIS 700TH HOMER.",LF,LF,"'buy YOUR TICKET,",LF
            .asc "WE'RE ALMOST SOLD",LF,"OUT!'",ED
aBuyDesk:   .asc "jEFFERSON SCOFFS,",LF,"'wHAT AN ABSURD",LF
            .asc "NOTION.'",ED,"jUST take IT!",ED
aViolence:  .asc "tHAT'S A SET OF",LF,"SKILLS THAT... yOU",LF
            .asc "WOULD NOT FARE WELL.",ED,ED
aEOB:       .asc "17:00. qUITTING TIME!",LF,"yOU DID NOT QUITE",LF
            .asc "MAKE QUOTA TODAY, SO",LF,"NO BONUS FOR YOU.",LF,LF
            .asc "yOU HEAD HOME TO",LF,"CONTEMPLATE YOUR TIME",LF
            .asc "MANAGEMENT SKILLS.",ED,ED
aFoundGum:  .asc "aS YOU EXAMINE THE",LF,"TABLE, YOU FEEL",LF
            .asc "SOMETHING STICKY AND",LF,"WET, WHICH YOU",LF
            .asc "INSTINCTIVELY DROP",LF,"IN DISGUST.",ED,ED
aTRebels:   .asc "'vANDE WAS SERIOUSLY",LF,"INJURED IN OUR FIRST",LF
            .asc "ENGAGEMENT. aLL IS",LF,"LOST!'",LF,LF,"...AND...",LF,LF
            .asc "'wITHOUT HER",LF,"LEADERSHIP, THIS",LF,"REVOLUTION ENDS",LF
            .asc "TODAY.'",ED,ED
aTMedic:    .asc "'lET ME WORK. i'M",LF,"TRYING TO REPLACE HER",LF
            .asc "HEART WITH THE ORGAN",LF,"printer!'",ED,ED
aTVande:    .asc "sHE SAYS NOTHING.",ED,ED
aPrScan:    .asc "a LIGHT SHINES ON THE",LF,"GUM FOR A MOMENT, AND",LF
            .asc "THE PRINTER CHIRPS",LF,"CHEERFULLY.",ED,ED
aPrEnter:   .asc "a CARTESIAN ARM IN A",LF,"GLASS CYLINDER MOVES",LF
            .asc "SWIFTLY FROM THE",LF,"BOTTOM OF A",LF
            .asc "PLATFORM, LAYERING",LF,"MATERIAL THAT QUICKLY",LF
            .asc "LOOKS EYE-LIKE.",LF,LF,"iN ABOUT ONE MINUTE,",LF
            .asc "THE CYLINDER OPENS,",LF,"REVEALING AN EYE",LF
            .asc "STARING SADLY UP",LF,"AT YOU.",ED
            .asc "nOTHING HAPPENS.",ED
aWin:       .asc "tHE bOSS ENTERS THE",LF,"iNTAKE rOOM WITH A",LF
            .asc "CHARMING BOTTLE OF",LF,"SOMETHING DELICIOUS,",LF
            .asc "AND HANDS IT TO YOU.",LF,LF
            .asc "'sOME RESOURCEFUL",LF,"WORK TODAY,' SHE",LF
            .asc "SAYS, 'tHESE ITEMS",LF,"WILL TEACH US A LOT.",LF
            .asc "tAKE THE REST OF THE",LF,"DAY OFF, GO GET SOME",LF
            .asc "ICE CREAM.'",ED,ED
aAtJeff:    .asc "fOR EXAMPLE, IN LIKE",LF,"TWO SECONDS YOUR FACE",LF
            .asc "IS ON THE HARDWOOD",LF,"FLOOR, AND YOUR ARM",LF
            .asc "IS PINNED PAINFULLY",LF,"BEHIND YOUR BACK.",LF,LF
            .asc "'fIRST BURGLARY, THEN",LF,"THIS? i'M LOSING MY",LF
            .asc "PATIENCE. lET US talk",LF,"LIKE ENLIGHTENED",LF
            .asc "CITIZENS.'",ED,ED
aAtBoy:     .asc "fOR EXAMPLE, YOU",LF,"SUDDENLY FIND",LF
            .asc "YOURSELF SURROUNDED",LF,"BY THREE dETROIT",LF
            .asc "POLICE OFFICERS WHO",LF,"RENDER YOU IMMOBILE,",LF
            .asc "AND THEN...",ED,ED
aAtRebels:  .asc "fOR EXAMPLE, THESE",LF,"REBELS, WHO'VE",LF
            .asc "ALREADY HAD A REALLY",LF,"BAD DAY, EASILY",LF
            .asc "BLINDFOLD YOU AND",LF,"DRAG YOU...",LF
            .asc "SOMEWHERE.",ED,ED
aScDNA:     .asc "yOU'LL NEED TO BE WAY",LF,"MORE SPECIFIC.",ED,ED
aPrFail:    .asc ED,"nOTHING HAPPENS.",ED
aStealHelm: .asc "a REBEL GRABS YOUR",LF,"REEL AND HURLS IT",LF
            .asc "INTO THE WOODS!",ED,ED
aStealH2:   .asc "aLL THE REBELS SPOT",LF,"YOU WITH THE hELM",LF
            .asc "AND SOON THEY'RE",LF,"AGRILY UPON YOU.",LF,LF
            .asc "iT SEEMS LIKE THEY",LF,"MOSTLY PLAN TO KILL",LF,"YOU.",LF,LF
            .asc "run!!",ED,ED         
aCaught:    .asc "iN THE END, YOU DON'T",LF,"KNOW THE FOREST LIKE",LF
            .asc "THEY DO. tHE REBELS",LF,"SURROUND YOU, AND",LF
            .asc "THAT IS PRETTY MUCH",LF,"THAT.",ED,ED
aCell:      .asc "sEEMS LIKE THERE'S NO",LF,"COVERAGE.",ED,"yOU DON'T HAVE A",LF
            .asc "PHONE.",ED
aRevCoin:   .asc "tHE BUREAU TOP ROLLS",LF,"OPEN. tHERE'S NOT",LF
            .asc "MUCH THERE.",ED,"tHERE'S NOT MUCH.",ED
aBallFly:   .asc "a PARABOLIC 2-rbi",LF,"BALL IS HEADED RIGHT",LF
            .asc "AT YOU. catch IT!",ED
            .asc ED
aAdEntry:   .asc "tHE bOSS ISN'T ALWAYS",LF
            .asc "IN, BUT SHE IS TODAY,",LF,"AND SHE GIVES YOU A",LF
            .asc "SLIGHT NOD AS YOU",LF,"EXIT THE vERTI-tUBE.",LF,LF
            .asc "'dAMN BUSY DAY,",LF,"AHEAD,' SHE SAYS.",ED,ED
aTrip:      .asc "yOU FEEL YOUR FOOTING",LF,"GIVE OUT AS YOU",LF
            .asc "NAVIGATE A STEEP",LF,"GRADIENT IN COMPLETE",LF
            .asc "DARKNESS.",LF,LF
            .asc "uNABLE TO FIND YOUR",LF,"REEL, YOU WRITHE ON",LF
            .asc "ON THE GROUND IN",LF,"PAIN, REALIZING THAT",LF
            .asc "THAT IT WILL BE",LF,"HOURS BEFORE THE",LF
            .asc "bOSS COMES LOOKING",LF,"FOR YOU...",ED,ED
aWear:      .asc "iT DOES NOT FIT.",ED,COL_ALERT,"yOU DON'T HAVE THAT.",ED    
aYum:       .asc "yUM! tHIS IS WHAT YOU",LF,"LOVE ABOUT 1934.",ED  
            .asc COL_ALERT,"yOU DON'T HAVE THAT.",ED
aLockdown:  .asc COL_ALERT,"bEHIND YOU, THE NORTH",LF,"DOOR SHUTS WITH A",LF
            .asc "TERRIFYING ker chunk.",LF,"tHE KEYPAD ROTATES",LF
            .asc "AWAY. aLARM SOUNDS.",LF,LF,"yOU START TO SUSPECT",LF
            .asc "THE CODE WAS WRONG.",ED,ED
aComing:    .asc COL_ALERT,"yOU HEAR SHOUTING",LF,"VOICES GETTING",LF
            .asc "CLOSER. tHEY TRACK",LF,"YOU WITHOUT EFFORT.",LF,LF
            .asc "find your reel!",ED,ED
aAtFan:     .asc "fOR EXAMPLE, A COUPLE",LF,"OF THOROUGHLY",LF
            .asc "INTOXICATED FANS GRAB",LF,"YOU BY BOTH ARMS AND",LF
            .asc "THROW YOU OUT OF THE",LF,"BALLPARK.",ED,ED
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TIMERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            
; TimerRoom  - The room that causes the timer to start, when entered.
; TimerItem  - The item that causes the timer to start, when moved via action.
; TimerInit  - The number of turns to which the timer is set when started. If
;              the value is 1, then the action is triggered immediately upon 
;              entering the room.
; TimerTrig  - How the timer is triggered when TimerRoom is entered
;              0 = Trigger on first entry
;              1 = Trigger on second and subsequent entries unless running
;              2 = Trigger on any entry unless already running
;              3 = Trigger on any entry, retrigger if already running
; TimerTest  - The Action ID that's executed when the TimerTrig condition is
;              met. If the result is SUCCESS, then the timer is started.
;              Otherwise, it is not started. If TimerTest is 0, the timer is
;              always started if the TimerTrig condition is met.
; TimerAct   - The Action ID that's executed when the timer reaches 0.
;
; Memory is allocated to keep track of 48 Timers
TimerInit:  .asc 1,  1 , 1, 1, 7, 1, 1, 1, 8, 1, 1, 1, 5, 1,ED
TimerRoom:  .asc 1,  3 ,12,10,10,14,23,48,48,11, 2,19,48,48
TimerItem:  .asc 0,  0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
TimerTrig:  .asc 0,  0,  2, 2, 0, 2, 0, 2, 2, 2, 0, 0, 2, 2
TimerTest:  .asc 0,  0,  0, 0, 0, 0, 0,53,53, 0, 0, 0,53,53
TimerAct:   .asc 38, 2, 18,18,14,11,33,52,54,58,59,60,66,68
TimerDir:   .asc $01 ; Timer 0 direction ($01 = +1, $ff = -1)
TimerTgt:   .asc 240 ; Timer 0 target (at which action happens)
TimerOffst: .asc 13  ; Display time offset for Timer 0
