INCLUDE "inc/hardware.inc"
INCLUDE "src/functions.asm"
INCLUDE "src/ram.asm"
INCLUDE "src/io.asm"
INCLUDE "src/tests.asm"

SECTION "Vectors", ROM0[$0]
    ds $38 - @

;------------------------------------------------------------------------
; General purpose crash handler vector for instruction $FF.
;------------------------------------------------------------------------
CrashHandlerVector::
    jp CrashHandler

    ds $100 - @

SECTION "Test", ROM0[$100]
    di
    jp InitTests
    ds $150 - @

;------------------------------------------------------------------------
; Initializes the GB for running the testing routines and falls through
; to the test running routine.
;------------------------------------------------------------------------
InitTests::
    cp $01
    jr nz, .notDMGorSGB ; Check if A = $01 (DMG or SGB)
    ld a, h
    cp $01
    jr z, .isDMG        ; Check if H = $01 (DMG)
    ld a, $03           ; Otherwise SGB
    jr .endModelCheck
.isDMG
    ld a, $01
    jr .endModelCheck
.notDMGorSGB
    cp $ff
    jr nz, .notMGBorSGB ; Check if A = $FF (MGB or SGB)
    ld a, c
    cp $13
    jr z, .isMGB        ; Check if C = $13 (MGB)
    ld a, $03           ; Otherwise SGB
    jr .endModelCheck
.isMGB
    ld a, $02
    jr .endModelCheck
.notMGBorSGB
    ld a, b
    and a
    jr z, .isCGB        ; Check if B = $00 (CGB)
    ld a, $05           ; Otherwise AGB/AGS
    jr .endModelCheck
.isCGB
    ld a, $04
.endModelCheck
    ldh [hDeviceModel], a

.initWaitLCD
    ; Wait for VBlank, disable LCD
	ldh a, [rLY]
	cp SCRN_Y
	jr c, .initWaitLCD
    xor a
    ld [rLCDC], a

;------------------------------------------------------------------------
; Iterates over the given list of tests and locks up once all
; tests finish or one fails.
;------------------------------------------------------------------------
RunTests::
    ; Initially load pointer to test routine pointers
    ld hl, TestRoutines

.testIterateLoop
    ; Load compatibility header length
    ld a, [hli]
    cp $ff
    jr z, .breakTestLoop          ; Break if header $ff found
    and a
    jr z, .skipCompatibilityCheck ; Run test regardless of model if value is zero

    ; Check if model is compatible
    ld b, a
.compatibilityCheckLoop
    xor a
    ld c, a
    ld a, [hli]
    ld d, a
    ldh a, [hDeviceModel]
    cp d
    jr nz, .notCompatible
    inc c                         ; Increment C to $01 if compatible
.notCompatible
    dec b
    jr nz, .compatibilityCheckLoop

    ; Run test if compatible
    xor a
    or c
    jr nz, .skipCompatibilityCheck

    ; Skip test otherwise
    inc hl
    inc hl
    jr .testIterateLoop

.skipCompatibilityCheck
    ; Load DE with test routine pointer
    ld a, [hl]
    cp $ff
    jr z, .breakTestLoop          ; Exit loop when $FF byte is read
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a

    ; Preserve HL, load DE into HL, call HL
    push hl
    ld h, d
    ld l, e
    call _hl_
    pop hl

    ; Skip lockup if null pointer returned
    ld a, e
    or d
    jr z, .testIterateLoop

    ; Load font tiles
    ld hl, $9210
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
    call Memcpy

    ; Print string, enable LCD and lock up
    call PrintString
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a
    jr @

.breakTestLoop
    ; Load font tiles
    ld hl, $9210
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
    call Memcpy

    ; Print "All tests OK!"
    ld de, strAllPassed
    call PrintString

    ; Enable LCD
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a
    jr @

;------------------------------------------------------------------------
; Jumped to from the $38 reset vector (most commonly associated with)
; inaccuracy-related crashes. Fetches a string pointer from HRAM,
; prints it to the screen and locks up.
;------------------------------------------------------------------------
CrashHandler::
    ; Reset SP in case of stack overflow
    ld sp, _RAM+$1000
    
    ; Load font tiles
    ld hl, $9210
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
    call Memcpy

    ; Fetch pointer from HRAM and print
    ld hl, hCrashError
    ld a, [hli]
    ld e, a
    ld a, [hl]
    ld d, a
    call PrintString

    ; Enable LCD and lock up
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a
    jr @

strAllPassed: db "All tests OK!", 0

SECTION "Font", ROM0
FontTiles:
INCBIN "inc/font.chr"
FontTilesEnd: