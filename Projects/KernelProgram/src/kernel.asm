[bits 32]
[org 0x8000]
; Newline character and null terminator macro for string endings
%define STREND 0x0A, 0

kernelMain:
  ; Setup data segment registers
  mov ax, 0x10
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov esp, 0x90000   ; Setup stack
  
  ; Setup display
  call clearScreen  ; Clear all contents
  call hideCursor   ; Disable the hardware cursor, different to software curser position
  
  ; Initialize cursor position
  mov dword [cursorPos], 0xB8000
  
  ; Print first message
  mov esi, kernelInitMsg
  call printVGA
  
  ; Stop here, infinite loop
  jmp $

; Clear the screen
clearScreen:
  pusha
  mov edi, 0xB8000       ; VGA text buffer
  mov ecx, 80 * 25       ; 80 columns, 25 rows
  mov ax, 0x0F20         ; Space character with white on black
  rep stosw              ; Fill screen with spaces
  
  popa
  ret

; Hide the hardware text cursor
hideCursor:
  pusha
  ; Set cursor start register to disable cursor
  mov al, 0x0A           ; Cursor start register
  mov dx, 0x3D4          ; VGA index register
  out dx, al
  mov al, 0x20           ; Disable cursor (bit 5 set)
  mov dx, 0x3D5          ; VGA data register
  out dx, al
  popa
  ret

; PrintVGA
; Print a string of characters
; Input: ESI = pointer to string
; Uses global cursorPos variable
printVGA:
  pusha
  mov edi, [cursorPos]   ; Load current cursor position
  mov ah, 0x0F           ; White on black attribute
.printLoop:
  lodsb                  ; Load byte from ESI into AL
  test al, al            ; Check for null terminator
  jz .done               ; If terminator, then finish
  
  ; Check for newline
  cmp al, 0x0A           ; Line Feed?
  je .newline            ; Conditional jump if equal to print a new line
  
  ; Print character
  mov [edi], al          ; Store character
  mov [edi+1], ah        ; Store attribute
  add edi, 2             ; Move to next character cell
  jmp .printLoop
  
.newline:
  ; Save the color attribute
  push ax
  ; Move to next VGA line (80 columns * 2 bytes)
  mov eax, edi
  sub eax, 0xB8000       ; Get offset from start of VGA buffer
  mov ebx, 160           ; 80 * 2
  xor edx, edx
  div ebx                ; divide offset by 160
  inc eax                ; move to next line
  mul ebx                ; get byte offset
  add eax, 0xB8000       ; add back VGA base address
  mov edi, eax
  ; Restore the color attribute
  pop ax
  jmp .printLoop         ; Return to the main loop
.done:
  mov [cursorPos], edi   ; Save current cursor position
  popa                   ; Pop all registers and return
  ret

; Global cursor position
cursorPos dd 0xB8000

; Make sure string is properly null-terminated
kernelInitMsg db "[+] Kernel 32 bit init", STREND
newlineMsg db STREND

; Pad the kernel to 1024 bytes (2 sectors)
times 1024 - ($ - $$) db 0
