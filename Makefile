all: rng.tap

wav: rng.wav

welldone.zx7: welldone.raw
	zx7b welldone.raw welldone.zx7

title.zx7: title.raw
	zx7b title.raw title.zx7

levels/levels.asm: levels/raw/*
	(cd levels && ./build_levels.sh)

rng.tap: *.asm levels/levels.asm title.zx7 welldone.zx7
	sjasmplus main.asm

clean:
	rm *.tap *.wav rng.bin *.zx7 levels/levels.asm levels/*.zx7
