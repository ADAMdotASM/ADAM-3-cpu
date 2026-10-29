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
#d "Collatz Conjecture\nEnter Hex:\n\n", 0x00
current: #res 2
count: #res 2

start:
    ldi lo(start_msg)
    psh
    ldi hi(start_msg)
    psh
    jsr printstring

    jsr input_handler
    sti "\n" terminal
    pop
    sta current+1
    pop
    sta current

    ldi 0
    sta count
    sta count+1

    loop:
        ;prints header
        lda count+1
        cal printByte
        lda count
        cal printByte
        sti ":" terminal
        sti " " terminal
        inw count
        ;prints current value to term
        lda current+1
        cal printByte
        lda current
        cal printByte
        sti "\n" terminal
        ;checks if a value of one has been reached, if so, resets
        lda current+1
        bnz checkparity
        lda current
        cmi 0x01
        beq end
        ;checks if current value is odd or even and jumps accordinly
        checkparity:
        lda current
        ani 0x01
        beq dividiebytwo

        times3plus1:
            ;copies current value into a temp space
            lda current
            sta .temp
            lda current+1
            sta .temp+1
            ;multiplies current value by two
            lda current
            lsh
            sta current
            lda current+1
            rol
            sta current+1
            ;adds the stored original to make it times 3
            lda current
            add .temp
            sta current
            lda current+1
            adc .temp+1
            sta current+1
            ;adds one
            inw current
            jmp loop
            .temp: #res 2
        dividiebytwo:
            lda current+1
            rsh
            sta current+1
            lda current
            ror
            sta current
            jmp loop


end:
    sti "\n" terminal
    jmp start

input_handler:
    .first:
        din keyboard
        biz .first
        psh
        sta terminal
    .second:
        din keyboard
        biz .second
        psh
        sta terminal
    .third:
        din keyboard
        biz .third
        psh
        sta terminal
    .fourth:
        din keyboard
        biz .fourth
        psh
        sta terminal
    .wait:
        din keyboard
        cmi 0x0a
        bne .wait
        sti "\n" terminal
    jsr text2word
    ret

text2word:
    pop
    cal ascii2hex
    sta .temp1
    pop
    cal ascii2hex
    lsh
    lsh
    lsh
    lsh
    ora .temp1
    sta .temp1

    pop
    cal ascii2hex
    sta .temp2
    pop
    cal ascii2hex
    lsh
    lsh
    lsh
    lsh
    ora .temp2
    sta .temp2

    lda .temp1
    psh
    lda .temp2
    psh
    ret
    

    .temp1: #res 1
    .temp2: #res 1

ascii2hex:
    cmi 0x3a
    blt .number
    adi -39
    .number:
    adi -48
    ret

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