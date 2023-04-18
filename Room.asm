

.const MAX_FADECOLOR = 5
fadecolors:	
	.byte 0,9,2,8,$a,1,3,$e,6

Room:
{

.segment ZP "Room"															
//	move to ROOM
description_bit:
							.byte 0 
last_room:		
							.byte 0 
contents:			.byte 0 
x_position:		.byte 0 
y_position:		.byte 0 
memory_offset:
							.byte 0 

.segment CODE "Room"															

//	0, NORTH, EAST, SOUTH , WEST
xdir:	.byte 0,-2, 2, 2, -2 
ydir:	.byte 0,-1, -1, 1, 1
xpos:	.byte LEFT+$38,RIGHT,LEFT,LEFT,RIGHT 
ypos:	.byte TOP+$1c,BOTTOM,BOTTOM,TOP,TOP
	//	
	Switch:
	{
		lda y_position
		and #7 
		asl 
		asl 
		asl 
		sta adder 
		clc 
		lda x_position
		and #7 
		adc adder:#$00 
		tax 
		stx memory_offset
		lda Map,x 
		sta description_bit
		lda MapContents,x 
		sta contents
		lda memory_offset
		cmp last_room
		bne redraw
		rts
	redraw:

		sta last_room
		jsr Draw

		//	turn everything off but player 

		jsr DrawMap
		jsr DrawGreebles

		lda #$ff
		sta VIC.spr_ena

		lda #$0 
		sta VIC.spr_hi_x
		sta.z Prize.available
		sta.z Prize.type
		sta.z Monster.available
		sta.z Monster.type 
		sta.z ent_health+1
		sta.z ent_damage+1

		lda contents 
		and #%0000_1000
		beq noPrize 
		lda contents 
		and #3
		sta.z Prize.type
		inc.z Prize.available

	noPrize:
		clc
		lda contents 
		and #%10000000
		beq noMonsters0
		lda contents 
		lsr 
		lsr 
		lsr 
		lsr
		and #3
		sta.z Monster.type
		tay 
		lda Monster.hp,y 
		sta.z ent_health+1
		lda Monster.dmg,y 
		sta.z ent_damage+1
		inc.z Monster.available

	noMonsters0:
		rts
	}

	Decide:
	{
		lda x_position
		and #7 
		sta x_position
		lda y_position
		and #$7
		sta y_position

		lda #$00 
	//	sta playerDirection
//		jsr Keyboard.Update

		lda.z Dice.active
		bne out
		lda.z StringSystem.active
		bne out 
		jmp canMove
	out:
		rts
	canMove:

		ldy #$00
		//	check we have North as an option
		lda description_bit 
		and #1 
		beq noNorth 
		//	north 
		lda.z Joystick.input_dy
		cmp #$ff
		bne noNorth
		dec y_position	
		lda #NORTH 
		sta playerDirection
		iny 
	noNorth:
		//	check for east 
		lda description_bit 
		and #2 
		beq noEast 

		lda.z Joystick.input_dx
		cmp #$01
		bne noEast
		inc x_position	
		lda #EAST
		sta playerDirection
		iny 
	noEast:

		//	south

		lda description_bit 
		and #8 
		beq noSouth 
		lda.z Joystick.input_dy
		cmp #$01
		bne noSouth
		inc y_position	
		lda #SOUTH
		sta playerDirection
		iny 
	noSouth:

		//	west
		lda description_bit 
		and #4
		beq noWest

		lda.z Joystick.input_dx
		cmp #$ff
		bne noWest
		dec x_position	
		lda #WEST 
		sta playerDirection
		iny 
	noWest:

		cpy #0 
		beq nothing
		lda #$1c 
		sta movecounter

	nothing:
		rts
	}


	DrawMap:
	{
		mov16 #VIC_SCR+$10:output_scr
		mov16 #$d810:output_col
		mov16 #Map:input_tile
		mov16 #MapVisit:input_visit
		
		ldx memory_offset

		lda #MAX_FADECOLOR 
		sta MapVisit,x
	nomore:
		ldx #$00 
	yloop:
		stx tx
		ldy #$00 
	xloop:
		lda (input_tile),y
		and #$f
		ora #$40 
		sta (output_scr),y 

		lda (input_visit),y
		tax
		lda fadecolors,x 
		sta (output_col),y
		cpx #0
		beq noDec 

		lda (input_visit),y
		sec 
		sbc #$1 
		sta (input_visit),y 

	noDec:
		iny 
		cpy #8
		bne xloop
		add16 #8:input_tile
		add16 #8:input_visit
		add16 #40:output_scr
		add16 #40:output_col
		ldx tx:#$00
		inx
		cpx #8 
		bne yloop
		rts
	}



	Draw:
	{
		lda description_bit 
		and #1
		tax
		mov16 #PLAYFIELD:output_scr
		mov16 #PLAYFIELDCOLOR:output_col	
		jsr DrawTile 


		lda description_bit
		lsr 
		and #1
		ora #2
		tax
		mov16 #PLAYFIELD+10:output_scr
		mov16 #PLAYFIELDCOLOR+10:output_col	
		jsr DrawTile 

		lda description_bit
		lsr 
		lsr 
		and #1
		ora #4
		tax
		mov16 #PLAYFIELD+(8*40):output_scr
		mov16 #PLAYFIELDCOLOR+(8*40):output_col	
		jsr DrawTile 

		lda description_bit
		lsr 
		lsr 
		lsr 
		and #1
		ora #6
		tax
		mov16 #PLAYFIELD+10+(8*40):output_scr
		mov16 #PLAYFIELDCOLOR+10+(8*40):output_col	
	//	fall thru 
	//	jsr DrawTile 
	//	rts
	}

	DrawTile:
	{
		lda tileptrs.lo,x 
		sta input_tile
		lda tileptrs.hi,x 
		sta input_tile+1
		ldx #$00 
	yloop:
		ldy #$00 
	xloop:
		lda (input_tile),y
		sta (output_scr),y 
		stx tx 
		tax 
		lda tileattr,x 
		sta (output_col),y
		ldx tx:#$00
		iny 
		cpy #10 
		bne xloop
		add16 #10:input_tile
		add16 #40:output_scr
		add16 #40:output_col
		inx
		cpx #8 
		bne yloop
		rts
	}

	DrawGreebles:
	{
		ldx memory_offset
		lda MapGreebs,x
		sta input_tile
		ldx #$00 
next:
		lda input_tile
		asl 
		sta input_tile
		bcc skipG
		lda greebs,x 
		sta output_scr
		lda greebs+1,x 
		sta output_scr+1 

		ldy #$00 
		lda #$1 
		sta (output_scr),y
skipG:
		inx 
		inx 
		cpx #$10 
		bne next 

		rts
	}

//	greeband:	.word %00000001,%00000010,%00000100,%00001000,%00010000,%00100000,%01000000,%10000000
	greebs:
		.word	VIC_SCR + 19 + (17*40)
		.word	VIC_SCR + 24 + (15*40)
		.word	VIC_SCR + 20 + (15*40)
		.word	VIC_SCR + 16 + (16*40)
		.word	VIC_SCR + 22 + (17*40)
		.word	VIC_SCR + 18 + (18*40)
		.word	VIC_SCR + 21 + (17*40)
		.word	VIC_SCR + 17 + (19*40)

}

tileptrs:
 .lohifill 16, tileset+(i*(10*8))
