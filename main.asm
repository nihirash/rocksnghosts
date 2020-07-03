SINCLAIR1 = #EFFE

SCREEN = #2000
SCREEN_END = SCREEN + 768
CHARS = #2800

PLAYER_LEFT = 3
PLAYER_RIGHT = 0
PLAYER_DEAD = 11

BOULDER = 6
FALLING_BOULDER = 7
BRICK = 5
FIELD = 8
CRYSTAL = 9
FALLING_CRYSTAL = 10

ENEMY_LEFT = 12
ENEMY_RIGHT = 13
ENEMY_UP = 14
ENEMY_DOWN = 15
ENEMY_DEAD = 16

MAX_LEVELS = 12

    DEVICE ZXSPECTRUM48
    org #4000
start:
    ld sp, start - 1
    call cls
    ; Load font
    ld de, CHARS, hl, sprites, bc, 1016 : ldir 
    ;ld de, CHARS + 1015, hl, sprites : call dzx7
    ; Start screen
    ld de, SCREEN_END - 1, hl, title : call dzx7
.intoWait
    xor a
    ld bc, 32766
    in a, (c)
    rrca 
    jr c, .intoWait

    xor a : ld (cur_level), a
level_state:
    call restartLev
    call drawStatusLine
.loop
    call controls
    ld a, (playerSprite) : xor 1 : ld (playerSprite), a : inc a
    ld hl, (playerPos) : ld (hl), a
    call level_life
    dup 3
    halt
    edup 
    ld a, (is_alive) : or a : call z, die
    ld a, (crystals), b, a, a, (crystals_total)
    cp b : call z, nextLevel
    ld bc, 64510 : in a, (c) : and 8 : jr nz, .loop 
    xor a : ld (is_alive), a  
    jr .loop

gamefinished:
    call cls
    ld de, SCREEN_END - 1, hl, welldone : call dzx7
.loop
    xor a
    ld bc, 32766
    in a, (c)
    rrca 
    jr c, .loop
    jp start
nextLevel:
    ld a, (cur_level)
    inc a
    cp MAX_LEVELS
    jp nc, gamefinished
    ld (cur_level), a
    di
    ld b, #ff
.beep
    push bc
    ld a, #7f
    in a, (#fe)
1
    nop : nop 
    djnz 1B
    out (#fe), a
    pop bc
    djnz .beep
    ei
    jp restartLev

level_life:
    call moveEnemies
    ; Physics
    ld ix, #0A09 : call falling
    ld ix, #0706 : call falling
    call bangAnim
    ret

bangAnim:
    ld hl, SCREEN + 32, bc, 736
.loop
    ld a, (hl)
    cp ENEMY_DEAD : jr z, .nextFrame
    cp ENEMY_DEAD + 1 : jr z, .fillZero
.exitLoop
    inc hl
    dec bc : ld a, b : or c : jr nz, .loop
    ret
.nextFrame
    inc (hl)
    jr .exitLoop
.fillZero
    xor a : ld (hl), a
    jr .exitLoop

controls:
    ld bc, SINCLAIR1 : in a, (c) : and 31

    push af: bit 4, a  : call z, p_left : pop af
    push af : bit 3, a : call z, p_right : pop af
    push af : bit 2, a : call z, p_down : pop af
    push af : bit 1, a : call z, p_up : pop af
    ret

moveEnemies:
    ld hl, SCREEN + 32
    ld bc, 736
.loop
    push bc, hl
    ld a, (hl)
    ld iy, hl 
    cp ENEMY_UP    : jr z, .enemyUp
    cp ENEMY_LEFT  : jr z, .enemyLeft
.loopExit
    pop hl, bc
    inc hl
    dec bc
    ld a, b : or c : jr nz, .loop
    ld hl, SCREEN_END
    ld b, 32
.rowLoop
    push bc, hl
    ld b, 23
.colLoop
    push hl, bc
    ld iy, hl
    ld a, (hl)
    cp ENEMY_RIGHT : jr z, .enemyRight
    cp ENEMY_DOWN  : jr z, .enemyDown
.rdLoopExit
    pop bc, hl
    ld de, 32 : sub hl, de
    djnz .colLoop

    pop hl, bc
    dec hl
    djnz .rowLoop
    ret
.kill
    xor a : ld (is_alive), a
    jp .loopExit

.enemyUp
    ld de, -32 : add hl, de
    ld a, (hl)
    and a : jr z, .forceMove
    cp PLAYER_RIGHT     : jr z, .kill
    cp PLAYER_LEFT      : jr z, .kill
    cp PLAYER_RIGHT + 1 : jr z, .kill
    cp PLAYER_LEFT  + 1 : jr z, .kill
    ld d, ENEMY_LEFT   : call .changeDirection
    jr .loopExit

.enemyLeft
    dec hl
    ld a, (hl)
    and a : jr z, .forceMove
    cp PLAYER_RIGHT    : jr z, .kill
    cp PLAYER_LEFT     : jr z, .kill
    cp PLAYER_RIGHT + 1: jr z, .kill
    cp PLAYER_LEFT  + 1: jr z, .kill
    ld d, ENEMY_DOWN   : call .changeDirection
    jr .loopExit

.enemyDown
    ld de, 32 : add hl, de
    ld a, (hl)
    and a : jr z, .forceMoveDR
    cp PLAYER_RIGHT    : jr z, .killDR
    cp PLAYER_LEFT     : jr z, .killDR
    cp PLAYER_RIGHT + 1: jr z, .killDR
    cp PLAYER_LEFT  + 1: jr z, .killDR
    ld d, ENEMY_RIGHT   : call .changeDirection
    jr .rdLoopExit

.enemyRight
    inc hl
    ld a, (hl)
    and a : jr z, .forceMoveDR
    cp PLAYER_RIGHT    : jr z, .killDR
    cp PLAYER_LEFT     : jr z, .killDR
    cp PLAYER_RIGHT + 1: jr z, .killDR
    cp PLAYER_LEFT  + 1: jr z, .killDR
    ld d, ENEMY_UP     : call .changeDirection
    jp .rdLoopExit

.forceMove
    ld a, (iy)
    ld (hl), a
    xor a 
    ld (iy), a
    jp .loopExit

.forceMoveDR
    ld a, (iy) : ld (hl), a 
    xor a
    ld (iy), a
    jp .rdLoopExit

.changeDirection:
    ld a, d
    ld (iy), a
    ret

.killDR
    xor a : ld (is_alive), a
    jp .rdLoopExit

killPlayer:
    push af
    xor a : ld (is_alive), a
    pop af
    ret

p_left:
    ld a, (playerSprite) : cp 2 : jr z, .movement : cp 3 : jr z, .movement
    
    ld a, PLAYER_LEFT : ld (playerSprite), a 

.movement
    ld hl, (playerPos) : dec hl
    ld a, (hl) : and a : jr z, forceMove    
    cp ENEMY_DOWN : call z, killPlayer
    cp ENEMY_UP : call z, killPlayer
    cp ENEMY_LEFT : call z, killPlayer
    cp ENEMY_RIGHT : call z, killPlayer
    cp FIELD : jr z, forceMove
    cp CRYSTAL : jp z, eatCrystal
    cp BOULDER : ret nz
    ld de, hl : dec de
    ld a, (de) : and a : ret nz
    ld a, BOULDER : ld (de), a
    xor a : ld (hl), a
    ld hl, (playerPos) : xor a : ld (hl) , a : dec hl : ld (playerPos), hl
    ret

forceMove:    
    ex hl, de
    ld hl, (playerPos) : xor a : ld (hl), a
    ex hl, de
    ld (playerPos), hl
    ret


p_right: 
    ld a, (playerSprite) : and a : jr z, .movement
    cp 1 : jr z, .movement

    ld a, PLAYER_RIGHT : ld (playerSprite), a 
.movement
    ld hl, (playerPos) : inc hl
    ld a, (hl) : and a : jr z, forceMove
    cp ENEMY_DOWN : call z, killPlayer
    cp ENEMY_UP : call z, killPlayer
    cp ENEMY_LEFT : call z, killPlayer
    cp ENEMY_RIGHT : call z, killPlayer
    cp FIELD : jr z, forceMove
    cp CRYSTAL : jp z, eatCrystal
    cp BOULDER : ret nz
    ld de, hl : inc de
    ld a, (de) : and a : ret nz
    ld a, BOULDER : ld (de), a
    xor a : ld (hl), a
    ld hl, (playerPos) : xor a : ld (hl) , a : inc hl : ld (playerPos), hl
    ret

p_down:
    ld hl, (playerPos) : ld de, 32 : add hl, de
    ld a, (hl) : and a : jr z, forceMove
    cp FIELD : jr z, forceMove
    cp CRYSTAL : jp z, eatCrystal
    cp ENEMY_DOWN : call z, killPlayer
    cp ENEMY_UP : call z, killPlayer
    cp ENEMY_LEFT : call z, killPlayer
    cp ENEMY_RIGHT : call z, killPlayer
    ret

p_up:
    ld hl, (playerPos) : ld de, -32 : add hl, de
    ld a, (hl) : or a : jp z, forceMove
    cp FIELD : jp z, forceMove
    cp CRYSTAL : jp z, eatCrystal
    cp ENEMY_DOWN : call z, killPlayer
    cp ENEMY_UP : call z, killPlayer
    cp ENEMY_LEFT : call z, killPlayer
    cp ENEMY_RIGHT : call z, killPlayer
    ret

killEnemy
    push hl
    call bigBang
    pop hl
    ret

; Any falling item can be processed here
; IXl - usual item tile
; IXh - falling tile
falling:
    ld hl, SCREEN_END
    ld bc, 736
.loop
    ld a, (hl)
    cp ixl : jr z, .processUsualItem
    cp ixh : jr z, .processFallingItem
.skip
    dec hl
    dec bc
    ld a, b : or c : jr nz, .loop
    ret
.processUsualItem
    DISPLAY 'process usual ', $
    push hl
    ld de, 32 : add hl, de
    ld a, (hl)
    cp ENEMY_LEFT  : call z, killEnemy
    cp ENEMY_RIGHT : call z, killEnemy
    pop hl
    or a
    jr nz, .checkSides
    ld a, ixh, (hl), a
    jr .skip
.checkSides
    push hl
    ld de, 33 : add hl, de : ld a, (hl)
    and a
    jr nz, .checkLeft
    pop hl 
    push hl
    inc hl
    ld a, (hl) : ld de, 32 : add hl, de
    and a
    jr nz, .checkLeft
    ld a, (hl)
    cp ENEMY_LEFT  : call z, killEnemy
    cp ENEMY_RIGHT : call z, killEnemy
    ld a, ixh, (hl), a
    pop hl
    xor a : ld (hl), a
    jr .skip
.checkLeft
    pop hl
    push hl
    ld de, 31 : add hl, de : ld a, (hl)
    or a
    jr nz, .notMove
    pop hl : push hl
    dec hl : ld a, (hl), de, 32 : add hl, de
    and a
    jr nz, .notMove
    ld a, (hl)
    cp ENEMY_LEFT  : call z, killEnemy
    cp ENEMY_RIGHT : call z, killEnemy
    ld a, ixh, (hl), a
    pop hl : xor a : ld (hl), a
    jr .skip
.notMove
    pop hl
    jr .skip
.processFallingItem

    DISPLAY 'process falling ', $
    push hl
    ld de, 32 : add hl, de
    ld a, (hl) 
    cp 1 : jr z, .kill
    cp 2 : jr z, .kill
    cp 3 : jr z, .kill
    cp 4 : jr z, .kill
    cp ENEMY_LEFT  : call z, killEnemy
    cp ENEMY_RIGHT : call z, killEnemy
    pop hl
    or a
    jr nz, .notFal
    xor a : ld (hl), a
    push hl
    add hl, de 
    ld a, ixh, (hl), a
    pop hl
    jp .skip
.notFal    
    ld a, ixl, (hl), a
    jp .skip

.kill
    pop hl
    xor a : ld (is_alive), a
    ret

cls:
    xor a
    ld hl, SCREEN, de, SCREEN + 1, bc, 768, (hl), a
    ldir
    ret

eatCrystal:
    ; Some beep
    di
    ld b, #7f
.loop
    push bc
    ld a, #7f
    in a, (#fe)
    djnz $
    out (#fe), a
    pop bc
    djnz .loop
    ei

    xor a : ld (hl), a : ex hl, de
    ld hl, (playerPos) : ld (hl), a : ex hl, de : ld (playerPos), hl
    ld hl, crystals : inc (hl)
drawStatusLine:
    ld de, crystals_total_string, a, (crystals) : call pnum
    ld de, crystals_get, a, (crystals_total) : call pnum
    ld a, (cur_level) : inc a : ld de, level_number : call pnum
    ld de, SCREEN, hl, top_line, bc, status_line_size : ldir
    ret


smallPause:
    ld b, 5
1   halt
    djnz 1B
    ret

die:
    
    di
    ld b, #ff
.beep
    push bc
    ld a, #ff : sub b : ld b, a
    ld a, #7f
    in a, (#fe)
1
    nop
    djnz 1B
    out (#fe), a
    pop bc
    djnz .beep
    ei

    ld hl, (playerPos)
    call bigBang
    ld b, 20
.loop
    push bc
    halt
    call level_life
    pop bc
    djnz .loop

; Make here unpack level data
restartLev:
    ld a, 1, (is_alive), a
.introLoop
    ld hl, SCREEN + 32, de, SCREEN + 33, a, FIELD, (hl), a, bc, 736 : ldir
    call smallPause
    ld hl, SCREEN + 32, de, SCREEN + 33, bc, 736, a, 16, (hl), a : ldir 
    call smallPause
    ld hl, SCREEN + 32, de, SCREEN + 33, bc, 736, a, 17, (hl), a : ldir
    call smallPause
    ; Extract level
    ld a, (cur_level), h, 0, l, a, de, leveltable
    add hl, hl : add hl, de
    ld de, (hl) 
    ld hl, SCREEN_END - 1
    ex hl, de
    call dzx7

    xor a : ld (crystals), a, (crystals_total), a
    
    ld bc, 736
    ld hl, SCREEN_END
.loop
    ld a, (hl)
    or a : jr z, .loopexit
    cp 05 : jr c, .foundStart 
    cp CRYSTAL : jr z, .foundCrystal 
.loopexit
    dec hl : dec bc
    ld a, b : or c : jr nz, .loop
    jp drawStatusLine
.foundStart
    ld (playerPos), hl
    jr .loopexit
.foundCrystal
    ld de, crystals_total
    ex hl, de
    inc (hl)
    ex hl, de
    jr .loopexit
; HL - top center
bigBang:
    dec hl
    ld a, (hl)
    cp BRICK
    jr z, .skip1
    ld a, ENEMY_DEAD, (hl), a
.skip1
    inc hl
    ld a, (hl)
    cp BRICK
    jr z, .skip2
    ld a, ENEMY_DEAD, (hl), a
.skip2
    inc hl
    ld a, (hl)
    cp BRICK
    jr z, .skip3
    ld a, ENEMY_DEAD, (hl), a
.skip3
    push de
    ld de, 30 : add hl, de
    pop de
    dup 3
    ld a, (hl)
    cp BRICK
    jr z, 1F
    ld a, ENEMY_DEAD, (hl), a
1   inc hl
    edup
    ret

    ret
; A - number
; DE - buffer
pnum:
        ld hl, .table
        ld b, 3
.pdb1   ld c, '0' - 1
.pdb2   inc c
        sub (hl)
        jr nc, .pdb2
        add a, (hl)
        push af
        ld a, c
        ld (de), a
        inc de
        pop af
        inc hl
        djnz .pdb1
        ret
.table  db 100, 10, 1

top_line              db "Crystals: "
crystals_total_string db "   /"
crystals_get          db "       Level: "
level_number          db "    "
status_line_size = $ - top_line
is_alive       db 1
playerPos      dw SCREEN + 66 
playerSprite   db PLAYER_RIGHT
crystals_total db 5
crystals       db 0

level_data
    db 30
    db 0

sprites
    incbin "chars.raw"
    include "dzx7.asm"

cur_level   db  0

    incbin "welldone.zx7"
welldone = $ - 1

    incbin "title.zx7"
title = $ - 1
leveltable
    dw level1 
    dw level2
    dw level3
    dw level4
    dw level5
    dw level6
    dw level7
    dw level8
    dw level9 
    dw level10
    dw level11
    dw level12

    include "levels/levels.asm"
    DISPLAY "SIZE: ",  $ - start
    display "Last addr: ", $

    SAVEBIN "rng.bin", start, $ - start