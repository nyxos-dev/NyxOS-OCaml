# NyxOS-OCaml

NyxOS, rebuilt from scratch in OCaml — a freestanding x86_64 operating system.
Part of the NyxOS family: the same OS, built again in a different language.

The original (C): https://github.com/kazah-png/nyx-os

**Why OCaml:** unikernels, where the OS is the application.
Proven in the wild: MirageOS.

**Layout:** `boot/` — entry + bootstrap · `kernel/` — the kernel proper.

**Status:** early — bringing up the toolchain and a minimal higher-half kernel.
