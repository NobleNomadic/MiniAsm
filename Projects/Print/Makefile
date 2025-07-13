ASM = nasm

SRC_DIR = src
BUILD_DIR = build

# Build the floppy image by copying the bin and truncating to 1.44MB
$(BUILD_DIR)/boot.img: $(BUILD_DIR)/boot.bin
	cp $(BUILD_DIR)/boot.bin $(BUILD_DIR)/boot.img
	truncate -s 1440k $(BUILD_DIR)/boot.img

# Assemble boot.asm to boot.bin
$(BUILD_DIR)/boot.bin: $(SRC_DIR)/boot.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(SRC_DIR)/boot.asm -f bin -o $(BUILD_DIR)/boot.bin

.PHONY: all clean

all: $(BUILD_DIR)/boot.img

clean:
	rm -rf $(BUILD_DIR)/*
