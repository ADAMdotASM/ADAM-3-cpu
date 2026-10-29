#include "ruledef.asm"
terminal = 0xfd00

nop                     ;reserved for cal/ret
ldi 0xfe                ;initialise stack pointers
sta 0xffff
sta 0xfeff
jmp start               ;jump to start of program

start_msg:
#d "Fibonacci:\n\n", 0x00

start:
    ldi lo(start_msg)
    psh
    ldi hi(start_msg)
    psh
    jsr printstring
    
    fibloop:
        ;print header
        lda count
        cal printByte
        sti ":" terminal
        sti " " terminal

        ;print num
        lda y+7
        cal printByte
        lda y+6
        cal printByte
        lda y+5
        cal printByte
        lda y+4
        cal printByte
        lda y+3
        cal printByte
        lda y+2
        cal printByte
        lda y+1
        cal printByte
        lda y+0
        cal printByte

        ;calculate x + y into z
        lda x+0
        add y+0
        sta z+0

        lda x+1
        adc y+1
        sta z+1

        lda x+2
        adc y+2
        sta z+2

        lda x+3
        adc y+3
        sta z+3

        lda x+4
        adc y+4
        sta z+4

        lda x+5
        adc y+5
        sta z+5

        lda x+6
        adc y+6
        sta z+6

        lda x+7
        adc y+7
        sta z+7

        ;check for overflow and halt
        bic halt

        ;copy y into x
        mov y+0 x+0
        mov y+1 x+1
        mov y+2 x+2
        mov y+3 x+3
        mov y+4 x+4
        mov y+5 x+5
        mov y+6 x+6
        mov y+7 x+7
        ;copy z into y
        mov z+0 y+0
        mov z+1 y+1
        mov z+2 y+2
        mov z+3 y+3
        mov z+4 y+4
        mov z+5 y+5
        mov z+6 y+6
        mov z+7 y+7

        lda count
        inc
        sta count
        jmp fibloop


    x: #d8 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    y: #d8 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    z: #d8 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    count: #d8 0x01

halt:
    jmp halt


;prints Acc to terminal as hex
printByte:
    psh
    psh
    rsh
    rsh
    rsh
    rsh
    cal printHex
    printHex:
        ani 0x0f
        cmi 0x0a
        blt .number
        adi 0x07
    .number:
        adi 0x30
        sta terminal
        pop
        ret

;psh null term pointer, prints
printstring:
    pop
    sta .ptr + 1
    pop
    sta .ptr
    .loop:
        ldr .ptr
        biz .done
        sta terminal
        inw .ptr
        jmp .loop
    .done:
        ret
    .ptr: #res 2