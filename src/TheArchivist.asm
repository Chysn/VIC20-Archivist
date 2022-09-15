;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;                                The Archivist
;                                  VICfiction
;                            (c)2022, Jason Justian
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
; GAME-SPECIFIC CONFIGURATION SETTINGS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            
; Colors
SCRCOL      = 8                 ; Screen color
COL_INPUT   = 5                 ; Input color
COL_NORM    = 30                ; Text color
COL_ALERT   = 28                ; Alert color
COL_ITEM    = 158               ; Item color
COL_ROOM    = 31                ; Room name color
COL_DIR     = 159               ; Directional display color

; Game Configuration
; When the SCORE_TGT number of items are present in the room id specified
; by SCORE_ROOM, the action id specified in SCORE_ACT is triggered
SCORE_RM    = 1                 ; Score room id
SCORE_TGT   = 5                 ; Target score
SCORE_ACT   = 2                 ; Action id when score is achieved

; Inventory Configuration
; Make sure any inventory configured here has an ItemRoom value of 0
ST_ITEM_L   = 6                 ; Starting Item ID, left hand
ST_ITEM_R   = 0                 ; Starting Item ID, right hand 

; Timer Configuration
TIMER_START = 4                 ; Timer starting value
TIMER_DIR   = $04               ; Timer direction ($01 = +1, $ff = -1)
TIMER_TGT   = 248               ; Timer target (at which TIMEOUT_ACT happens)
TIMEOUT_ACT = 0                 ; Timeout action ID
TRIGGER     = 0                 ; Timer value when triggered
TIME_OFFSET = 9                 ; Display time offset (e.g., for clocks)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GAME DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
Directions: .asc 'DUEWSN' ; Compass directions
;           .asc 'DUSPAF' ; Maritime directions

; Text - Game Messages, Errors, etc.
Intro:      .asc CLRHOME,COL_NORM,"yOU ARRIVE AT WORK",LF,"IN THE USUAL WAY, BY"
            .asc LF,"CURSOR. aFTER ALL,",LF,"YOU LIVE IN 1841. yOU",LF
            .asc "ONLY work IN 6205.",LF,LF,"yOU STRAIGHEN YOUR",LF
            .asc "GLASSES AND GLANCE AT",LF,"YOUR QUOTA SHEET.",LF,LF
            .asc "dAMN BUSY DAY AHEAD.",LF,LF,
            .asc 156,"tHE aRCHIVIST",LF,LF,"2022, jASON jUSTIAN",LF,
            .asc "bEIGE mAZE vic lAB",ED
ScoreTx:    .asc "iNTAKE:",ED
NoVerbTx:   .asc COL_ALERT,"nO NEED TO DO THAT",ED
NoDropTx:   .asc COL_ALERT,"yOU DON'T HAVE THAT",ED
HaveItTx:   .asc COL_ALERT,"yOU ALREADY HAVE IT",ED
GameOverTx: .asc COL_ALERT,"     - the end -",ED
NotHereTx:  .asc COL_ALERT,"tHAT'S NOT HERE",ED
NoPathTx:   .asc COL_ALERT,"yOU CAN'T GO THAT WAY",ED
NoMoveTx:   .asc COL_ALERT,"tHAT WON'T MOVE",ED
FullTx:     .asc COL_ALERT,"bOTH HANDS ARE FULL",ED
NoLightTx:  .asc COL_ALERT,"yOU CANNOT SEE",ED
ConfirmTx:  .asc COL_ALERT,"ok",ED

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VERBS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            
; VerbID - Cross-referenced ID list for verb synonyms
; Basic - GO (MovE), LooK (L,EX), GeT (TakE), DroP, InventorY (I)
; Game - TALK(6), WIND(7), DIAL(8), SET(2), SWAP(9), BUY(10), CATCH(11)
;        OPEN(12)
; Verb IDs are 1-indexed
Verb1:      .byte 'G','M','L','L','E','G','T','D','I','I'   ; Basic Verbs
            .byte 'T','W','D','R','S','B','C','O',ED
VerbL:      .byte 'O','E','K','L','X','T','E','P','Y','I'   ; Basic Verbs
            .byte 'K','D','L','D','P','Y','H','N'
VerbID:     .byte  1,  1,  2,  2,  2,  3,  3,  4,  5,  5    ; Basic Verbs
            .byte  6,  7,  8,  2,  9, 10, 11, 12

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ROOMS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            
; Room IDs are 1-indexed
Rooms:      ; Main Facility (1-3)
            ;     D, U, E, W, S, N, ActID, RmProp, DescL, DescH
            .byte 2, 0, 0, 0, 0, 0, 0, 0, <rIntake,>rIntake
            .byte 0, 1, 3, 0, 0, 0, 0, 0, <rOffice,>rOffice
            .byte 0, 0, 0, 2, 0, 0, 2, 0, <rPlaza,>rPlaza
            
            ; Graff House, 1776 (4-8)
            ;     D, U, E, W, S, N, ActID, RmProp, DescL, DescH
            .byte 0, 0, 5, 0, 0, 0, 0, 0, <rCorner,>rCorner
            .byte 0, 7, 0, 4, 0, 0, 0, 0, <rFoyer,>rFoyer
            .byte 0, 0, 0, 0, 0, 7, 0, 0, <rJeffRoom,>rJeffRoom
            .byte 5, 0, 0, 0, 6, 8, 0, 0, <rLanding,>rLanding
            .byte 0, 0, 0, 0, 7, 0, 0, 0, <rJeffBed,>rJeffBed
            
            ; Navin Field, 1934 (9-15)
            ;     D, U, E, W, S, N, ActID, RmProp, DescL, DescH
            .byte 0, 0, 0, 0, 0,14, 0,  0, <rTBooth,>rTBooth
            .byte 0, 0,11,13,14, 0, 18, 0, <rHomeSt,>rHomeSt
            .byte 0, 0, 0,12,10, 0, 14, 0, <rRightF,>rRightF
            .byte 0, 0,11,13,10, 0, 18, 0, <rCenterF,>rCenterF
            .byte 0, 0,12, 0,10, 0, 0,  0, <rLeftF,>rLeftF
            .byte 0, 0, 0, 0, 9,10, 11, 0, <rCorridor,>rCorridor
            .byte 0, 0,15,15, 0, 0, 0,  0, <rJail,>rJail
            
            ; Nefertari's Tomb, 1256BC (16-22)
            ;     D, U, E, W, S, N, ActID, RmProp, DescL, DescH
            .byte 0, 0,17, 0, 0, 18, 0, 1, <rAnteCh,>rAnteCh
            .byte 0, 0, 0,16, 0, 0 , 0, 1, <rSideCh,>rSideCh
            .byte 19,0, 0, 0, 16,0 , 0, 1, <rRamp,>rRamp
            .byte 0,18,21,20, 0, 22, 0, 1, <rSarcRm,>rSarcRm
            .byte 0,0, 19, 0, 0, 0 , 0, 1, <rWAnnex,>rWAnnex
            .byte 0,0,  0,19, 0, 0 , 0, 1, <rEAnnex,>rEAnnex
            .byte 0,0,  0, 0,19, 0 , 0, 1, <rResOs,>rResOs

; Room Descriptions
;     The room name is terminated by ED, after which is the room description,
;     also terminated by ED
rIntake:    .asc "iNTAKE rOOM",ED,"tHIS CIRCULAR ROOM IS",LF
            .asc "YOUR WORK AREA. tHE",LF,"CURSOR DOMINATES THE",LF
            .asc "EXACT CENTER OF THE",LF,"SPACE. tHE CONSOLE IS",LF
            .asc "ABOUT A METER AWAY.",LF,LF,"a LADDER TUBE LEADS",LF
            .asc "DOWN TO aDMIN.",ED
rOffice:    .asc "bOSS'S oFFICE",ED,"tHE bOSS ISN'T ALWAYS",LF
            .asc "IN, BUT SHE IS TODAY,",LF,"AND SHE GIVES YOU A",LF
            .asc "SLIGHT NOD AS YOU",LF,"EXIT THE LADDER.",LF,LF
            .asc "'dAMN BUSY DAY,",LF,"TODAY,' SHE SAYS.",LF,LF
            .asc "tHE DOOR TO THE EAST",LF,"IS MARKED WITH A HUGE",LF
            .asc "RED EXCLAMATION MARK.",ED
rPlaza:     .asc "pLAZA",ED,ED

            ; Graff House, 1776
rCorner:    .asc "cORNER",ED,"tHE CORNER OF 7TH AND",LF,"mARKET sTREET IN",LF
            .asc "pHILADELPHIA.",LF,LF,"a NEW HOUSE WITH AN",LF
            .asc "INTRICATE fLEMISH",LF,"bOND BRICK PATTERN",LF
            .asc "ADORNS THE CORNER.",LF,LF,"tHERE'S AN ENTRYWAY",LF
            .asc "ON THE WEST FRONT.",ED
rFoyer:     .asc "fOYER, gRAFF hOUSE",ED,"tHE WHOLE OF gRAFF",LF
            .asc "hOUSE IS CLEARLY",LF,"NEW CONSTRUCTION,",LF
            .asc "LOVINGLY DESIGNED AND",LF,"BUILT BY ITS OCCUPANT",LF
            .asc "AND LANDLORD.",LF,LF
            .asc "tHERE'S A STAIRWAY",LF,"UP, BUT THE REST OF",LF
            .asc "THE HOUSE IS LOCKED",LF
            .asc "OFF.",ED            
rLanding:   .asc "lANDING",ED,"tHERE ARE ROOMS TO",LF,"THE NORTH AND SOUTH.",ED
rJeffRoom:  .asc "pARLOR",ED,"sOMEBODY IS DOING A",LF,"LOT OF WRITING HERE.",LF
            .asc "pAPERS ARE STREWN",LF,"AROUND, ANYTHING",LF
            .asc "LINEN IS STAINED BY",LF,"INK. a WASTEBASKET",LF
            .asc "BRIMS WITH REJECTED",LF,"DRAFTS READING 'iN",LF
            .asc "cONGRESS.'",ED   
rJeffBed:   .asc "bED cHAMBER",ED,"tHE BED IS NEATLY",LF
            .asc "MADE AND TINY.",LF,"wHOEVER RENTS THIS",LF
            .asc "ROOM DOESN'T SLEEP",LF,"MUCH.",ED
rTBooth:    .asc "tICKET bOOTH",ED,"nAVIN fIELD, dETROIT.",LF,LF
            .asc "tODAY THE tIGERS ARE",LF,"PLAYING THE yANKEES",LF
            .asc "WITH bABE rUTH. tHIS",LF,"IS A SPECIAL DAY.",LF,LF
            .asc "a FRECKLY KID AT THE",LF,"COUNTER IS BARKING,",LF
            .asc "'tICKETS! bUY YOUR",LF,"TICKETS HERE!'",ED
rHomeSt:    .asc "hOME pLATE sTANDS",ED,"tHE GREEN OF THE",LF
            .asc "DIAMOND IS SOMETHING",LF,"YOU'LL NEVER FORGET,",LF
            .asc "AS ARE THE SOUNDS OF",LF,"THE BAT AND THE SMELL",LF
            .asc "OF THE ALMONDS.",LF,LF,"bUT YOU DON'T WANT TO",LF
            .asc "BE BEHIND THE PLATE.",LF,LF,"lEFT fIELD IS TO THE",LF
            .asc "WEST, AND rIGHT fIELD",LF,"TO THE EAST.",ED
rRightF:    .asc "rIGHT fIELD sTANDS",ED,"tHE CROWD ROARS.",ED
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
rJail:      .asc "dETROIT jAIL",ED,"tHE CELL IS LIKE 2x2",LF
            .asc "METERS. iT'S SUPER",LF,"EMBARASSING.",LF,LF
            .asc "hOPEFULLY YOU HAVE",LF,"YOUR REEL.",ED
rAnteCh:    .asc "aNTECHAMBER",ED,"tOMB OF nEFERTARI,",LF
            .asc "vALLEY OF THE qUEENS,",LF,"lUXOR.",LF,LF
            .asc "tHE SMARTPHONE HAS",LF,"ENOUGH ILLUMINATION",LF
            .asc "FOR YOU TO FIND YOUR",LF,"WAY, AND FOR YOU TO",LF
            .asc "APPRECIATE THE RICHLY",LF,"COLORED ILLUSTRATIONS",LF
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
;     Bit 4 = Is trigger for timer (when this item is moved to a room, the
;             timer starts)
;     Bit 5 = Is global (can be interacted with from any room)
;     Bit 6 = Is scored (counts as 1 point when dropped in score room)
;     Bit 7 = Is light source (rooms with "is dark" can be seen)
;   ItemTxt  - Address of item name and description
;   (The item name is terminated by ED, after which is the item description,
;    also terminated by ED)
; 
; Item IDs are 1-indexed
Item1:      .byte 'C','C','B','R','Q','W','1','D','1','S','*','J','B'
            .byte 'T','C','1','G','*','*','*','1','S','P','I','N','P'
            .byte 'B','F','S',ED
ItemL:      .byte 'R','E','S','L','A','H','6','K','1','E','*','N','L'
            .byte 'T','N','4','E','*','*','*','C','S','E','S','E','T'
            .byte 'T','S','L'
ItemRoom:   .byte  1 , 1,  2 , 2 , 1 , 0,  1 , 6 , 1 , 1 , 6 , 0 , 0
            .byte  0 , 8,  1 ,13 ,11 , 0,  0 , 1 ,19 ,21 , 0 , 21,20
            .byte 21 ,20, 20
ItemProp:   .byte  3 , 3,  3 , 0, 0 , 8,  3 ,$40,  3 ,$80, 7 , 2 ,$40
            .byte  0 , 0,  3 , 1 , 7 , 7,  7 , 3,  2 , 0 ,35 , 0 , 0
            .byte  0 , 2,$40
ItemTxtL:   .byte <iCursor,<iConsole,<iBoss,<iReel,<iQuota,<iWatch,<iYear
            .byte <iDesk,<iYear,<iPhone,0,<iJefferson,<iBall,<iTicket
            .byte <iSixpence,<iYear,<iGlove,0,0,0,<iYear,<iSarc,<iPlaque
            .byte <iIllus,<iNecklace,<iPendant,<iBracelet,<iFigurines,<iSandal
ItemTxtH:   .byte >iCursor,>iConsole,>iBoss,>iReel,>iQuota,>iWatch,>iYear
            .byte >iDesk,>iYear,>iPhone,0,>iJefferson,>iBall,>iTicket
            .byte >iSixpence,>iYear,>iGlove,0,0,0,>iYear,>iSarc,>iPlaque
            .byte >iIllus,>iNecklace,>iPendant,>iBracelet,>iFigurines,>iSandal

; Item Descriptions
iCursor:    .asc "cURSOR",ED,"tHE CURSOR LOOKS LIKE",LF
            .asc "A STEAM ENGINE",LF,"STUFFED IN A TUXEDO.",LF
            .asc "sEVERAL WHEELS SPIN",LF,"AT VARYING SPEEDS.",LF
            .asc "tUBES AND VALVES ARE",LF,"EVERYWHERE.",LF,LF
            .asc "tHE bOSS TRIED TO",LF,"EXPLAIN HOW IT WORKS",LF
            .asc "ONCE. hAD TO DO WITH",LF,"BUBBLES. iT GETS YOU",LF
            .asc "FROM WHEN TO WHEN.",ED
iConsole:   .asc "cONSOLE",ED,"yOU'D THINK THEY'D",LF
            .asc "HAVE FANCIER CONSOLES",LF,"IN THE 63RD CENTURY,",LF
            .asc "BUT THIS CONSOLE IS",LF,"JUST A STAND WITH A",LF
            .asc "ROTARY CONTROL TO",LF,"dial DESTINATIONS.",ED
iBoss:      .asc "tHE boss",ED,"tHE bOSS LOOKS LIKE A",LF
            .asc "MIDDLE-AGED WOMAN",LF,"IN A VIOLET LAB COAT,",LF
            .asc "BUT YOU KNOW SHE'S",LF
            .asc "BEEN DOING THIS FOR A",LF,"HUNDRED YEARS. sHE'S",LF
            .asc "WORKING MENTALLY AT",LF,"THE MOMENT, BUT YOU",LF
            .asc "KNOW YOU CAN ALWAYS",LF,"talk TO HER.",ED
iReel:      .asc "tEMPORAL reel",ED,"tHE REEL IS THE",LF
            .asc "REMOTE COMPONENT OF",LF,"THE CURSOR. iT'S A",LF
            .asc "PALM-SIZED WHEEL WITH",LF,"A PARALLEL SMALLER",LF
            .asc "WHEEL AFFIXED, SOFTLY",LF,"WHIRRING, WITH A",LF
            .asc "PULSING AMBER LIGHT.",LF,LF
            .asc "yOU OPERATE IT BY",LF,"windING IT.",ED
iQuota:     .asc "quota SHEET",ED,"--dUE tODAY--",LF,LF," * 1776",LF
            .asc " * 1934",LF," * 2022",LF," * 1255bc",LF," * 23",LF,LF
            .asc "cHERNOV COLLECTS",LF,"YOUR iNTAKE AT 17:00.",LF,
            .asc "yOU JUST NEED TO drop",LF,"ASSETS IN THIS ROOM.",ED
iWatch:     .asc "pOCKET watch",ED,"18TH cENTURY. a GIFT",LF
            .asc "FROM dAD. oRNATE.",ED
iYear:      .asc "jUST A YEAR",ED,"dial THE YEAR INTO",LF,"THE CONSOLE.",ED
iDesk:      .asc "jEFFERSON'S desk",ED,"tHIS IS THE DESK THAT",LF
            .asc "tHOMAS jEFFERSON IS",LF,"USING TO WRITE THE",LF
            .asc "dECLARATION OF",LF,"iNDEPENDENCE. iF IT",LF
            .asc "GOES MISSING, HE'LL",LF,"WRITE IT ON SOMETHING",LF
            .asc "ELSE.",LF,LF,"iF IT SEEMS THERE'S A",LF
            .asc "PARADOX HERE, THAT'S",LF,"cHERNOV'S PROBLEM.",ED
iPhone:     .asc "smartphone",ED,"nOT IN THE LEAST",LF,"ANACHRONISTIC, IT'S"
            .asc LF,"A 150MM BY 75MM SLAB",LF,"WITH A BRIGHT SCREEN.",LF,LF
            .asc "zERO BARS.",ED
iJefferson: .asc "tHOMAS jefferson",ED,"yES, that jEFFERSON.",ED
iBall:      .asc "rUTH'S hOME rUN ball",ED,"bABE rUTH HIT HIS",LF
            .asc "700TH HOME RUN WITH",LF,"THIS BASEBALL.",ED
iTicket:    .asc "bASEBALL ticket",ED,"jULY 14, 1934 tIGERS",LF
            .asc "VS. yANKEES $1.40",ED
iSixpence:  .asc "sIXPENCE coin",ED,"aN OLD bRITISH COIN,",LF
            .asc "WORTHLESS NOW.",ED
iGlove:     .asc "bASEBALL glove",ED,"iT'S A TAD SMALL,",LF
            .asc "AS A CHILD'S GLOVE,",LF,"BUT IT SHOULD WORK.",ED
iPlaque:    .asc "iNSCRIBED gOLD plaque",ED,"yOUR ANCIENT eGYPTIAN",LF,
            .asc "IS RUSTY. mAYBE LIKE:",LF,LF,COL_ALERT
            .asc "take no  gold  from my",LF,"birthright,  lest  its",LF
            .asc "curse snuff your light",LF
            .asc "(silver & bronze too!)",LF,COL_NORM
            .asc "eGYPTIAN MUMMY CURSE?",LF,"that CAN'T BE A REAL",LF
            .asc "THING. rIGHT...?",ED
iSarc:      .asc "sarcophagus",ED,"nEFERTARI'S FINAL",LF
            .asc "RESTING PLACE IS",LF,"AMAZING, LIKE",LF
            .asc "EVERYTHING HERE.",LF,"sTUNNING ROSE",LF
            .asc "GRANITE, INLAID WITH",LF,"GOLD AND CARNELIAN.",LF
            .asc "tHE qUEEN'S CARVED",LF,"FACE LOOKS HOPEFULLY",LF
            .asc "AT THE CEILING.",ED
iIllus:     .asc ED,"tHEY JUST CAN'T BE",LF,"ADEQUATELY EXPRESSED",LF
            .asc "IN THIS MEDIUM. iF",LF,"YOU'RE STUCK IN THE",LF
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
iSandal:    .asc "nEFERTARI'S sandal",ED,"aN INTRICATELY-WOVEN",LF
            .asc "PAPYRUS SANDAL.",LF,"wOMENS' SIZE 9.",ED

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ACTIONS
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
;                ActTo can also specify a Room ID, if ActFrom is 0.
;
;                If ActTo is 0, the ActFrom item will be moved to the room that
;                the player is currently in.
;
;                If both ActFrom and ActTo are 0, then the text is displayed and 
;                the game ends.
;
;                If both ActFrom and ActTo are the same non-zero Item ID, only
;                messages will be displayed.
;   ActResTxt  - The address of the success and failure messasges
;                (The success message is terminated by ED, after which is the
;                 failure message, also terminated by ED)
;
; Action IDs are zero-indexed, and the action id $ff (EV) is reserved for
; actions triggered by events (timer target, enters-room, score target)
ActVerb:    .byte 6,7,EV,8,8,3, 3,  6, 9,  9, 9,EV, 8,10,EV,11,11,11
            .byte EV, 8,12,ED
ActItem:    .byte 3,4,0, 7,9,8, 8, 12,10,  4, 0,0 ,16,14, 0,13,13,13
            .byte 0, 21,22
ActInRoom:  .byte 0,0,0, 0,0,0, 0,  0, 6,  6, 6,0,  0, 9, 0,11,11,11
            .byte 0,  0, 0
ActInvCon:  .byte 0,4,0, 0,0,0, 0,  0,10,  4, 0,0,  0,15, 0, 0,17, 0
            .byte 13, 0, 0
ActRoomCon: .byte 3,0,0, 1,1,11,12, 0,12, 12,12,0 , 1, 0,18,20,19,19
            .byte 0,  1,22
ActInvExcl: .byte 0,1,0, 0,0,8, 8,  8, 8,  8, 8,14, 0, 0, 0,0,  0, 0
            .byte 0,  0, 0
ActFrom:    .byte 1,0,0, 0,0,11,1,  1, 10, 4, 1,0 , 0,15,18,1, 17,19
            .byte 0,  0, 1
ActTo:      .byte 1,1,0, 4,0,12,1,  1, 8,  8, 1,9 , 9,14,19,1, 13,20
            .byte 15,16, 1
ActResTxtL: .byte <aBoss,<aHome,<aDie,<aX,<a1841,<aJeffEnter,<aJeffSay
            .byte <aJeffOffer,<aJeffAcc,<aJeffAcc,<aJeffDecl
            .byte <aNeedTix,<aX,<aBuyTix,<aBallHit,<aMissed,<aTryCatch,0
            .byte <aToJail,<aX,<aOpSarc
ActResTxtH: .byte >aBoss,>aHome,>aDie,>aX,>a1841,>aJeffEnter,>aJeffSay
            .byte >aJeffOffer,>aJeffAcc,>aJeffAcc,>aJeffDecl
            .byte >aNeedTix,>aX,>aBuyTix,>aBallHit,>aMissed,>aTryCatch,0
            .byte >aToJail,>aX,>aOpSarc
            
; Action Results
aBoss:      .asc "'hAVE A GREAT DAY,",LF,"AND DON'T FORGET YOUR",LF
            .asc "REEL!'",ED,"sHE'S NOT HERE.",ED
aHome:      .asc CLRHOME,"bEING REELED BACK IS",LF,"ALWAYS DISCONCERTING.",LF
            .asc "iT'S LIKE RIDING A",LF,"ROLLER COASTER WHILE",LF
            .asc "WEARING A vr HEADSET",LF,"OF A DIFFERENT ROLLER",LF
            .asc "COASTER.",LF,LF,"tHE SENSATION LASTS",LF
            .asc "ONLY A MOMENT AND",LF,"YOU'RE BACK TO YOUR",LF
            .asc "iNTAKE rOOM.",ED
            .asc "yOU DON'T HAVE A",LF,"TEMPORAL REEL.",ED
aDie:       .asc CRSRUP,CRSRUP,CRSRUP,CRSRUP,"tHE bOSS RUSHES TO",LF
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
            .asc "BE A DAMN BUSY DAY.",ED,"tHERE'S NO CONSOLE.",ED
aJeffEnter: .asc "jUST AS YOU TAKE THE",LF,"LITTLE DESK, A TALL",LF
            .asc "MAN EMERGES FROM",LF,"BEHIND AND WRESTS IT",LF
            .asc "FROM YOUR HANDS.",ED,ED
aJeffSay:   .asc "'i DON'T THINK THIS",LF,"BELONGS TO YOU,'",LF
            .asc "jEFFERSON FROWNS.",ED,ED
aJeffOffer: .asc "'i INVENTED THIS DESK",LF,"AND i'M NOT GOING TO",LF
            .asc "LET YOU TAKE IT.",LF,LF,"'bUT... yOU LOOK LIKE",LF
            .asc "SOMEONE WITH ACCESS",LF,"TO GREAT FUTURISTIC",LF
            .asc "INVENTIONS. iF YOU",LF,"BRING ME SOMETHING",LF
            .asc "FROM THE FUTURE, i'LL",LF,"swap IT FOR MY",LF
            .asc "EXCELLENT DESK!'",ED,"'oUR BUSINESS IS",LF
            .asc "CONCLUDED. i BID YOU",LF,"GOOD DAY.'",ED
aJeffDecl:  .asc "'i HAVE ABSOLUTELY NO",LF,"INTEREST IN THAT.'",ED
            .asc "nOBODY TO SWAP WITH!",ED
aJeffAcc:   .asc "'wHAT A MARVELOUS",LF,"THING! i DARESAY WE",LF
            .asc "HAVE A DEAL.",LF,LF,"'i'LL HAVE A TABLE",LF
            .asc "BROUGHT UP SO i CAN",LF,"FINISH THIS OTHER",LF
            .asc "PROJECT.'",LF,LF
            .asc "jEFFERSON HANDS",LF,"YOU HIS DESK.",ED,ED
aNeedTix:   .asc "fRECKLE-FACED KID AT",LF,"THE COUNTER STOPS",LF
            .asc "YOU. 'yOU NEED TO BUY",LF,"A TICKET TO GET IN!'",ED
            .asc "'yOU BETTER GET IN,",LF,"bABE'S ON DECK!'",ED
aBuyTix:    .asc "'tHAT'S SOME FUNNY",LF,"LOOKIN' MONEY, BUT i",LF
            .asc "GUESS IT SPENDS THE",LF,"SAME. hERE'S YOUR",LF
            .asc "TICKET.'",ED,"'tHESE TICKETS COST",LF
            .asc "money!' tHE KID SAYS.",ED
aBallHit:   .asc "yOU HEAR THE CRACK",LF,"OFF rUTH'S BAT AND",LF
            .asc "SEE THE BALL HEADING",LF,"RIGHT AT YOU. yOU",LF
            .asc "KNEW EXACTLY WHERE TO",LF,"BE...",ED
            .asc "tHE GAME GOES ON.",ED
aMissed:    .asc "tHE MOMENT'S PASSED.",LF,"lET IT GO.",ED,ED
aTryCatch:  .asc "wITH A SATISFYING",LF,"THUD, THE BALL PLANTS",LF
            .asc "ITSELF IN THE",LF,"PILFERED GLOVE. fANS",LF
            .asc "EYE YOU SUSPICIOUSLY.",LF,LF,"yOU... BETTER GET OUT",LF
            .asc "OF HERE.",ED
            .asc "wITH NOTHING TO CATCH",LF,"THE BALL, IT BOUNCES",LF
            .asc "OUT OF YOUR HANDS AND",LF,"INTO THE HANDS OF",LF
            .asc "ANOTHER FAN, WHO RUNS",LF,"LAUGHING FROM nAVIN",LF
            .asc "fIELD.",ED
aToJail:    .asc "a LITTLE KID CRIES",LF,"AND POINTS AT YOU,",LF
            .asc "'sTOLE MY GLOVE!'",LF,LF,"cROWD DISAPPROVES,",LF
            .asc "AND SO DO dETROIT'S",LF,"fINEST...",ED,ED
aOpSarc:    .asc "dID YOU MISS THE BIT",LF,"ABOUT THE GRANITE?",LF
            .asc "tHE LID ALONE WEIGHS",LF,"SEVERAL THOUSAND KG,",LF
            .asc "AND IT'S NOT WHAT",LF,"YOU'RE HERE FOR.",ED,ED
