bits 16
org 0

%include    'boot/var.asm'

jmp Var.BaseSeg : boot

; the first loaded section
boot:
    cli
    
    mov     ax,     cs
    mov     ds,     ax
    mov     fs,     ax
    mov     gs,     ax

    xor     ax,     ax
    mov     ss,     ax
    mov     sp,     Var.StackTop

        mov     es,     ax

    sti

    mov byte [es:DRIVE_NUMBER], dl

    ; print loading
    mov si, msg.Load
    call    writeString

    mov es, ax

    mov cx, 1
    mov bx, 0x10
    mov di, Var.SectorBuffer

    ; call readVolume

    mov bx, 0x01
    call readVolume

readVolume:
    call readDisk
    jc fail

    mov al, [es:Var.SectorBuffer]
    cmp al, 0x01
    je .found

    cmp al ,0xff
    je fail

    inc bx
    jmp readVolume

    .found:
        mov si, msg.primaryFound
        call writeString

        mov bx, [es:Var.SectorBuffer + \
                ISO9660.PrimaryVolumeDescriptor.rootDirEntry + \
                ISO9660.Directory.locationLBA]

        mov [es:ROOT_DIR], bx

    .findLoader:
        .proccSector:
            ; load cur dirrectory sector intro the buffer
            mov     cx,     1                   ; read 1 sector
            mov     di,     Var.SectorBuffer   ; read into sector buffer

            call    readDisk
            jc      fail

        .proccDirEntry:
            xor ax,     ax
            mov al,     [es:di + ISO9660.Directory.lengthRecord]
            cmp al, 0
            je fail

            test byte [es:di + ISO9660.Directory.fileFlags], 0x02
            jnz .nextDirEntry

            cmp byte [es:di + ISO9660.Directory.nameLength], filelength
            jne .nextDirEntry

            push di
            mov cx,     filelength
            mov si,     filename
            add di,     ISO9660.Directory.name
            cld
            rep cmpsb
            pop di
            je .loaderFound

        .nextDirEntry:
            add di,     ax
            cmp di,     Var.SectorBuffer + Var.SectorBuffer.Size
            jb .proccDirEntry

        .nextSector:
            inc bx
            jmp .proccSector

        .loaderFound:
            mov si, msg.loaderFound
            call writeString

    .readLoader:
        mov bx, [es:di + ISO9660.Directory.locationLBA]

        .calcSize:

            mov cx, [es:di + ISO9660.Directory.size]

            add cx, Var.SectorBuffer.Size - 1
            shr cx, 11

        .load:
            mov ax,     Var.LoaderSeg
            mov es,     ax
            xor di,     di

            call readDisk
            jc fail

    .launchLoader:
        jmp     0x0000 : Var.Loader

jmp $

fail:
  mov si, msg.Fail
  call writeString
  jmp $

readDisk:
  mov word [BIOS + DAP.readSector], cx
  mov word [BIOS + DAP.offset], di
  mov word [BIOS + DAP.segment], es
  mov word [BIOS + DAP.first], bx

  lea si, [BIOS]

  mov ax, 0x4200
  int 0x13
  ret

 struc DAP
    .size:            resw 1 ; packet size
    .readSector:      resw 1; unused
    .offset:          resw 1 ; number of sector
    .segment:         resw 1
    .first:           resq 1
  endstruc

align 4
BIOS:
istruc DAP
  at DAP.size,        db DAP_size
  at DAP.readSector,  dw 0
  at DAP.offset,      dw 0
  at DAP.segment,     dw 0
  at DAP.first,       dq 0
iend

notFound:
    mov si, msg.notFound
    call writeString
    jmp $

; data segment
loadSectorMsg   db "Loading Sector...", 0x0d, 0x0a, 0
ok  db "ok", 0x0d, 0x0a, 0 ; for testing


%include    'boot/string.asm'
%include    'boot/iso.asm'


; ---------------------------------------------

msg.Load db "Booting...", 0x0d, 0x0a, 0
msg.Fail db "ERR: Booting Failure", 0x0d, 0x0a, 0
msg.no_file db "ERR: File Not Found", 0x0d, 0x0a, 0
msg.crlf db "Starting Cluster", 0x0d, 0x0a, 0
msg.notFound db "ERR: Failed To Load", 0x0d, 0x0a, 0
msg.primaryFound db "Primary Volume has been found", 0x0d, 0x0a, 0
msg.loaderFound db "Loader was Found", 0x0d, 0x0a, 0

DRIVE_NUMBER db 0
filename db 'KERNEL.SYS;1'
filelength equ ($ - filename)


ROOT_DIR db 0


end_program:
; Is the entry zero length? If so, we ran out of files in the

    times   0x1fe - ($ - $$)    db  0
    signature   dw 0xaa55
