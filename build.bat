del bin\crap4k.prg
del bin\boot.prg
rem python entblocks.py ldtk1.0\samples.ldtk >world.asm

java -jar c:\Devtools\KickAssembler\KickAss.jar -odir bin -bytedump -showmem -vicesymbols "Boot.asm"
if exist "bin\boot.prg" (
	exomizer.exe sfx 2048 "bin\boot.prg" -o bin\crap4kexo.prg
)
