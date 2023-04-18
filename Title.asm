
Title:
{
	.segment ZP "Titlescreen ZP"
line:	.byte 0 
lineoff:	.word 0 
	.segment CODE "Titlescreen"


	Init:
	{
		c64_screen($0400)
		VIC_charset_1000()
		ldx #$00 
ccolo:
		lda #$1
		sta $d800,x 
		sta $d900,x 
		sta $da00,x 
		sta $db00,x 
		dex 
		bne ccolo

		lda game_state
		and #1 
		bne nodead 
		lda #$a8 
		sta lineoff
		lda #$da
		sta lineoff+1
		lda #$0
		jsr clearLine
nodead:

		lda game_state
		and #2 
		bne nowin 
		lda #$f8 
		sta lineoff
		lda #$da
		sta lineoff+1
		lda #$0
		jsr clearLine
nowin:


		ldx #$FC 
clr:
		lda #$00 
		sta $02,x 
		sta DIGITS_RAM,x 
		dex 
		bne clr
		stx VIC.spr_ena
		lda #$ff
		sta.z Room.last_room
		RNDSID()
		and #3
		sta prizeIndex

		jsr TaskOS.Init
		sta line


		TaskOS_RegisterFunction(Title.Update,0)	 
		rts
	}

	clearLine:
	{
		ldy #$00
clear:
		sta (lineoff),y
		iny 
		cpy #40
		bne clear
		rts
	}

	Update:
	{
//		jsr Keyboard.Update

		lda.z Joystick.input_btn
		beq noExit 
		jmp Game.Init
	noExit:

		rts
	}
}