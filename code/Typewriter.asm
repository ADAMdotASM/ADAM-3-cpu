#include "ruledef.asm"
controller = 0x00
keyboard = 0x01
terminal = 0xfd00
screenx = 0xfd02
screeny = 0xfd03
screendraw = 0xfd04


initialise:
    nop                     ;reserved for cal/ret
    ldi 0xfe                ;initialise stack pointers
    sta 0xffff
    sta 0xfeff
    jmp start               ;jump to start of program
    #addr 0x0100            ;fill rest of 0 page with 0x00

cursorx: #res 1
cursory: #res 1


start:
    sti 0 cursorx
    sti 0 cursory
    jsr clear_screen

    mainloop:

        waitforinput:
            din keyboard
            biz waitforinput
            sta input
        checkforcommands:

        printchar:
            lda cursorx
            psh
            lda cursory
            psh
            lda input
            adi -46
            lsh
            lsh
            lsh
            add .ptr
            sta .temp1
            ldi 0
            adc .ptr+1
            sta .temp2
            lda .temp1
            psh
            lda .temp2
            psh
            jsr drawtile

        inx cursorx
        lda cursorx
        cmi 16
        blt mainloop
        sti 0 cursorx
        inx cursory
        jmp mainloop

        .ptr: #d8 lo(tiledata_dot), hi(tiledata_dot)
        .temp1: #res 1
        .temp2: #res 1

    input: #res 1

halt:
    jmp halt


clear_screen:


    ret

;psh x tile, psh y tile, psh pointer for image data
drawtile:
    pop
    sta .ptr+1
    pop
    sta .ptr
    pop
    lsh
    lsh
    lsh
    sta screeny
    pop
    lsh
    lsh
    lsh
    sta screenx
    sta .xtemp

    ldi 8 
    sta .line_count
    .loop_line:
        ldi 8
        sta .pixel_count
        mov .xtemp screenx
        ldr .ptr
        .loop_pixel:
            lsh
            bnc .white
            sti 1 screendraw
            jmp .next_pixel
        .white:
            sti 0 screendraw
        .next_pixel:
            inx screenx
            dex .pixel_count
            bnz .loop_pixel
        inw .ptr
        inx screeny
        dex .line_count
        bnz .loop_line
    ret
    .ptr: #res 2
    .pixel_count: #res 1
    .line_count: #res 1
    .xtemp: #res 1




tiledata_space: #d8 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
tiledata_dot: #d8 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x18
tiledata_fsl: #d8 0x00, 0x0c, 0x0c, 0x18, 0x18, 0x18, 0x30, 0x30
tiledata_0: #d8 0x00, 0x3c, 0x66, 0x76, 0x6e, 0x66, 0x66, 0x3c
tiledata_1: #d8 0x00, 0x08, 0x18, 0x38, 0x18, 0x18, 0x18, 0x7e
tiledata_2: #d8 0x00, 0x3c, 0x66, 0x66, 0x0e, 0x1c, 0x38, 0x7e
tiledata_3: #d8 0x00, 0x7e, 0x7e, 0x06, 0x3c, 0x06, 0x7e, 0x7e
tiledata_4: #d8 0x00, 0x0e, 0x1e, 0x36, 0x66, 0x7e, 0x06, 0x06
tiledata_5: #d8 0x00, 0x7e, 0x7e, 0x60, 0x7c, 0x06, 0x7e, 0x7c
tiledata_6: #d8 0x00, 0x3c, 0x7c, 0x60, 0x7c, 0x66, 0x66, 0x3c
tiledata_7: #d8 0x00, 0x7e, 0x7e, 0x06, 0x0c, 0x0c, 0x18, 0x18
tiledata_8: #d8 0x00, 0x3c, 0x66, 0x66, 0x3c, 0x66, 0x66, 0x3c
tiledata_9: #d8 0x00, 0x3e, 0x66, 0x66, 0x3e, 0x06, 0x06, 0x06