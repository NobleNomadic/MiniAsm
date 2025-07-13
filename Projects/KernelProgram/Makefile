ASM = nasm

SRC_DIR = src
BUILD_DIR = build

BOOT_SRC = $(SRC_DIR)/boot.asm
KERNEL_SRC = $(SRC_DIR)/kernel.asm
PROGRAM_SRC = $(SRC_DIR)/program.asm
BOOT_BIN = $(BUILD_DIR)/boot.bin
KERNEL_BIN = $(BUILD_DIR)/kernel.bin
PROGRAM_BIN = $(BUILD_DIR)/program.bin
IMG = $(BUILD_DIR)/boot.img

all: $(IMG)

# Rule: assemble boot.asm
$(BOOT_BIN): $(BOOT_SRC)
	mkdir -p $(BUILD_DIR)
	$(ASM) $< -f bin -o $@

# Rule: assemble kernel.asm
$(KERNEL_BIN): $(KERNEL_SRC)
	$(ASM) $< -f bin -o $@

# Rule: assemble program.asm
$(PROGRAM_BIN): $(PROGRAM_SRC)
	$(ASM) $< -f bin -o $@

# Rule: build floppy image
$(IMG): $(BOOT_BIN) $(KERNEL_BIN) $(PROGRAM_BIN)
	cp $(BOOT_BIN) $(IMG)
	dd if=$(KERNEL_BIN) of=$(IMG) bs=512 seek=1 conv=notrunc
	dd if=$(KERNEL_BIN) of=$(IMG) bs=512 seek=1 conv=notrunc
	truncate -s 1440k $(IMG)

clean:
	rm -rf $(BUILD_DIR)/*

.PHONY: all clean
