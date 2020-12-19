SECTION "OAM DMA Bus Conflict Test", ROMX
TestDMABusConflict::
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

    ; 160 bytes DMA - 8 bytes wait loop - 17 bytes string
    REPT 160 - 8 - 17
    nop 
    ENDR

    ld de, $0000
    ret

SECTION "OAM DMA Bus Conflict Test Routine", ROMX, ALIGN[8]
DMATransferData::
    REPT 160
    nop 
    ENDR