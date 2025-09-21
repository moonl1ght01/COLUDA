NASM = nasm
NASM_FLAGS = -f bin

BOOT_SECTOR = boot.asm
BOOT_BIN = boot.bin

all: $(BOOT_BIN)

$(BOOT_BIN): $(BOOT_SECTOR)
	$(NASM) -f bin $(NASM_FLAGS) $(BOOT_SECTOR) -o $(BOOT_BIN)

clean:
	rm -f *.bin *.o *.elf

run: $(BOOT_BIN)
	qemu-system-i386 -drive format=raw,file=$(BOOT_BIN),if=floppy -nographic
