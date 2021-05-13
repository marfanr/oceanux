; This function is used to display text on the bios screen
; using si as input
writeString:
    ; first save all registers first before we change it
    pusha
    ; make the value in ax register be 0
    xor     ax, ax    
    ; call the Teletype output function 
    mov     ah, 0x0e
    ; Clear Direction Flag
    cld
    ; start a looping
    ; we read the text by displaying it letter by letter
    .loop:
        ; load all si register into al register
        lodsb        
        ; if the value in register al is equal to 0 it means that all 
        ; letters in register si have been printed
        ; and we can finish this looping
        cmp      al, 0
        je      .exit

        ; interrupt forvideo mode, character and string output, and graphics
        int      0x10
        jmp     .loop ; make looping until finish
    ; end the loop
    .exit:
        ; before returning to the previous program we return all the registers
        ; that we stored earlier
        popa
        ret 

clearScreen:
    mov ax, 0x3
    int 10h
    ret