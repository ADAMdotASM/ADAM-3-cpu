#ruledef
{
    nop => 0x00
    ldi {value: i8} => 0x01 @ value
    inc => 0x02
    dec => 0x03
    adi {value: i8} => 0x04 @ value
    jmp {value: u16} => 0x05 @ $le(value)
    bge {value: u16} => 0x06 @ $le(value)
    bic {value: u16} => 0x06 @ $le(value)
    blt {value: u16} => 0x07 @ $le(value)
    bnc {value: u16} => 0x07 @ $le(value)
    beq {value: u16} => 0x08 @ $le(value)
    biz {value: u16} => 0x08 @ $le(value)
    bne {value: u16} => 0x09 @ $le(value)
    bnz {value: u16} => 0x09 @ $le(value)
    add {value: u16} => 0x0a @ $le(value)
    adc {value: u16} => 0x0b @ $le(value)
    sub {value: u16} => 0x0c @ $le(value)
    sbb {value: u16} => 0x0d @ $le(value)
    lda {value: u16} => 0x0e @ $le(value)
    sta {value: u16} => 0x0f @ $le(value)
    psh => 0x10
    pop => 0x11
    sec => 0x12
    clc => 0x13
    din {value: u8} => 0x14 @ value
    cal {value: u16} => 0x15 @ $le(value)
    ret => 0x16
    lsh => 0x17
    rsh => 0x18
    ars => 0x19
    rol => 0x1a
    ror => 0x1b
    sti {value: i8}{dest: u16} => 0x1c @ value @ $le(dest)
    bpo {value: u16} => 0x1d @ $le(value)
    bng {value: u16} => 0x1e @ $le(value)
    cmp {value: u16} => 0x1f @ $le(value)
    cmi {value: i8} => 0x20 @ value
    ldr {value: u16} => 0x21 @ $le(value)
    str {value: u16} => 0x22 @ $le(value)
    jsr {value: u16} => 0x15 @ $le(value)

    neg => 0x27

    mov {src: u16}{dest: u16} => 0x2c @ $le(src) @ $le(dest)

    inw {value: u16} => 0x2f @ $le(value)


    inx {value: u16} => 0x35 @ $le(value)
    dex {value: u16} => 0x36 @ $le(value)



    xri {value: i8} => 0xf9 @ value
    ora {value: u16} => 0xfa @ $le(value)
    ori {value: i8} => 0xfb @ value
    and {value: u16} => 0xfc @ $le(value)
    ani {value: i8} => 0xfd @ value
    bit {value: i8} => 0xfe @ value
    nor {value: u16} => 0x8a @ $le(value)
    nri {value: i8} => 0x84 @ value
    inv => 0x97
}

#fn hi(x) => {x >> 8}
#fn lo(x) => {x & $FF}