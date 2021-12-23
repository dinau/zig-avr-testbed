CC=avr-gcc
AS=avr-as
LD=avr-ld
OBJDUMP=avr-objdump
OBJCOPY=avr-objcopy
MCU=atmega328p
TARGET=-mmcu=$(MCU)
PROGRAM=avrdude
PROGRAM_CFG=/etc/avrdude.conf
PROGRAM_DEV=/dev/ttyACM0
EXECUTABLES=$(basename $(wildcard *.c)) $(basename $(wildcard *.zig))
ALL=$(foreach f, $(EXECUTABLES), $(f).s $(f).dmp $(f).hex)

ELFS += intblink.elf blink.elf
ELFS += blinker.elf

all: $(ELFS)

# :: means terminal.
#%.elf:: %.c
#	@#$(CC) $(DEBUG) $(CFLAGS) -o $@ $<
#
#%.elf:: %.S
#	$(CC) -xassembler-with-cpp $< $(TARGET) -o $@ -nostdlib

#%.dmp: %.elf
#	@$(OBJDUMP) -d -S -l $< > $@
#
#%.s:: %.c
#	@$(CC) $(CFLAGS) -S $<
#
#%.s:: %.zig
#	@zig build-obj -femit-asm -fno-emit-bin --strip -O ReleaseSmall -target avr-freestanding-none -mcpu=$(MCU) $<

ZIG_OPT += --strip
ZIG_OPT += -O ReleaseSmall
ZIG_OPT += -target avr-freestanding-none
ZIG_OPT += -mcpu=$(MCU)

CFLAGS  = -mmcu=$(MCU) -Os -ffunction-sections -fdata-sections
CFLAGS += -Wl,--gc-sections

%.o: %.c Makefile
	@echo -------------------------------
	avr-gcc -c -o $@  $(CFLAGS) $<

%.o: %.zig Makefile
	@echo -------------------------------
	zig build-obj -femit-bin=$@  $(ZIG_OPT) $<

%.elf: %.o
	-$(CC) $(CFLAGS) -o $@ $^
	-@$(OBJDUMP) -hdSC $@ > $(@:%.elf=%.lst)
	@$(OBJCOPY) -O ihex $@ $(@:%.elf=%.hex)
	-@avr-size $@


#%.hex: %.elf
#	@$(OBJCOPY) -O ihex $< $@
#
#%.bin: %.elf
#	@$(OBJCOPY) -O binary $< $@

#upload-%.elf: %.elf
#	$(PROGRAM) -C$(PROGRAM_CFG) -v -V -patmega328p -carduino -P$(PROGRAM_DEV) -b115200 -D -Uflash:w:$<:e
#
#upload-%.hex: %.hex
#	$(PROGRAM) -C$(PROGRAM_CFG) -v -V -patmega328p -carduino -P$(PROGRAM_DEV) -b115200 -D -Uflash:w:$<:i
#
#%:
#	/bin/false

clean:
	@rm -f *.dmp *.s *.hex *.bin *.out *.elf *.o *.lst
	@rm -fr zig-cache
