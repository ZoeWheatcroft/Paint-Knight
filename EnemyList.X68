*-----------------------------------------------------------
* Title      : Enemy List
* Written by : Zoe Wheatcroft
* Date       : 6/9/23
* Description: List of all the enemies in a scene
*-----------------------------------------------------------

* ENEMY CONSTANTS
ENEMY_WIDTH     EQU 34
ENEMY_HEIGHT    EQU 26
ENEMY_START_HP  EQU 3

ENEMY_X         EQU 0
ENEMY_Y         EQU 2
ENEMY_HP        EQU 4
ENEMY_W         EQU 6
ENEMY_H         EQU 8
ENEMY_STATE     EQU 10
ENEMY_STATE_TIMER EQU 12

ENEMY_IDLE      EQU 0 ; state index for idle
ENEMY_HURT      EQU 1 ; state index for hurt
ENEMY_ATTACK    EQU 2 ; state index for attacking
ENEMY_DEAD      EQU 3

ENEMY_STATE_INTERVAL EQU    800 ; how often the enemy switches between states
ENEMY_HURT_INTERVAL   EQU   50 ; how long the enemy stays hurt before attacking

ENEMY_STRUCT_SIZE   EQU 14


AliveEnemies  dc.w    6

EnemyStart  dc.w    0

Enemy1      dc.w    $5F ; x 
            dc.w    $17a ;y 
            dc.w    $3 ; health
            dc.w    $22 ; w
            dc.w    $1A ; h
            dc.w    $0 ; state
            dc.w    $0 ; state timer 
            
Enemy2      dc.w    $200 ; x 
            dc.w    $19e ;y 
            dc.w    $3 ; health
            dc.w    $22 ; w
            dc.w    $1A ; h
            dc.w    $0 ; state
            dc.w    $0 ; state timer 
            
Enemy3      dc.w    $163 ; x 
            dc.w    $21f ;y 
            dc.w    $3 ; health
            dc.w    $22 ; w
            dc.w    $1A ; h
            dc.w    $0 ; state
            dc.w    $0 ; state timer 

            
Enemy4      dc.w    $165 ; x 
            dc.w    $2Db ;y 
            dc.w    $3 ; health
            dc.w    $22 ; w
            dc.w    $1A ; h
            dc.w    $0 ; state
            dc.w    $0 ; state timer 
            
Enemy5      dc.w    $36 ; x 
            dc.w    $28d ;y 
            dc.w    $3 ; health
            dc.w    $22 ; w
            dc.w    $1A ; h
            dc.w    $0 ; state
            dc.w    $0 ; state timer 
            
Enemy6      dc.w    $205 ; x 
            dc.w    $362 ;y 
            dc.w    $3 ; health
            dc.w    $22 ; w
            dc.w    $1A ; h
            dc.w    $0 ; state
            dc.w    $0 ; state timer 


EnemyEnd    dc.w    0

EnemyToRedraw   dc.l    0 ; if the player is overlapping w/ an enemy, 
                            ;the enemy will need to be redrawn to inval the player


















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
