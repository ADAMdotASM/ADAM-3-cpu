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
#d "RNG Test:\nPress Enter To Start", 0x00
counter: #res 1
counter2: #res 1
pointer: #d8 0x00, 0x05


start:
    ldi lo(start_msg)
    psh
    ldi hi(start_msg)
    psh
    cal printstring
    ;waits for enter and increments seed
    waitloop:
        inw prng_seed
        din keyboard
        cmi 0xa
        bne waitloop

    ;clears array of random numbers to start from 0
    cleararray:
        sti 0 pointer
        sti 16 counter
        ldi 0
        .loop:
            str pointer
            inx pointer
            dex counter
            bnz .loop
        
    ;generates 1024 random numbers and increments counters
    sti 0 counter
    sti 4 counter2
    generateloop:
        jsr prng
        ani 0x0f
        sta pointer
        ldr pointer
        inc
        str pointer

        dex counter
        bnz generateloop
        dex counter2
        bnz generateloop
    
    ;prints out results to term
    sti 16 counter
    sti 0 pointer
    printloop:
        ;print header
        sti "\n" terminal
        lda pointer
            ani 0x0f
            cmi 0x0a
            blt .number
            adi 0x07
        .number:
            adi 0x30
            sta terminal
        sti ":" terminal
        sti " " terminal

        ;print value
        ldr pointer
        cal printByte

        inx pointer
        dex counter
        bnz printloop

    sti "\n" terminal
    sti "\n" terminal
    jmp start

halt:
    jmp halt





;store seed into prng_seed, invoke for a random 8bit number
prng:
    sti 8 prng_count
    lda prng_seed
    .loop:
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
        dex prng_count
        bnz .loop
        sta prng_seed
        ret
    prng_seed: #d8 0x02, 0x05
    prng_count: #res 1

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