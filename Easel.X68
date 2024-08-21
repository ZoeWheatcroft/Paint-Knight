*-----------------------------------------------------------
* Title      : Easel 
* Written by : Zoe Wheatcroft
* Date       : 6/21/23
* Description: Management system for the easel. If the number of alive enemies = 0 and enemy collides w the easel, 
*               then the game has been won
*-----------------------------------------------------------

* easel's update-- I called it check instead of update because nothing about the easel
* actually changes or needs to 'update' every frame. A check just needs to be done!
checkEasel
    move.w  AliveEnemies, d0
    cmpi.w  #0, d0
    bne     checkEaselFalse ; there are still enemies alive, do nothing
    
    ; now to put the player on the stack
    move.l  #KNIGHT_HEIGHT,-(sp)
    move.l  #KNIGHT_HB_W,-(sp)
    
    lea     Knight, a0
    move.l  KNIGHT_YPOS(a0),d0
    lsr.l   #$8, d0
    lsr.l   #$8, d0
    move.l  d0,-(sp)
    move.l  KNIGHT_XPOS(a0),d0
    lsr.l   #$8,d0
    lsr.l   #$8,d0
    move.l  d0,-(sp)
    
    move.l  #EASEL_H,-(sp)
    move.l  #EASEL_W,-(sp)
    move.l  #EASEL_Y,-(sp)
    move.l  #EASEL_X,-(sp)
    
    jsr     collide
    add.l   #$20, sp
    
    cmp.w   #0, d7 
    beq     checkEaselFalse ;if didn't collide w player, return

* collided w/ player and amnt enemies == 0, game is over
    move.w      #GAME_WON, GameState
    rts
    
* we end up here if a necessary condition for the easel to be ready and game to be won is false
checkEaselFalse 
    rts


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
