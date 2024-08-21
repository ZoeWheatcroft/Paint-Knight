*-----------------------------------------------------------
* Title      : Loads the title screen
* Written by : Zoe Wheatcroft
* Date       : 6/8/2023
* Description: Controls the title screen and controls for it 
*-----------------------------------------------------------

initTitleScreen

    ; turn off key board echo
    move.b  #ENABLE_ECHO,d0
    move.b  #0, d1 ; disable echo
    trap    #15

    ; get the bit map we're rendering 
    lea     Title, a1
    move.l  a1, -(sp)
    ; starting top left corner of chunk
    move.w  #000, d0 ; x
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  #000, d0 ; y
    move.l  d0, -(sp)
    
    ; set the width and height of what we want to render
    move.l  #SCREEN_WIDTH,-(sp) ; d3 = width of chunk
    move.l  #684,-(sp) ; d4 = chunk height
    
    move.l  #$00000000,-(sp) ; d5 = where to display
    move.l  $1c(a1),-(sp) ; d6 = 32/24 bit color

    jsr     displayChunk
    add.l   #24, sp
    

    
    rts
    
    
getStartKey
    jsr     updateTimeVariables
    move.l  DeltaTime, d0
    move.l  DripTimer, d1
    add.l   d0, d1
    move.l  d1, DripTimer
    cmp.l   d0, d1
    blt     dontDrip
    
    ; drip
    clr.l   d1
    move.l  d1, DripTimer ; reset the drip timer
    
    ; draw black square to cover up last drip
    move.l  $00000000, d1 ; put black into d1
    move.b  #SET_PEN_COLOR, d0
    trap    #15
    move.b  #SET_FILL_COLOR, d0
    trap    #15 ; set fill and pen to black
    move.b  #DRAW_RECT,d0
    move.w  #DRIP_X, d1
    move.w  #DRIP_Y+1,d2
    clr.w   d3
    clr.w   d4
    add.w   #DRIP_W, d3
    add.w   #DRIP_H,d4
    add.w   d1, d3
    add.w   d2, d4
    trap    #15

    move.w  DripSwitch, d0
    cmpi.w  #0, d0
    bne     shortDrip
    
    ; rerender 
    lea     Title2, a1
    move.l  a1, -(sp)
    ; starting top left corner of chunk
    move.w  #DRIP_X, d0 ; x
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  #DRIP_Y, d0 ; y
    move.l  d0, -(sp)
    
    ; set the width and height of what we want to render
    move.l  #DRIP_W,-(sp) ; d3 = width of chunk
    move.l  #DRIP_H,-(sp) ; d4 = chunk height
    
    move.w  #DRIP_X, d0 ; x
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  #DRIP_Y, d0 ; y
    move.l  d0, -(sp)
    move.l  $1c(a1),-(sp) ; d6 = 32/24 bit color

    jsr     displayChunk
    add.l   #24, sp
    move.w  #1, DripSwitch
    move.b  #DRAW_BUFFER, D0
    trap    #15
    bra     dontDrip
    
shortDrip
        lea     Title, a1
    move.l  a1, -(sp)
    ; starting top left corner of chunk
    move.w  #DRIP_X, d0 ; x
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  #DRIP_Y, d0 ; y
    move.l  d0, -(sp)
    
    ; set the width and height of what we want to render
    move.l  #DRIP_W,-(sp) ; d3 = width of chunk
    move.l  #DRIP_H,-(sp) ; d4 = chunk height
    
    move.w  #DRIP_X, d0 ; x
    lsl.l     #$8, d0
    lsl.l     #$8, d0
    move.w  #DRIP_Y, d0 ; y
    move.l  d0, -(sp)
    move.l  $1c(a1),-(sp) ; d6 = 32/24 bit color

    jsr     displayChunk
    add.l   #24, sp
    move.b  #DRAW_BUFFER, D0
    trap    #15
    move.w  #0, DripSwitch
    
dontDrip
    move.b  #READ_CHAR, d0
    trap    #15
    cmpi.b   #101, d1
    bne     GetStartKey
    rts




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
