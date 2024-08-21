*-----------------------------------------------------------
* Title      : BackgroundRenderer
* Written by : Zoe Wheatcroft
* Date       : 6/16/2023
* Description: Renders the hills and the sky
*               The sky is continually updating, so there is an update background func
*               The sky render works by drawing a rectangle to the top of the hills using graphics
*               and then filling in the cracks and crevices by going downwards until it encounters non sky colors 
*-----------------------------------------------------------

initBackground
    ; get the bit map we're rendering 
    lea     Hills, a1
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
    
    move.w  #SKY_R_START, SkyColorR
    move.w  #SKY_G_START, SkyColorG
    move.w  #SKY_B_START, SkyColorB    
    jsr     drawSkyInit
    
* Initialize sun 
    move.l  #SUN_COLOR, d1
    move.b  #SET_PEN_COLOR, d0
    trap    #15

    move.b  #SET_FILL_COLOR,d0
    trap    #15
    
    clr.l   d1
    clr.l   d7
    move.b  #DRAW_CIRCLE,d0
    move.w  #SUN_SIZE, d6
    move.w  #SCREEN_WIDTH,d1
    lsr.l   #$1, d1 ; d1 = x, halfway point
    move.w  d6, d7
    lsr.l   #$1, d7 
    sub.l   d7, d1 ; d1 = x - sun_w/2
    
    move.w  d1, d3
    add.l   #SUN_SIZE, d3 ; d3 = right edge 
    
    ; calculate y pos
    move.l  #0, SunYPos
    move.l  SunYPos, d2
    move.w  d2, d4
    addi.w  #SUN_SIZE,d4
    trap    #15
    
    rts

    
updateBackground
    ; draw and update the sky 
    jsr     drawSky
    jsr     updateSun
    rts


updateSun
    jsr     drawSun
    jsr     checkSunset ; is it sunset?
    rts
    
checkSunset
    move.l  SunYPos, d0
    swap    d0
    cmpi.w  #HILLTOP_BOT, d0
    beq     sunsetEndGame
    rts
sunsetEndGame
    move.w  #SUNSET_LOST, GameState
    rts

drawSun
    ; draw the sun  
    move.l  #SUN_COLOR, d1
    move.b  #SET_PEN_COLOR, d0
    trap    #15

    move.b  #SET_FILL_COLOR,d0
    trap    #15
    
    clr.l   d1
    clr.l   d7
    move.b  #DRAW_CIRCLE,d0
    move.w  #SUN_SIZE, d6
    move.w  #SCREEN_WIDTH-1,d1
    lsr.l   #$1, d1 ; d1 = x, halfway point
    move.w  d6, d7
    lsr.l   #$1, d7 
    sub.l   d7, d1 ; d1 = x - sun_w/2
    
    move.w  d1, d3
    add.l   #SUN_SIZE, d3 ; d3 = right edge 
    
    ; calculate y pos 
    move.l  SunYPos, d2
    move.l  DeltaTime, d5 
    mulu.w  #SUN_SPEED, d5
    add.l   d5, d2 
    move.l  d2, SunYPos
    swap    d2
    move.w  d2, d4
    addi.w  #SUN_SIZE,d4
    
    trap    #15
    
   
    ; add the hills on top
        ; start by invaling 
    lea     Hills, a1
    move.l  a1, -(sp)
    ; starting top left corner of chunk
    clr.l   d1
    move.w  #SCREEN_WIDTH-1,d1
    subi.l   #SUN_SIZE,d1 ; d1 = x - sun_w
    lsr.l   #$1, d1 ; d1 = x/2,halfway point
    
    move.w  d1, d0 ; x
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.l  SunYPos, d1
    swap    d1
    subi.w  #1, d1
    move.w  d1, d0 ; y

    move.l  d0, -(sp)
    
    ; set the width and height of what we want to render
    move.l  #SUN_SIZE+1,-(sp) ; d3 = width of chunk
    move.l  #SUN_SIZE+1,-(sp) ; d4 = chunk height
    
    clr.l   d1
    move.w  #SCREEN_WIDTH-1,d1
    subi.l   #SUN_SIZE,d1 ; d1 = x - sun_w
    lsr.l   #$1, d1 ; d1 = x/2,halfway point
    
    move.w  d1, d0 ; x
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.l  SunYPos, d1
    swap    d1
    subi.w  #1, d1
    move.w  d1, d0 ; y
    move.l  d0, -(sp)
    move.l  $1c(a1),-(sp) ; d6 = 32/24 bit color

    jsr     displayChunk
    add.l   #24, sp
    
    rts
    
drawSkyInit
    move.w  SkyColorB, d1
    cmpi.w  #$00C1, d1 ; magic number, replace 
    bgt     gIncrement
    subi.w  #SKY_CHANGER, d1
    move.w  d1, SkyColorB

gIncrementInit
    lsl.l   #$8, d1 
    move.w  SkyColorG, d1
    cmpi.w  #$0061, d1
    bgt     rIncrement
    subi.w  #SKY_CHANGEG, d1
    move.w  d1, SkyColorG

rIncrementInit
    lsl.l   #$8, d1 
    move.w  SkyColorR, d1
    cmpi.w  #$FF9F, d1
    bgt     skyPenColor
    add.w   #SKY_CHANGEB, d1
    move.w  d1, SkyColorR

skyPenColorInit
    lsr.l   #$8, d1 
    move.l  LastSkyColor, d7
    move.l  d1, LastSkyColor
    move.b  #SET_PEN_COLOR,d0
    trap    #15
    move.b  #SET_FILL_COLOR,d0
    trap    #15
    
    ; draw the rect down to the top edge of the hills
    move.w  #0, d1 ;LX
    move.w  #0, d2 ;UY
    move.w  #SCREEN_WIDTH, d3 ; RX
    move.w  #HILLTOP_TOP+1, d4 ;BY
    move.b  #DRAW_RECT,d0
    trap    #15
    
    
* in order to fill in the gap between the bottom of the sky and top of the hill,
* we're going to store the location of the hill edge and then draw a line from the box to the edge
* this means that on subsequent runs, we just get the hill edge from memory and draw the line
* instead of spending time searching for the edge
* This reduces the time from ~20*640 to 1*640 on subsequent runs
    lea     SkyEdgeLocation, a1 ; prepare address so we can add the loc for top of hill in
    move.l  #0, d1 ; d1 = x pos
    move.l  #SCREEN_WIDTH, d5 ; d4 = x loops
    move.l  #0, d7 ; we're checking for black (no black = hill start)
findSkyEdgeXloop
    move.l  #HILLTOP_TOP+2, d2 ; d2 = y startpos 
findSkyEdgeYLoop
    move.b  #GET_PIXEL_COLOR, d0
    trap    #15
    
    cmp.l   d0, d7 ; check color @ location == black
    bne     finishYFindEdgeLoop ; if hit hills, done w column
    
    addi.w  #1, d2 ; didnt hit hills, increase y and continue
    bra     findSkyEdgeYLoop
finishYFindEdgeLoop    
    subi.w  #1, d2
    move.w  d2, (a1)+ ; add the new y pos to the data and increase the pointer
    ; draw the line 
* Now that we know where the top edge of the hills is, we draw a line from the box down to the top edge
* to fill in the gap. 
* Draw line where X1 = D1.W, Y1 = D2.W, X2 = D3.W, Y2 = D4.W
    move.w  d1, d3 ; x will be the same, make x2 = x1
    move.w  #HILLTOP_TOP+2, d4 ; d4 = start y 
    ; drawing line from (d1, d2), hill edge, to (d3, d4), box edge
    move.b  #DRAW_LINE, d0
    trap    #15

    ; finished column, incrememnt x vars
    addi.w  #1, d1
    
    dbra    d5, findSkyEdgeXloop

    
    rts
    
    
drawSky
    move.w  SkyColorB, d1
    cmpi.w  #$00C1, d1 ; magic number, fix
    bgt     gIncrement
    subi.w  #SKY_CHANGER, d1
    move.w  d1, SkyColorB

gIncrement
    lsl.l   #$8, d1 
    move.w  SkyColorG, d1
    cmpi.w  #$0061, d1
    bgt     rIncrement
    subi.w  #SKY_CHANGEG, d1
    move.w  d1, SkyColorG


rIncrement
    lsl.l   #$8, d1 
    move.w  SkyColorR, d1
    cmpi.w  #$FF9F, d1
    bgt     skyPenColor
    add.w   #SKY_CHANGEB, d1
    move.w  d1, SkyColorR



skyPenColor
    lsr.l   #$8, d1 
    move.l  LastSkyColor, d7
    move.l  d1, LastSkyColor
    move.b  #SET_PEN_COLOR,d0
    trap    #15
    move.b  #SET_FILL_COLOR,d0
    trap    #15
* the bulk of the sky is just a rectangle above the hills, we can draw that by just making a large box
* that goes down the top of the hills 
    ; draw the rect
    move.w  #0, d1 ;LX
    move.w  #0, d2 ;UY
    move.w  #640, d3 ; RX
    move.w  #HILLTOP_TOP+1, d4 ;BY
    move.b  #DRAW_RECT,d0
    trap    #15
    
    
* fill in the hill crevices by looping through each column of pixels
* the edge of the hill is stored in memory, we'll retrieve each y pos and draw a line from 
* the bottom of the box to the top of the hill

    move.l  #0, d1 ; d1 = x pos
    move.b  #DRAW_LINE,d0
    move.l  #SCREEN_WIDTH, d5 ; d4 = x loops
    lea     SkyEdgeLocation, a1
    move.l  #HILLTOP_TOP+2, d2 ; d2 = y startpos, y1
skyFillInXLoop
    
    move.w  (a1)+, d4 ; bottom y pos, y2
    move.w  d1, d3 ; x2 = x1
    
    trap    #15

    ; finished column, reset y vars and incrememnt x vars
    addi.w  #1, d1
    
    dbra    d5, skyFillInXLoop
    
    move.l  #0, a1
    
    rts









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
