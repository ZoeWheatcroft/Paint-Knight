*-----------------------------------------------------------
* Title      : Enemy 
* Written by : Zoe Wheatcroft
* Date       : 6/8/23
* Description: Class for enemy, manages enemy factors
*-----------------------------------------------------------

updateEnemy
    jsr     enemyPlayerCollide
    jsr     invalEnemy
    rts

* Initialize all of the enemies in the scene -- draw them, set the starting health and put timers at a rand number
initEnemy
    ; get the bit map we're rendering 
    lea     Enemy_bmp, a0
    
    lea     EnemyStart, a1
    lea     EnemyEnd, a2
    adda.l  #$2, a1
    
    move.l  a2, a3 ; figure out the num of enemies 
    suba.l  a1, a3 ; diff in addresses
    move.l  a3, d3
    divs.w  #ENEMY_STRUCT_SIZE, d3 ; get num of enemies 
    move.w  d3, AliveEnemies
    
initEnemyLoop
    move.l  a1, -(sp)
    move.l  a2, -(sp)
    
    move.l  a0, -(sp)
    ; starting top left corner of chunk
    move.w  #000, d0 ; x
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  #000, d0 ; y
    move.l  d0, -(sp)

    ; set the width and height of what we want to render
    move.l  #ENEMY_WIDTH,-(sp) ; d3 = width of chunk
    move.l  #ENEMY_HEIGHT,-(sp) ; d4 = chunk height

    move.w  ENEMY_X(a1),d0
    move.w  ENEMY_Y(a1),d1
    swap    d0
    move.w  d1, d0
    move.l  d0, -(sp) ; where to draw it
    move.l  $1c(a0),-(sp) ; d6 = 32/24 bit color
    jsr     displayChunk
    add.l   #24, sp
    
    move.l  (sp)+,a2
    move.l  (sp)+,a1
    
    move.w  #ENEMY_START_HP, ENEMY_HP(a1)
    
    ; start the state timer at a random number 
    jsr     getRandomLongIntoD6
    
    swap    d6 ; clear the upper word
    move.w  #0, d6
    swap    d6
    
    move.w  #ENEMY_STATE_INTERVAL, d5
    divs.w  d5, d6 ; mod for enemy state interval to get it in range
    swap    d6 ; put the remainder in the lw 
    
    swap    d6 ; clear the upper word
    move.w  #0, d6
    swap    d6
    
    move.w  d6, ENEMY_STATE_TIMER(a1)
    
    add.l   #ENEMY_STRUCT_SIZE, a1
    cmp.l   a1, a2
    bne     initEnemyLoop
    
finishInitEnemy
    
    move.l  #0, EnemyToRedraw
    
    rts
    
* should rename, this is moreso the enemy state management system 
* also deals w/ calling animation updates when necessary 
invalEnemy
    move.l  DeltaTime, d6
    
    lea     EnemyStart, a1
    adda.l  #$2, a1
    lea     EnemyEnd, a2
    
invalEnemyLoop
    * check if hp == 0 but enemy is registered as dead
    *skip if enemy is dead
    move.w  ENEMY_HP(a1),d1 ; get curr enemy hp
    cmpi.b  #0, d1
    bne     checkEnemyHurt
    ; now we know that the enemy is dead, check fresh or old
    move.w  ENEMY_STATE(a1),d1
    cmpi.b  #ENEMY_DEAD, d1 ; is enemy noted as dead?
    bne     killEnemy              ; if enemy is not noted as dead, update and redraw enemy 
    beq     continueInvalEnemyLoop ; if enemy is noted as dead, skip state update etc
checkEnemyHurt
    move.w  ENEMY_STATE_TIMER(a1),d5
    move.w  ENEMY_STATE(a1),d1
* Doing check here to see if enemy was forced into hurt state and needs to redraw
* If so, enemy state timer would be 0 and state = hurt
    cmpi.b  #ENEMY_HURT, d1
    bne     increaseEnemyStateTimer
    cmpi.w  #0, d5
    bne     increaseEnemyStateTimer
    bra     enterEnemyHurtState
increaseEnemyStateTimer
    move.w  ENEMY_STATE(a1),d1
    move.w  ENEMY_STATE_TIMER(a1),d5
    add.w   d6, d5 ; add delta time to the timer 
    move.w  d5, ENEMY_STATE_TIMER(a1)
    cmpi.w  #0, d5 ; overflow check
    blt     updateEnemyState
    cmpi.w  #ENEMY_STATE_INTERVAL, d5 ; check if timer is done and state should change
    blt     continueInvalEnemyLoop
updateEnemyState
    ; timer is up, update the state
    clr.w   d5
    move.w  d5, ENEMY_STATE_TIMER(a1) ; reset the state timer
    move.w  ENEMY_STATE(a1),d1
    cmpi.w  #ENEMY_ATTACK, d1
    beq     updateEnemyStateIdle ; if enemy is attacking, switch to idle
    ; switch from idle/hurt to attacking
    move.w  #ENEMY_ATTACK, d1
    move.w  d1, ENEMY_STATE(a1)
    bra     updateEnemySprite
    
* transfer the enemy into the hurt state, special case b/c it is forced out of natural progression by sword
enterEnemyHurtState
    ; start the timer at whatever value it needs to start at 
    move.w  #ENEMY_STATE_INTERVAL, d0
    subi.w  #ENEMY_HURT_INTERVAL, d0
    move.w  d0, ENEMY_STATE_TIMER(a1)
    bra     updateEnemySprite
    
* transfer the enemy into dead state, special case b/c it is forced 
killEnemy
    move.w  #ENEMY_DEAD, ENEMY_STATE(a1) ; note enemy as dead
    move.w  AliveEnemies, d0
    subi.w  #1, d0
    move.w  d0, AliveEnemies ; decrease the number of alive enemies
    bra     updateEnemySprite            ; update sprite to be dead
    
updateEnemyStateIdle
    move.w  #ENEMY_IDLE, d1
    move.w  d1, ENEMY_STATE(a1)

updateEnemySprite
    jsr     drawEnemy

continueInvalEnemyLoop
    adda.l  #ENEMY_STRUCT_SIZE, a1
    cmp.l   a1, a2
    bne     invalEnemyLoop

    rts
    
    
* draw the enemy at it's curr state and pos
* a1 should already have the address of enemy to redraw
drawEnemy
    move.l  a1, -(sp)
    
    * INVAL W HILLS
    lea     Hills, a3
    move.l  a3, -(sp)
    ; starting top left corner of chunk
    move.w     ENEMY_X(a1),d0
    move.w     ENEMY_Y(a1),d1
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  d1, d0
    move.l  d0, -(sp)
    
    ; set the width and height of what we want to render
    move.l  #ENEMY_WIDTH,-(sp) ; d3 = width of chunk
    move.l  #ENEMY_HEIGHT,-(sp) ; d4 = chunk height
    
    move.w  ENEMY_X(a1),d0 ; x
    move.w  ENEMY_Y(a1),d1 ; y
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  d1, d0
    move.l  d0, -(sp) ; where to draw it
    move.l  $1c(a3),-(sp) ; d6 = 32/24 bit color
    jsr     displayChunk
    add.l   #24, sp
    move.l  (sp),a1
    
    lea     Enemy_bmp, a3
    move.l  a3, -(sp)
    ; calculate the starting x by multiplying state * width
    ; each sprite is evenly spaced and aligns w/ state index
    move.w  ENEMY_STATE(a1),d1
    mulu.w  #ENEMY_WIDTH, d1 
    move.w  d1, d0 ; x
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  #000, d0 ; y
    move.l  d0, -(sp)

    ; set the width and height of what we want to render
    move.l  #ENEMY_WIDTH,-(sp) ; d3 = width of chunk
    move.l  #ENEMY_HEIGHT,-(sp) ; d4 = chunk height

    move.w  ENEMY_X(a1),d0 ; x
    move.w  ENEMY_Y(a1),d1 ; y
    swap    d0
    move.w  d1, d0
    move.l  d0, -(sp) ; where to draw it
    move.l  $1c(a3),-(sp) ; d6 = 32/24 bit color
    jsr     displayChunk
    add.l   #24, sp
    move.l  (sp)+,a1
    rts
    

* returns- a1, address of enemy to re render
*           d7, whether to re render enemy 
enemyPlayerCollide
    lea     EnemyStart, a1
    adda.l  #$2, a1
    lea     EnemyEnd, a2

enemyPlayerCollideLoop
    lea     Knight,a0
    move.l  d2,-(sp) ; put x velocity as parameter
    move.l  a1,-(sp) ; move enemy address on stack
    move.l  KNIGHT_YPOS(a0),-(sp) ; move knight y pos on stack
    move.l  KNIGHT_XPOS(a0),-(sp) ; move knight x pos on stack
    
    jsr     enemyCollide ; check for ceiling above
    
    move.l  (sp)+,d2
    move.l  (sp)+,d3
    add.l   #8, sp ; compensate for address put on sp
    cmp.b   #0, d7 ; did player and enemy collide
    beq     enemyPlayerCollision ; leave loop if collided
    adda.l  #ENEMY_STRUCT_SIZE, a1
    cmp.l   a1, a2 
    bne     enemyPlayerCollideLoop
    bra     noEnemyPlayerCollision
    
enemyPlayerCollision
    move.l  a1, EnemyToRedraw
    move.w  #1, d7 ; set flag so update enemy knows enemy will need to be re rendered 
    move.w  ENEMY_STATE(a1), d0
    cmpi.w  #ENEMY_ATTACK, d0
    bne     returnEnemyPlayerCollide ; the enemy and player collided while enemy was not attacking
    jsr     hurtPlayer
    bra     returnEnemyPlayerCollide
noEnemyPlayerCollision
    clr.l   d7
    move.l  d7, EnemyToRedraw
returnEnemyPlayerCollide
    rts
    
    
hurtPlayer
    lea     Knight,a0
    move.w  KNIGHT_HP(a0),d0
    subi.w  #1, d0
    move.w  d0, KNIGHT_HP(a0)
    rts
    
    
    
    
    
enemyCollide
    movem.l D_REGS,-(sp) ; preserve all registers

    move.l  36(sp),d0 ; d0 is this x/left 
    move.l  40(sp),d1 ; d1 is this y/top
    move.l  44(sp),a1 ; a1 = address of other
    
    swap    d0
    swap    d1 ; put x and y into lower word to cut off floating points
    swap    d6
    
     ; if(this.right >= other.left)
    add.w   #KNIGHT_HB_W, d0 ; d0 = this.right
    move.w  ENEMY_X(a1),d3 ; d3 = other.left
    cmp     d3, d0 ; branch if d0 < d3
    blt     noCollisionFound
    
enemyCollideLeft
    ; if this.left <= other.right
    ; d0 = this.left
    move.w  ENEMY_X(a1),d3 ; d3 = other.left
    move.w  ENEMY_W(a1),d4
    add.w   d4, d3 ; d3 = other.right
    subi.w  #KNIGHT_HB_W, d0 ; d0 = this.left
    cmp.w   d3, d0 
    bgt     noCollisionFound
    
* now we know that there is overlap on either the left or right edge,
* but we need to confirm that the top OR bottom edge is also overlapping
enemyCollideTopOverlap
    ; if this.top >= other.top
        ; if this.top <= other.bottom
    move.w  ENEMY_Y(a1),d3 ; d3 = other.top
    cmp     d3, d1 ; this top >= other.top?
    blt     enemyCollideBottomOverlap
    move.w  ENEMY_H(a1),d4
    add.w   d4, d3
    cmp     d3, d1 ; this top <= other.bottom??
    bgt     enemyCollideBottomOverlap
    bra     collisionFound

enemyCollideBottomOverlap
    ; this.bottom >= other.top
        ; this.bottom <= other.bottom
    move.w  ENEMY_Y(a1),d3 ; d3 = other.top
    lea     Knight, a0
    move.w  d1,d5
    addi.w  #KNIGHT_HEIGHT,d5 ; d5 = this.bottom
    cmp     d3, d5 ; bottom>= top?
    blt     noCollisionFound
    move.w  ENEMY_H(a1),d4
    add.w   d4, d3 ; d3 = other.bottom
    cmp     d3, d5 ; this bottom <= other.bottom??
    bgt     noCollisionFound
    bra     collisionFound
















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
