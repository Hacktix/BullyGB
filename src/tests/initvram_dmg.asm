SECTION "Initial VRAM Test", ROMX
InitVRAMTest::
    ; Load pointer to VRAM into HL
    ld hl, $8000

    ; Check first 16 bytes for zero
    ld b, $00
    ld de, $0010
    call CheckZero           ; Increments B to $01 if non-zero bytes are found
    dec b
    jr nz, .validFirstBytes
    jr .invalidTileData
.validFirstBytes
    inc b

    ; Compare proper tile data to expected values
    ld de, ExpectedTileData
    ld bc, EndExpectedTileData - ExpectedTileData
.tileDataComparisonLoop
    ; Compare byte to expected tile data byte
    ld a, [de]
    inc de
    cp [hl]
    inc hl
    jr nz, .invalidTileData
    ; Compare following byte to $00
    ld a, [hli]
    and a
    jr nz, .invalidTileData
    dec bc
    ld a, b
    or c
    jr nz, .tileDataComparisonLoop
    jr .validTileData
.invalidTileData
    ld de, strInvalidTileData
    ret
.validTileData

    ; Check next $1764 bytes for zero
    ld b, $00
    ld de, $1764
    call CheckZero           ; Increments B to $01 if non-zero bytes are found
    dec b
    jr nz, .validInbetween
    jr .invalidTileData
.validInbetween
    inc b

    ; Compare background map data
    ld de, ExpectedMapData
    ld bc, EndExpectedMapData - ExpectedMapData
    call Memcmp
    jr nz, .invalidMapData

    ; Check next $6D0 bytes for zero
    ld b, $00
    ld de, $06D0
    call CheckZero           ; Increments B to $01 if non-zero bytes are found
    dec b
    jr nz, .validEnd
.invalidMapData
    ld de, strInvalidMapData
    ret
.validEnd

    ; Clear DE and return - test passed
    ld de, $00
    ret

;------------------------------------------------------------------------
; Checks DE bytes starting at HL and compares them to $00, increments
; B by 1 and returns early if a non-zero byte is encountered.
;------------------------------------------------------------------------
CheckZero:
    ld a, [hli]
    and a
    jr z, .validZero
    inc b
    ret
.validZero
    dec de
    ld a, d
    or e
    jr nz, CheckZero
    ret

strInvalidTileData: db "Invalid initial   tile data", 0
strInvalidMapData: db "Invalid initial   map data", 0

ExpectedTileData:
db $F0, $F0, $FC, $FC, $FC, $FC, $F3, $F3
db $3C, $3C, $3C, $3C, $3C, $3C, $3C, $3C
db $F0, $F0, $F0, $F0, $00, $00, $F3, $F3
db $00, $00, $00, $00, $00, $00, $CF, $CF
db $00, $00, $0F, $0F, $3F, $3F, $0F, $0F
db $00, $00, $00, $00, $C0, $C0, $0F, $0F
db $00, $00, $00, $00, $00, $00, $F0, $F0
db $00, $00, $00, $00, $00, $00, $F3, $F3
db $00, $00, $00, $00, $00, $00, $C0, $C0
db $03, $03, $03, $03, $03, $03, $FF, $FF
db $C0, $C0, $C0, $C0, $C0, $C0, $C3, $C3
db $00, $00, $00, $00, $00, $00, $FC, $FC
db $F3, $F3, $F0, $F0, $F0, $F0, $F0, $F0
db $3C, $3C, $FC, $FC, $FC, $FC, $3C, $3C
db $F3, $F3, $F3, $F3, $F3, $F3, $F3, $F3
db $F3, $F3, $C3, $C3, $C3, $C3, $C3, $C3
db $CF, $CF, $CF, $CF, $CF, $CF, $CF, $CF
db $3C, $3C, $3F, $3F, $3C, $3C, $0F, $0F
db $3C, $3C, $FC, $FC, $00, $00, $FC, $FC
db $FC, $FC, $F0, $F0, $F0, $F0, $F0, $F0
db $F3, $F3, $F3, $F3, $F3, $F3, $F0, $F0
db $C3, $C3, $C3, $C3, $C3, $C3, $FF, $FF
db $CF, $CF, $CF, $CF, $CF, $CF, $C3, $C3
db $0F, $0F, $0F, $0F, $0F, $0F, $FC, $FC
db $3C, $42, $B9, $A5, $B9, $A5, $42, $3C
EndExpectedTileData:

ExpectedMapData:
db $01, $02, $03, $04, $05, $06, $07, $08
db $09, $0A, $0B, $0C, $19, $00, $00, $00
db $00, $00, $00, $00, $00, $00, $00, $00
db $00, $00, $00, $00, $00, $00, $00, $00
db $0D, $0E, $0F, $10, $11, $12, $13, $14
db $15, $16, $17, $18
EndExpectedMapData: