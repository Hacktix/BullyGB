;------------------------------------------------------------------------
; # Test Routine Map
; This section contains a simple list of pointers to the individual
; test routines, terminated by an $FF byte.
;
; In order to add a test routine to this array, you must first
; INCLUDE the relevant assembly file. Next you must add an entry
; below the "TestRoutines::" label in the following format:
;
;   db (model_count) [compatible_models...]
;   dw (test_routine_label)
;
; Whereas "model_count" is the amount of model identifiers that
; follow, and "compatible_models" a list of the model identifiers
; that the test should be compatible with. The following values
; are valid:
;   $01 - DMG
;   $02 - MGB
;   $03 - CGB
;   $04 - SGB
;   $05 - AGB/AGS
; Leaving the "model_count" value at zero will mark the test as
; compatible with all models.
;
; * NOTES FOR TEST DEVELOPMENT *
; Initial register values as well as RAM values may depend on the
; tests that run first. If your test relies on any of these values,
; which it shouldn't anyway, but whatever, make sure they're placed
; in the correct order.
;
; The test routines are CALLed, so they must be terminated using a
; RET instruction.
;
; The framework expects the result of the test to be stored in the
; DE register pair. Both should be set to $00 if the test passed,
; otherwise they should contain a pointer to the string that should
; be displayed as an error message.
;------------------------------------------------------------------------

INCLUDE "src/tests/echoram.asm"
INCLUDE "src/tests/bootreg.asm"
INCLUDE "src/tests/dmabusconflict.asm"

SECTION "Test Routine Pointers", ROM0
TestRoutines::
    ; Tests writing to Echo RAM and reading from Normal RAM and vice versa
    db 0
    dw TestEchoRAM

    ; Checks if the BOOT register ($FF50) is set correctly and read-only
    db 0
    dw BootregTest

    ; Executes code using bus conflicts during OAM DMA and attempts to modify
    ; memory while DMA is active.
    db 0
    dw TestDMABusConflict

    db $ff