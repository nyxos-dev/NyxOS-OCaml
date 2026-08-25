# NyxOS-OCaml - a freestanding 64-bit OCaml kernel (ocamlopt), booted via a GRUB ISO.
KERNEL  := nyxos-ocaml.elf
ISO     := nyxos-ocaml.iso
CFLAGS  := -ffreestanding -fno-stack-protector -fno-pic -mno-red-zone -m64 -O2 -c

$(ISO): $(KERNEL) grub.cfg
	mkdir -p isodir/boot/grub
	cp $(KERNEL) isodir/boot/kernel.elf
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO) isodir 2>/dev/null
	@echo "iso: $(ISO)"

$(KERNEL): boot.o kernel.o octrt.o ocaml_boot.o linker64.ld
	ld -T linker64.ld -o $@ boot.o kernel.o octrt.o ocaml_boot.o
	@grub-file --is-x86-multiboot $@ && echo "multiboot: OK"

# ocamlopt emits native amd64; the module entry runs with no runtime because
# its GC polls are defused in the boot stub (see ocaml_boot.s).
kernel.o: kernel.ml
	ocamlopt -c kernel.ml

octrt.o: octrt.c
	gcc $(CFLAGS) octrt.c -o $@

ocaml_boot.o: ocaml_boot.s
	as ocaml_boot.s -o $@

boot.o: boot64.asm
	nasm -f elf64 $< -o $@

run: $(ISO)
	qemu-system-x86_64 -cdrom $(ISO)

clean:
	rm -rf *.o *.cmi *.cmx kernel.s $(KERNEL) $(ISO) isodir shot.ppm

.PHONY: run clean
