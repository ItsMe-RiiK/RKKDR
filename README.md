# RKKDR

![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)

**RKKDR** is a modular Linux Kernel Driver project designed to support various userspace-controllable features directly from kernel space. The current initial feature is a hardware-level AutoClicker, new feature will be added later.

> **⚠️ PLATFORM NOTICE:**
> This driver interacts directly with the Linux kernel input subsystem (`<linux/input.h>`) and relies on `sysfs` for userspace communication. 
> **It is ONLY compatible with Linux environments.** It is currently developed and tested on **Arch Linux**. Compatibility with other distros (Ubuntu, Debian, Fedora, etc.) is highly likely but not officially tested. It is strictly incompatible with Windows or macOS.

## Architecture Structure

RKKDR enforces a strict separation between Kernel-Space C code and User-Space applications (like GUIs).

```text
RKKDR/
├── src/                       <-- KERNEL-SPACE
│   ├── main.c                 
│   └── features/
│       └── autoclicker/       
│           ├── autoclicker.c  <-- Core kernel logic
│           └── autoclicker.h  
│
└── features/                  <-- USER-SPACE (GUIs, Scripts, etc)
    └── autoclicker/           
        └── gui/               
            ├── app.cpp        <-- Native C++ GTK3 GUI
            └── image/
```

## Setup & Compilation

### Requirements
You will need the kernel headers for your specific Linux distribution, standard build tools, and `gtk3` for the C++ GUI.

On **Arch Linux**:
```bash
sudo pacman -S linux-headers base-devel gtk3 pkgconf
```

## Usage

### The Easy Way (Desktop Shortcut)
1. Double-click the `AutoClicker.desktop` file (or move it to your actual Desktop).
2. It will automatically compile the driver and C++ GUI, load it into the kernel, and launch it.

### The Manual Way
Compile the C++ GUI and load the kernel driver:
```bash
make load
```
*(Note: `make load` will automatically clean up compilation junk files after building).*

Run the C++ GUI:
```bash
sudo -E bin/AutoClickerGUI
```

Unload the driver when finished:
```bash
make unload
```

## License

This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for details.
