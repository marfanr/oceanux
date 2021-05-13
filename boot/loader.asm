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
extern apa
section .text

boot32:
    .text:
    mov ax, DATA_SEG
    mov ds, eax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov eax, 0x8000
    mov esp, eax


    ; mov byte [0xB8000], 'S'
    jmp apa

    jmp $


; Note that, since we are in protected mode, we cannot call BIOS INT any more.
; Instead, we feed ASCII to buffer, which is [ebx]
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

hello: db "Hello world!",0

times   0x8000 - ($ - $$)    db  0
