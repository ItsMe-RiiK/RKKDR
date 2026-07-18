# RKKDR (Kernel Driver)

![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)

**RKKDR** is a modular Linux Kernel Driver project designed to support various userspace-controllable features directly from kernel space. Currently, it features a hardware-level AutoClicker and an Acer Battery WMI controller.

> **⚠️ PLATFORM NOTICE:**
> This driver interacts directly with the Linux kernel subsystem (`<linux/input.h>`, WMI, ACPI) and relies on `sysfs` for userspace communication. 
> **It is ONLY compatible with Linux environments.** It is currently developed and tested on **Arch Linux**. Compatibility with other distros is highly likely but not officially tested. It is strictly incompatible with Windows or macOS.

---

## Architecture Structure

RKKDR enforces a strict, professional separation between Kernel-Space driver code and User-Space applications. 

- **Kernel Space (`src/`)**: Contains the core driver and hardware interaction logic.
- **User Space (`projects/`)**: Contains standalone GUI applications and CLI utilities that interact with the kernel. These projects are fully isolated and have their own Makefiles.

```text
RKKDR/
├── src/                       <-- KERNEL SPACE (Hardware logic)
│   ├── main.c                 
│   └── features/
│       ├── autoclicker/       <-- Input subsystem simulation
│       └── battery/           <-- WMI/ACPI firmware calls
│
└── projects/                  <-- USER SPACE (Interfaces)
    ├── AutoClicker/        <-- Standalone C++ GTK3 GUI
    │   ├── src/app.cpp
    │   ├── Makefile
    │   └── launcher.sh        <-- Automated launch script
    │
    └── AcerBattery/        <-- Standalone C CLI Utility
        ├── src/main.c
        └── Makefile
```

---

## Setup & Compilation

### Requirements
You will need the kernel headers for your specific Linux distribution, standard build tools, and `gtk3` for the AutoClicker C++ GUI.

On **Arch Linux**:
```bash
sudo pacman -S linux-headers base-devel gtk3 pkgconf
```

### Building the Kernel Driver
To compile and load the kernel driver into memory:
```bash
make load
```
*(Note: Output binaries are placed cleanly into the `release/` directory, while intermediate junk is kept in `build/`).*

To unload the driver when finished:
```bash
make unload
```

---

## Using the Projects

Because userspace applications are separated, they must be compiled via their own Makefiles.

### AutoClicker GUI
You can easily launch the GUI by running its dedicated launcher script, which automatically handles compilation and kernel loading:
```bash
./projects/AutoClicker/launcher.sh
```

### Acer Battery Controller
Compile the CLI utility first:
```bash
make -C projects/AcerBattery
```
Then run it to check battery status:
```bash
./release/AcerBattery --status
```
Or to toggle battery health limits (requires sudo):
```bash
sudo ./release/AcerBattery --health 1
```

---

## License

This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for details.
