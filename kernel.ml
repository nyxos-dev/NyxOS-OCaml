(* ============================================================
   NyxOS-OCaml -- a freestanding x86_64 kernel in OCaml.
   ============================================================
   Entered in 64-bit long mode from boot64.asm via kmain. Does not
   allocate: the string ops are compiler primitives (inlined), and
   the only outside call is an external that stores one VGA cell. *)

external vga_store : int -> int -> unit = "vga_store" [@@noalloc]

let banner = "NyxOS-OCaml  ::  booting from scratch"

let () =
  (* clear to a blank white-on-black screen *)
  for i = 0 to 80 * 25 - 1 do
    vga_store i 0x0F20
  done;
  (* paint the banner in Nyx purple (VGA attribute 0x0D) *)
  for i = 0 to String.length banner - 1 do
    vga_store i (0x0D00 lor Char.code (String.unsafe_get banner i))
  done
