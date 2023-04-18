// java -jar KickAss.jar foo.asm -o foo.prg

// 0000 all closed 
// 0001 tl open  
// 0010 tr open 
// 0100 bl open 
// 1000 br open 
// test 

#import "modules/c64.asm"
#import "modules/macros.asm"

//	enums 

.enum {DAMAGE,HEALTH,GOLD,ROLLED,DIED,DMGUP,HLTHUP,GLDUP,BUFF}
.enum {SFX_WALKING,SFX_SWORD,SFX_MONSTER_EXPLODE,SFX_PLAYER_HURT,SFX_KEY,SFX_TREASURE,SFX_BOSS,SFX_BOSS_HURT,SFX_BOSS_EXPLODE,SFX_CHALICE,SFX_START,SFX_DEAD}

//	assemble flags 

.var MUSIC = 1
.var DEBUG = 0	//	enables BORDER macro

//	consts
.const RASTER_TOPLINE = $10 
.const RASTER_MIDLINE = $73
.const CHR_RAM = $3800
.const SPR_RAM = $2100
.const DIGITS_RAM = SPR_RAM - $100
.const SPR_BASE = SPR_RAM/64
.const VIC_SCR = $2800
.const SPR_PTR = VIC_SCR+$3f8 
.const PLAYFIELD = VIC_SCR + 10 + (9*40)
.const PLAYFIELDCOLOR = $d800 + 10 + (9*40)
.const UNPACKED_FONT = CHR_RAM+$400 

.const PRIZE_SPR = 1
.const MONSTER_SPR = 2

.const DICE_SPR = 3
.const DICE_FRAME = SPR_BASE + 9
.const DICE_WAIT = 3
.const DICE_DELAY = 50*1
.const DIGIT_FADETIME = 50
.const DEAD_DELAY = 50*2

.const NORTH 	= 1
.const EAST 	= 2
.const SOUTH 	= 3
.const WEST 	= 4

//	sprite positions for edges 
.const LEFT 	= $73
.const RIGHT 	= $e3 
.const TOP 		= $80+8+4
.const BOTTOM = $c0+4

.file [name="boot.prg", segments="CODE"]
// primary ZP 
.segment ZP [start=$04]																		
ticker:							.byte 0
//	move to player
playerDirection:		.byte 0 
movecounter:				.byte 0 
framecount:					.byte 0 
maxframes:					.byte 0
prizeIndex:					.byte 0 

ent_health:					.byte 0,0
ent_damage:					.byte 0,0
game_state:					.byte 0
Monster_Count:			.byte 0 
.align 2	
input_tile:					.word 0 
input_visit: 				.word 0 
input_str: 					.word 0 
output_scr:					.word 0 
output_str:					.word 0 
output_col:					.word 0 
output_col2:				.word 0 

destFunc:						.word 0 


.segment DATA [start=$8000]
GambleRND:					.fill 256,0
GambleRange:				.fill 256,0
multab_l:						.fill 256,0
multab_h:						.fill 256,0
MapVisit:						.fill 8*8,0
MapContents:				.fill 8*8,0
MapGreebs:						.fill 8*8,0

.segment CODE [start=$0400]
	#import "title_screen.asm"

*=$0800
.segment CODE "Boot"
Start:
{
	sei 
	ldx #$ff
	txs

	//	for PAL/NTSC
	{
		jsr SystemType
		//	for PAL setup 
		lda #$4 
		sta maxframes
		sta framecount

		lda SystemType.isNTSC 
		beq notNTSC 
		lda #$5
		sta maxframes
	notNTSC:
	}
	//	copy vic default state
	ldx #vic_len
vic_set:
	lda vic_settings,x 
	sta $d016,x 
	dex 
	bpl vic_set
	ldx #$00
	stx game_state
	//	setup
	jsr Joystick.Init
	jsr Title.Init
	.if (MUSIC==1) 
	{
		lda #$00 
		jsr SFX.Init
//		jsr DMX.Init
	}
	//	game loop
vwait:
	lda $d012 
	cmp #RASTER_MIDLINE 
	bne vwait

	border(3)

	//	handle difference between NTSC/PAL 
	//	here we skip a frame on NTSC so the logic will always run 50 hz 
	dec framecount
	bpl stepOS 
	lda maxframes
	sta framecount
stepOS:			
	//	if framecount == 5 then it's the frame we should skip on NTSC machines
	//	this value wont happen on PAL machines
	lda framecount
	cmp #$5 
	beq noTick
	inc ticker


	.if (MUSIC==1)
	{
		border(2)
		jsr SFX.Update
//		jsr Random.Init

//		jsr DMX.Play
	}

//	border(5)
//	jsr $400a
	border(1)
	//	step the TaskOS				
	jsr TaskOS.Step
noTick:
	jsr Joystick

	border(0)
	jmp vwait
}


.macro SFX_EFFECT(index)
{
	.if (MUSIC==1)
	{
		lda #index 
		sta SFX.effect
	}
}

.if (MUSIC==1)
{
	#import "SFX.asm"
}


//	import all the parts
#import "Room.asm"
#import "Utils.asm"
#import "Dice.asm"
#import "Prize.asm"
#import "Monster.asm"
#import "Hero.asm"
#import "Strings.asm"
#import "Game.asm"
#import "Title.asm"

//	modules
#import "modules/random.asm"
#import "modules/taskos.asm"
#import "modules/systemtype.asm"
#import "modules/joystick.asm"

	//	d016
vic_settings:
	// $d016   17  18  19  1a  1b  1c  1d  1e  1f
  .byte $c8,$00,$af,$7b,$f0,$00,$3f,$00,$07,$00
	//	$d020  21 22 23 24 25 26
 	.byte $00,$00,$1,$2,0,00,01
	 //	sprites
	.byte $c,$0,$0,$2,$2,$2,$1,$1
.label vic_len = * - vic_settings

//	align the binary data
	.align 256 

tileset: 
	.segment CODE "Tileset"
	.import binary "resources\landecm - tiles.bin"

tileattr:
	.segment CODE "Tile Attributes"
	.import binary "resources\landecm - CharAttribs_L1.bin"

Map:
	.segment CODE "Map"
	.import binary "resources\map - Map (8bpc, 8x8).bin"

	* = SPR_RAM "Sprites"
	.import binary "resources\critters - sprites.bin"
	* = CHR_RAM "Chars"
	.import binary "resources\landecm - chars.bin"
	* = CHR_RAM+$200 "Map Chars"
	.import binary "resources\map - chars.bin"

