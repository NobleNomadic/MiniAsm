[bits 16]
[org 0x7C00]

; Macro for end of string with newline
%define STREND 0x0D, 0x0A, 0x00

; Entry point
start:
  ; Setup data
  mov ax, 0
  mov ds, ax
  ; Setup stack
  mov ss, ax
  mov sp, 0x7C00
  
  ; Clear the screen with BIOS interupt to reset mode
  mov ah, 0x00 ; Setup font and tty data
  mov al, 0x03
  int 0x10     ; Call BIOS interupt

  ; Print msg variable
  mov si, msg    ; Load message into SI
  call printString

  ; Finished, hang system
  jmp hang

; Print a string
; Loop over data in SI
printString:
  push ax    ; Push used registers to stack
  push si
.printLoop:
  lodsb         ; Load the next character
  or al, al     ; Check if its a null terminator
  jz .done      ; Finish and exit function
  mov ah, 0x0E  ; Set AH to get ready for BIOS interupt for tty print
  int 0x10      ; Call BIOS interupt

  ; Continue the loop
  jmp .printLoop
.done:
  pop si        ; Return register state
  pop ax
  ret

; Hang program
hang:
  jmp $ ; Jump to the current location in memory


; DATA SECTION
msg db "Hello!", STREND

; Boot signature
times 510 - ($ - $$) db 0
dw 0xAA55
