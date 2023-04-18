
Game:
{
	Update:
	{
		sta VIC_SCR
noStop:
		rts
	}

	damage:	.byte $12,$34,$45
	Init:
	{	
		lda #$0b 
		sta VIC.cr1
		lda #$00 
		sta VIC.bg_color0
		sta game_state
		sta Monster_Count

		sta ClearScreen.clr
		jsr ClearScreen
		jsr TaskOS.Init
		TaskOS_RegisterFunction(Hero.Init,0)	 
		TaskOS_RegisterFunction(Hero.UpdateDamage,3)	 
		TaskOS_RegisterFunction(Dice.WaitForGamble,2)
		TaskOS_RegisterFunction(Prize.WaitForPrize,0)					

		TaskOS_RegisterFunction(Monster.Update,0)					
		TaskOS_RegisterFunction(Monster.UpdateDamage,3)	 
		TaskOS_RegisterFunction(Update,0)	 
		TaskOS_RegisterFunction(StringSystem.Init,0)	 

		lda #LEFT+24
		sta VIC.Sprite0_x+(PRIZE_SPR<<1)
		lda #RIGHT-24
		sta VIC.Sprite0_x+(MONSTER_SPR<<1)

		lda #LEFT+$38
		sta VIC.Sprite0_x
		lda #TOP+$1c
		sta VIC.Sprite0_y

	//	VIC_bank_4000()
	//	VIC_disable_mc()

		jsr Random.Init

	//	fill map with random elements and treasure 
	//	two loops
	//	fill with 1-6 
		lda #$1
		ldx #$00
	rangeSet:
		sta GambleRange,x 
		clc 
		adc #1 
		cmp #7 
		bne noreset 
		lda #$1  
	noreset:
		inx 
		bne rangeSet		
	//	fill rnd table
		lda #$ff 
		sta ticker
		ldx #$00 
	randomize:
		RNDSID()
		tay
		lda GambleRange,y 
		sta GambleRND,x 
		inx 
		bne randomize

		//	prepare rooms
		ldx #$00 
	mRand:

		lda #$00 
		sta MapContents,x

		RNDSID()
		and #$f 
		sta MapGreebs,x  
		//	only goodies in rooms not hallways
		lda Map,x 
		and #$f
		cmp #6
		beq noStuff 
		cmp #9 
		beq noStuff 
	Stuff:		
		lda prizeIndex
		and #3 
		tay 
		inc prizeIndex
		ora #%00001000
		sta MapContents,x 
	noStuff:

		//	monsters
		clc
		RNDSID()
//		cmp #$80 
		bpl noMonster
		rol 
		rol
		and #%01110000
		ora MapContents,x
		ora #%10000000
		sta MapContents,x
		inc Monster_Count
noMonster:
		lda #$00 
		sta MapVisit,x

		inx 
		cpx #8*8 
		bne mRand

		RNDSID()
		and #$7 
		sta Room.x_position
		RNDSID()
		and #$7 
		sta Room.y_position

		jsr Room.Switch
		VIC_charset_3800()
		c64_screen($2800)
		lda #$1b 
		sta VIC.cr1

		rts
	}
}

