//sfx code for dunjon battler
//2010 jeffrey ouellette
// ------------------------
 

//.label		sid  = $d400 	//sid voice 1 start
//.label		ring = $d40f 	//hi byte voice 3 freq

SFX:
{
.segment ZP "SFX"

loslidestep:	.byte 0
hislidestep:	.byte 0
slideneg:			.byte 0
time:					.byte 0 //decrement
type:         .byte 0 //which sound number?
bouncetime:		.byte 0 //time until slide reversed
bouncemax:		.byte 0 //holds the reset value for bouncetime
freqhi:				.byte 0 //
freqlo:				.byte 0 //

write:				.byte 0 //if zero able to play same sound again, ignored with higher priority sounds
sfxindex:			.byte 0 //remember index for proper decay

effect:				.byte $ff //set to start effect $ff = no new effect

.segment CODE "SFX"

	Init:
	{
			lda #$00
			ldx #$00
	_sf2:
			sta SID.v1_frequency_l,x
			inx
			cpx #$19
			bne _sf2
			lda #$f
			sta $d418
			rts
	}

	Update:
	{
			RNDSID()
			sta sfx_hifreq
			lda.z effect	//Jump here from interupt
			cmp #$ff	//Has a new sound effect been requested? 
			bne _sf0
	_sf1:
			jmp continue	//No, continue with current sound
	_sf0:
			cmp.z write
			bcc _sf1		//higher priority?
			jmp newsound	//initialise a sound

	continue:
			lda.z time
			bne l0		//sound over, clear write flag
			sta.z write
			ldx.z sfxindex
			lda sfx_waveform,x
			and #254
			sta SID.v1_control	//close gate 
			rts
	l0:
			dec.z time	//sound still playing
			lda #$ff
			sta.z effect	//clear new sound request
			lda.z loslidestep
			bne l1		//slide on sound?
			rts
	l1:
			lda.z slideneg	//slide down?
			bne slidedown
			clc
			lda.z freqlo	//get voice freq lo byte and add
			adc.z loslidestep    
			sta SID.v1_frequency_l
			sta.z freqlo
			lda.z freqhi	//get voice freq hi byte and add
			adc.z hislidestep  
			sta SID.v1_frequency_h
			sta.z freqhi
			lda.z bouncetime
			cmp #$ff	//is there a bounce?
			bne bounceslide
			rts
	slidedown:
			sec
			lda.z freqlo        
			sbc.z loslidestep  
			sta SID.v1_frequency_l
			sta.z freqlo
			lda.z freqhi        
			sbc.z hislidestep
			sta SID.v1_frequency_h
			sta.z freqhi
			lda.z bouncetime
			cmp #$ff
			bne bounceslide
			rts

	bounceslide:
			ldx #1
			ldy #0
			sec
			sbc #1
			sta.z bouncetime
			bcc switch
			rts
	switch:
			lda.z slideneg
			beq _txa
			tya
			beq swout
	_txa:
			txa
	swout:
			sta.z slideneg	//reverse slide direction
			lda.z bouncemax
			sta.z bouncetime  //reset timer
			rts
			
	newsound:
			lda.z effect
			tax
			stx.z write
			stx.z sfxindex
			lda #0
			sta SID.v1_control
			lda #15
			sta SID.volume
			lda sfx_time,x
			sta.z time
			lda sfx_bounce,x
			sta.z bouncetime
			sta.z bouncemax
			lda sfx_ringmod,x
			sta.z SID.v3_frequency_h
			lda sfx_loslidestep,x
			sta.z loslidestep
			lda sfx_hislidestep,x
			sta.z hislidestep
			lda sfx_slideneg,x
			sta.z slideneg
			lda sfx_lofreq,x
			sta.z freqlo
			sta SID.v1_frequency_l
			lda sfx_hifreq,x
			sta.z freqhi
			sta SID.v1_frequency_h
			lda sfx_lopulse,x
			sta SID.v1_pulse_width_l
			lda sfx_hipulse,x
			sta SID.v1_pulse_width_h
			lda sfx_atdc,x
			sta SID.v1_attack_decay
			lda sfx_ssrl,x
			sta SID.v1_sustain_release
			lda sfx_waveform,x
			sta SID.v1_control
			lda #$ff
			sta.z effect
			rts
	}
//-------------------------------------------
//SFX DEFINITIONS
//Priority for least to greatest
// 0 Walking
// 1 Sword
// 2 Monster Explode
// 3 Player Hurt
// 4 Collect Key
// 5 Collect Treasure
// 6 Boss Attack
// 7 Boss Hurt
// 8 Boss Explode
// 9 Chalice
// 10 Game Start
// 11 Player Dies
//-------------------------------------------



.segment CODE "Sound FX Data"

sfx_time:					.byte 3,4,25,15,20,20,6,25,45,50,70,100		
//attack / delay
sfx_atdc:					.byte $13,$02,$15,$10,$10,$01,$04,$71,$00,$a6,$71,$0f
//sustain/release
sfx_ssrl:					.byte $38,$95,$96,$5a,$6a,$65,$a4,$c6,$ca,$cb,$a9,$35
//lo byte slide amount
sfx_loslidestep:	.byte 1,1,127,204,204,8,127,127,127,1,63,1
//hi byte slide amount
sfx_hislidestep:	.byte 10 ,15,30,0,0,0,5,0,204,50,0,2
	//slide negative or positive?
sfx_slideneg:			.byte 1,0,0,0,0,0,1,0,0,0,0,1
		
sfx_waveform:
		.byte 129	//walking
		.byte 129	//sword
		.byte 129	//explode
		.byte 65	//hurt
		.byte 85	//key
		.byte 81	//treasure
		.byte 21	//boss attack
		.byte 129	//boss hurt
		.byte 129	//boss die
		.byte 21	//chalice
		.byte 21	//game start
		.byte 129	//die
		
sfx_lofreq:
		.byte 233 
		.byte 0
		.byte 40
		.byte 40
		.byte 0
		.byte 200
		.byte 0
		.byte 100
		.byte 100
		.byte 4
		.byte 100
		.byte 0

sfx_hifreq:
		.byte 100 
		.byte 200
		.byte 100
		.byte 2
		.byte 120
		.byte 3
		.byte 30
		.byte 2
		.byte 15
		.byte 0
		.byte 7
		.byte 220

sfx_lopulse:
		.byte 0 
		.byte 80
		.byte 0
		.byte 127
		.byte 80
		.byte 127
		.byte 12
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0

sfx_hipulse:
		.byte 0 
		.byte 5
		.byte 0
		.byte 2
		.byte 0
		.byte 4
		.byte 10
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		
sfx_ringmod:
		.byte 0 
		.byte 0
		.byte 0
		.byte 10
		.byte 10
		.byte 0
		.byte 0
		.byte 5
		.byte 0
		.byte 2
		.byte 2
		.byte 0

sfx_bounce:
		.byte $ff	//changes slide back and 
		.byte $3	//forth after x number of 
		.byte 2		//cycles, $ff = no bounce
		.byte 5
		.byte $ff
		.byte $ff
		.byte 3
		.byte 10
		.byte $ff
		.byte 4
		.byte $ff
		.byte $ff
}
	
		
