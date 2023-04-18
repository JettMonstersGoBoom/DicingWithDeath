#importonce 

.pseudocommand asl16 src : tar {
    .if (tar.getType()==AT_NONE) .eval tar=src

    lda src 
    asl 
    sta tar 
    lda _16bit_nextArgument(src)
    rol 
    sta _16bit_nextArgument(tar)
}

.pseudocommand lsr16 src : tar {
    .if (tar.getType()==AT_NONE) .eval tar=src

    lda src 
    lsr 
    sta tar 
    lda _16bit_nextArgument(src)
    ror 
    sta _16bit_nextArgument(tar)
}

.pseudocommand rol16 src : tar {
    .if (tar.getType()==AT_NONE) .eval tar=src

    lda src 
    rol 
    sta tar 
    lda _16bit_nextArgument(src)
    rol 
    sta _16bit_nextArgument(tar)
}

.pseudocommand ror16 src : tar {
    .if (tar.getType()==AT_NONE) .eval tar=src

    lda src 
    ror
    sta tar 
    lda _16bit_nextArgument(src)
    ror 
    sta _16bit_nextArgument(tar)
}

.pseudocommand cmp16 vla:vlb {
    lda _16bit_nextArgument(vla)
    cmp _16bit_nextArgument(vlb)
    bne _DONE
    lda vla
    cmp vlb
_DONE:
}

.pseudocommand mov16 src : tar {
    lda src
    sta tar
    lda _16bit_nextArgument(src)
    sta _16bit_nextArgument(tar)
}

.pseudocommand add16 arg1 : arg2 : tar {
    .if (tar.getType()==AT_NONE) .eval tar=arg2
    clc
    lda arg1
    adc arg2
    sta tar
    lda _16bit_nextArgument(arg1)
    adc _16bit_nextArgument(arg2)
    sta _16bit_nextArgument(tar)
}

.pseudocommand sub16 arg1 : arg2 : tar {
    .if (tar.getType()==AT_NONE) .eval tar=arg2
    sec
    lda arg1
    sbc arg2
    sta tar
    lda _16bit_nextArgument(arg1)
    sbc _16bit_nextArgument(arg2)
    sta _16bit_nextArgument(tar)
}


.pseudocommand cmp16_l arg1 : arg2 : skipto {

    lda _16bit_nextArgument(arg1)
    cmp _16bit_nextArgument(arg2)
    bcc skipto
    bne ok
    lda arg1 
    cmp arg2 
    bcc skipto
ok:
}
