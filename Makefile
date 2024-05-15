BUILD  := $(abspath BUILD)

BOOTL1 := $(BUILD)/BOOTL1.BIN
BOOTL1_MK := $(abspath BOOTL1)

IMAGE := AOS.IMG

$(IMAGE): always_image $(BOOTL1)
	dd if=/dev/zero of=$(IMAGE) bs=$$((1024*1024)) count=16 status=none
	mkfs.fat -F 16 $(IMAGE) > /dev/null
	dd if=$(BOOTL1) of=$(IMAGE) conv=notrunc status=none

always_image: always
	rm -rf $(IMAGE)

$(BOOTL1): always_$(BOOTL1)
	@echo "Building $(BOOTL1)"
	@$(MAKE) -C $(BOOTL1_MK) OUT=$(BOOTL1)
always_$(BOOTL1): always
	rm -rf $(BOOTL1)

always:
	mkdir -p $(BUILD)
