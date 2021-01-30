NAME = BULLYGB
PADVAL = 0

RGBASM = rgbasm
RGBLINK = rgblink
RGBFIX = rgbfix

RM_F = rm -f

ASFLAGS = -h
LDFLAGS = -t -w -n bully.sym -t
FIXFLAGS = -v -c -p $(PADVAL) -t $(NAME)

bully.gb: bully.o
	$(RGBLINK) $(LDFLAGS) -o $@ $^
	$(RGBFIX) $(FIXFLAGS) $@

bully.o: src/main.asm
	$(RGBASM) $(ASFLAGS) -o $@ $<

.PHONY: clean
clean:
	$(RM_F) bully.o bully.gb