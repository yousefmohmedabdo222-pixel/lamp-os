[bits 16]
[org 0x7c00]
start:
    mov ax, 0x0003
    int 0x10
    mov si, msg
    call print
    jmp $
print:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print
.done:
    ret
msg db 'LAMP OS - Direct Boot Success!', 0
times 510-($-$$) db 0
dw 0xAA55
