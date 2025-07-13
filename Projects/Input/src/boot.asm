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
  mov ah, 0x00 ; Set tty
  mov al, 0x03 ; Tty mode
  int 0x10     ; Call BIOS interupt

  ; Print msg variable
  mov si, msg      ; Load message into SI
  call printString ; Call print function

  ; Get a character and echo it
  call readLine

  ; Now that the message entered is in inputBuffer, print it
  ; Add a newline
  mov si, newline
  call printString
  ; Print the additional message
  mov si, echoMsg
  call printString
  ; Use the input buffer to print
  mov si, inputBuffer
  call printString

  ; Finished, hang system
  jmp hang


; Read a string of characters
; Repeat readChar until enter is pressed (0x0D), then add 0x0A + 0x00
readLine:
  pusha
  mov di, inputBuffer  ; DI points to input buffer start

.readLoop:
  call readChar       ; AL = char read (already echoed)
  cmp al, 0x0D        ; check if Enter pressed
  je .doneReading

  mov [di], al        ; store char in buffer
  inc di              ; Increment DI array
  jmp .readLoop       ; Continue the loop

.doneReading:
  mov byte [di], 0x0D ; CR
  inc di
  mov byte [di], 0x0A ; LF
  inc di
  mov byte [di], 0x00 ; Null terminator
  popa
  ret

; Read a single character, echo it back, and store it in AL
readChar:
  mov ah, 0x00 ; Set tty mode
  int 0x16     ; BIOS interupt for wait for key press
  mov ah, 0x0E ; Set tty print
  int 0x10     ; Call BIOS interupt for print
  ret

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
msg db "READY", STREND           ; Ready message for input
echoMsg db "You entered: ", 0x00 ; Message to show input is working
inputBuffer resb 128             ; Reserve 128 bytes for getting input
newline db STREND                ; Print a new line

; Boot signature
times 510 - ($ - $$) db 0
dw 0xAA55
