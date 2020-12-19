SECTION "Functions", ROM0
;------------------------------------------------------------------------
; Copies a given amount of bytes between memory spaces.
; Parameters:
;  * DE - Base Pointer to source memory region
;  * HL - Base Pointer to destination memory region
;  * BC - Amount of bytes to copy
;
; Destroys: A, F, B, C, D, E
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
; Helper routine used to call a routine at memory address HL.
;------------------------------------------------------------------------
_hl_::
	jp hl