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


;bottom bit of each is fractional
ballposx: #d8 0x20
ballposy: #d8 0x80
ballvelx: #d8 0x3
ballvely: #d8 0x2

playerscore: #d8 0x00
cpuscore: #d8 0x00

start:
    jsr draw_scores
    jsr draw_arena
    jsr drawnet
    mainloop:
        jsr input_handler
        jsr clear_screen
        jsr physics
        jsr drawball

        



        ;check if someone has won the game
        lda playerscore
        cmi 9
        beq halt
        lda cpuscore
        cmi 9
        beq halt
        jmp mainloop

halt:
    jmp halt




draw_arena:
    sti 128 draw_arena_count
    sti 9 screeny
    ldi 1
    .loop:
        mov draw_arena_count screenx
        sta screendraw
        dex draw_arena_count
        bnz .loop
    ret
    draw_arena_count: #res 1


drawnet:
    sti 64 screenx
    sti 9 screeny
    sti 4 drawnet_count1
    sti 15 drawnet_count2

    ldi 1
    drawnet_loop:
        sta screendraw
        inx screeny
        dex drawnet_count1
        bnz drawnet_loop

        sti 4 drawnet_count1
        inx screeny
        inx screeny
        inx screeny
        inx screeny
        dex drawnet_count2
        bnz drawnet_loop
    ret
    drawnet_count1: #res 1
    drawnet_count2: #res 1


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

draw_scores:
    ;draws player score
    ldi 4
    psh
    ldi 0
    psh
    lda playerscore
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

    ;draws cpu score
    ldi 12
    psh
    ldi 0
    psh
    lda cpuscore
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

    ret
    .ptr: #d8 lo(tiledata_0), hi(tiledata_0)
    .temp1: #res 1
    .temp2: #res 1

drawball:
    ;x
    lda ballposx
    rsh
    cmi 64
    beq .done
    sta screenx
    ;y
    lda ballposy
    rsh
    sta screeny
    ;draw ball
    sti 1 screendraw
    .done:
    ret
    
clear_screen:
    ;erase previous ball position
    lda ballposx
    rsh
    cmi 64
    beq .done
    sta screenx
    lda ballposy
    rsh
    sta screeny
    sti 0 screendraw
    .done:
    ret

physics:
    ;update xpos by xvel
    lda ballposx
    add ballvelx
    ;flip vel if required
    rsh
    cmi 127
    blt dontinvertvelx
    invertsvelx:
    ;inverts velocity
    lda ballvelx
    neg
    sta ballvelx
    dontinvertvelx:
    lda ballposx
    add ballvelx
    sta ballposx

    .updatey:
    ;update ypos by yvel
    lda ballposy
    add ballvely
    ;flip vel if required
    rsh
    cmi 10
    bge .checknext
    lda ballvely
    neg 
    sta ballvely
    .checknext:
    cmi 127
    blt .next
    lda ballvely
    neg 
    sta ballvely
    .next:
    lda ballposy
    add ballvely
    sta ballposy

    .done:
    ret

input_handler:
    din controller
    bit 0x01
    biz .next1
    inx cpuscore
    jsr draw_scores
    .next1:
    din controller
    bit 0x02
    biz .next2
    inx playerscore
    jsr draw_scores
    .next2:
    ret


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