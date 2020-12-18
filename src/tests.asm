;------------------------------------------------------------------------
; # Test Routine Map
; This section contains a simple list of pointers to the individual
; test routines, terminated by a zero byte.
;
; In order to add a test routine to this array, simply INCLUDE the
; relevant file and add a `dw <RoutineLabelName>` line below the
; TestRoutines label. The framework takes care of everything else.
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

INCLUDE "src/tests/example.asm"

SECTION "Test Routine Pointers", ROM0
TestRoutines::
    dw ExampleTest
    db 0