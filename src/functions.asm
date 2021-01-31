SECTION "Functions", ROM0
;------------------------------------------------------------------------
; Copies a given amount of bytes between memory spaces.
; Parameters:
;  * DE - Base Pointer to source memory region
;  * HL - Base Pointer to destination memory region
;  * BC - Amount of bytes to copy
;
; Destroys: All Registers
;------------------------------------------------------------------------
Memcpy::
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, Memcpy
    ret

;------------------------------------------------------------------------
; Copies a zero-terminated string to a given memory region.
; Parameters:
;  * DE - Base Pointer to source string
;  * HL - Base Pointer to destination memory region
;
; Destroys: A, F, D, E
;------------------------------------------------------------------------
Strcpy::
    ld a, [de]
    inc de
    ld [hli], a
    and a
    jr nz, Strcpy
    ret

;------------------------------------------------------------------------
; Compares BC bytes starting at HL to the memory region starting at
; DE. Sets zero flag if equal, unsets it otherwise.
; Parameters:
;  * BC - Size of memory region to compare
;  * DE - Base pointer to first memory region
;  * HL - Base pointer to second memory region
;
; Destroys: All Registers
;------------------------------------------------------------------------
Memcmp::
    ld a, [de]
    inc de
    cp [hl]
    inc hl
    jr nz, .notEqual
    dec bc
    ld a, b
    or c
    jr nz, Memcmp
    xor a
    ret
.notEqual
    xor a
    inc a
    ret

;------------------------------------------------------------------------
; Helper routine used to call a routine at memory address HL.
;------------------------------------------------------------------------
_hl_::
	jp hl

;------------------------------------------------------------------------
; Converts the value in A into two ASCII encoded hex characters and
; stores them in DE.
; Parameters:
;  * A - Value to be converted
;
; Destroys: A, F, D, E
;------------------------------------------------------------------------
ConvertToASCII::
    push af
    call ConvertNibbleToASCII
    ld e, a
    pop af
    swap a
    call ConvertNibbleToASCII
    ld d, a
    ret

;------------------------------------------------------------------------
; Converts the lower nibble of A to an ASCII encoded hex character
; and stores it in A.
; Parameters:
;  * A - Value to be converted
;
; Destroys: A, F
;------------------------------------------------------------------------
ConvertNibbleToASCII::
    and $0F
    cp 10
    jr nc, .letterCharacter
    add "0"
    ret
.letterCharacter
    add "A"
    ret