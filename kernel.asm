[bits 16]
[org 0x7c00]
start:
    ; تنظيف الشاشة
    mov ax, 0x0003
    int 0x10
    
    ; إعداد موضع النص
    mov dh, 5
    mov dl, 20
    call move_cursor
    
    ; رسم شعار
    mov si, banner_top
    call print_string
    
    mov dh, 6
    mov dl, 25
    call move_cursor
    mov si, title
    call print_string
    
    mov dh, 7
    mov dl, 20
    call move_cursor
    mov si, banner_bottom
    call print_string
    
    ; معلومات النظام
    mov dh, 9
    mov dl, 22
    call move_cursor
    mov si, message1
    call print_string
    
    mov dh, 10
    mov dl, 22
    call move_cursor
    mov si, message2
    call print_string
    
    mov dh, 11
    mov dl, 22
    call move_cursor
    mov si, message3
    call print_string
    
    ; انتظار ثم إعادة التشغيل
    mov dh, 13
    mov dl, 22
    call move_cursor
    mov si, press_key
    call print_string
    
    mov ah, 0x00
    int 0x16
    int 0x19  ; إعادة التشغيل

move_cursor:
    mov ah, 0x02
    mov bh, 0
    int 0x10
    ret

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

banner_top   db '=============================', 0x0D, 0x0A, 0
title        db '      🪔 LAMP OS v1.0      ', 0x0D, 0x0A, 0
banner_bottom db '=============================', 0x0D, 0x0A, 0x0D, 0x0A, 0
message1     db 'Boot successful!', 0x0D, 0x0A, 0
message2     db 'Kernel loaded at 0x7C00', 0x0D, 0x0A, 0
message3     db 'System ready', 0x0D, 0x0A, 0
press_key    db 'Press any key to restart...', 0

times 510-($-$$) db 0
dw 0xAA55
