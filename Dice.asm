
Dice:
{
	.segment ZP "Dice"

spinning:		.byte 0 
amount:			.fill 3,0
current:		.fill 3,0
total:			.fill 2,0 
spincount:	.fill 3,0
inmotion:		.fill 3,0
gpos:				.byte 0
rounds:			.byte 0 
active:			.byte 0 

	.segment CODE "Dice"
notDone:
	rts	
//	decrement sprite frames to look like they're rolling 
// 	stop when the roll count is 0 ( 6-1 )
Spin:
{
	//	spinning logic
	ldx #$00 

	stx spinning	//	clear spinning flag 
spinDice:

	//	check if we've spun for rollcount
	lda spincount,x 
	//	if not we keep spinning
	bne spin
	//	check if we've hit the requested number
	lda amount,x
	cmp current,x 
	bne spin 
	lda inmotion,x 
	beq noSFX
	//	play the clonk when the dice stops 
	dec inmotion,x 
	SFX_EFFECT(SFX_SWORD)
noSFX:
	jmp next
	//	no? keep spinning
	//	spinning logic
spin:
	dec current,x 
	inc spinning 
	//	check if we're 0
	lda current,x
	cmp #0
	bne nobottom
	//	it's fine keep going 
	//	when the dice hits 1 we reset to 6 and decrement spins
	dec spincount,x
	//	set current number to 6 
	lda #6
	sta current,x
	//	next dice
	jmp next
nobottom:
	//	decrement frame 
	//	this is a flag to tell us we're completely done. all 3 dice are finished
next:
	//	fixup sprite pointer
	clc 
	lda current,x 
	adc #DICE_FRAME-1 
	sta SPR_PTR+DICE_SPR,x
	//	next one
	inx 
	cpx #3 
	bne spinDice

	//	check flag to see if we're spinning
	lda spinning
	bne notDone
	
	// once done we update the amount by adding 3 dice together 
	// for whichever set of dice we're on. ( player or monster )
	// y = 0 player
	// y = 1 monster
	ldy rounds
	ldx #$00 
addup:
	clc
	// use BCD for addition here
	// add the dice together
	sed
	lda total,y
	adc amount,x 
	sta total,y
	cld

	inx 
	cpx #3 
	bne addup

endSpin:
	//	player or monster round
	lda rounds
	bne mNumber
	//	if we're finished with round 0 ( player )
	//	update hero number
	PushString #ROLLED:total
	jmp pNumber
mNumber:
	//	if we're finished with round 1 ( monster )
	//	reset both states
	lda #0 
	sta.z Monster.state
	sta.z Hero.state
	PushString #ROLLED|$80:total+1

	clc
	lda total
	cmp total+1
	bcc p0 
	//	the monster is damaged
	SFX_EFFECT(SFX_BOSS_HURT)

	lda #$2
	sta.z Monster.state
	jmp pNumber
p0:
	//	the player is damaged
	SFX_EFFECT(SFX_PLAYER_HURT)

	lda #$2
	sta.z Hero.state
pNumber:
	//	now disable the dice
//	ldx TaskOS.Step.CurrentTask
	ldx.z TaskOS.CurrentTask
	//	and adjust runtime
	lda #DICE_DELAY
	sta.z TaskOS.ResetTime,x 
	sta.z TaskOS.Timer,x 
	TaskOS_SwitchFunction(Disable)
	rts
}

Disable:
{
	//	basically we sit here until both dice have spun
	inc rounds 
	lda rounds 
	cmp #2 
	beq endSpin
	//	if not we're spinning for the monster 
	//	so trigger that
//	ldx TaskOS.Step.CurrentTask
	ldx.z TaskOS.CurrentTask
	lda #DICE_WAIT
	sta.z TaskOS.ResetTime,x 
	lda #DICE_DELAY
	sta.z TaskOS.Timer,x 
	TaskOS_SwitchFunction(Spin)
	jsr ResetSpinners
	//	move dice screen location
	lda #$c0 
	ldy #$b8
	jsr ResetSpinners.PositionDice
	rts
endSpin:
	//	move them off 
	lda #$ff 
	sta VIC.Sprite0_y+(DICE_SPR<<1)
	sta VIC.Sprite1_y+(DICE_SPR<<1)
	sta VIC.Sprite2_y+(DICE_SPR<<1)

	//	now we can gamble again	
//	ldx TaskOS.Step.CurrentTask
	ldx.z TaskOS.CurrentTask
	lda #0
	sta.z TaskOS.ResetTime,x 
	sta.z TaskOS.Timer,x 
	TaskOS_SwitchFunction(WaitForGamble)
	rts
}

ResetSpinners:
{
	//	random offset into random table 
	RNDSID()
	sta gpos
	//	set number of spins
	ldx #4 
	stx spincount
	ldx #6
	stx spincount+1
	ldx #8
	stx spincount+2
	lda #$01 
	sta inmotion
	sta inmotion+1
	sta inmotion+2
	//	randomize 
	ldx gpos
	lda GambleRND,x 	
	sta amount

	sta current+1	//	offset so we don't start on the start frame
	clc
	adc #DICE_FRAME-1 
	sta SPR_PTR+DICE_SPR+2
	inx 
	//	next random dice
	lda GambleRND,x 
	sta amount+1
	sta current+2
	clc
	adc #DICE_FRAME-1 
	sta SPR_PTR+DICE_SPR+1
	inx 
	//	next random dice

	lda GambleRND,x 
	sta amount+2
	sta current
	clc
	adc #DICE_FRAME-1 
	sta SPR_PTR+DICE_SPR
	inx 

	//	default is player location
	lda #$a0 
	ldy #$b2 
	//	called by monster 
PositionDice:
	sty VIC.Sprite0_y+(DICE_SPR<<1)
	sty VIC.Sprite0_y+(DICE_SPR<<1)+4
	iny 
	iny 
	sty VIC.Sprite0_y+(DICE_SPR<<1)+2

	ldx #$00 
sprLo:
	sta VIC.Sprite0_x+(DICE_SPR<<1),x
	clc 
	adc #12
	inx 
	inx 
	cpx #6 
	bne sprLo
	rts	
}

//	wait for the Action button 

WaitForGamble:
{
//	only if we've stopped moving 
	lda playerDirection
	beq stopped
nope:
	rts
stopped:	
	//	game_state is 0 if we're running normally
	//	1 if we died 
	//	2 if we won
	lda game_state
	bne nope
	//	
	lda #$00 
	sta active

	lda.z Joystick.input_btn
	beq noGamble 
	lda.z Joystick.last_input_btn
	bne nope 

	//	see if there's a prize 
	//	grab that first
	lda.z Prize.available
	beq noPrize 
	lda #$00 
	sta.z Prize.available
	sta.z Joystick.input_btn
	sta.z Joystick.last_input_btn

	//	clear out map contents
	ldx Room.memory_offset
	lda MapContents,x 
	and #%11110111
	sta MapContents,x 
	//	give loot
	lda.z Prize.type
	jmp Hero.LootGiven

noPrize:
	//	if there's a monster 
	//	we can respond to A
	lda.z Monster.available 
	beq noGamble
	//	start dice
	lda #$00 
	sta rounds
	sta total
	sta total+1
	inc active
	SFX_EFFECT(SFX_BOSS)

	jsr ResetSpinners
	ldx.z TaskOS.CurrentTask
//	ldx TaskOS.Step.CurrentTask
	lda #DICE_WAIT
	sta.z TaskOS.ResetTime,x 
	TaskOS_SwitchFunction(Spin)
noGamble:
	rts
}
}
