SECTION "DIV Test", ROMX
TestDIV::
    ; Store initial DIV value
    ld a, [rDIV]
    ld b, a

    ; Load expected value based on model
    ldh a, [hDeviceModel]
    cp $03
    jr z, .modeSGB
    jr nc, .modeDMG
    ld a, $AD           ; Expected value for CGB and AGB/AGS (TODO: Confirm AGB/AGS and CGB-0)
    jr .endLoadCP
.modeSGB
    ld a, $DA           ; Expected value for SGB and SGB2 (TODO: Confirm)
    jr .endLoadCP
.modeDMG
    ld a, $27           ; Expected value for DMG and MGB (TODO: Confirm DMG-0)
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