SECTION "Undocumented Registers", ROMX
UndocumentedRegistersTest::
    ; Test register $FF72
    ldh a, [$FF72]
    and a
    jr z, .validInitFF72
    ld de, strInvalidInit
    ld b, "2"
    jr ReturnFailString
.validInitFF72
    dec a
    ldh [$FF72], a
    ldh a, [$FF72]
    cp $FF
    jr z, .validWriteFF72
    ld de, strFailWrite
    ld b, "2"
    jr ReturnFailString
.validWriteFF72

    ; Test register $FF73
    ldh a, [$FF73]
    and a
    jr z, .validInitFF73
    ld de, strInvalidInit
    ld b, "3"
    jr ReturnFailString
.validInitFF73
    dec a
    ldh [$FF73], a
    ldh a, [$FF73]
    cp $FF
    jr z, .validWriteFF73
    ld de, strFailWrite
    ld b, "3"
    jr ReturnFailString
.validWriteFF73

    ; Test register $FF74
    ldh a, [$FF74]
    and a
    jr z, .validInitFF74
    ld de, strInvalidInit
    ld b, "4"
    jr ReturnFailString
.validInitFF74
    dec a
    ldh [$FF74], a
    ldh a, [$FF74]
    cp $FF
    jr z, .validWriteFF74
    ld de, strFailWrite
    ld b, "4"
    jr ReturnFailString
.validWriteFF74

    ; Test register $FF75
    ldh a, [$FF75]
    cp %10001111
    jr z, .validInitFF75
    ld de, strInvalidInit
    ld b, "5"
    jr ReturnFailString
.validInitFF75
    ld a, $FF
    ldh [$FF75], a
    ldh a, [$FF75]
    cp $FF
    jr z, .didWriteFF75
    ld de, strFailWrite
    ld b, "5"
    jr ReturnFailString
.didWriteFF75
    ld a, %01110000
    ldh [$FF75], a
    ldh a, [$FF75]
    cp $FF
    jr z, .validWriteFF75
    ld de, strFailBitsFF75
    ret
.validWriteFF75

    ld de, $0000
    ret

;------------------------------------------------------------------------
; Generates a fail string in WRAM and returns a pointer to the
; testing framework.
; Parameters:
;  * DE - Base Pointer to error string
;  * B  - Character to be appended to the error string
;------------------------------------------------------------------------
ReturnFailString::
    ld hl, _RAM
    call Strcpy
    dec hl
    ld a, b
    ld [hli], a
    xor a
    ld [hl], a
    ld de, _RAM
    ret

strInvalidInit: db "Invalid initial   $FF7", 0
strFailWrite: db "Read-only $FF7", 0
strFailBitsFF75: db "Incorrect writeable bits on $FF75", 0