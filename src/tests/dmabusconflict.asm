SECTION "OAM DMA Bus Conflict Test", ROMX
TestDMABusConflict::
    ; Pre-load crash error into HRAM
    ld hl, hCrashError
    ld a, LOW(strConflictCrash)
    ld [hli], a
    ld a, HIGH(strConflictCrash)
    ld [hl], a

    ; Preserve SP, set stack to RAM
    ld hl, sp+$00
    ld sp, _RAM + $1000
    push hl

    ; Initialize RAM used during DMA test to $FF
    ld hl, $FFFF
    push hl
    push hl
    pop hl
    pop hl

    ; Initiate OAM DMA
    ld a, HIGH(DMATransferData)
    ldh [rDMA], a
    nop                           ; Wait for OAM DMA to start

    ; If no DMA bus conflicts occur - wait out DMA and fail
    ld a, $28
.noConflictWaitLoop
    dec a
    jr nz, .noConflictWaitLoop
    ld de, strNoConflicts
    ret

; Error messages stored here to not waste space
strNoConflicts: db "No DMA conflicts", 0
strConflictCrash: db "DMA bus conflict  always reads $FF", 0
strIncorrectA: db "Bad instruction   timing", 0
strIncorrectB: db "Invalid register B", 0
strIncorrectC: db "Invalid register C", 0
strIncorrectDE: db "POP ignores DMA   conflict", 0

    ; 160 bytes DMA - 9 bytes wait loop - error message string bytes (+ space for terminating zero byte)
    REPT 160 - 9 - STRLEN("No DMA conflicts ") - STRLEN("DMA bus conflict  always reads $FF ") - STRLEN("Bad instruction   timing ") - STRLEN("Invalid register B ") - STRLEN("Invalid register C ") - STRLEN("POP ignores DMA   conflict ")
    nop 
    ENDR

    ; Restore SP
    pop hl
    ld sp, hl

    ; Compare values to expected values
    cp $01
    jr z, .validRegA               ; Invalid value due to bad instruction timing
    ld de, strIncorrectA
    ret
.validRegA
    ld a, b
    cp HIGH(DMATransferData)
    jr z, .validRegB               ; Invalid value due to A not being preserved or 'ld b, a' not being executed
    ld de, strIncorrectB
    ret
.validRegB
    ld a, c
    and a
    jr z, .validRegC               ; Invalid value due to 'xor a' or 'ld c, a' not being executed
    ld de, strIncorrectC
    ret
.validRegC
    ld a, [hDeviceModel]
    cp $04                         ; Set carry if DMG, SGB or MGB
    ld a, d
    jr nc, .checkDE_CGB
    cp $13
    jr z, .validRegD               ; Invalid value due to popping off RAM instead of DMA conflict values
    ld de, strIncorrectDE
    ret
.validRegD
    ld a, e
    cp $37
    jr z, .validRegE               ; Invalid value due to popping off RAM instead of DMA conflict values
    ld de, strIncorrectDE
    ret
.checkDE_CGB                       ; # CGB behaves differently with this
    cp HIGH(DMATransferData)
    jr z, .validRegD_CGB           ; Invalid value due to not popping off RAM 
    ld de, strIncorrectDE_CGB
    ret
.validRegD_CGB
    ld a, e
    cp LOW(DMATransferData)
    jr z, .validRegE               ; Invalid value due to not popping off RAM
    ld de, strIncorrectDE_CGB
    ret
.validRegE
    ld hl, hCrashError
    ld a, [hli]
    cp $01
    jr z, .validhCrashErrorLo      ; Invalid value due to HRAM value not being written
    ld de, strIncorrectHRAM
    ret
.validhCrashErrorLo
    ld a, [hl]
    cp $01
    jr z, .validhCrashErrorHi      ; Invalid value due to HRAM value not being written
    ld de, strIncorrectHRAM
    ret
.validhCrashErrorHi
    ld hl, $CFFD
    ld a, [hDeviceModel]
    cp $04                         ; Set carry if DMG, SGB or MGB
    ld a, [hld]
    jr nc, .checkRamCGB
    cp $ff
    jr z, .validRamHi              ; Invalid value due to RAM writes not being blocked
    ld de, strIncorrectRAM
    ret
.validRamHi
    ld a, [hl]
    cp $ff
    jr z, .validRamLo              ; Invalid value due to RAM writes not being blocked
    ld de, strIncorrectRAM
    ret
.checkRamCGB                       ; # CGB also behaves differently with this
    cp HIGH(DMATransferData)
    jr z, .validRamHiCGB           ; Invalid value due to RAM writes being blocked
    ld de, strIncorrectRAM_CGB
    ret
.validRamHiCGB
    ld a, [hl]
    cp LOW(DMATransferData)
    jr z, .validRamLo              ; Invalid value due to RAM writes being blocked
    ld de, strIncorrectRAM_CGB
    ret
.validRamLo

    ; Clear DE and return - test passed
    ld de, $0000
    ret

; Remaining error messages that didn't fit into 160 OAM DMA bytes
strIncorrectDE_CGB: db "DMA blocks POP    from RAM", 0
strIncorrectHRAM: db "DMA blocks HRAM   writes", 0
strIncorrectRAM: db "DMA allows RAM    writes", 0
strIncorrectRAM_CGB: db "DMA blocks RAM    writes", 0

SECTION "OAM DMA Bus Conflict Test Routine", ROMX, ALIGN[8]
DMATransferData::
.dmaCodeStart
    ld b, a             ; Loads HIGH(DMATransferData) into B
    xor a               ; Sets A to $00
    ld c, a             ; Loads $00 into C
    push bc             ; Pushes BC to stack (ignored since stack is on RAM)

    inc a               ; Won't be executed since the 'push bc'
    inc a               ; instruction should still be running
    inc a               ; while these bytes are transferred.

    pop de              ; Pops next two bytes into DE
    dw $1337

    ld hl, hCrashError  ; Loads crash handler pointer into HL
    inc a               ; Increment A to $01
    ld [hli], a         ; Writes $00 to hCrashError (actually, since hCrashError is in HRAM)
    inc a               ; Won't be executed due to HRAM write being active during this
    ld [hl], a          ; Writes $00 to hCrashError+1
    inc a               ; Again - won't be executed, same reason as above

    ; EXPECTED END STATE:
    ; A = $01
    ; B = HIGH(DMATransferData)
    ; C = $00
    ; D = $13
    ; E = $37
    ; [hCrashError] = $01
    ; [hCrashError+1] = $01
    ; [$CFFD] = $FF
    ; [$CFFC] = $FF

.dmaCodeEnd
    REPT 160 - (.dmaCodeEnd - .dmaCodeStart)
    nop 
    ENDR