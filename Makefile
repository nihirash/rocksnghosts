all: rng.tap

wav: rng.wav

welldone.zx7: welldone.raw
	zx7b welldone.raw welldone.zx7

title.zx7: title.raw
	zx7b title.raw title.zx7

levels/levels.asm: levels/raw/*
	(cd levels && ./build_levels.sh)

rng.bin: *.asm levels/levels.asm title.zx7 welldone.zx7
	sjasmplus main.asm

rng.tap: rng.bin
	appmake +ace --org 16384 --blockname "rng"  -b rng.bin

rng.wav: rng.bin
	appmake +ace --org 16384 --blockname "rng" --audio -b rng.bin

clean:
	rm *.tap *.wav rng.bin *.zx7 levels/levels.asm levels/*.zx7
