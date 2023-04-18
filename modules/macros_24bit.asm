#importonce 

.pseudocommand mov24 src : tar {
    lda src
    sta tar
    lda _16bit_nextArgument(src)
    sta _16bit_nextArgument(tar)
    lda _24bit_nextArgument(src)
    sta _24bit_nextArgument(tar)
}

.pseudocommand add24 arg1 : arg2 : tar {
    .if (tar.getType()==AT_NONE) .eval tar=arg2
    clc
    lda arg1
    adc arg2
    sta tar
    lda _16bit_nextArgument(arg1)
    adc _16bit_nextArgument(arg2)
    sta _16bit_nextArgument(tar)
    lda _24bit_nextArgument(arg1)
    adc _24bit_nextArgument(arg2)
    sta _24bit_nextArgument(tar)
}


.pseudocommand sub24 arg1 : arg2 : tar {
    .if (tar.getType()==AT_NONE) .eval tar=arg2
    sec
    lda arg1
    sbc arg2
    sta tar
    lda _16bit_nextArgument(arg1)
    sbc _16bit_nextArgument(arg2)
    sta _16bit_nextArgument(tar)
    lda _24bit_nextArgument(arg1)
    sbc _24bit_nextArgument(arg2)
    sta _24bit_nextArgument(tar)
}


.pseudocommand rol24 src : tar {
    .if (tar.getType()==AT_NONE) .eval tar=src

    lda src 
    rol 
    sta tar 
    lda _16bit_nextArgument(src)
    rol 
    sta _16bit_nextArgument(tar)
    lda _24bit_nextArgument(src)
    rol 
    sta _24bit_nextArgument(tar)
}

.pseudocommand ror24 src : tar {
    .if (tar.getType()==AT_NONE) .eval tar=src

    lda src 
    ror
    sta tar 
    lda _16bit_nextArgument(src)
    ror 
    sta _16bit_nextArgument(tar)
    lda _24bit_nextArgument(src)
    ror 
    sta _24bit_nextArgument(tar)
}


.pseudocommand cmp24 vla:vlb {
    lda _24bit_nextArgument(vla)
    cmp _24bit_nextArgument(vlb)
    bne _DONE
    lda _16bit_nextArgument(vla)
    cmp _16bit_nextArgument(vlb)
    bne _DONE
    lda vla
    cmp vlb
_DONE:
}

.pseudocommand neg24 vla:res {
    .if (res.getType()==AT_NONE) .eval res=vla
    sec 
    lda #$00 
    sbc vla 
    sta res 
    lda #0 
    sbc _16bit_nextArgument(vla)
    sta _16bit_nextArgument(res)
    lda #0 
    sbc _24bit_nextArgument(vla)
    sta _24bit_nextArgument(res)
}


.pseudocommand asrm24 src : tar {
    .if (tar.getType()==AT_NONE) .eval tar=src
    clc
    lda src
    sta tar      
    lda _16bit_nextArgument(src)
    sta _16bit_nextArgument(tar)
    lda _24bit_nextArgument(src)
    sta _24bit_nextArgument(tar)
    asl 
    ror _16bit_nextArgument(tar)
    ror tar
}

.pseudocommand cmp24_l arg1 : arg2 : skipto {
    lda _24bit_nextArgument(arg1)
    cmp _24bit_nextArgument(arg2)
    bcc skipto
    lda _16bit_nextArgument(arg1)
    cmp _16bit_nextArgument(arg2)
    bcc skipto
    lda arg1 
    cmp arg2 
    bcc skipto
ok:
}

.pseudocommand cmp24_g arg1 : arg2 : skipto {
    lda _24bit_nextArgument(arg1)
    cmp _24bit_nextArgument(arg2)
    bcc ok
    bne skipto
    lda _16bit_nextArgument(arg1)
    cmp _16bit_nextArgument(arg2)
    bcc skipto
    bne skipto
    lda arg1 
    cmp arg2 
    bcs skipto
ok:
}
