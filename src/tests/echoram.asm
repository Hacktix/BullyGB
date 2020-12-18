SECTION "Echo RAM Test", ROMX
TestEchoRAM::
    ; Load test string into normal RAM
    ld de, strEchoRAMTestRead
    ld hl, _RAM
    call Strcpy

    ; Read values from echo RAM
    ld de, strEchoRAMTestRead
    ld hl, $E000
.loopReadNormalRAM
    ld a, [de]
    and a
    jr z, .endReadNormalRAM  ; Skip comparison if end of string reached
    inc de
    cp [hl]
    inc hl
    jr z, .loopReadNormalRAM ; Jump back to start of loop if string matches up
    ld de, strEchoRAMFailRead
    ret
.endReadNormalRAM

    ; Load test string into echo RAM
    ld de, strEchoRAMTestWrite
    ld hl, $E000
    call Strcpy

    ; Read values from normal RAM
    ld de, strEchoRAMTestWrite
    ld hl, _RAM
.loopReadEchoRAM
    ld a, [de]
    and a
    jr z, .endReadEchoRAM  ; Skip comparison if end of string reached
    inc de
    cp [hl]
    inc hl
    jr z, .loopReadEchoRAM ; Jump back to start of loop if string matches up
    ld de, strEchoRAMFailRead
    ret
.endReadEchoRAM

    ; Clear DE and return - test passed
    ld de, $0000
    ret

strEchoRAMTestRead: db "Echo RAM Read Test", 0
strEchoRAMTestWrite: db "Echo RAM Write Test", 0
strEchoRAMFailRead: db "Bad Echo RAM Reads", 0
strEchoRAMFailWrite: db "Bad Echo RAM Writes", 0