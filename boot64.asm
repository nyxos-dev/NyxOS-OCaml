; ============================================================
; Multiboot -> long-mode trampoline (shared by the 64-bit NyxOS-* kernels).
; ============================================================
; GRUB loads this in 32-bit protected mode. It enables SSE, identity-maps the
; first 1 GiB with 2 MiB pages, switches the CPU to 64-bit long mode, and calls
; the language's kmain(). (64-bit ELF => boot via a GRUB ISO, not `qemu -kernel`.)
bits 32

MB_MAGIC    equ 0x1BADB002
MB_FLAGS    equ 0x0
MB_CHECKSUM equ -(MB_MAGIC + MB_FLAGS)

section .multiboot
align 4
    dd MB_MAGIC
    dd MB_FLAGS
    dd MB_CHECKSUM

section .bss
align 4096
p4_table: resb 4096
p3_table: resb 4096
p2_table: resb 4096
align 16
stack_bottom: resb 16384
stack_top:

section .rodata
gdt64:
    dq 0                                        ; null descriptor
.code: equ $ - gdt64
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53)    ; 64-bit code segment
.pointer:
    dw $ - gdt64 - 1
    dq gdt64

section .text
global _start
extern kmain
_start:
    mov esp, stack_top

    ; enable SSE (x86-64 code assumes it is available)
    mov eax, cr0
    and ax, 0xFFFB                 ; clear CR0.EM
    or  ax, 0x2                    ; set   CR0.MP
    mov cr0, eax
    mov eax, cr4
    or  eax, (1<<9) | (1<<10)      ; CR4.OSFXSR | CR4.OSXMMEXCPT
    mov cr4, eax

    ; identity map the first 1 GiB with 2 MiB pages
    mov eax, p3_table
    or  eax, 0b11
    mov [p4_table], eax
    mov eax, p2_table
    or  eax, 0b11
    mov [p3_table], eax
    mov ecx, 0
.map:
    mov eax, 0x200000
    mul ecx
    or  eax, 0b10000011           ; present | writable | huge
    mov [p2_table + ecx*8], eax
    inc ecx
    cmp ecx, 512
    jne .map

    ; turn on paging + long mode
    mov eax, p4_table
    mov cr3, eax
    mov eax, cr4
    or  eax, 1<<5                  ; CR4.PAE
    mov cr4, eax
    mov ecx, 0xC0000080           ; EFER MSR
    rdmsr
    or  eax, 1<<8                  ; EFER.LME
    wrmsr
    mov eax, cr0
    or  eax, 1<<31                ; CR0.PG
    mov cr0, eax

    lgdt [gdt64.pointer]
    jmp gdt64.code:long_mode

bits 64
long_mode:
    xor ax, ax
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov rsp, stack_top
    call kmain
    cli
.hang:
    hlt
    jmp .hang
