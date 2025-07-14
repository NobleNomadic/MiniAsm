ASM = nasm
SRC_DIR = src
BUILD_DIR = build

# Build the floppy image using dd instead of cp + truncate
$(BUILD_DIR)/boot.img: $(BUILD_DIR)/boot.bin
	dd if=/dev/zero of=$(BUILD_DIR)/boot.img bs=512 count=2880
	dd if=$(BUILD_DIR)/boot.bin of=$(BUILD_DIR)/boot.img conv=notrunc

# Assemble boot.asm to boot.bin
$(BUILD_DIR)/boot.bin: $(SRC_DIR)/boot.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(SRC_DIR)/boot.asm -f bin -o $(BUILD_DIR)/boot.bin

.PHONY: all clean run
all: $(BUILD_DIR)/boot.img

clean:
	rm -rf $(BUILD_DIR)/*
