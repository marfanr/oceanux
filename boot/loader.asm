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
    mov     sp,     Var.StackTop

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
    mov si, loaderLoaded
    call writeString


jmp $



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

times   0x8000 - ($ - $$)    db  0
