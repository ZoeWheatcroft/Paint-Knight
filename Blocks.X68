*-----------------------------------------------------------
* Title      : Blocks 
* Written by : Zoe Wheatcroft
* Date       : 6/5/2023
* Description: Data for all the inanimate blocks in the scene
*-----------------------------------------------------------

BLOCK_DATA_SIZE     EQU 8 ; byte size of blocks

BLOCK_X             equ 0 ; when accessing a pointer, these can be used as offsets 
BLOCK_Y             equ 2
BLOCK_W             equ 4
BLOCK_H             equ 6

BlockStart      dc.w    0

Block1          dc.w    $1c4 ; x
                dc.w    $1B7 ; y
                dc.w    $A0 ; width
                dc.w    $16 ; height
                
Block2          dc.w    $11
                dc.w    $194
                dc.w    $A0
                dc.w    $15
                
Block3          dc.w    $F2
                dc.w    $15C
                dc.w    $A5
                dc.w    $14
                
Block4          dc.w    $10C
                dc.w    $239
                dc.w    $B5
                dc.w    $16

Block4Step      dc.w    $18C
                dc.w    $24D
                dc.w    $58
                dc.w    $1A                

Block5          dc.w    $93
                dc.w    $1E5
                dc.w    $75
                dc.w    $18
                
Block6          dc.w    $21D
                dc.w    $25A
                dc.w    $47
                dc.w    $20

Block6Chunk2    dc.w    $21D
                dc.w    $27A
                dc.w    $47
                dc.w    $20

Block6Chunk3    dc.w    $21D
                dc.w    $29A
                dc.w    $47
                dc.w    $20

Block6Chunk4    dc.w    $21D
                dc.w    $2BA
                dc.w    $47
                dc.w    $20
                
Block7          dc.w    $1A4
                dc.w    $2E5
                dc.w    $50
                dc.w    $11
                
Block8          dc.w    $131
                dc.w    $2F5
                dc.w    $50
                dc.w    $11
                
Block9          dc.w    $AF
                dc.w    $301
                dc.w    $50
                dc.w    $11
                
Block10         dc.w    $C
                dc.w    $338
                dc.w    $5D
                dc.w    $F
                
Block11         dc.w    $2E
                dc.w    $37B
                dc.w    $83
                dc.w    $14
                                
Block12         dc.w    $1A1
                dc.w    $37C
                dc.w    $D1
                dc.w    $14


Block13         dc.w    $93
                dc.w    $3CA
                dc.w    $146
                dc.w    $1E
                
Block14         dc.w    $19
                dc.w    $2A7
                dc.w    $75
                dc.w    $16

BlockEnd        dc.w    0                









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
