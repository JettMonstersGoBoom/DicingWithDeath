.const MONSTER_FRAME = SPR_BASE + 1

Monster:
{
.segment ZP "Monster"
//health:			.byte 0 
//damage:				.byte 0 
type:				.byte 0 
available:	.byte 0 
color_index:	.byte 0 
state:				.byte 0
	.segment CODE "Monster"
	UpdateDamage:
	{
		lda state 
		beq sexit

		dec state
		cmp #2 
		bne checkone 
		lda #DIGIT_FADETIME
		sta.z TaskOS.ResetTime,x 
		sta.z TaskOS.Timer,x 
sexit:		
		rts

checkone:
		lda #3
		sta.z TaskOS.ResetTime,x 
	

		lda #BOTTOM-21
		sta VIC.Sprite0_y+(MONSTER_SPR<<1)
		lda #RIGHT-24
		sta VIC.Sprite0_x+(MONSTER_SPR<<1)

		ldx #1
		ldy #0
		jsr ent_DealDamage

		beq killed
//		PushString #HEALTH|$80:ent_health+1
		PushString #DAMAGE|$80:ent_damage
		rts
killed:
//	died
		dec Monster_Count
		
//		PushString #DIED|$80:#00
		lda #$00 
		sta available
		sta state
		sta ent_health+1
		
		SFX_EFFECT(SFX_MONSTER_EXPLODE)

		ldx Room.memory_offset
		lda MapContents,x 
		and #%01111111
		sta MapContents,x

		lda Monster_Count
		bne ndead
		lda game_state
		ora #$2 
		sta game_state
		jmp Title.Init
ndead:


		rts
	}

	Update:
	{
		lda available
		bne check
		lda ent_health+1
		bne check
		lda #$ff 
		sta VIC.Sprite0_y+(MONSTER_SPR<<1)
		rts 
	check:

		lda #BOTTOM-21
		sta VIC.Sprite0_y+(MONSTER_SPR<<1)
	
//	if damaged
		lda state 
		beq noAction

		clc 
		RNDSID()
		and #3 
		adc #RIGHT-24-2
		sta VIC.Sprite0_x+(MONSTER_SPR<<1)
		clc 
		RNDSID()
		and #3 
		adc #BOTTOM-21-2
		sta VIC.Sprite0_y+(MONSTER_SPR<<1)
		rts
noAction:


		lda type
		tay
		clc 
		adc #MONSTER_FRAME
		sta SPR_PTR+MONSTER_SPR
		lda colors,y
		sta $d027+MONSTER_SPR
		rts
	}



dmg:
	.byte $2,$4,$6,$8 
hp:
	.byte $6,$8,$10,$14	
colors:
	.byte 2,5,3,$f
}

