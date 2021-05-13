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

.init:
    call check_cpuid
    call check_long_mode

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
    jmp fail

fail:
    mov si, msg.Fail
    call writeString
    jmp $

; DATA -----------------------------------------------------------

loaderLoaded db "entering stage#2...", 0x0d, 0x0a, 0
msg.Fail db "ERR: Booting Failure", 0x0d, 0x0a, 0

; STRING ---------------------------------------------------------

%include 'boot/string.asm'

times   0x8000 - ($ - $$)    db  0
