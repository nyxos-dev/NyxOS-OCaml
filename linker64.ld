/* Link a 64-bit kernel at 1 MiB with the Multiboot header first. */
ENTRY(_start)

SECTIONS {
    . = 1M;

    .multiboot : { *(.multiboot) }
    .text      : { *(.text*) }
    .rodata    : { *(.rodata*) *(.data.rel.ro*) }
    .data      : { *(.data*) }
    .bss       : { *(.bss*)  *(COMMON) }
}
