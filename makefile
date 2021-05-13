AS = nasm
ASFLAG = -f bin
ASFLAG64 = -f elf64
BUILDDIR = build
KERNELDIR = kernel
GCC = gcc
GCCFLAG = -ffreestanding -c -nostdlib
BOOTDIR = boot
KERNEL_ASM_SRC = $(shell find $(KERNELDIR) -name "*.asm")
KERNEL_ASM_OBJ = $(patsubst %.asm, $(BUILDDIR)/%.o, $(KERNEL_ASM_SRC))
KERNEL_C_SRC = $(shell find $(KERNELDIR) -name "*.c")
KERNEL_C_OBJ = $(patsubst %.c, $(BUILDDIR)/%.o, $(KERNEL_C_SRC))

default: boot kernel iso

kernel:: $(KERNEL_C_OBJ) $(KERNEL_ASM_OBJ)
	mkdir -p $(BUILDDIR)/iso	
	x86_64-elf-ld -o $(BUILDDIR)/iso/kernel.sys $(BUILDDIR)/loader.bin $(KERNEL_C_OBJ) $(KERNEL_ASM_OBJ) -Ttext 0x8000 --oformat binary
	@echo -e " $(ETERA) build kernel success"

$(BUILDDIR)/%.o : %.asm
	mkdir -p $(dir $@)
	$(AS) $(ASFLAG64) $< -o $@

$(BUILDDIR)/%.o : %.c
	mkdir -p $(dir $@)
	$(GCC) $(GCCFLAG) $< -o $@

iso:
	@genisoimage -R -J -c bootcat -b $(BOOTDIR)/boot.sys -no-emul-boot -boot-load-size 4 -o \
	 ./$(BUILDDIR)/etera.iso ./$(BUILDDIR)/iso
	@echo -e " $(ETERA) write image success"


boot::
	mkdir -p $(BUILDDIR)/$(BOOTDIR)
	mkdir -p $(BUILDDIR)/iso/$(BOOTDIR)
	nasm -f bin $(BOOTDIR)/boot.asm -o  $(BUILDDIR)/$(BOOTDIR)/boot.o
	nasm -f elf64 $(BOOTDIR)/loader.asm -o  $(BUILDDIR)/loader.bin
	cp $(BUILDDIR)/$(BOOTDIR)/boot.o $(BUILDDIR)/iso/$(BOOTDIR)/boot.sys
	@echo -e " $(ETERA) build bootloader success"

test::
	@qemu-system-x86_64 -cdrom ./build/etera.iso -bios ./tools/bios.bin

# Regular Colors
BLACK := \033[0;30m# Black
RED := \033[0;31m # Red
GREEN := \033[0;32m # Green
YELLOW := \033[0;33m # Yellow
BLUE = \033[0;34m # Blue
PURPLE =\033[0;35m # Purple
CYAN = \033[0;36m # Cyan
RESET := \033[0m # Text Reset

ETERA := [$(CYAN)OCEANUX$(RESET)]
