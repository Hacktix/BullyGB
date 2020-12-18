SECTION "Example Test", ROMX
ExampleTest::
    ; Loads $00 into DE, telling the testing framework the test passes.
    ; Loading a pointer to a string here would tell it to fail and print the message of said string.
    xor a
    ld d, a
    ld e, a
    ret