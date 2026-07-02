DRIVER_NAME := RKKDR
KDIR := /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)
BUILD_DIR := $(PWD)/build
SRC_DIR := $(PWD)/src
BIN_DIR := $(PWD)/bin
KEYS_DIR := $(PWD)/keys

all: prep compile sign compile_commands post_clean

prep:
	@mkdir -p $(BUILD_DIR) $(BIN_DIR)
	@cp -r $(SRC_DIR)/* $(BUILD_DIR)/
	@echo "obj-m += $(DRIVER_NAME).o" > $(BUILD_DIR)/Makefile
	@echo "$(DRIVER_NAME)-objs := $$(find $(BUILD_DIR) -name '*.c' | sed "s|^$(BUILD_DIR)/||" | sed 's/\.c$$/.o/' | tr '\n' ' ')" >> $(BUILD_DIR)/Makefile

compile: compile_gui
	$(MAKE) -C $(KDIR) M=$(BUILD_DIR) modules
	@cp $(BUILD_DIR)/$(DRIVER_NAME).ko $(BIN_DIR)/

compile_gui:
	@echo "Building Userspace GUIs..."
	@g++ features/autoclicker/gui/app.cpp -o $(BIN_DIR)/AutoClickerGUI $$(pkg-config --cflags --libs gtk+-3.0)

sign:
	$(KDIR)/scripts/sign-file sha256 $(KEYS_DIR)/MOK.priv $(KEYS_DIR)/MOK.der $(BIN_DIR)/$(DRIVER_NAME).ko

compile_commands:
	$(MAKE) -C $(KDIR) M=$(BUILD_DIR) compile_commands.json
	@cp $(BUILD_DIR)/compile_commands.json $(PWD)/compile_commands.json
	-@sed -i 's|$(BUILD_DIR)|$(SRC_DIR)|g' $(PWD)/compile_commands.json

post_clean:
	@rm -rf $(BUILD_DIR)

clean:
	@echo 1234 | sudo -S rm -rf $(BUILD_DIR)/* $(BIN_DIR)/* $(PWD)/compile_commands.json 2>/dev/null || rm -rf $(BUILD_DIR)/* $(BIN_DIR)/* $(PWD)/compile_commands.json

load: all
	@echo "Unloading old driver (if it exists)..."
	-@echo 1234 | sudo -S rmmod $(DRIVER_NAME) 2>/dev/null || true
	@echo "Loading new driver..."
	@echo 1234 | sudo -S insmod $(BIN_DIR)/$(DRIVER_NAME).ko
	@echo "Last 5 lines of kernel log:"
	@echo 1234 | sudo -S dmesg | tail -n 5

unload:
	@echo 1234 | sudo -S rmmod $(DRIVER_NAME)
