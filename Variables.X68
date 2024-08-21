*-----------------------------------------------------------
* Title      : Variables
* Written by : Zoe Wheatcroft
* Date       : 6/7/2023
* Description: Stores game variables
*               Does NOT store level specific variables
*-----------------------------------------------------------

* registers and constants
D_REGS       REG  D0-D7
A_REGS       REG  A0-A7

* TRAP CODES
READ_CHAR        EQU 5
GET_TIME        EQU 8
TERMINATE       EQU 9
ENABLE_ECHO     EQU 12
GET_4KEYS       EQU 19
GET_MOUSE       EQU 61
SET_RESOLUTION  EQU 33

READ_MOUSE_DOWN EQU 0

SET_PEN_COLOR   EQU 80
SET_FILL_COLOR  EQU 81
GET_PIXEL_COLOR EQU 83

DRAW_PIXEL      EQU 82
DRAW_LINE       EQU 84
DRAW_RECT       EQU 87
DRAW_CIRCLE     EQU 88

SET_DRAW_MODE   EQU 92
DRAW_BUFFER     EQU 94
DRAW_TEXT       EQU 95


* SIZES
DRIP_W          EQU 12
DRIP_H          EQU 24
DRIP_X          EQU 252
DRIP_Y          EQU 407
DRIP_TIME_LENGTH    EQU     500

SCREEN_WIDTH    EQU 640
SCREEN_HEIGHT   EQU 1000

SKY_CHANGER     EQU 24
SKY_STOPR       EQU 65280

SKY_CHANGEB     EQU 48
SKY_STOPB       EQU 84

SKY_CHANGEG     EQU 24
SKY_STOPG       EQU 84

EASEL_X         EQU 316
EASEL_Y         EQU 317
EASEL_W         EQU 25
EASEL_H         EQU 31

* KNIGHT VARIABLES
KNIGHT_HEIGHT   EQU 32
KNIGHT_WIDTH    EQU 30
KNIGHT_HB_W     EQU 19

KNIGHT_STARTX   EQU 319
KNIGHT_STARTY   EQU 914
KNIGHT_STARTHP  EQU 3

KNIGHT_XPOS     EQU 0
KNIGHT_YPOS     EQU 4
KNIGHT_XVEL     EQU 8
KNIGHT_YVEL     EQU 12
KNIGHT_HP       EQU 16
KNIGHT_STATE    EQU 18
KNIGHT_W        EQU 20

KNIGHT_SPEED    EQU 85000
KNIGHT_ACCELERATION EQU 1100
KNIGHT_JUMP     EQU 301500
GRAVITY_SCALE   EQU 9000

* Knight states
KNIGHT_IDLE     EQU 0
KNIGHT_ATTACK1  EQU 1
KNIGHT_ATTACK2  EQU 2
KNIGHT_RUN      EQU 3

HEART_HEIGHT    EQU 24
HEART_WIDTH     EQU 32
HEART_SPACING   EQU -42
HEART_START_X   EQU 588
HEART_START_Y   EQU 960


* VTABLES
Knight      ds.l    5
; x pos - lw
; y pos - lw
; x velocity - lw
; y velocity - lw
; health- w
; state - w
; knight width - w

KNIGHT_SWORD_X  EQU 16
KNIGHT_SWORD_Y  EQU 2
KNIGHT_SWORD_W  EQU 14
KNIGHT_SWORD_H  EQU 13

KnightGrounded  dc.w    0 ; is the knight grounded and avaliable to jump?
KnightAttacking dc.w    0

KnightLastXPos   dc.l   $0
KnightLastYPos  dc.l    $0
KnightLastHP    dc.w    $0
KnightLastState dc.w    $0

Score           dc.l    $0
ScoreNull       dc.b    0

* HILL CONSTANTS
HILLTOP_TOP     EQU 263
HILLTOP_BOT     EQU 276
HILL_COLOR      EQU 6849867

* SKY VALUES
SKY_R_START EQU     $8700 ; start colors are used to reinit sky on diff runs 
SkyColorR   dc.w   $8700
SKY_G_START EQU     $E700
SkyColorG   dc.w    $e700
SKY_B_START EQU     $EB00
SkyColorB   dc.w    $eb00
LastSkyColor    ds.l    $00000000
SunsetColorR    dc.w    $f700
SunsetColorG    dc.w    $7b00
SunsetColorB    dc.w    $2000

SkyIncrementR       dc.b    $8
SkyIncrementG       dc.b    $8
SkyIncrementB       dc.b    $8
                    dc.w    0
                    
* SUN VALUES 
SunYPos             dc.l    $0
SUN_SPEED           EQU     4500
SUN_SIZE            EQU     30
SUN_COLOR           EQU     $009EFA
                    
* GAME STATE
GameState       dc.w    1

* GAME STATE CONSTANTS
GAME_LOOP       EQU     0 ; regular game loop 
PLAYER_LOST     EQU     1 ; player died
SUNSET_LOST     EQU     2 ; player ran out of time
GAME_WON        EQU     3
                    
* TIME VALUES
LastFrameTime   dc.l    $0
DeltaTime       dc.l    $0
DripTimer       dc.l    $0
DripSwitch      dc.w    $0

* COLOR VALUES
YELLOW equ $00169c4 
BLACK equ $00000000 
WHITE equ $00FFFFFF 

* BITMAPS
Hills   INCBIN  "./Assets/Hills.bmp"
Title   INCBIN  "./Assets/Title.bmp"
Title2   INCBIN  "./Assets/Title2.bmp"
Knight_bmp  INCBIN  "./Assets/Knight.bmp"
Enemy_bmp       INCBIN  "./Assets/Enemy.bmp"
IronGalaxy  INCBIN  "./Assets/IronGalaxyLogo_Square.bmp"
Heart       INCBIN  "./Assets/Heart.bmp"
Instructions_bmp       INCBIN  "./Assets/Instructions.bmp"

DoneDebug   dc.b    'Finished.',0
WonMessage  dc.b    'GAME WON',0
WonMessage2 dc.b    'you cleared the hill and made it to the easel before sundown!',0
ScoreMessage    dc.b    'your score is : ',0
LostMessage dc.b    'GAME LOST',0
SunsetMessage   dc.b    'you ran out of time! sunset came and went',0
DiedMessage     dc.b    'you died!',0
ReplayMessage   dc.b    'press R to replay',0
LoadingMessage  dc.b    'LOADING...',0
            dc.l    0


KnightFrameSizes    dc.w    19, 30, 30

KnightAttackFunctionTable   dc.l    idlePlayerAttack, advancingPlayerAttack, performingPlayerAttack

GameStateFunctionTable      dc.l    gameLoop, gamePlayerDied, gameSunset, gameWon

SkyEdgeLocation     ds.w    641









































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
