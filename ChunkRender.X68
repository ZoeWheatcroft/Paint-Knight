*-----------------------------------------------------------
* Title      : Bitmap Subroutine
* Written by : Zoe Wheatcroft
* Date       : 6/1/2023
* Description:

* Renders bitmap from bottom up, using the top left as 0,0
* Pure white is noted as transparent
*-----------------------------------------------------------

* Put program code here




; init
* bit map details:
* 0A - Starting address of bitmap image data (long)
* 12 - bitmap width (long)
* 16 - bitmap height (long)
* 1C - bits per pixel, color depth

   
* Display Chunk - displays a chunk of a bmp file, renders bottom up, (0,0) is top left
* If it reads 00FFFFFF (pure white) it will write the pixel as transparent
* parameters:
* a1- pointer
* 2- top left corner (x, y) you want to display 
* 3- width of the chunk
* 4- height of the chunk
* 5- top left corner (x,y) on the output screen to display chunk
* 6- 32 bit or 24 bit 
displayChunk
    movem.l D_REGS,-(sp) ; put everything on the stack
    ;add.l   #32, sp
    add.l   #36, sp ; add an offset of the d regs + pc counter
    move.w  (sp),d6 ; bit color size
    clr.l   d5
    move.l  4(sp),d5 ; where to display chunk on screen
    move.l  8(sp),d4 ; chunk height
    move.l  12(sp),d3 ; chunk width
    move.l  16(sp),d2 ; starting coordinate of chunk
    move.l  20(sp),a0 ; pointer to chunk

    ; change chunk pointer to pixel data
    move.l  $A(a0),d7
    move.l  a0, a1
    ; put pixel address in big endian 
    swap    d7
    ror.l   #$08,d7 ; d7 = pixel data offset
    adda.l  d7, a1
    ; moving sp back
    sub.l  #36, sp
    
    * set color flag
    ; put color size into little end
    ror.w   #$8, d6
    ; set d6 to be color flag
    ; 0 - 24 bit color
    ; 2 - 32 bit color
    cmpi.w  #32, d6
    beq     displayChunk32
    clr     d6
    move.b  #3, d6 ; will later be used for multiplication based on byte size of color
    bra     aroundSetFlag32bit
setFlag32bit
    clr     d6
    move.b  #4, d6
aroundSetFlag32bit
    
    
    * increase color pointer based on starting point
    ; do the y increase
    clr.l   d1
    add.w   d2,d1 ; d1 = y start
    add.w   d4,d1
    move.l  $16(a0),d7 ; d7 = bmp h
    jsr     littleToBigEnd
    sub.l   d1, d7 ; d7 = bmp h - (y start + chunk h)
    move.l  d7, d1
    
    move.l  $12(a0),d7 ; d7 = bmp w 
    jsr     littleToBigEnd
    exg     d1, d6
    jsr     multiply ; d7 = bmp w * y start
    exg     d1, d6
    jsr multiply  ; d7 = bmp w * y start * 3|4
    adda.l  d7, a1
    
    
    
    ; do the x increase
    clr.l     d7
    move.l  d7, a6
    swap    d2 ; put x into lower word
    move.w  d2, d7 ; d7 = chunk start x  
    jsr     multiply
    adda.l  d7, a1
    ;PICK UP HERE, FINISH X AND Y INCREASE AND MULTIPLY FUNC
    
    ; break d5 into x and y register
    move.w  d5, d2
    add.l   d4, d2
    swap    d5
    move.w  d5, d1 ; d5 will hold the x reset value
    swap    d5
    move.w  d1, d5
    subi.l  #1, d3 ; compensate for dbra
    subi.l  #1, d4
    
displayChunkRow
   ; move.w  d1, d5 ; temp store d1 in d4 so d1 can be used for color
    * set the pen color
    ; select processing based on color size and index
    cmpi.b  #4, d6
    beq     get32bColor
    
get24bColor
    move.b  (a1)+,d1
    lsl.w   #$8, d1
    move.b  (a1)+,d1
    lsl.l   #$8, d1
    move.b  (a1)+,d1
    
    andi.l  #$00FFFFFF, d1
    bra     setPenColor
get32bColor
    move.l  (a1)+,d1
    lsr.l   #$8, d1
    cmpi.l  #$00FFFFFF, d1
    beq     increaseChunkRow ; skip the draw if alpha

setPenColor
    move.b  #SET_PEN_COLOR, d0
    trap    #15

    ; d5 = x y pos
    ; d3 = num x loops
    ; d4 = num y loops
    move.w  d5, d1 ; undo temp storage
    move.b  #DRAW_PIXEL, d0
    trap    #15
    ; drew pixel
increaseChunkRow
    ; increment x 
    addi.w  #1, d5
    dbra    d3, displayChunkRow
    
    ; done with row, reset row vars and increment y stuff
    subi.w  #1, d2 ; increase y pos
    swap    d5
    move.w  d5, d1 ; reset x pos
    swap    d5
    move.w  d1, d5
    move.l  48(sp),d3 ; reset x loops to chunk width
    ; increase color pointer by bmp width - chunk width
    move.l  $12(a0),d7 ; d7 = bmp width
    jsr     littleToBigEnd
    sub.l   d3, d7 ; d7 = bmp width - chunk width
    mulu.w  d6, d7 ; d7 = d7 * color byte size
    adda.l  d7, a1
    
    subi.l  #1, d3 ; compensate for dbra offset
    dbra    d4, displayChunkRow
    
    movem.l (sp)+,D_REGS
    rts

displayChunk32

    clr     d6
    move.b  #4, d6
    
    * increase color pointer based on starting point
    ; do the y increase
    clr.l   d1
    add.w   d2,d1 ; d1 = y start
    add.w   d4,d1
    move.l  $16(a0),d7 ; d7 = bmp h
    jsr     littleToBigEnd
    sub.l   d1, d7 ; d7 = bmp h - (y start + chunk h)
    move.l  d7, d1
    
    move.l  $12(a0),d7 ; d7 = bmp w 
    jsr     littleToBigEnd
    exg     d1, d6
    jsr     multiply ; d7 = bmp w * y start
    exg     d1, d6
    jsr multiply  ; d7 = bmp w * y start * 3|4
    adda.l  d7, a1
    
    ; do the x increase
    clr.l     d7
    move.l  d7, a6
    swap    d2 ; put x into lower word
    move.w  d2, d7 ; d7 = chunk start x  
    jsr     multiply
    adda.l  d7, a1
    ;PICK UP HERE, FINISH X AND Y INCREASE AND MULTIPLY FUNC
    
    ; break d5 into x and y register
    move.w  d5, d2
    add.l   d4, d2
    swap    d5
    move.w  d5, d1 ; d5 will hold the x reset value
    swap    d5
    move.w  d1, d5
    subi.l  #1, d3 ; compensate for dbra
    subi.l  #1, d4
    move.l  #$00ffffff, d6
    move.w  #1,d7
displayChunkRow32
    move.l  (a1)+,d1
    lsr.l   #$8, d1
    cmp.w  d6, d1 ; check if the color is pure white
    beq     increaseChunkRow32 ; skip the draw if alpha

    move.b  #SET_PEN_COLOR, d0
    trap    #15

    ; d5 = x y pos
    ; d3 = num x loops
    ; d4 = num y loops
    move.w  d5, d1 ; undo temp storage
    move.b  #DRAW_PIXEL, d0
    trap    #15
    ; drew pixel
increaseChunkRow32
    ; increment x 
    add.w   d7, d5
    dbra    d3, displayChunkRow32
    
    ; done with row, reset row vars and increment y stuff
    subi.w  #1, d2 ; increase y pos
    swap    d5
    move.w  d5, d1 ; reset x pos
    swap    d5
    move.w  d1, d5
    move.l  48(sp),d3 ; reset x loops to chunk width
    ; increase color pointer by bmp width - chunk width
    move.l  $12(a0),d7 ; d7 = bmp width
    jsr     littleToBigEnd
    sub.l   d3, d7 ; d7 = bmp width - chunk width
    mulu.w  #4, d7 ; d7 = d7 * color byte size
    adda.l  d7, a1
    
    subi.l  #1, d3 ; compensate for dbra offset
    move.w  #1, d7
    dbra    d4, displayChunkRow32
    
    movem.l (sp)+,D_REGS
    rts





















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
