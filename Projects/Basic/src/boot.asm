[bits 16]
[org 0x7C00]

; Entry point
start:
  ; Setup data
  mov ax, 0
  mov ds, ax
  ; Setup stack
  mov ss, ax
  mov sp, 0x7C00
  
  ; Clear the screen with BIOS interupt to reset mode
  mov ax, 0x00 ; Set mode
  int 0x10     ; Call BIOS interupt

; Hang program
hang:
  jmp $

; Boot signature
times 510 - ($ - $$) db 0
dw 0xAA55
