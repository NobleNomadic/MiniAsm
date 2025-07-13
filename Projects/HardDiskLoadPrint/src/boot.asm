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

  ; Load the kernel
  jmp loadKernel

  ; Finished, hang system
  jmp hang

; Load the kernel from the disk into memory and give it control
loadKernel:
  mov ax, 0x0000      ; Load segment 0x0000
  mov es, ax
  mov bx, 0x8000      ; Load to 0000:8000 (segment:offset = physical 0x8000)

  ; BIOS Enhanced Disk Drive (EDD) LBA read
  mov ah, 0x42
  mov dl, 0x80             ; Hard disk

  mov si, lba_packet
  int 0x13
  jc diskReadFail     ; Jump if carry (error)

  ; Debug: print once the kernel is loaded before jumping
  mov si, afterLoad
  call printString

  ; Fully jump to 0000:8000 and give that code control
  jmp 0x0000:0x8000

diskReadFail:
  mov si, diskErr
  call printString
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
msg db "Bootable device found", STREND
diskErr db "Disk read failed", STREND
afterLoad: db "Loaded kernel, jumping now", STREND

; LBA Packet
lba_packet:
  db 0x10              ; size of packet (16 bytes)
  db 0                 ; reserved
  dw 4                 ; number of sectors to read
  dw 0x8000            ; buffer offset
  dw 0x0000            ; buffer segment
  dq 0x00000001        ; LBA (start from sector 1)

; Boot signature
times 510 - ($ - $$) db 0
dw 0xAA55
