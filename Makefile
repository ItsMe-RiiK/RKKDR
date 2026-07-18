DRIVER_NAME := RKKDR
KDIR := /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)
BUILD_DIR := $(PWD)/build
SRC_DIR := $(PWD)/src
RELEASE_DIR := $(PWD)/release
KEYS_DIR := $(PWD)/keys

SUDO_CMD ?= sudo
-include .local.mk

all: prep compile sign compile_commands post_clean

prep:
	@mkdir -p $(BUILD_DIR) $(RELEASE_DIR)
	@cp -r $(SRC_DIR)/* $(BUILD_DIR)/
	@echo "obj-m += $(DRIVER_NAME).o" > $(BUILD_DIR)/Makefile
	@echo "$(DRIVER_NAME)-objs := $$(find $(BUILD_DIR) -name '*.c' | sed "s|^$(BUILD_DIR)/||" | sed 's/\.c$$/.o/' | tr '\n' ' ')" >> $(BUILD_DIR)/Makefile

compile:
	$(MAKE) -C $(KDIR) M=$(BUILD_DIR) modules
	@cp $(BUILD_DIR)/$(DRIVER_NAME).ko $(RELEASE_DIR)/


sign:
	$(KDIR)/scripts/sign-file sha256 $(KEYS_DIR)/MOK.priv $(KEYS_DIR)/MOK.der $(RELEASE_DIR)/$(DRIVER_NAME).ko

compile_commands: prep
	$(MAKE) -C $(KDIR) M=$(BUILD_DIR) compile_commands.json
	@cp $(BUILD_DIR)/compile_commands.json $(PWD)/compile_commands.json
	-@sed -i 's|$(BUILD_DIR)|$(SRC_DIR)|g' $(PWD)/compile_commands.json

post_clean:
	@rm -rf $(BUILD_DIR)

clean:
	@$(SUDO_CMD) rm -rf $(BUILD_DIR)/* $(RELEASE_DIR)/* $(PWD)/compile_commands.json 2>/dev/null || rm -rf $(BUILD_DIR)/* $(RELEASE_DIR)/* $(PWD)/compile_commands.json

load: all
	@echo "Unloading old driver (if it exists)..."
	@$(SUDO_CMD) rmmod $(DRIVER_NAME) 2>/dev/null || true
	@echo "Loading new driver..."
	@$(SUDO_CMD) insmod $(RELEASE_DIR)/$(DRIVER_NAME).ko
	@echo "Last 5 lines of kernel log:"
	@$(SUDO_CMD) dmesg | tail -n 5

unload:
	@$(SUDO_CMD) rmmod $(DRIVER_NAME)
