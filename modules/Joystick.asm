#importonce 

Joystick:
{
.segment ZP
input_dx: .byte 0 
input_dy: .byte 0 
input_btn:  .byte 0
last_input_dx: .byte 0 
last_input_dy: .byte 0 
last_input_btn:  .byte 0

.segment CODE
    lda #$00 
    sta CIA1.ddra 
    lda input_dx
    sta last_input_dx
    lda input_dy
    sta last_input_dy
    lda input_btn
    sta last_input_btn
    ldx #$00 
    ldy #$00 

    lda CIA1.pra     // get input from port 2 only
djrrb:
    lsr           // the accumulator. this least significant
    bcs djr0      // 5 bits contain the switch closure
    dey           // information. if a switch is closed then it
djr0:
    lsr           // produces a zero bit. if a switch is open then
    bcs djr1      // it produces a one bit. The joystick dir-
    iny           // ections are right, left, forward, backward
djr1:
    lsr           // bit3=right, bit2=left, bit1=backward,
    bcs djr2      // bit0=forward and bit4=fire button.
    dex           // at rts time dx and dy contain 2's compliment
djr2:
    lsr           // direction numbers i.e. $ff=-1, $00=0, $01=1.
    bcs djr3      // dx=1 (move right), dx=-1 (move left),
    inx           // dx=0 (no x change). dy=-1 (move up screen),
djr3:
    lsr           // dy=0 (move down screen), dy=0 (no y change).
    stx input_dx        // the forward joystick position corresponds
    sty input_dy        // to move up the screen and the backward
    lda #$00 
    sbc #0 
    sta input_btn
    rts           // position to move down screen.
    //
    // at rts time the carry flag contains the fire
    // button state. if c=1 then button not pressed.
    // if c=0 then pressed.

Init:
	lda #$00 
	sta input_dx
	sta input_dy
	sta input_btn
	rts
}


