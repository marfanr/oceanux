; Run program on 16 bits
global _start

%include 'boot/var.asm'

bits 16
;this sector starting from this code
_start:
    cli

    ; Initialize all segment registers to zero.
    xor     ax,     ax
    mov     ds,     ax
    mov     es,     ax
    mov     fs,     ax
    mov     gs,     ax
    mov     ss,     ax

    ; Initialize the stack pointer.
    mov     bp,     0x8000
    mov sp, bp

    ; Clear all remaining general purpose registers.
    xor     bx,     bx
    xor     cx,     cx
    xor     dx,     dx
    xor     si,     si
    xor     di,     di
    xor     bp,     bp

    sti

    mov bp, 0x8000
    mov sp, bp
    mov si, loaderLoaded
    call writeString
    call A20Setup

init:
    cli
    ; VESA ---------------------------------------------------------------------
    push es
    mov ax, 0x4F00
    mov di, 0x49500
    int 0x10
    cmp ax, 0x004F
    jne fail
    pop es

    mov ax, 0x4F02	; set VBE mode
    mov bx, 0x4114	; VBE mode number; notice that bits 0-13 contain the mode number and bit 14 (LFB) is set and bit 15 (DM) is clear.
    int 0x10			; call VBE BIOS
    cmp ax, 0x004F	; test for error
    jne fail
    ; --------------------------------------------------------------------- VESA

    ; load gdt
    lgdt [GDT32_POINTER]

    ; switch protected mode
    mov eax, cr0
    or al, 1       ; set PE (Protection Enable) bit in CR0 (Control Register 0)
    mov cr0, eax

    jmp GDT32_CODE : boot32

; GDT --------------------------------------------------------------------------
struc GDT32
    .limitL: resw 1
    .baseL: resw 1
    .baseM: resb 1
    .access: resb 1
    .limitH: resb 1
    .baseH: resb 1
endstruc

align 4
GDT32_START:
    ; null descriptor
    istruc GDT32
        at GDT32.limitL, dw 0x0000
        at GDT32.baseL, dw 0x0000
        at GDT32.baseM, db 0x00
        at GDT32.access, db 0x00
        at GDT32.limitH, db 0x00
        at GDT32.baseH, db 0x00
    iend
    ; Code descriptor
    istruc GDT32
        at GDT32.limitL, dw 0xFFFF
        at GDT32.baseL, dw 0x0000
        at GDT32.baseM, db 0x00
        at GDT32.access, db 10011010b
        at GDT32.limitH, db 11001111b
        at GDT32.baseH, db 0x00
    iend
    ; Data Descriptor
    istruc GDT32
        at GDT32.limitL, dw 0xFFFF
        at GDT32.baseL, dw 0x0000
        at GDT32.baseM, db 0x00
        at GDT32.access, db 10010010b
        at GDT32.limitH, db 11001111b
        at GDT32.baseH, db 0x00
    iend
GDT32_POINTER:
    dw ($ - GDT32_START - 1)
    dd GDT32_START

GDT32_CODE equ 0x08
GDT32_DATA equ 0x10

; Fail -------------------------------------------------------------------------
fail:
    mov si, msg.Fail
    call writeString
    jmp $

; HARDWARE NOT SUPPORTED -------------------------------------------------------
HardwareNotSupported:
    mov si, msg.HardwareNotSupported
    call writeString
    jmp $

; DATA -------------------------------------------------------------------------
loaderLoaded db "Now On Sector#2...", 0x0d, 0x0a, 0
msg.Fail db "ERR: Booting Failure", 0x0d, 0x0a, 0
msg.HardwareNotSupported db "ERR: Hardware Not Supported :(", 0x0d, 0x0a, 0

; LIB --------------------------------------------------------------------------

%include 'boot/string.asm'
%include 'boot/A20.asm'

; Entering
; 32 BIT -----------------------------------------------------------------------
bits 32
section .text
boot32:
    .text:
    mov ax, GDT32_DATA
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov ebx, Var.StackBot
    mov esp, ebx

    call check_cpuid
    call check_long_mode
    call setup_page_table
    call enable_pagging

    lgdt [gdt64.pointer]

    ; activate long mode
    jmp gdt64.code_segment:boot64

; Chec CPU-ID ------------------------------------------------------------------
check_cpuid:
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 1 << 21
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    cmp eax,ecx
    je .no_cpuid
    ret
.no_cpuid:
    mov al, "C"
    jmp fail32

; check long mode -------------------------------------------------------------
check_long_mode:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .no_long_mode

    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .no_long_mode

    ret
.no_long_mode:
    mov al, "L"
    jmp fail32

; setup page table ------------------------------------------------------------
setup_page_table:
    mov eax, page_table_l3
    or eax, 0b11 ; present writable
    mov [page_table_l4], eax

    mov eax, page_table_l2
    or eax, 0b11 ; present writable
    mov [page_table_l3], eax

    mov ecx, 0 ;counter
.loop:

    mov eax, 0x200000 ; 2MiB
    mul ecx
    or eax, 0b10000011 ; present, writable, huge page
    mov [page_table_l2 + ecx * 8], eax

    inc ecx ; increment counter
    cmp ecx, 512 ;checks if whle table is mapped
    jne .loop ; if not, continue

    ret

; enable pagging --------------------------------------------------------------
enable_pagging:
    ; pass page table location to cpu
    mov eax, page_table_l4
    mov cr3, eax

    ;eanable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ;enable paging
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ret

; Fail for 32 bit --------------------------------------------------------------
fail32:
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte [0xb800a], al
    hlt

; print video mode -------------------------------------------------------------
msg32.Fail db "ERR: Booting Failure", 0x0d, 0x0a, 0

print:
.loop:
    lodsb
    or al,al
    jz .halt
    or eax,0x0100
    mov word [ebx], ax
    add ebx,2
    jmp .loop
.halt:
    ret

; page_table -------------------------------------------------------------------
section .bss
align 4096
page_table_l4:
    resb 4096
page_table_l3:
    resb 4096
page_table_l2:
    resb 4096
stack_bottom:
    resb 4096 * 4
stack_top:

; GDT64 ------------------------------------------------------------------------
section .rodata
gdt64:
    dq 0 ; zero entry
.code_segment: equ $ - gdt64
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53) ; code segment
.pointer:
    dw $ - gdt64 - 1
    dq gdt64

; Entering
; 64 BIT -----------------------------------------------------------------------
bits 64
extern kern_main
boot64:
     mov rdi, 0x49500
    ; call Main  Kernel Function
    call kern_main
    jmp $


times   0x8000 - ($ - $$)    db  0
