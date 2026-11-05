        ; Tells assembler to emit 16-bit code and where code will load
        bits 16
        org 0x7C00

        ; Sets mode to 320x200, 256 colors
        mov ax, 0x0013
        int 0x10

        ; ES -> VGA framebuffer
        push 0xA000
        pop es

        mov di, 100*320 + 150   ; top-left corner: y=100, x=150
        mov al, 4               ; palette color index, 4 for red
        mov dx, 20              ; box height in rows

        ; Draws the red box
row:    mov cx, 20              ; box width in pixels
        rep stosb               ; write AL to ES:[DI], CX times, DI advances
        add di, 320-20          ; jump to start of next row (screen width - box width)
        dec dx
        jnz row

        jmp $                   ; hang here so the screen stays up

        ; Pads size to 512 bytes and adds the 0x55AA boot signature
        times 510 - ($ - $$) db 0
        dw 0xAA55
