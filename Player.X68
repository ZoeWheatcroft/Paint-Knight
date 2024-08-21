*-----------------------------------------------------------
* Title      : Player
* Written by : Zoe Wheatcroft
* Date       : 6/2/2023
* Description:
* Handles all aspects of the player, from physics to rendering 
*-----------------------------------------------------------


initPlayer
    ; get the knight and set the initial pos 
    lea     Knight,a0
    move.l  #KNIGHT_STARTY, d2
    sub.l   #KNIGHT_HEIGHT, d2 ; y pos w/ account for knight height
    move.l  #KNIGHT_WIDTH, d3 
    lsr.w     #$1, d3 ; div d3 by 2?
    move.l  #KNIGHT_STARTX, d4 
    sub.l   d3, d4 ; d4 = x pos w/ account for width
    lsl.l   #$8, d4
    lsl.l   #$8, d4
    move.l  d4, KNIGHT_XPOS(a0)
    lsl.l   #$8, d2
    lsl.l   #$8, d2
    move.l  d2, KNIGHT_YPOS(a0)
    clr.l     d2
    move.l  d2, KNIGHT_XVEL(A0) ; set velocity to 0
    move.l  d2, KNIGHT_YVEL(a0)
    move.w  #KNIGHT_STARTHP, KNIGHT_HP(a0)
    
    ; get the bit map we're rendering 
    lea     Knight_bmp, a1
    move.l  a1, -(sp)
    ; starting top left corner of chunk
    move.w  #000, d0 ; x
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  #000, d0 ; y
    move.l  d0, -(sp)

    ; set the width and height of what we want to render
    move.l  #KNIGHT_WIDTH,-(sp) ; d3 = width of chunk
    move.l  #KNIGHT_HEIGHT,-(sp) ; d4 = chunk height

    move.l  KNIGHT_XPOS(a0),d0 ; x
    move.l  KNIGHT_YPOS(a0),d1 ; y
    lsr.l     #$8, d1
    lsr.l     #$8, d1
    move.w  d1, d0
    move.l  d0, -(sp) ; where to draw it
    move.l  $1c(a1),-(sp) ; d6 = 32/24 bit color
    jsr     displayChunk
    add.l   #24, sp
    
    ; set the state to 0
    lea     Knight, a0
    move.w  #KNIGHT_IDLE, KNIGHT_STATE(a0)
    
    move.w  #0, KnightLastHP
    
    rts
    
    
updatePlayer
    lea     Knight, a0
    move.l  KNIGHT_XPOS(a0),KnightLastXPos
    move.l  KNIGHT_YPOS(a0),KnightLastYPos
    jsr     getPlayerInput
    
    jsr     checkPlayerNeedInval
    cmpi.w  #0, d7
    beq     dontInvalPlayer
    jsr     invalPlayer
dontInvalPlayer
    jsr     invalHealth
    jsr     handlePlayerAttack
    jsr     checkPlayerAlive
    rts
    

checkPlayerNeedInval
    lea     Knight, a0
    move.l  KNIGHT_XPOS(a0),d1
    move.l  KnightLastXPos, d0
    cmp.l   d0, d1
    bne     returnPlayerNeedInval
    move.l  KNIGHT_YPOS(a0),d1
    move.l  KnightLastYPos, d0
    cmp.l   d0, d1
    bne     returnPlayerNeedInval    
    ; x and y are the same, check if enemy collided or state changed
    move.l  EnemyToRedraw, d0
    cmpi.w  #0, d0
    bne     returnPlayerNeedInval
    move.w  KnightLastState, d0
    move.w  KNIGHT_STATE(a0),d1
    cmp.l   d0, d1
    bne     returnPlayerNeedInval
    
returnPlayerNeedInval
    move.w  d1, KnightLastState
    move.w  #1, d7
    rts
returnPlayerNoInval
    move.w  #0, d7
    rts

* check if the player is alive and update the gamestate if so    
checkPlayerAlive
    lea     Knight, a0
    move.w  KNIGHT_HP(a0),d0
    cmp.w   #0, d0
    beq     killPlayer
    move.l  KNIGHT_YPOS(a0),d0 ; check if the player fell off, L, ratio, etc
    swap    d0
    cmpi.w  #SCREEN_HEIGHT,d0
    bgt     killPlayer
    rts
killPlayer
    move.w  #PLAYER_LOST, GameState
    rts

invalHealth 
    lea  KnightLastHP, a2
    move.w  (a2),d0
    lea     Knight, a0
    move.w  KNIGHT_HP(a0),d7
    cmp.w   d0, d7
    beq     invalHealthReturn

    move.w  #HEART_START_X, d5
    move.w  #KNIGHT_STARTHP, d6
    subi.w  #1, d6 ; compensate for dbra

invalHealthLoop
    cmp     d7, d6 ; check if this heart should be full
    bge     invalHealthEmpty
    * Draw a full heart
    lea     Heart, a1
    move.l  a1, -(sp)
    ; starting top left corner of chunk
    move.w  #000, d0 ; x
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  #000, d0 ; y
    move.l  d0, -(sp)

    ; set the width and height of what we want to render
    move.l  #HEART_WIDTH,-(sp) ; d3 = width of chunk
    move.l  #HEART_HEIGHT,-(sp) ; d4 = chunk height

    move.l  d5,d0 ; x
    move.l  #HEART_START_Y,d1 ; y
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  d1, d0
    move.l  d0, -(sp) ; where to draw it
    move.l  $1c(a1),-(sp) ; d6 = 32/24 bit color
    jsr     displayChunk
    add.l   #24, sp
    bra     invalHealthLoopIncrement
invalHealthEmpty
    lea     Heart, a1
    move.l  a1, -(sp)
    ; starting top left corner of chunk
    move.w  #HEART_WIDTH, d0 ; x
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  #000, d0 ; y
    move.l  d0, -(sp)

    ; set the width and height of what we want to render
    move.l  #HEART_WIDTH,-(sp) ; d3 = width of chunk
    move.l  #HEART_HEIGHT,-(sp) ; d4 = chunk height

    move.l  d5,d0 ; x
    move.l  #HEART_START_Y,d1 ; y
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  d1, d0
    move.l  d0, -(sp) ; where to draw it
    move.l  $1c(a1),-(sp) ; d6 = 32/24 bit color
    jsr     displayChunk
    add.l   #24, sp

invalHealthLoopIncrement
    addi.w   #HEART_SPACING, d5   
    dbra    d6, invalHealthLoop
invalHealthReturn
    lea     Knight,a0
    move.w  KNIGHT_HP(a0),d0
    move.w  d0,(a2)
    rts
    
invalPlayer
    lea     Hills, a1
    move.l  a1, -(sp)
    ; starting top left corner of chunk
    move.l     KnightLastXPos, d0
    move.l     KnightLastYPos, d1
    lsr.l     #$8, d1
    lsr.l     #$8, d1
    move.w  d1, d0
    move.l  d0, -(sp)
    
    ; set the width and height of what we want to render
    move.l  #KNIGHT_WIDTH,-(sp) ; d3 = width of chunk
    move.l  #KNIGHT_HEIGHT,-(sp) ; d4 = chunk height
    
    lea     KnightLastXPos, a0
    lea     KnightLastYPos, a2
    move.l  (a0),d0 ; x
    move.l  (a2),d1 ; y
    lsr.l     #$8, d1
    lsr.l     #$8, d1
    move.w  d1, d0
    move.l  d0, -(sp) ; where to draw it
    move.l  $1c(a1),-(sp) ; d6 = 32/24 bit color
    jsr     displayChunk
    add.l   #24, sp
    
    move.l  EnemyToRedraw, d0
    cmpi.l  #0, d0 ; is enemy to redraw null
    beq     drawPlayer ; if enemy == null, dont draw
invalPlayerEnemy
    move.l  d0, a0
    lea     Enemy_bmp, a1
    move.l  a1, -(sp)
    ; starting top left corner of chunk
    move.w      ENEMY_STATE(a0),d0
    mulu.w      #ENEMY_WIDTH, d0
    move.w     #0,d1 ; y
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  d1, d0
    move.l  d0, -(sp)
    
    ; set the width and height of what we want to render
    move.l  #ENEMY_WIDTH,-(sp) ; d3 = width of chunk
    move.l  #ENEMY_HEIGHT,-(sp) ; d4 = chunk height
    
    move.l  ENEMY_X(a0),d0 ; x
    move.l  ENEMY_Y(a0),d1 ; y
    lsr.l     #$8, d1
    lsr.l     #$8, d1
    move.w  d1, d0
    move.l  d0, -(sp) ; where to draw it
    move.l  $1c(a1),-(sp) ; d6 = 32/24 bit color
    jsr     displayChunk
    add.l   #24, sp
    
drawPlayer
    ; get the bit map we're rendering 
    lea     Knight_bmp, a1
    lea     Knight,a0
    move.l  a1, -(sp)
    ; starting top left corner of chunk
    move.w  KNIGHT_STATE(a0),d1
    mulu.w  #KNIGHT_WIDTH, d1
    move.w  d1, d0 ; x
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  #000, d0 ; y
    move.l  d0, -(sp)
    
    ; set the width and height of what we want to render
    move.l  #KNIGHT_WIDTH,-(sp) ; d3 = width of chunk
    move.l  #KNIGHT_HEIGHT,-(sp) ; d4 = chunk height
    
    move.l  KNIGHT_XPOS(a0),d0 ; x
    move.l  KNIGHT_YPOS(a0),d1 ; y
    lsr.l     #$8, d1
    lsr.l     #$8, d1
    move.w  d1, d0
    move.l  d0, -(sp) ; where to draw it
    move.l  $1c(a1),-(sp) ; d6 = 32/24 bit color
    jsr     displayChunk
    add.l   #24, sp
    rts
    

* Because it uses entirely different input than movement and functions vastly differently, 
* player attack has its own method to handle the input, collisions and resizing involved
handlePlayerAttack
    lea     Knight, a0
    clr.l   d0
    move.w  KNIGHT_STATE(a0),d0
    lsl.w   #2, d0 ; multiply by 4 so we can use the virtual table
    lea     KnightAttackFunctionTable, a1
    move.l  (a1,d0),a2
    jsr     (a2)
    rts
    
    
idlePlayerAttack
    move.b  #GET_MOUSE, d0
    move.b  #READ_MOUSE_DOWN, d1
    trap    #15
    
    btst.l  #0, d0
    beq     idlePlayerAttackReturn
    
    move.w  #KNIGHT_ATTACK1, KNIGHT_STATE(a0)
    move.w  #1, KnightAttacking
idlePlayerAttackReturn
    rts
advancingPlayerAttack
    move.w  #KNIGHT_ATTACK2, KNIGHT_STATE(a0)
    jsr     swordAttack
    rts
performingPlayerAttack
    move.w  #KNIGHT_IDLE, KNIGHT_STATE(a0)
    move.w  #0, KnightAttacking
    jsr     swordAttack
    rts
    
swordAttack
    lea     Knight, a0
    lea     EnemyStart, a1
    adda.l  #$2, a1
    lea     EnemyEnd, a2
    
swordAttackLoop
    * put enemy dimension and position on stack
    move.w  ENEMY_H(a1),d0 ; h2
    move.l  d0,-(sp)  
    move.w  ENEMY_W(a1),d0 ; w2
    move.l  d0,-(sp)  
    move.w  ENEMY_Y(a1),d0 ; y2
    move.l  d0,-(sp)  
    move.w  ENEMY_X(a1),d0 ; x2
    move.l  d0,-(sp)  
    * put sword dimension and position on stack
    move.l  #KNIGHT_SWORD_H,-(sp) ; h1
    move.l  #KNIGHT_SWORD_W,-(sp) ; w1
    move.l  KNIGHT_YPOS(a0),d0
    swap    d0
    addi.w  #KNIGHT_SWORD_Y,d0
    move.l  d0,-(sp) ; y1
    move.l  KNIGHT_XPOS(a0),d0
    swap    d0
    addi.w  #KNIGHT_SWORD_X,d0
    move.l  d0,-(sp) ; x1
    
    jsr     collide
    add.l   #$20,sp
    
    cmpi.b  #0, d7
    beq     continueSwordAttackLoop
    move.w  ENEMY_HP(a1),d0
    cmpi.b  #0, d0
    beq     continueSwordAttackLoop  ; enemy is dead, do not hurt
    subi.w  #1, d0
    move.w  d0, ENEMY_HP(a1)
    move.w  #ENEMY_HURT, ENEMY_STATE(a1)
    move.w  #0, ENEMY_STATE_TIMER(a1)
continueSwordAttackLoop
    add.l   #ENEMY_STRUCT_SIZE, a1
    cmp.l   a1, a2
    bne     swordAttackLoop
     
returnSwordAttack
    rts
    
* get the input that controls the player (movement + attack)
* d7 is the return, it is a flag that indicates if the player moved
* this will be used to tell if the knight needs to be invaled and redone 
getPlayerInput
    lea     Knight,a0


    ; start by updating velocities
    move.b  #GET_4KEYS, d0
    move.l  #'A'<<24+'D'<<16+'W'<<8+'L',D1 ; check for keypress (a,d,w,f)
    trap    #15
    
    
    ; calculate jump velocity
    ; traditionally, we would factor in delta time
    ; however, since this is an instant force jump instead of accel, 
    ; we do not use delta time to keep jumps consistent
    move.l  #KNIGHT_JUMP, d4

    
    ; calculate movement acceleration
    move.l  DeltaTime, d6
    move.l  #KNIGHT_ACCELERATION, d2
    exg     d2, d7
    jsr     multiply ; d2 = accel * time, amount of accel to add
    exg     d2, d7

    
    
    clr.l     d5
    clr.l     d0 ; d0 will act as a flag for if a was pressed
    clr.l     d7 ; flag for if d was pressed
    ; check for a 
    btst.l  #24, d1
    beq     getPlayerInputD
    move.l  KNIGHT_XVEL(a0),d3
    sub.l   d2, d3
    move.l  d3, KNIGHT_XVEL(a0)
    move.b  #1, d5
    move.b  #1, d0
    
getPlayerInputD
    ; check for d 
    btst.l  #16, d1
    beq     handleXVelocityInput
    move.l  KNIGHT_XVEL(a0),d3
    add.l   d2, d3
    move.l  d3, KNIGHT_XVEL(a0)
    move.b  #1, d5
    move.b  #1, d7
    
handleXVelocityInput
* if we got a but the curr vel is positive, switch the sign 
* if we got d but the curr vel is neg, switch the sign
    cmp.b   d0,d7 ; if got both or neither, skip
    beq     getPlayerInputW 
    ; cur x vel is in d3
    cmpi.b  #0, d0
    beq     handleXVelocityInputD ; got d, handle accordingly
    ; got a, velocity should be negative
    cmpi.l  #0, d3
    ; if d3 < 0, branch, nothing to do
    blt     getPlayerInputW
    neg.l     d3
    move.l  d3, KNIGHT_XVEL(a0)
    bra     getPlayerInputW 
    
handleXVelocityInputD
    ; got d, velocity should be pos
    cmpi.l  #0, d3
    bgt     getPlayerInputW ; if already positive, nothing to do
    neg.l     d3
    move.l  d3, KNIGHT_XVEL(a0)
    

getPlayerInputW
    ; check for w 
    clr.b   d0
    btst.l  #8, d1
    beq     addPlayerGravity
    move.w  KnightGrounded, d1
    cmpi.b  #0, d1
    beq     addPlayerGravity ; player can't jump if not grounded
    clr.w   d0
    move.w  d0, KnightGrounded ; set grounded to false
    move.b  #1, d0 ; switch on flag for jump
    clr.l   d0
    move.l  d0, KNIGHT_YVEL(a0) ; clear the y velocity to create a clean and consistent jump
    move.l  KNIGHT_YVEL(a0),d3 ; add the jump to velocity
    sub.l   d4, d3
    move.l  d3, KNIGHT_YVEL(a0)
   ; bra     checkXPlayerInput


addPlayerGravity
    move.l  #GRAVITY_SCALE, d4
    ; because gravity is acceleration, we multiply it by delta time
    exg     d4, d7
    jsr     multiply
    exg     d4, d7
    move.l  KNIGHT_YVEL(a0),d3
    add.l   d4, d3
    move.l  d3, KNIGHT_YVEL(a0)

checkXPlayerInput
    ; use the updated velocities to move the player 
    clr     d7 ; d7 = flag for moved
    ; if no a/d input, set xvel to 0
    cmpi.b  #0, d5
    bne     movePlayerX
    move.l  d5, KNIGHT_XVEL(a0)
    
movePlayerX
    move.l  KNIGHT_XVEL(a0),d1
    
    ; clamp velocity to knight speed 
    exg     d1, d7
    move.l  #KNIGHT_SPEED, -(sp)
    move.l  #-KNIGHT_SPEED, -(sp)
    jsr     clamp
    add.l   #8, sp
    exg     d1, d7
    
    exg     d1, d7
    jsr     multiply
    exg     d1, d7
    
    move.l  KNIGHT_XPOS(a0),d2
    add.l   d1, d2
    

movePlayerY
    move.l  KNIGHT_YVEL(a0),d1
    move.l  DeltaTime, d6
    exg     d1, d7
    jsr     multiply
    exg     d1, d7
    move.l  KNIGHT_YPOS(a0),d3
    add.l   d1, d3
    
checkCollision
    ; prepare to skip ground check if d0 = 1 (pressed jump)
    ; if don't skip ground check, the player detect ground and stop
    cmpi.b  #1, d0 ; was jump pressed?
    beq     playerCeilingCheck ; if yes, skip ground check
    
playerGroundCheck
    lea     BlockStart,a1
    adda.l  #$2, a1
    lea     BlockEnd, a2
    
groundCheckLoop
    move.l  a1,-(sp)
    move.l  d3,-(sp) ; move new y pos on stack
    move.l  d2,-(sp) ; move new x pos on stack
    
    jsr     playerCollideYDown ; check for ground
    
    move.l  (sp)+,d2
    move.l  (sp)+,d3
    add.l   #4, sp ; compensate for address put on sp
    
    cmpi.b  #0, d7 ; 0 = collided, 1 = no collision
    beq     playerIsGrounded ; if collided, leave loop and set vars
    
    ; did not hit ground yet
    adda.l  #BLOCK_DATA_SIZE, a1 ; increase a1 to next block
    cmp     a1, a2 ; is current address at the end? 
    bne     groundCheckLoop ; if address!=end, loop
    
    
    move.w  #0, d0
    move.w  d0, KnightGrounded ; set grounded to 0, false
    bra     playerCeilingCheck ; not grounded, check ceiling 
playerIsGrounded
    move.w  #1, d0 ; set grounded to 1, true
    move.w  d0, KnightGrounded
    clr.l   d0
    ; snap the player to the ground under them
    move.w  2(a1),d0 ; get the top of what was collided with
    ;subi.w  #1,d0 ; subtract one so that we're over it
    subi.w  #KNIGHT_HEIGHT, d0 ; offset by the player height
    swap    d0 ; align it with knight ypos formatting
    move.l  d0, KNIGHT_YPOS(a0) ; snap player to ground
    clr.l   d0
    move.l  d0, KNIGHT_YVEL(a0) ; reset player y vel 
    bra     checkCollisionX ; if grounded, skip check for ceiling
    
playerCeilingCheck
    lea     BlockStart,a1
    adda.l  #$2, a1
    lea     BlockEnd, a2
    
ceilingCheckLoop
    move.l  a1,-(sp)
    move.l  d3,-(sp) ; move new y pos on stack
    move.l  d2,-(sp) ; move new x pos on stack
    
    jsr     playerCollideYUp ; check for ceiling above
    
    move.l  (sp)+,d2
    move.l  (sp)+,d3
    add.l   #4, sp ; compensate for address put on sp
    
    cmpi.b  #0, d7 ; 0 = collided, 1 = no collision
    beq     ceilingCollision ; if collided, leave loop and set vars
    
    ; did not hit ground yet
    adda.l  #BLOCK_DATA_SIZE, a1 ; increase a1 to next block
    cmp     a1, a2 ; is current address at the end? 
    bne     ceilingCheckLoop ; if address!=end, loop

    move.l  d3, KNIGHT_YPOS(a0) ; advance position 
    bra     checkCollisionX

ceilingCollision
    ; yowza we collided
    clr.l   d0
    move.l  d0, KNIGHT_YVEL(a0)
    ; snap to the ceiling
    clr.l   d0 
    move.w  BLOCK_Y(a1),d0
    move.w  BLOCK_H(a1),d1
    add.w   d1, d0 ; bottom edge of the ceiling
    addi.w  #1, d0
    swap    d0 ; d0 = bottom to snap to
    move.l  d0, KNIGHT_YPOS(a0)
    
checkCollisionX
        lea     BlockStart,a1
    adda.l  #$2, a1
    lea     BlockEnd, a2
    
checkCollisionXLoop
    move.l  d2,-(sp) ; put x velocity as parameter
    move.l  a1,-(sp)
    move.l  d3,-(sp) ; move new y pos on stack
    move.l  d2,-(sp) ; move new x pos on stack
    
    jsr     playerCollideX ; check for ceiling above
    
    move.l  (sp)+,d2
    move.l  (sp)+,d3
    add.l   #8, sp ; compensate for address put on sp
    
    cmpi.b  #0, d7 ; 0 = collided, 1 = no collision
    beq     returnGetPlayerInput ; if collided, leave loop and set vars
    
    ; did not hit ground yet
    adda.l  #BLOCK_DATA_SIZE, a1 ; increase a1 to next block
    cmp     a1, a2 ; is current address at the end? 
    bne     checkCollisionXLoop  ; if address!=end, loop
    
    move.l  d2, KNIGHT_XPOS(a0) ; add x vel to pos
    move.b  #1, d7
    
returnGetPlayerInput
    move.b  #1, d7
    rts




* player collision system
* note- the collision system only works for things SMALLER than the player
* Therefore, the player should always be the smallest thing in the 
playerCollideYUp
    movem.l D_REGS,-(sp) ; preserve all registers
    move.l  36(sp),d0 ; d0 is this x/left 
    move.l  40(sp),d1 ; d1 is this y/top
    move.l  44(sp),a1 ; a1 = address of other
    
    swap    d0
    swap    d1 ; put x and y into lower word to cut off floating points

    ; check this.top =< other.bottom
    
    move.w  BLOCK_Y(a1),d3 ; d3 = other top
    move.w  BLOCK_H(a1),d4 ; needed to offset for bottom
    add.w   d4, d3 ; d3 = other.bottom
    cmp.w   d3, d1 ; top =< bottom? 
    bgt     noCollisionFound ; branch if false
    
    ; to prevent something above counting a collision, check we are under the block
    ; check old bottom < block bot
    lea     Knight, a0
    move.l  KNIGHT_YPOS(a0),d4
    swap    d4
    addi.l  #KNIGHT_HEIGHT, d4 ; d4 = knight's bottom edge
    cmp.w     d3, d4 ; old bot > block bot?
    blt     noCollisionFound ; branch if old < black

    bra     gotCollisionY ; check the sides 

* ground check
* parameters:
* 0(sp) -> new x value
* 4(sp) -> new y value
* 8(sp) -> other
* d7 = flag return value 
playerCollideYDown
    movem.l D_REGS,-(sp) ; preserve all registers
    move.l  36(sp),d0 ; d0 is this x/left 
    move.l  40(sp),d1 ; d1 is this y/top
    move.l  44(sp),a1 ; a1 = address of other
    
    swap    d0
    swap    d1 ; put x and y into lower word to cut off floating points

    ; check this.bottom >= other.top
    
    move.w  d1, d2 ; move y into d2 and add height to make it bottom
    addi.w  #KNIGHT_HEIGHT,d2 ; d2 = this.bottom
    move.w  BLOCK_Y(a1),d3 ; d3 = other top
    cmp.w   d2, d3
    bgt     noCollisionFound ; this bottom was above other top, no collision
    
    ; to prevent colliding w/ thing above and phasing through thing underneath,
    ; check old top < block top
    lea     Knight, a0
    move.l  KNIGHT_YPOS(a0),d4
    swap    d4
    cmp.w     d3, d4 
    ; break if old top > block top, means block is just underneath
    bgt     noCollisionFound
    

*at this point, we collided on the y axis but need to check for overlap
gotCollisionY

    ; check if this left is between others
    ; if(this.left>=other.left){
    ;   if(this.left =< other.right){
    ;       bra     collisionFoundY
    ; d0 = this.left
    move.w  BLOCK_X(a1),d2 ; d2 = other.left
    cmp     d2, d0 ; branch if d0 < d2
    blt     checkCollisionYRight
    move.w  BLOCK_W(a1),d3 ; d3 = other.width
    add.w   d2, d3 ; d3 = other.width + other.left = other.right
    cmp     d3, d0 ; branch if d0 > d3
    bgt     checkCollisionYRight
    bra     collisionFound ; left wall was within others

checkCollisionYRight
    ; if(this.right >= other.left){
    ;   if(this.right <= other.right){
    ;       bra collisionFoundY
    add.w   #KNIGHT_HB_W, d0 ; d0 = this.right
    move.w  BLOCK_X(a1),d2 ; d2 = other.left
    cmp.w     d2, d0 ; branch if d0 < d2
    blt     noCollisionFound
    move.w  BLOCK_W(a1),d3 ; d3 = other.width
    add.w   d2, d3 ; d3 = other.width + other.left = other.right
    cmp.w     d3, d0 ; branch if d0 > d3
    bgt     noCollisionFound
    ; found a collision!
    
collisionFound
    movem.l (sp)+,D_REGS
    clr.l   d7
    move.b  #0, d7
    bra     returnPlayerCollide
    
noCollisionFound
    movem.l (sp)+,D_REGS
    move.b  #1, d7
returnPlayerCollide
    rts
    

* side check
* parameters:
* 0(sp) -> new x value
* 4(sp) -> new y value
* 8(sp) -> other address
* 12(sp) -> x velocity
* d7 = flag return value 
playerCollideX
    movem.l D_REGS,-(sp) ; preserve all registers
    move.l  40(sp),d6 ; d6 = x velocity
    move.l  36(sp),d0 ; d0 is this x/left 
    move.l  40(sp),d1 ; d1 is this y/top
    move.l  44(sp),a1 ; a1 = address of other
    
    swap    d0
    swap    d1 ; put x and y into lower word to cut off floating points
    swap    d6

    cmp.w   #0, d6
    blt     playerCollideXLeft 
     ; if(this.right >= other.left)
    add.w   #KNIGHT_HB_W, d0 ; d0 = this.right
    move.w  BLOCK_X(a1),d3 ; d3 = other.left
    cmp     d3, d0 ; branch if d0 < d3
    blt     noCollisionFound
    
playerCollideXLeft
    ; if this.left <= other.right
    ; d0 = this.left
    move.w  BLOCK_X(a1),d3 ; d3 = other.left
    move.w  BLOCK_W(a1),d4
    add.w   d4, d3 ; d3 = other.right
    cmp.w   d3, d0 
    bgt     noCollisionFound
    
* now we know that there is overlap on either the left or right edge,
* but we need to confirm that the top OR bottom edge is also overlapping
playerCollideXCheckTop
    ; if this.top >= other.top
        ; if this.top <= other.bottom
    move.w  BLOCK_Y(a1),d3 ; d3 = other.top
    cmp     d3, d1 ; this top >= other.top?
    blt     playerCollideXCheckTopSmaller
    move.w  BLOCK_H(a1),d4
    add.w   d4, d3
    cmp     d3, d1 ; this top <= other.bottom??
    bgt     playerCollideXCheckTopSmaller
    bra     collisionFound
playerCollideXCheckTopSmaller

playerCollideXCheckBottom
    ; this.bottom >= other.top
        ; this.bottom <= other.bottom
    move.w  BLOCK_Y(a1),d3 ; d3 = other.top
    lea     Knight, a0
    move.w  KNIGHT_HEIGHT(a0),d5
    add.w   d1,d5 ; d5 = this.bottom
    cmp     d3, d5 ; bottom>= top?
    blt     playerCollideXCheckBottomSmaller
    move.w  BLOCK_H(a1),d4
    add.w   d4, d3 ; d3 = other.bottom
    cmp     d3, d1 ; this bottom <= other.bottom??
    bgt     playerCollideXCheckBottomSmaller
    bra     collisionFound
    
playerCollideXCheckBottomSmaller
    bra     noCollisionFound























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
