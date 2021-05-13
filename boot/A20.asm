A20Setup:
    call manulcheckA20
    call biosEnableAI20
        .hang:
            call fastA20Gate    
            call HardwareNotSupported
            call A20CantEnabled
            hlt
            jmp .hang

    
manulcheckA20:      
    pushf
    push ds
    push es
    push di
    push si
 
    cli
 
    xor ax, ax ; ax = 0
    mov es, ax
 
    not ax ; ax = 0xFFFF
    mov ds, ax
 
    mov di, 0x0500
    mov si, 0x0510
 
    mov al, byte [es:di]
    push ax
 
    mov al, byte [ds:si]
    push ax
 
    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF
 
    cmp byte [es:di], 0xFF
 
    pop ax
    mov byte [ds:si], al
 
    pop ax
    mov byte [es:di], al
 
    mov ax, 0
    je .exit
 
    mov ax, 1
    .exit:
        sti
        pop si
        pop di
        pop es
        pop ds
        popf        
        cmp ax, 1     
        je _start.enterProtectedMode
        ret       

biosEnableAI20:    
    
    mov ax,     2403h ; check A20 gate supported
    int 15h
    jb  keyboardControllerEnableA20
    cmp ah,     0
    jnz keyboardControllerEnableA20

    mov ax,     2402h
    int 15h
    jb keyboardControllerEnableA20
    cmp ah,     0
    jnz keyboardControllerEnableA20

    .checkIfEnabled:
        cmp al,     1
        jz manulcheckA20

    .enablingGate:
        mov ax,     2401h ; enabling gate
        int 15h
        jb keyboardControllerEnableA20
        cmp ah,     0
        jnz keyboardControllerEnableA20
        jmp .checkIfEnabled
    
keyboardControllerEnableA20:
    cli ; dissable interrupt
    
    call .a20wait
    mov al,     0xad    ; dissable keyboard
    out 0x64,   al

    call .a20wait   ; when controller ready for command
    mov al,     0xd0    ;   send command read for input
    out 0x64,   al

    call .a20wait2  ; whe controller has data ready
    in al,  0x60    ;   Read input from keyboard
    push eax

    call .a20wait
    mov al,     0xd1    ; Set command 0xd1 (write to output)
    out 0x64,   al

    call .a20wait
    pop eax  ; Write input back, with bit #2 set
    or al,       2
    out 0x60,    al

    call .a20wait
    mov al,     0x64
    out 0x64,   al

    call .a20wait
    sti ; bring back interrupt
    jmp manulcheckA20
        .a20wait:
            in al,      0x64
            test al,    2
            jnz .a20wait
            ret
        .a20wait2:
            in al,  0x64
            test al, 1
            jz .a20wait2
            ret
        
        
fastA20Gate:
    in al,      0x92
    test al,    2
    jnz manulcheckA20
    or al,      2
    and al,     0xfe
    out 0x92,   al
    ret                    
           

    ; Testing A20 line Manual
    ;  Returns: 0 in ax if the a20 line is disabled (memory wraps around)
    ;      1 in ax if the a20 line is enabled (memory does not wrap around)


