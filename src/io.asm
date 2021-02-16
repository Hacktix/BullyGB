SECTION "IO Functions", ROM0
;------------------------------------------------------------------------
; Prints a given string to the screen.
; Parameters:
;  * DE - Base Pointer to String
;
; Destroys: A, F, D, E, H, L
;------------------------------------------------------------------------
PrintString::
    ; Load VRAM base pointer into HL
    ld hl, $9821

.printLoop
    ; Load character and check if null
    ld a, [de]
    inc de
    and a
    ret z

    ; Print character to serial
    ldh [rSB], a

    ; Load into VRAM and check for line wrapping
    ld [hli], a
    ld a, l
    and $13
    cp $13
    jr nz, .printLoop

    ; Handle line wrap
    ld a, l
    add $0e
    ld l, a
    adc h
    sub l
    ld h, a

    jr .printLoop