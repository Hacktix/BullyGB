SECTION "OAM DMA Bus Conflict Test", ROMX
TestDMABusConflict::
    ; Pre-load crash error into HRAM
    ld hl, hCrashError
    ld a, LOW(strConflictCrash)
    ld [hli], a
    ld a, HIGH(strConflictCrash)
    ld [hl], a

    ; Initiate OAM DMA
    ld a, HIGH(DMATransferData)
    ldh [rDMA], a

    ; If no DMA bus conflicts occur - wait out DMA and fail
    ld a, $28
.noConflictWaitLoop
    dec a
    jr nz, .noConflictWaitLoop
    ld de, strNoConflicts
    ret

strNoConflicts: db "No DMA conflicts", 0
strConflictCrash: db "DMA bus conflict  always reads $FF", 0

    ; 160 bytes DMA - 8 bytes wait loop - error message string bytes (+ space for terminating zero byte)
    REPT 160 - 8 - STRLEN("No DMA conflicts ") - STRLEN("DMA bus conflict  always reads $FF ")
    nop 
    ENDR

    ld de, $0000
    ret

SECTION "OAM DMA Bus Conflict Test Routine", ROMX, ALIGN[8]
DMATransferData::
    REPT 160
    nop 
    ENDR