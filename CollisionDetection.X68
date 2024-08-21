*-----------------------------------------------------------
* Title      : CollisionDetection
* Written by : Zoe Wheatcroft
* Date       : 6/20/23
* Description: General collision detection, used for sword/enemy and player/easel
*----------------------------------------------------------


* between obj1 and obj2, obj 1 should always be smaller
* parameters are: x1, y1, w1, h1
*                 x2, y2, w2, h2
* returns 1 on collision
* returns 0 on no collision
collide
    movem.l D_REGS,-(sp)
    add.l   #36, sp
    
    ; get all the variables from the stack
    move.l  (sp),d0 ; x1
    move.l  4(sp),d1 ; y1
    move.l  8(sp),d2 ; w1
    move.l  12(sp),d3 ; h1
    
    move.l  16(sp),d4 ; x2
    move.l  20(sp),d5 ; y2
    move.l  24(sp),d6 ; w2
    move.l  28(sp),d7 ; h2
    sub.l   #36, sp
    
    add.w   d0, d2 ; d2 = right edge 1
    add.w   d1, d3 ; d3 = bottom edge 1
    
    add.w   d4, d6 ; d6 = right edge 2
    add.w   d5, d7 ; d7 = bottom edge 2
    
* check for overlap on the y edge 
collideYAxisTop
    ; check if top edge is between other top and bottom
    ; start by checking if y1 > y2, top 1 is under top 2
    cmp.w   d5, d1
    blt     collideYAxisBottom
    ; next check that y1 < b2 (bottom of obj 2), top 1 is above bottom 2
    cmp.w   d7, d1
    bgt     collideYAxisBottom
    bra     collideXAxisLeft

collideYAxisBottom
    ; check if bottom edge is between other top and bottom
    ; start by checking b1 > y2, bottom 1 is under top 2 
    cmp.w   d5, d3
    blt     noCollision
    ; next check that b1 < b2, bottom 1 is above bottom 2
    cmp.w   d7, d3
    bgt     noCollision
    bra     collideXAxisLeft
collideXAxisLeft
    ; check that the left edge is between other left and right
    ; start by checking x1 > x2 
    cmp.w   d4, d0
    blt     collideXAxisRight
    ; next check that x1 < r2
    cmp.w   d6, d0
    bgt     collideXAxisRight
    bra     collision 

collideXAxisRight
    ; check that the right edge is between other left and right
    ; start by checking r1 > x2
    cmp.w   d4, d2
    blt     noCollision
    ; next check that r1 < r2
    cmp.w   d6, d2
    bgt     noCollision
    bra     collision
    
noCollision    
    movem.l (sp)+,D_REGS
    move.l  #0, d7
    rts
collision
    movem.l (sp)+,D_REGS
    move.l  #1, d7
    rts
    
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
