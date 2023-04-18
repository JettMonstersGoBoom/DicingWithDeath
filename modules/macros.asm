#importonce 

.macro border(col)
{
	.if (DEBUG==1)
	{
		lda #col 
		sta $d020 
	}
}

.macro pushall() 
{
	pha 
	txa 
	pha 
	tya 
	pha 
}

.macro pullall()
{
	pla
	tay 
	pla 
	tax 
	pla
}


.function _arg0(arg) {
    .if (arg.getType()==AT_IMMEDIATE) 
        .return CmdArgument(arg.getType(),<arg.getValue())
    .return CmdArgument(arg.getType(),arg.getValue())
}

.function _16bit_nextArgument(arg) {
	.if (arg.getType()==AT_IMMEDIATE) .return CmdArgument(arg.getType(),>arg.getValue())
	.return CmdArgument(arg.getType(),arg.getValue()+1)
}

.function _24bit_nextArgument(arg) {
 .if (arg.getType()==AT_IMMEDIATE)
	 .return CmdArgument(arg.getType(),arg.getValue()>>16)
 .return CmdArgument(arg.getType(),arg.getValue()+2)
}

#import "macros_16bit.asm"
#import "macros_24bit.asm"
