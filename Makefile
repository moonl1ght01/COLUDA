i686 = i686-elf-as

BOOT_SECTOR = boot.asm
BOOT_BIN = boot.bin

all: $(BOOT_BIN)

$(BOOT_BIN): $(BOOT_SECTOR)
	$(i686) $(BOOT_SECTOR) -o $(BOOT_BIN)

clean:
	rm -f *.bin *.o *.elf

run: $(BOOT_BIN)
	qemu-system-i386 -drive format=raw,file=$(BOOT_BIN),if=floppy -nographic
