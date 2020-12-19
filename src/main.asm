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
    ; Wait for VBlank, disable LCD
	ldh a, [rLY]
	cp SCRN_Y
	jr c, InitTests
    xor a
    ld [rLCDC], a

    ; Load font tiles
    ld hl, $9000
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
    call Memcpy

;------------------------------------------------------------------------
; Iterates over the given list of tests and locks up once all
; tests finish or one fails.
;------------------------------------------------------------------------
RunTests::
    ; Initially load pointer to test routine pointers
    ld hl, TestRoutines

.testIterateLoop
    ; Load DE with test routine pointer
    ld a, [hl]
    and a
    jr z, .breakTestLoop          ; Exit loop when zero byte is read
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

    ; Print string, enable LCD and lock up
    call PrintString
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a
    jr @

.breakTestLoop
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