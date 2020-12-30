SECTION "HRAM", HRAM
hDeviceModel: db            ; One-byte identifier of the device type based on initial register values.
                            ; $01 - DMG
                            ; $02 - MGB
                            ; $03 - CGB
                            ; $04 - SGB
                            ; $05 - AGB/AGS

hCrashError: ds 2           ; 16-bit pointer to string that should be displayed when instruction $FF is run