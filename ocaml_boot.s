# ============================================================
# NyxOS-OCaml -- boot stub bridging boot64.asm to the OCaml entry.
# ============================================================
# boot64.asm calls kmain. We set up the two OCaml native registers
# that caml_startup would normally establish -- r14 = domain state,
# r15 = young_ptr -- then jump into the compiled module's entry.
#
#   * domain_state[0]  = young_limit : kept 0, so the loop GC-polls
#                        (young_ptr > young_limit) always pass.
#   * domain_state[64] = C stack ptr : OCaml switches rsp here for
#                        external calls (vga_store, caml_initialize).
#   * r15 (young_ptr)  = a large constant; never bumped (no allocs).

    .text
    .globl kmain
kmain:
    leaq    ocaml_dstate(%rip), %r14      # r14 = domain state
    movq    $0, (%r14)                    # young_limit = 0
    leaq    ocaml_cstack_top(%rip), %rax
    movq    %rax, 64(%r14)                # C-call stack top
    movq    $0x40000000, %r15             # young_ptr (polls always pass)
    call    camlKernel.entry
    ret

    .bss
    .align 16
ocaml_dstate:
    .skip 256
    .align 16
ocaml_cstack:
    .skip 32768
ocaml_cstack_top:
