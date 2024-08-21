*-----------------------------------------------------------
* Title      : Main Gameloop program
* Written by : Zoe Wheatcroft
* Date       : 6/8/2023
* Description: 
*-----------------------------------------------------------
    ORG    $1000

D_REGS       REG  D0-D7
A_REGS       REG  A0-A7

START:                  ; first instruction of program

main

    jsr     initScreen
    jsr     initTitleScreen
    move.b  #DRAW_BUFFER, D0
    trap    #15
    jsr     getStartKey

    jsr     displayLoadingScreen
    move.b  #DRAW_BUFFER, D0
    trap    #15
    
    jsr     displayInstructions
    move.b  #DRAW_BUFFER,d0
    trap    #15
    jsr     getContinueKey

startGame
    jsr     displayLoadingScreen
    move.b  #DRAW_BUFFER, D0
    trap    #15
    
    jsr     initBackground
    jsr     initEnemy
    jsr     initPlayer
    
    move.b  #DRAW_BUFFER, D0
    trap    #15
    
    move.w  #0, GameState ; set the game state to the normal game loop
    
    jsr     initTimeVariables
    
gameLoop
    jsr     updateTimeVariables
    jsr     updateBackground
    jsr     updateEnemy
    jsr     updatePlayer
    jsr     checkEasel
    
    move.b  #DRAW_BUFFER, D0
    trap    #15
    
    ; get the game state and use a virtual table to call next func
    jsr     getGameState
    jsr     (a0)
    
    
    
displayLoadingScreen
    jsr     clearScreen
    move.b  #SET_PEN_COLOR, d0
    move.l  #WHITE, d1
    trap    #15
    
    lea     LoadingMessage, a1
    move.b  #DRAW_TEXT, d0
    move.w  #SCREEN_WIDTH/2-50, d1
    move.w  #SCREEN_HEIGHT/2-50, d2
    trap    #15
   
    rts
    
displayInstructions
    jsr     clearScreen
    ; get the bit map we're rendering 
    lea     Instructions_bmp, a1
    move.l  a1, -(sp)
    ; starting top left corner of chunk
    move.w  #000, d0 ; x
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  #000, d0 ; y
    move.l  d0, -(sp)
    
    ; set the width and height of what we want to render
    move.l  #SCREEN_WIDTH,-(sp) ; d3 = width of chunk
    move.l  #SCREEN_HEIGHT,-(sp) ; d4 = chunk height
    
    move.l  #$00000000,-(sp) ; d5 = where to display
    move.l  $1c(a1),-(sp) ; d6 = 32/24 bit color

    jsr     displayChunk
    add.l   #24, sp

    
    rts
    
getContinueKey  
    move.b  #READ_CHAR, d0
    trap    #15
    cmpi.b   #101, d1
    bne     getContinueKey
    rts
    
gamePlayerDied
*   Set the background color to black
*   Write: GAME LOST you died!

    move.l  #0, d1
    move.b  #SET_PEN_COLOR, D0
    trap    #15 ; draw the background
    move.l  #SET_FILL_COLOR, D0
    trap    #15

    move.b  #DRAW_RECT, d0
    move.w  #0, d1
    move.w  #0, d2
    move.w  #SCREEN_WIDTH, d3
    move.w  #SCREEN_HEIGHT,d4
    trap    #15 

    lea     LostMessage, a1
    move.w  #200, d1
    move.w  #200, d2
    move.b  #DRAW_TEXT, d0
    trap    #15
    
    lea     DiedMessage, a1
    move.w  #80, d1
    move.w  #220, d2
    move.b  #DRAW_TEXT, d0
    trap    #15
    
    lea     ReplayMessage, a1
    move.w  #80, d1
    move.w  #235, d2
    move.b  #DRAW_TEXT, d0
    trap    #15
    
     move.b  #DRAW_BUFFER, D0
    trap    #15

    bra     getReplayKey
    
    move.w  #TERMINATE, d0
    trap    #15

gameSunset
*   Set the background color to yellow and pen color to black
*   Write: GAME LOST you ran out of time!

    move.l  #0, d1
    move.b  #SET_PEN_COLOR, D0
    trap    #15 ; draw the background
    move.l  #SET_FILL_COLOR, D0
    trap    #15

    move.b  #DRAW_RECT, d0
    move.w  #0, d1
    move.w  #0, d2
    move.w  #SCREEN_WIDTH, d3
    move.w  #SCREEN_HEIGHT,d4
    trap    #15 
    
    lea     LostMessage, a1
    move.w  #200, d1
    move.w  #200, d2
    move.b  #DRAW_TEXT, d0
    trap    #15
    
    lea     SunsetMessage, a1
    move.w  #80, d1
    move.w  #220, d2
    move.b  #DRAW_TEXT, d0
    trap    #15

    lea     ReplayMessage, a1
    move.w  #80, d1
    move.w  #235, d2
    move.b  #DRAW_TEXT, d0
    trap    #15   
    
    move.b  #DRAW_BUFFER, D0
    trap    #15

    bra     getReplayKey
    
    move.w  #TERMINATE, d0
    trap    #15
    

gameWon
*   Set the background color to yellow and pen color to black
*   Write: GAME WON you cleared the hill and made it to the easel before sundown!

    move.l  #YELLOW, d1
    move.b  #SET_PEN_COLOR, D0
    trap    #15 ; draw the background
    move.l  #SET_FILL_COLOR, D0
    trap    #15

    move.b  #DRAW_RECT, d0
    move.w  #0, d1
    move.w  #0, d2
    move.w  #SCREEN_WIDTH, d3
    move.w  #SCREEN_HEIGHT,d4
    trap    #15 
    
    move.l  #0, d1
    move.b  #SET_PEN_COLOR, d0
    trap    #15
    
    lea     WonMessage, a1
    move.w  #200, d1
    move.w  #200, d2
    move.b  #DRAW_TEXT, d0
    trap    #15
    
    lea     WonMessage2, a1
    move.w  #80, d1
    move.w  #220, d2
    move.b  #DRAW_TEXT, d0
    trap    #15
    
;   code is not working atm and dont want it to bug during demo
*    lea     ScoreMessage, a1
*    move.w  #80, d1
*    move.w  #235, d2
*    move.b  #DRAW_TEXT, d0
*    trap    #15
*    
*    ; calculate the player's final score 
*    move.l  SunYPos, d0
*    move.l  #HILLTOP_BOT, d1
*    sub.l   d0, d1
*    ; d1 = final score = total distance to bottom of hills - position of sun
*    ; this rewards for speed 
*    move.l  d1, Score
*    lea     Score, a1
*    move.w  #150, d1
*    move.w  #235, d2
*    move.b  #DRAW_TEXT, d0
*    trap    #15
    
    lea     ReplayMessage, a1
    move.w  #80, d1
    move.w  #235, d2
    move.b  #DRAW_TEXT, d0
    trap    #15
    
     move.b  #DRAW_BUFFER, D0
    trap    #15

    bra     getReplayKey
    
    move.w  #TERMINATE, d0
    trap    #15
    


clearScreen
    move.b  #SET_PEN_COLOR, d0
    move.l  #0, d1
    trap    #15
    move.b  #SET_FILL_COLOR, d0
    trap    #15

    move.b  #DRAW_RECT, d0
    move.w  #0, d1
    move.w  #0, d2
    move.w  #SCREEN_WIDTH, d3
    move.w  #SCREEN_HEIGHT, d4
    trap    #15
    rts
    
    
    
* get the game state and return the function that should be called 
* this uses a func table to see what the game should do next (game loop, game over, game won, etc)
* returns address of next game state func to call in a0
getGameState
    move.w  GameState, d0
    lsl.w   #2, d0
    lea     GameStateFunctionTable, a1
    move.l  (a1,d0),a0
    rts
    
initTimeVariables
    ; since the random num generator is also based off time, we init that here too
    jsr     seedRandomNumber
    move.b  #GET_TIME, d0
    trap    #15
    move.l  d1, LastFrameTime
    rts
    
updateTimeVariables
    move.l  LastFrameTime, d2
    move.b  #GET_TIME, d0
    trap    #15
    move.l  d1, LastFrameTime
    sub.l   d2, d1
    move.l  d1, DeltaTime
    rts

initScreen
    move.b  #SET_RESOLUTION, d0
    move.w  #SCREEN_WIDTH, d1
    swap    d1
    move.w  #SCREEN_HEIGHT, D1
    trap    #15
    * turn on double buffering
    move.b  #17, d1
    move.b  #SET_DRAW_MODE, d0
    trap    #15
    rts
    
getReplayKey
    move.b  #READ_CHAR, d0
    trap    #15
    cmp.b   #114, d1
    bne     getReplayKey
    beq     startGame

    SIMHALT             ; halt simulator

* Put variables and constants here

    Include     "Player.X68"
    Include     "Title.X68"
    Include     "Enemy.X68"
    Include     "Easel.X68"
    Include     "CollisionDetection.X68"
    Include     "Math.X68"
    Include     "RandomNumbers.X68"
    Include     "ChunkRender.X68"
    Include     "BackgroundRenderer.X68"
    Include     "Blocks.X68"
    Include     "Variables.X68"
    Include     "EnemyList.X68"

    END    START        ; last line of source































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
