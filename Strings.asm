	.segment CODE "StringSystem Data"
	.encoding "screencode_mixed"
sDMG:			.text "Damage"
					.text "Health"
					.text " Gold "
					.text "Rolled"
					.text " DIED!"
					.text " DMG+ "
					.text " HLTH+"
					.text "Gold +"
					.text " BUFF "

stable: .lohifill 8,sDMG+(i*6)
/*
.macro mPushString(strcode,digit)
{
	tsx //	get current stack 
	stx lastStack
	ldx.z StringSystem.SP
	txs
	lda #strcode
	pha
	lda digit 
	pha
	tsx
	stx.z StringSystem.SP
	ldx lastStack:#$00
	txs // 
}
*/
.pseudocommand PushString strcode : digit {
	lda strcode 
	sty.z StringSystem.temp
	stx.z StringSystem.temp+1
	ldy digit 
	jsr StringSystem.PushString
	ldx.z StringSystem.temp+1
	ldy.z StringSystem.temp
}


StringSystem:
{
	.segment ZP "StringSystem"
	SP:										.byte 0
	lSP:									.byte 0
	temp:									.fill 2,0
	color_index:					.byte 0
	display_number:				.fill 3,0
	display_messagecode:	.byte 0
	active:								.byte 0 
	.segment CODE "StringSystem"	
	PushString:
	{
		tsx //	get current stack 
		stx.z StringSystem.lSP
		ldx.z StringSystem.SP
		txs
		pha 
		tya
		pha 
		tsx
		stx.z StringSystem.SP
		ldx StringSystem.lSP
		txs // 
		rts
	}

	Init:
	{
		lda #<Update
		sta.z TaskOS.UpdateLSB,x 
		lda #>Update
		sta.z TaskOS.UpdateMSB,x 

		ldx #$00
	clearStrings: 
		lda #$00 
		sta $0100,x 
		inx 
		cpx #$40 
		bne clearStrings
		lda #$3f 
		sta SP
		lda #$00
		sta color_index
		rts
	}


	Update:
	{
		lda color_index
		bne fading 
		lda SP
		cmp #$3f
		bne updateNumberSprite
		lda #$00 
		sta active

		rts
	fading:
		lda #$01
		sta active
		sta.z TaskOS.ResetTime,x 

		lda ticker 
		and #3 
		bne nofade
		ldy color_index
		lda fadecolors,y 
		sta VIC.Sprite6_color
		sta VIC.Sprite7_color
		dec color_index
		lda color_index
		bne nofade
		ldx #$00
		lda #$00 
clrspr:
		sta DIGITS_RAM,x 
		inx 
		cpx #$80
		bne clrspr
nofade:		
		rts





updateNumberSprite:
		lda #$01
		sta active

		lda #MAX_FADECOLOR
		sta color_index
		lda #1 
		sta VIC.Sprite6_color
		sta VIC.Sprite7_color

		lda #DIGIT_FADETIME
		sta.z TaskOS.ResetTime,x 
		sta.z TaskOS.Timer,x 

		tsx 
		stx cSP 

		ldx SP 
		txs 
		pla 
		sta display_number
		pla 
		sta display_messagecode
		tsx 
		stx SP

		ldx cSP:#$00
		txs

		lda display_messagecode
		and #$80 
		bne monsterspo 

		ldx #0
		jmp onscreen
monsterspo:
		ldx #1
onscreen:

		lda StringY,x 
		sta VIC.Sprite6_y 
		sta VIC.Sprite7_y 

		lda StringX,x
		sta VIC.Sprite6_x
		clc 
		adc #24 
		sta VIC.Sprite7_x

		mov16 #DIGITS_RAM:output_str
		lda display_messagecode
		and #$7f 
		tay
		jsr DrawString

		mov16 #DIGITS_RAM+(8*3)+2:output_str
		lda display_number
		lsr 
		lsr 
		lsr 
		lsr
		tax
		lda hextab,x 
		jsr DrawCharToSpr

		mov16 #DIGITS_RAM+(8*3)+64:output_str
		clc
		lda display_number
		and #$f 
		tax
		lda hextab,x 
		jmp DrawCharToSpr
	}

hextab:
	.text "0123456789ABCDEF"
StringX:
	.byte LEFT+$38-12,RIGHT-24-12
StringY:
	.byte TOP+$1c-8,TOP+$1c-2

}







