SECTION "DIV Test", ROMX
TestDIV::
    ; Store initial DIV value
    ld a, [rDIV]
    ld b, a

    ; Load expected value based on model
    ldh a, [hDeviceModel]
    cp $03
    jr z, .modeSGB
    jr c, .modeDMG
    cp $04
    jr z, .modeCGB
    ld a, $29           ; Expected value for AGB and AGS (TODO: Confirm)
    jr .endLoadCP
.modeCGB
    ld a, $29           ; Expected value for CGB (TODO: Confirm CGB-0)
    jr .endLoadCP
.modeSGB
    ld a, $DA           ; Expected value for SGB and SGB2 (TODO: Confirm)
    jr .endLoadCP
.modeDMG
    ld a, $AE           ; Expected value for DMG and MGB (TODO: Confirm DMG-0)
.endLoadCP

    ; Compare values
    cp b
    jr z, .validInitValue
    ld de, strInvalidInitValue
    ret
.validInitValue

    ld de, $0000
    ret

strInvalidInitValue: db "Invalid initial   DIV", 0