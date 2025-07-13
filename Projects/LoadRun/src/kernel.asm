[bits 16]
[org 0x8000] ; Address must be correct and align with bootloader code

; Entry point
start:
  ; Print hello message
  mov si, hello
  call printString

  ; Hang kernel
  jmp $

; Print a string
printString:
  lodsb           ; Load next character
  or al, al       ; Check for terminator
  jz .done        ; Finish printing and return
  mov ah, 0x0E    ; Tty print
  int 0x10        ; Call interupt
  jmp printString ; Loop
.done:
  ret

hello db "Kernel loaded", 0x0D, 0x0A, 0
