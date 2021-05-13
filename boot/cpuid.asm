detectCPUID:
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

    xor eax, ecx
    jz noCPUID
    ret

detectLongMode:
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz  noLongMode
    ret

noLongMode:
    mov byte [0xb8000], 'N'
    mov byte [0xb8000], 'L'

    hlt

noCPUID:
    mov byte [0xb8000], 'N'
    mov byte [0xb8000], 'C'
    hlt
    