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
    mov ah, 0x00
    mov al, 3
    int 10h

    ; load gdt
    lgdt [gdt_pointer]

    ; switch protected mode
    mov eax, cr0
    or al, 1       ; set PE (Protection Enable) bit in CR0 (Control Register 0)
    mov cr0, eax

    jmp CODE_SEG : boot32

; GDT ------------------------------------------------------------
gdt_start:
    dq 0x0 ; offset 0x0
  ; descriptor for cs
gdt_code: ; offset 0x8
    dw 0xFFFF; segment limit first 0-15 bits
    dw 0x0 ; base first 0:15 bits
    db 0x0 ; base firsts 0:15 bits
    db 10011010b ; access byte
    db 11001111b ; ; limit 16:19
    db 0x0 ; base 24:31 bits

; descritor for es, ds , ss, fs
gdt_data: ; offset 0x10
    dw 0xFFFF ; segment limit 0-15 bits
    dw 0x0; base first 0:15 bits
    db 0x0 ; base 16:23bits
    db 10010010b ; access byte
    db 11001111b ; limit 16:19
    db 0x0 ; base 24:31 bits

gdt_end:
gdt_pointer:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; Fail -----------------------------------------------------------
fail:
    mov si, msg.Fail
    call writeString
    jmp $

; HARDWARE NOT SUPPORTED -----------------------------------------
HardwareNotSupported:
    mov si, msg.HardwareNotSupported
    call writeString
    jmp $

; DATA -----------------------------------------------------------

loaderLoaded db "entering stage#2...", 0x0d, 0x0a, 0
msg.Fail db "ERR: Booting Failure", 0x0d, 0x0a, 0
msg.HardwareNotSupported db "ERR: Hardware Not Supported :(", 0x0d, 0x0a, 0

; LIB ------------------------------------------------------------

%include 'boot/string.asm'
%include 'boot/A20.asm'

; Entering
; 32 BIT ---------------------------------------------------------

[bits 32]

section .text

boot32:
    .text:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov ebx,0x8000
    mov esp, ebx

    mov byte [0xB8000], 'S'

    call check_cpuid
    call check_long_mode
    call setup_page_table
    call enable_pagging

    lgdt [gdt64.pointer]

    jmp gdt64.code_segment:boot64

; Chec CPU-ID -------------------------------------------------------------------
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
    ; emanle long mode
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


; print video mode --------------------------------------------------------------
msg32.Fail db "ERR: Booting Failure", 0x0d, 0x0a, 0

print:
.loop:
    lodsb                           ; load string byte from [DS:SI] into AL
    or al,al                        ;
    jz .halt                         ; the above two lines => jump if AL==0. Equivalent to CMP AL; JE halt
    or eax,0x0100           ; config text color to be 1 (blue)  [4bit bg color][4bit text color][8bit ascii]
                        ; more color info can be found in https://en.wikipedia.org/wiki/Video_Graphics_Array#Color_palette
    mov word [ebx], ax      ; feed ASCII and color to buffer in memory
    add ebx,2                       ; increase ebx by two bytes (1byte for color, 1byte for ASCII)
    jmp .loop
.halt:
    ret

; -------------------------------------------------------------------------------
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

section .rodata
gdt64:
    dq 0 ; zero entry
.code_segment: equ $ - gdt64
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53) ; code segment
.pointer:
    dw $ - gdt64 - 1
    dq gdt64

; Entering
; 64 BIT ---------------------------------------------------------
bits 64
extern apa

boot64:
    mov byte [0xB8000], 'C'
    call apa
    jmp $

times   0x8000 - ($ - $$)    db  0
