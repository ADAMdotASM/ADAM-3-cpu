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
#d "Blackjack\nPress Enter\n\n", 0x00


start:
    psi lo(start_msg)
    psi hi(start_msg)
    jsr printstring

    .waitforstart:
        inw prng_seed
        din keyboard
        cmi 0x0a
        bne .waitforstart


    mainloop:
        jsr prng
        cal printByte
        jmp mainloop


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


;store seed into prng_seed, invoke for a random 8bit number
prng:
    lda prng_seed
    prng_loop:
        rol
        sta prng_seed
        lda prng_seed + 1
        rol
        sta prng_seed + 1
        lda prng_seed
        bnc .skip
        ;0x39 is the spigot tap spots
        xri 0x39
        .skip:
        for 8 prng_loop
        sta prng_seed
        ret
    prng_seed: #d8 0x02, 0x05

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