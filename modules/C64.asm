#importonce 

// cpu
.label cpu6510_ddr  = 0
.label cpu6510_port = 1

SID:{
	.label v1_frequency_l	= $d400
	.label v1_frequency_h	= $d401
	.label v1_pulse_width_l	= $d402
	.label v1_pulse_width_h	= $d403
	.label v1_control				= $d404
	.label v1_attack_decay	= $d405
	.label v1_sustain_release	= $d406

	.label v2_frequency_l	= $d407
	.label v2_frequency_h	= $d408
	.label v2_pulse_width_l	= $d409
	.label v2_pulse_width_h	= $d40a
	.label v2_control				= $d40b
	.label v2_attack_decay	= $d40c
	.label v2_sustain_release	= $d40d

	.label v3_frequency_l	= $d40e
	.label v3_frequency_h	= $d40f
	.label v3_pulse_width_l	= $d410
	.label v3_pulse_width_h	= $d411
	.label v3_control				= $d412
	.label v3_attack_decay	= $d413
	.label v3_sustain_release	= $d414

	.label filter_cutoff_l	= $d415
	.label filter_cutoff_h	= $d416
	.label filter	= $d417
	.label volume	= $d418

	.label v3_out	= $d41b
	.label v3_adsr_out	= $d41c
}


VIC:{
	.label Sprite0_x     = $d000
	.label Sprite0_y     = $d001
	.label Sprite1_x     = $d002
	.label Sprite1_y     = $d003
	.label Sprite2_x     = $d004
	.label Sprite2_y     = $d005
	.label Sprite3_x     = $d006
	.label Sprite3_y     = $d007
	.label Sprite4_x     = $d008
	.label Sprite4_y     = $d009
	.label Sprite5_x     = $d00a
	.label Sprite5_y     = $d00b
	.label Sprite6_x     = $d00c
	.label Sprite6_y     = $d00d
	.label Sprite7_x     = $d00e
	.label Sprite7_y     = $d00f
	.label spr_hi_x   = $d010
	.label cr1        = $d011
	.label raster     = $d012
	.label lp_x       = $d013
	.label lp_y       = $d014
	.label spr_ena    = $d015
	.label cr2        = $d016
	.label spr_exp_y  = $d017
	.label mem        = $d018
	.label irq        = $d019
	.label irq_ena    = $d01a
	.label spr_dp     = $d01b
	.label spr_mcolor = $d01c
	.label spr_exp_x  = $d01d
	.label spr_ss_col = $d01e
	.label spr_sd_col = $d01f
	.label border     = $d020
	.label bg_color0  = $d021
	.label bg_color1  = $d022
	.label bg_color2  = $d023
	.label bg_color3  = $d024
	.label spr_color1 = $d025
	.label spr_color2 = $d026
	.label Sprite0_color = $d027
	.label Sprite1_color = $d028
	.label Sprite2_color = $d029
	.label Sprite3_color = $d02a
	.label Sprite4_color = $d02b
	.label Sprite5_color = $d02c
	.label Sprite6_color = $d02d
	.label Sprite7_color = $d02e
}

CIA1:
{
//  cia1
	.label pra				=$dc00
	.label prb       =$dc01
	.label ddra      =$dc02
	.label ddrb      =$dc03
	.label irq_ctrl 			=$dc0d
}

CIA2:
{
	.label pra       =$dd00
	.label prb       =$dd01
	.label ddra      =$dd02
	.label ddrb      =$dd03
	.label irq_ctrl 			=$dd0d
}

.label nmi_routine_addr   =$fffa
.label reset_routine_addr =$fffc
.label irq_routine_addr   =$fffe

.macro cia_disable_irq () { 
	lda #$7f
	sta CIA1.irq_ctrl
	sta CIA2.irq_ctrl
	lda CIA1.irq_ctrl
	lda CIA2.irq_ctrl
} 

.macro VIC_bank_0000	() {
	lda #$3 
	sta CIA2.ddra
	sta CIA2.pra
} 

.macro VIC_bank_4000 () {
	lda #$3 
	sta CIA2.ddra
	lda #$2
	sta CIA2.pra
}

.macro VIC_bank_8000 () {
	lda #$3 
	sta CIA2.ddra
	lda #$1
	sta CIA2.pra
}

.macro VIC_bank_c000 () {
	lda #$3 
	sta CIA2.ddra
	lda #$0
	sta CIA2.pra
}

.macro VIC_enable_mc () { 
	lda VIC.cr2 
	ora #$10 
	sta VIC.cr2
}

.macro VIC_disable_mc () { 
	lda VIC.cr2
	and #$ef 
	sta VIC.cr2
}

.macro VIC_enable_bitmap	() { 
	lda VIC.cr1 
	ora #$20 
	sta VIC.cr1
}

.macro VIC_enable_ecm	() { 
	lda VIC.cr1 
	ora #$40 
	sta VIC.cr1
}

.macro VIC_disable_bitmap	() { 
	lda VIC.cr1 
	and #$df 
	sta VIC.cr1
} 

.macro VIC_24_rows	() { 
	lda VIC.cr1 
	and #$7f 
	sta VIC.cr1
} 

.macro VIC_25_rows () { 
	lda VIC.cr1 
	ora #$8 
	sta VIC.cr1 
} 

.macro VIC_38_columns	() { 
	lda VIC.cr2 
	and #$f7 
	sta VIC.cr2 
} 

.macro VIC_40_columns () { 
	lda VIC.cr2 
	ora #$8 
	sta VIC.cr2
} 

.macro VIC_disable_irq () {
	lda #$00 
	sta VIC.irq_ena
	inc VIC.irq
} 

.macro VIC_enable_irq () {
	lda #$01
	sta VIC.irq_ena
	inc VIC.irq
} 

.macro VIC_charset_0000 () {
	lda VIC.mem 
	and #$f1 
	sta VIC.mem 
} 

.macro VIC_charset_0800 () {
	lda VIC.mem 
	and #$f1 
	ora #$2
	sta VIC.mem 
} 

.macro VIC_charset_1000 () {
	lda VIC.mem 
	and #$f1 
	ora #$4
	sta VIC.mem 
} 

.macro VIC_charset_1800 () {
	lda VIC.mem 
	and #$f1 
	ora #$6
	sta VIC.mem 
} 

.macro VIC_charset_2000 () {
	lda VIC.mem 
	and #$f1 
	ora #$8
	sta VIC.mem 
} 

.macro VIC_charset_2800 () {
	lda VIC.mem 
	and #$f1 
	ora #$a
	sta VIC.mem 
} 

.macro VIC_charset_3000 () {
	lda VIC.mem 
	and #$f1 
	ora #$c
	sta VIC.mem 
} 

.macro VIC_charset_3800 () {
	lda VIC.mem 
	and #$f1 
	ora #$e
	sta VIC.mem 
} 

.macro VIC_bitmap_0000 () { 
	lda VIC.mem 
	and #$f7 
	sta VIC.mem
} 

.macro VIC_bitmap_2000 () { 
	lda VIC.mem 
	ora #$8 
	sta VIC.mem
} 

.macro set_bg_color	(color) { 
	lda #color
	sta VIC.bg_color0
} 

.macro set_border_color	(color) { 
	lda #color
	sta VIC.border
} 

.macro c64_ram_only	() {
	lda #$7 
	sta cpu6510_ddr
	lda #$00 
	sta cpu6510_port
}

.macro c64_ram_io	() {
	lda #$7 
	sta cpu6510_ddr
	lda #$05 
	sta cpu6510_port
}

.macro c64_ram_io_kernal	() {
	lda #$7 
	sta cpu6510_ddr
	lda #$06 
	sta cpu6510_port
}

.macro c64_ram_io_basic	() {
	lda #$7 
	sta cpu6510_ddr
	sta cpu6510_port
}

.macro c64_ram_charset	() {
	lda #$7 
	sta cpu6510_ddr
	lda #$1
	sta cpu6510_port
}

.macro c64_ram_charset_kernal	() {
	lda #$7 
	sta cpu6510_ddr
	lda #$2
	sta cpu6510_port
}

.macro c64_ram_charset_basic	() {
	lda #$7 
	sta cpu6510_ddr
	lda #$3
	sta cpu6510_port
}

//	lda # (((screenchars & $3fff) / $0400) << 4) + (((screenpixels & $3fff) / $0800) << 1)
//	sta $d018
//// base: divisible by $400, $0000-$3c00 allowed
////macro void VIC.screen(word const base) () {
////    VIC.mem = (VIC.mem & $0f) | (base >> 6)
////}

.macro c64_screen (screen) { 
	lda VIC.mem 
	and #$f 
	ora #((screen)>>6)
	sta VIC.mem 
} 


