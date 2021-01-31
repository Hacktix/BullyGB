SECTION "Initial RAM State Test", ROMX
InitRAMTest::
    ; Store amount of $FF or $00 values in DE
    ld hl, _RAM
    xor a
    ld bc, $2000
    ld d, a
    ld e, a
.ramChecksumLoop
    ld a, [hli]
    cp $FF
    jr z, .nonSusRAM
    and a
    jr nz, .nonSusRAM
    inc de
.nonSusRAM
    dec bc
    ld a, b
    or c
    jr nz, .ramChecksumLoop

    ; Check if DE is $2000 (all RAM values either $FF or $00)
    ld a, d
    cp $20
    jr nz, .validInitRAM
    ld de, strNonRandomRAM
    ret
.validInitRAM
    ld de, $0000
    ret

strNonRandomRAM: db "Uninitialized RAM not randomized", 0