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