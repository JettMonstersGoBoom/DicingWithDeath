
.label MAGIC8 = $c3 

.macro RNDSID(){
	jsr Random.Rand
}

Random:
{
	.segment ZP
rng_zp_low: .byte 0 
rng_zp_high: .byte 0
	result8:	.byte 0 

	.segment CODE 

	//	reseed
	Init:
	{
		lda #$6f
		ldy #$81
		ldx #$ff
		sta $d413
		sty $d412
		stx $d40e
		stx $d40f
		stx $d414
		// seeding
		lda $d41b 
		adc $d012
		pha
		and #217
		clc
		pla
		and #255-217
		adc #>21263
		sta result8
		lda #$80 
		sta $d412 
		
		rts
	}

	Rand:
	{
		lda result8
		beq doEor
		asl
		beq noEor // if the input was $80, skip the EOR
		bcc noEor
doEor:
		eor #MAGIC8
noEor:
		sta result8
		rts
	}
}