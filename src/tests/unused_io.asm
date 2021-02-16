SECTION "Unused IO Test", ROMX
UnusedIOTest::
    ; Check unused IO regs (except CGB-only registers)
    ld hl, UnusedIOBlocks
.blockCheckLoop
    ld a, [hli]
    and a
    jr z, .endCheckLoop
    ld c, a
    ld a, [hli]
    ld b, a
    call CheckRegisters
    jr .blockCheckLoop
.endCheckLoop

    ; Check if running on DMG, skip next checks otherwise
    ld a, [hDeviceModel]
    cp $03
    jr c, .runTestsDMG

    ; Return success if running on CGB/AGB/AGS
    ld de, $0000
    ret

    ; Run same tests for CGB registers if on DMG
.runTestsDMG
    ld a, [hli]
    and a
    jr z, .endCheckLoopDMG
    ld c, a
    ld a, [hli]
    ld b, a
    call CheckRegisters
    jr .runTestsDMG
.endCheckLoopDMG
    
    ; Return success
    ld de, $0000
    ret

UnusedIOBlocks::
    ; # FORMAT:
    ;   First byte  - Memory Address (-$FF00)
    ;   Second byte - Block Size (Amount of bytes starting at memory address that should be $FF)
    db $03, $01
    db $08, $07
    db $15, $01
    db $1F, $01
    db $27, $09
    db $4E, $01
    db $57, $11
    db $63, $03
    db $71, $01
    db $78, $08
    db $00

UnusedIOBlocksDMG::
    ; Same as above, except it includes CGB registers which should read $FF on DMG models
    db $4D, $0A
    db $68, $04
    db $70, $08
    db $00

CheckRegisters::
    ; Loop through IO registers and check for $FF
    ldh a, [c]
    inc a
    jr nz, .invalidRegValue
    inc c
    dec b
    jr nz, CheckRegisters
    ret
.invalidRegValue
    ; Destroy return vector to test routine
    pop af

    ; Write base string to RAM
    ld hl, _RAM
    ld de, strInvalidRead
    call Strcpy

    ; Replace XX in error string with ASCII values
    ld a, c
    call ConvertToASCII
    ld hl, (_RAM + strlen("$FF"))
    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a

    ; Load error string pointer and return
    ld de, _RAM
    ret

strInvalidRead: db "$FFXX not $FF", 0