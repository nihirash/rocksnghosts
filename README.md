# Rocks And Ghosts

Small Rocks'n'Diamonds-like game for Jupiter Ace(16K Ram Pack required).

## Development enviroment

I'm using sjasmplus(fork from from [z00m128](https://github.com/z00m128/sjasmplus)), [zx7b](https://github.com/antoniovillena/zx7b) packer and appmake from [z88dk](https://github.com/z88dk/z88dk) package.

Compilation made by GNU Make(I've developed game under macOS but it nothing changes with GNU/Linux) - if you want build it from Microsoft Windows - you should make some bat file that will pack every file that should be packed, run sjasmplus on main.asm and execute appmake to create tap/wav file.

If you'll need help with this process - create issue and I'll make help you/prepare bat-file.

As graphics and level design was used CharPad(yes, commodore tool). Just load as charset chars.raw and make yourown map sized(32x23) - put it in levels/raw directory, add filename of raw file to main.asm in `leveltable` block and your level in game(also you may change MAX_LEVELS constant).

## License

I've licensed project by [Nihirash's Coffeeware License](LICENSE). 

Please respect it - it isn't hard.