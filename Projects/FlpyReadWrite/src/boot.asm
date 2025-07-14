[org 0x7C00]

start:
    cli
    xor ax, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [boot_drive], dl

    ; Fill buffer at 0x0500:0000 with 'A'
    mov ax, 0x0500
    mov es, ax
    xor di, di
    mov cx, 512
    mov al, 'A'
    rep stosb

    ; Reset disk
    mov dl, [boot_drive]
    mov ah, 0x00
    int 0x13

    ; Write buffer to sector 2 (CHS 0/0/2)
    mov ax, 0x0500
    mov es, ax
    xor bx, bx
    mov ah, 0x03
    mov al, 1      ; sectors
    mov ch, 0      ; cylinder
    mov cl, 2      ; sector
    mov dh, 0      ; head
    mov dl, [boot_drive]
    int 0x13
    jc fail

    ; Success: hang
    jmp $

fail:
    jmp $
    
boot_drive: db 0

times 510 - ($ - $$) db 0
dw 0xAA55
