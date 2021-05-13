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

    call check_cpuid

jmp $

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
    jmp fail

fail:
    mov si, msg.Fail
    call writeString
    jmp $

%include 'boot/string.asm'

; DATA -----------------------------------------------------------

loaderLoaded db "loader was found", 0x0d, 0x0a, 0
msg.Fail db "ERR: Booting Failure", 0x0d, 0x0a, 0

times   0x8000 - ($ - $$)    db  0
