SECTION "FF50 BOOT Register", ROMX
BootregTest::
    ; Check if BOOT register contains $FF
    ld a, [$ff50]
    cp $ff
    jr z, .validBootValue
    ld de, strBootregNotFF
    ret
.validBootValue

    ; Check if BOOT register is writeable
    xor a
    ld [$ff50], a
    ld a, [$ff50]
    cp $ff
    jr z, .regNotWritable
    ld de, strBootregWritable
    ret
.regNotWritable

    ; Clear DE and return - test passed
    ld de, $0000
    ret

strBootregNotFF: db "$FF50 not $FF", 0
strBootregWritable: db "$FF50 not readonly", 0