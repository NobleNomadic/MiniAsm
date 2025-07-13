BUILD_DIR = build
DISK_IMG  = $(BUILD_DIR)/disk.img

all: $(DISK_IMG)

$(DISK_IMG): $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin
	dd if=/dev/zero of=$@ bs=1M count=16
	dd if=$(BUILD_DIR)/boot.bin of=$@ conv=notrunc
	dd if=$(BUILD_DIR)/kernel.bin of=$@ bs=512 seek=1 conv=notrunc

$(BUILD_DIR)/boot.bin: src/boot.asm
	nasm -f bin $< -o $@

$(BUILD_DIR)/kernel.bin: src/kernel.asm
	nasm -f bin $< -o $@

clean:
	rm -rf $(BUILD_DIR)/*
