SECTION "Undocumented Registers", ROMX
UndocumentedRegistersTest::
    ; Test register $FF72
    ldh a, [$FF72]
    and a
    jr z, .validInitFF72
    ld de, strInvalidInitFF72
    ret
.validInitFF72
    dec a
    ldh [$FF72], a
    ldh a, [$FF72]
    cp $FF
    jr z, .validWriteFF72
    ld de, strFailWriteFF72
    ret
.validWriteFF72

    ; Test register $FF73
    ldh a, [$FF73]
    and a
    jr z, .validInitFF73
    ld de, strInvalidInitFF73
    ret
.validInitFF73
    dec a
    ldh [$FF73], a
    ldh a, [$FF73]
    cp $FF
    jr z, .validWriteFF73
    ld de, strFailWriteFF73
    ret
.validWriteFF73

    ; Test register $FF74
    ldh a, [$FF74]
    and a
    jr z, .validInitFF74
    ld de, strInvalidInitFF74
    ret
.validInitFF74
    dec a
    ldh [$FF74], a
    ldh a, [$FF74]
    cp $FF
    jr z, .validWriteFF74
    ld de, strFailWriteFF74
    ret
.validWriteFF74

    ; Test register $FF75
    ldh a, [$FF75]
    cp %10001111
    jr z, .validInitFF75
    ld de, strInvalidInitFF75
    ret
.validInitFF75
    ld a, $FF
    ldh [$FF75], a
    ldh a, [$FF75]
    cp $FF
    jr z, .didWriteFF75
    ld de, strFailWriteFF75
    ret
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

strInvalidInitFF72: db "Invalid initial   $FF72", 0
strFailWriteFF72: db "Read-only $FF72", 0
strInvalidInitFF73: db "Invalid initial   $FF73", 0
strFailWriteFF73: db "Read-only $FF73", 0
strInvalidInitFF74: db "Invalid initial   $FF74", 0
strFailWriteFF74: db "Read-only $FF74", 0
strInvalidInitFF75: db "Invalid initial   $FF75", 0
strFailWriteFF75: db "Read-only $FF75", 0
strFailBitsFF75: db "Incorrect writeable bits on $FF75", 0