
Hero:
{
.segment ZP "Hero"
gold:							.byte 0
color_index:			.byte 0
state:						.byte 0
lticker:					.byte 0 
	//	
.segment CODE "Hero"
	//	init gets called when the task is first called
	Init:
	{
		//	set up default state		
		lda #$00 
		sta state
		sta gold 
		lda #$5
		sta ent_damage
		lda #$25 
		sta ent_health
		//	set the sprite pointer
		lda #SPR_BASE 
		sta SPR_PTR 
		lda #(DIGITS_RAM)/64 
		sta SPR_PTR+6 

		lda #(DIGITS_RAM+$40)/64 
		sta SPR_PTR+7

		//	and the 3 digit hires sprite
		//	run every N frames
		lda #$02
		sta.z TaskOS.ResetTime,x 
		sta.z TaskOS.Timer,x 
		//	Change the function pointer 
		//	to Update
		TaskOS_SwitchFunction(Update)
		rts
	}

	//	task runs seperately 
	//	to count down after taking damage
	UpdateDamage:
	{
		//	state = 0 = nothing 
		//	2 is initial damage 
		//	1 is delayed call to finish up 
		lda state 
		beq exit

		//	state counts down
		dec state
		cmp #2 
		bne checkone 
		//	set a delay 
		lda #DIGIT_FADETIME
		sta.z TaskOS.ResetTime,x 
		sta.z TaskOS.Timer,x 
		rts

checkone:

		//	we've waited 
		//	set the delay back to normal 
		lda #3
		sta.z TaskOS.ResetTime,x 
		//	reposition sprite
		lda #LEFT+$38
		sta VIC.Sprite0_x
		lda #TOP+$1c
		sta VIC.Sprite0_y
		//	update health	and display	
		
		ldx #0
		ldy #1 
		jsr ent_DealDamage
		beq killed


//		PushString #HEALTH:ent_health
		PushString #DAMAGE:ent_damage
exit:
		rts

killed:
		lda #$00 
		sta state
		sta ent_health
		
		SFX_EFFECT(SFX_MONSTER_EXPLODE)
		ldx.z TaskOS.CurrentTask
		lda #DEAD_DELAY
		sta.z TaskOS.ResetTime,x 
		sta.z TaskOS.Timer,x 
		TaskOS_SwitchFunction(Died)
		lda #$1 
		sta game_state
		rts
	}

	Died:
	{
		jmp Title.Init 
		rts
	}

	//	the next "tick" after Init
	Update:
	{
//	if damaged
		lda state 
		beq noAction
		clc 
		RNDSID()
		and #3 
		adc #LEFT+$38-2
		sta VIC.Sprite0_x
		clc 
		RNDSID()
		and #3 
		adc #TOP+$1c-2
		sta VIC.Sprite0_y
		rts
noAction:
		lda playerDirection
		beq noSFX 
		dec lticker
		lda lticker
		and #$3
		bne noSFX
		SFX_EFFECT($00)
	noSFX:

		lda playerDirection
		bne Move
		jsr Room.Decide
Move:


		dec movecounter
		lda movecounter
		cmp #$e4 
		bne nocenter 
		lda #LEFT+$38
		sta VIC.Sprite0_x
		lda #TOP+$1c
		sta VIC.Sprite0_y
		lda #$00 
		sta playerDirection

nocenter:
		lda movecounter
		bne noset 
		jsr Room.Switch

		lda playerDirection
		and #7 
		tax
		lda Room.xpos,x
		sta VIC.Sprite0_x
		lda Room.ypos,x
		sta VIC.Sprite0_y

noset:


		lda playerDirection

		and #7 
		tax
		clc 
		lda VIC.Sprite0_x 
		adc Room.xdir,x
		sta VIC.Sprite0_x
		clc 
		lda VIC.Sprite0_y
		adc Room.ydir,x
		sta VIC.Sprite0_y

noMove:
		rts
	}

	Loot:
	{
		RNDSID()
		and #3
	}
	LootGiven:
	{
		cmp #3 
		bne nodmgplus 
		sed
		clc 
		lda ent_damage
		adc #1 
		sta ent_damage
		cld

		PushString #DMGUP:ent_damage
		SFX_EFFECT(SFX_KEY)
		rts
nodmgplus:
		cmp #0 
		bne nohealthplus 

		sed
		clc 
		lda ent_health
		adc #5
		sta ent_health
		cld

		PushString #HLTHUP:ent_health
		SFX_EFFECT(SFX_TREASURE)

		rts
nohealthplus:
		cmp #1
		bne nogoldplus 
		sed
		clc 
		lda Hero.gold
		adc #5
		sta Hero.gold
		cld
		PushString #GLDUP:Hero.gold
		SFX_EFFECT(SFX_CHALICE)
		rts
nogoldplus:


		rts
	}
}


