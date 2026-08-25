/* ============================================================
   NyxOS-OCaml -- a minimal freestanding OCaml runtime shim.
   ============================================================
   OCaml native code needs almost nothing here: this kernel never
   allocates (its loops only *poll* the GC, which we defuse in the
   boot stub by keeping young_ptr above young_limit), so caml_call_gc
   is never actually reached. We provide the VGA primitive, the field
   initialiser, and a halting stub for the unreachable GC entry. */

typedef long value;   /* OCaml value = native word; ints are tagged (n<<1)|1 */

/* external vga_store : int -> int -> unit -- args arrive tagged. */
value vga_store(value idx, value val)
{
    ((unsigned short *)0xB8000)[idx >> 1] = (unsigned short)(val >> 1);
    return 1;   /* Val_unit */
}

/* Store a value into a field (no write barrier needed without a GC). */
void caml_initialize(value *fp, value val)
{
    *fp = val;
}

/* Never reached: the loop polls pass because young_ptr > young_limit. */
void caml_call_gc(void)
{
    for (;;) __asm__ volatile ("hlt");
}
