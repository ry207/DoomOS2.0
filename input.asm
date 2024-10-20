[org 0x7c00]
cld ; Clear direction flag, positive increments for movsb and lodsb (string instructions)
lea di, [data] ; Load data address as DI (destination index)

%define ENDL 0x0D, 0x0A

start:
    mov ax, 0x3     ;clear scree
    int 10h         ;clear screen pt2
    jmp space

;new line
space:
    pop ax
    pop bx
    pop eax
    mov ah, 0x0e
    mov al, 13
    int 0x10
    mov ah, 0x0e
    mov al, 0AH
    int 0x10
    jmp arrow

;print arrow ->
arrow:
    mov ah, 0x0e
    mov al, '$'
    int 0x10
    pop ax
    pop bx
    pop eax
    jmp clear_stack

clear_stack:
    cmp di, data ; Do nothing if DI is already the beginning of 'data'
    je type
    dec di ; Move DI to previous byte
    mov byte [di], 0 ; Remove byte
    jmp clear_stack

type:
    mov ah, 0
    int 0x16 ; Load next character typed into AL
    mov [bx], al ; Copy character into BX
    cmp al, 0x0d
    je prepare_print ; Enter
    cmp al, 45      ;the - key prints new screen
    je start
    cmp al, 0x08
    je remove_byte ; Backspace
    cmp di, end_of_data
    je type ; End of data
    mov ah, 0x0e
    int 0x10
    jmp store_byte ; Other
store_byte:
    lea si, [bx] ; Load BX address as SI (source index)
    movsb ; Copy data at SI into DI then increment DI (and technically SI)
    jmp type
remove_byte:
    cmp di, data ; Do nothing if DI is already the beginning of 'data'
    je type
    dec di ; Move DI to previous byte
    mov byte [di], 0 ; Remove byte

    ; Display backspace for current input
    mov ah, 0x0e
    mov al, 0x08
    int 0x10 ; Move back a character
    mov al, ' '
    int 0x10 ; Cover the character with a blank space
    mov al, 0x08
    int 0x10 ; Move back again
    jmp type
prepare_print:
    lea si, [data] ; Load data address as SI
    mov ah, 0x0e
    mov al, 13
    int 0x10
    mov ah, 0x0e
    mov al, 0AH
    int 0x10
    jmp print_loop

; Reads then reprints data.
print_loop:
    lodsb ; Load byte in SI into AL
    cmp al, 0
    je space ; End of data
    int 0x10
    jmp print_loop


data:
    times 64 db 0 ; Generate 64 bytes of null data
end_of_data:
    db 0 ; Add null terminator

clear_command: db "[-] clears the screen [~]&[#] changes bgcolors [*] prints the title", 0


message: db "Type ? for a list of commands",ENDL, 0
name: db "DoomOS", 0



times 510-($-$$) db 0
dw 0AA55h

