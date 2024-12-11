[org 0x7c00]             ; Set the origin to the memory location where the BIOS loads the bootloader (0x7C00)

start:
    cli                  ; Disable interrupts
    mov ax, 0x07c0       ; Set up the stack segment
    mov ss, ax
    mov sp, 0x7c00       ; Stack pointer starts at 0x7C00

    ; Debug: Print 'B' to indicate bootloader is running
    mov ah, 0x0e         ; BIOS teletype function
    mov al, 'B'          ; Character to print
    int 0x10

    ; Load the kernel
    mov bx, kernel_address  ; Target memory location for the kernel
    mov dh, 0               ; Head 0
    mov dl, 0               ; Drive 0 (first floppy or hard disk)
    mov ch, 0               ; Cylinder 0
    mov cl, 2               ; Sector 2 (kernel starts here)
    call read_sector        ; Load kernel into memory

    ; Debug: Print 'L' to indicate kernel was loaded
    mov ah, 0x0e
    mov al, 'L'
    int 0x10

    ; Jump to the kernel entry point
    jmp kernel_address

    ; Debug: If the kernel returns, print 'E' (unexpected behavior)
    mov ah, 0x0e
    mov al, 'E'
    int 0x10
    hlt                    ; Halt the CPU if something went wrong

; BIOS disk read function
read_sector:
    push es                ; Save ES register
    mov ah, 0x02           ; BIOS read function
    mov al, 1              ; Read one sector
    mov es, bx             ; ES:BX points to the target memory
    int 0x13               ; Call BIOS interrupt
    jc error               ; Jump if carry flag (error)
    pop es                 ; Restore ES register
    ret

error:
    mov ah, 0x0e           ; BIOS teletype function
    mov al, 'X'            ; Debug: Print 'X' for error
    int 0x10
    hlt                    ; Halt the CPU on error

; Define the memory address where the kernel will be loaded
kernel_address equ 0x1000  ; Kernel will be loaded to memory location 0x1000

; Pad the bootloader to 512 bytes (one sector)
times 510-($-$$) db 0
dw 0xaa55                 ; Boot signature (required for BIOS to recognize this as bootable)
