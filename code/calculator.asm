#include "ruledef.asm"
keyboard = 0x01
terminal = 0xfd00

nop                     ;reserved for cal/ret
ldi 0xfe                ;initialise stack pointers
sta 0xffff
sta 0xfeff
jmp start               ;jump to start of program
#addr 0x0100            ;fill rest of 0 page with 0x00


start_msg:
#d "Calc Program\n\n", 0x00
error_msg:
#d "ERROR!\n", 0x00



start:
    ldi lo(start_msg)
    psh
    ldi hi(start_msg)
    psh
    jsr printstring

    

halt:
    jmp halt



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