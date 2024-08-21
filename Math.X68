*-----------------------------------------------------------
* Title      : Math
* Written by : Zoe Wheatcroft
* Date       : 6/5/2023
* Description: Some basic math functions to cover 68k holes
*-----------------------------------------------------------


* d7 = num to multiply
* d6 = how many times
* top num on stack = multiply by + 1 (from dbra)
multiply
    cmpi.l  #0, d6
    beq     return_zero
    move.l  d6,-(sp)
    move.l  #$00000000, a6
    subi.l  #1, d6
mul_loop
    adda.l   d7, a6
    dbra    d6, mul_loop
    move.l  a6, d7
    move.l  (sp)+,d6
    rts
return_zero
    move.l  #0, d7
    rts

; d7 = number to be clamped
; (sp) min number
; 4(sp) max number  
clamp
    move.l  d0, -(sp)
    move.l  8(sp),d0 ; min number
    cmp.l   d0, d7
    ; if d7 < d0(min) then return min in d7
    bgt     clampCompareMax
    move.l  d0, d7
    bra     returnClamp
clampCompareMax
    move.l  12(sp),d0 ; max number
    cmp.l   d0, d7
    ; if d7 > d0(max) then return max in d7
    blt     returnClamp
    move.l  d0, d7
returnClamp
    move.l  (sp)+, d0
    rts
    

* returns big endian translation in d7
* Translate from little to big endian
littleToBigEnd
    ror.w   #$08, d7
    swap    d7
    ror.w   #$08, d7
    rts
    


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
