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

; Load the kernel from the disk into memory and give it control
loadKernel:
  mov ax, 0x0000      ; Load segment 0x0000
  mov es, ax
  mov bx, 0x8000      ; Load to 0000:8000 (segment:offset = physical 0x8000)

  mov ah, 0x02        ; BIOS: read sectors
  mov al, 2           ; Read 2 sectors
  mov ch, 0           ; Cylinder 0
  mov cl, 2           ; Sector 2
  mov dh, 0           ; Head 0
  mov dl, 0x00        ; Drive 0 (floppy)
  int 0x13            ; Call BIOS

  jc .diskReadFail    ; Check read error

  ; Setup GDT for protected mode
  cli
  lgdt [gdt_descriptor]

  ; Enable protected mode
  mov eax, cr0
  or eax, 1
  mov cr0, eax

  ; Far jump to protected mode kernel (flush CS)
  jmp CODE_SEG:0x8000
.diskReadFail:
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

; -----------------------------
; GDT and Protected Mode Setup
; -----------------------------

gdt_start:
  ; Null descriptor
  dd 0x00000000
  dd 0x00000000

  ; Code segment: base 0x00000000, limit 0xFFFFF, type 0x9A
  dw 0xFFFF          ; Limit low
  dw 0x0000          ; Base low
  db 0x00            ; Base mid
  db 0x9A            ; Access byte
  db 0xCF            ; Flags + limit high
  db 0x00            ; Base high

  ; Data segment: base 0x00000000, limit 0xFFFFF, type 0x92
  dw 0xFFFF
  dw 0x0000
  db 0x00
  db 0x92
  db 0xCF
  db 0x00

gdt_end:

gdt_descriptor:
  dw gdt_end - gdt_start - 1
  dd gdt_start

CODE_SEG equ 0x08
DATA_SEG equ 0x10

; -----------------------------
; DATA SECTION
; -----------------------------

msg db "[*] Bootable device found", STREND
diskErr db "[-] Disk read failed", STREND

; Boot signature
times 510 - ($ - $$) db 0
dw 0xAA55
