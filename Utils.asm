
ClearScreen:
{
	mov16 #$d800:input_tile

	ldx #$00 
clearLoop:
	lda clr:#$00 
	sta VIC_SCR,x 
	sta VIC_SCR+$100,x 
	sta VIC_SCR+$200,x 
	sta VIC_SCR+$300,x 
	lda #$9
	sta $d800,x 
	sta $d900,x 
	sta $da00,x 
	sta $db00,x
	clc 
	lda input_tile 
	sta multab_l,x 
	adc #8 
	sta input_tile
	lda input_tile+1
	sta multab_h,x 
	adc #0 
	sta input_tile+1
	inx 
	beq eclearLoop
	jmp clearLoop
eclearLoop:
	rts
}

ent_DealDamage:
{
//		inc display_touched
	clc
	lda ent_health,x
	cmp ent_damage,y
	bcc killed 
	sec
	sed 
	sbc ent_damage,y
	sta ent_health,x
	cld
	beq killed
	sta ret
	lda ent_health,x 
	tay 
	lda #HEALTH
	ora orcode,x
	stx keepx 
	jsr StringSystem.PushString
	ldx keepx:#$00
	lda ret:#$00
	rts
killed:
	ldy #$00 
	lda #DIED 
	ora orcode,x 
	jsr StringSystem.PushString
;	cpx #1 
;	bne noLoot
;	jsr Hero.Loot		
noLoot:

	lda #$00
	rts
}
orcode:
	.byte 0,$80
DrawString:
{
.segment CODE "String"
//	lda TaskOS.Flags,x
	lda stable.lo,y 
	sta input_str
	lda stable.hi,y 
	sta input_str+1
	ldy #$00 
	lda (input_str),y
	jsr DrawCharToSpr
	inc output_str
	iny 
	lda (input_str),y
	jsr DrawCharToSpr
	inc output_str
	iny 
	lda (input_str),y
	jsr DrawCharToSpr
	
	add16 #$40-2:output_str
	iny 
	lda (input_str),y
	jsr DrawCharToSpr
	inc output_str
	iny 
	lda (input_str),y
	jsr DrawCharToSpr
	inc output_str
	iny 
	lda (input_str),y
	jmp DrawCharToSpr
}

DrawCharToSpr:
{
	stx lastX 
	sty lastY
	tax 
	lda multab_l,x 
	sta Character
	sta Characterrla
	lda multab_h,x 
	sta Character+1
	sta Characterrla+1
	lda #$33 
	sta $1
DrawChar:
	ldx #0
	ldy #$00 
ChrLoop:
	lda Character:$4408,x
	rla Characterrla:$4408,x
	sta (output_str),y
	iny 
	iny
	iny 
	inx 
	cpx #8 
	bne ChrLoop
	lda #$35 
	sta $1
	ldx lastX:#$00
	ldy lastY:#$00

	rts
}

/*
CopyRomFont:
{
	c64_ram_only()
	lda #$33        // make the CPU see the Character Generator ROM...
	sta $01           // ...at $D000 by storing %00110011 into location $01
	lda #$d8        // load high byte of $D000
	sta input_tile+1            // store it in a free location we use as vector
	lda #>UNPACKED_FONT
	sta output_col+1
	ldy #$00        // init counter with 0
	sty input_tile           // store it as low byte in the $FB/$FC vector
	sty output_col
	ldx #2        // we loop 16 times (16x255 = 4Kb)
copy:
	lda (input_tile),y      // read byte from vector stored in $fb/$fc
	rla (input_tile),y
	sta (output_col),y      // write to the RAM under ROM at same position
	iny                 // do this 255 times...
	bne copy       // ..for low byte $00 to $FF
	inc input_tile+1           // when we passed $FF increase high byte...
	inc output_col+1           // when we passed $FF increase high byte...
	dex                // ... and decrease X by one before restart
	bne copy       // We repeat this until X becomes Zero

	lda #$d0        
	sta input_tile+1    
	lda #(>UNPACKED_FONT)+2
	sta output_col+1
	ldx #$1        // we loop 16 times (16x255 = 4Kb)
copyU:
	lda (input_tile),y      // read byte from vector stored in $fb/$fc
	rla (input_tile),y
	sta (output_col),y      // write to the RAM under ROM at same position
	iny                 // do this 255 times...
	bne copyU       // ..for low byte $00 to $FF
	c64_ram_io()
	rts                 // return from subroutine
}

PrintDEC8:
{
	sty output_scr
	stx output_scr+1
	ldy #$af
	ldx #$ba
	sec
!:
	iny
	sbc #100
	bcs !-
!:
	dex
	adc #10
	bmi !-
	adc #$af
	sty hundreds
	stx tens
	sta ones 
	ldy #$00
.label hundreds = *+1			
	lda #$00
	sta (output_scr),y 
	iny

.label tens = *+1			
	lda #$00 
	sta (output_scr),y
	iny 

.label ones = *+1			
	lda #$00 
	sta (output_scr),y

	rts
}
*/
