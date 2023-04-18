
.const PRIZE_FRAME = SPR_BASE+5
Prize:
{
	.segment ZP "Prize"
type:				.byte 0 
available:	.byte 0 
	.segment CODE "Prize"

	WaitForPrize:
	{
	lda available
	bne check
	lda #$ff 
	sta VIC.Sprite0_y+(PRIZE_SPR<<1)
	rts 
check:

	lda #BOTTOM-21
	sta VIC.Sprite0_y+(PRIZE_SPR<<1)

	clc
	lda type 
	tay
	adc #PRIZE_FRAME
	sta SPR_PTR+PRIZE_SPR
	lda prizeColors,y 
	sta VIC.Sprite0_color+PRIZE_SPR
	rts
	}
prizeColors:
	.byte 8,7,2,$f
}