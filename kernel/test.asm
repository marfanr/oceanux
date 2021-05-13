bits 32
global testq
testq:
    mov esi, hello
    mov ebx, 0xB8000
    call print
    ret

print:
    .loop:
        lodsb                           ; load string byte from [DS:SI] into AL
        or al,al                        ;
        jz .halt                         ; the above two lines => jump if AL==0. Equivalent to CMP AL; JE halt
        or eax,0x0400           ; config text color to be 1 (blue)  [4bit bg color][4bit text color][8bit ascii]
                            ; more color info can be found in https://en.wikipedia.org/wiki/Video_Graphics_Array#Color_palette
        mov word [ebx], ax      ; feed ASCII and color to buffer in memory
        add ebx,2                       ; increase ebx by two bytes (1byte for color, 1byte for ASCII)
        jmp .loop
    .halt:
        ret

    hello: db "Hello world!",0
