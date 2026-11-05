; Tells assembler to emit 16-bit code and where code will load
        bits 16
        org 0x7C00

BLOCK_SIZE equ 8
ROWS equ 20
COLS equ 10

; Colors for tetronimos
T_COLOR equ 3 ;
L_COLOR equ 4 ; Red
J_COLOR equ 5 ;
I_COLOR equ 6 ;
O_COLOR equ 7 ;
S_COLOR equ 8 ;
Z_COLOR equ 9 ;

; Sets mode to 320x200, 256 colors
        mov ax, 0x0013
        int 0x10

; ES -> VGA framebuffer
        push 0xA000
        pop es

; Speeding up PIT tick rate
        mov al, 0x26
        out 0x40, al
        out 0x40, al

        mov ah, 4
start:
        mov al, 0               ; erase before running
        call draw
        mov bx, 100*320 + 150   ; top-left corner: y=100, x=150

frame:  hlt
        mov al, 0               ; black to erase
        call draw

        add bx, 320
        mov al, ah               ; Loads color
        call draw

        call read_input

        cmp bx, 180*320 + 150   ; stop when box reachs y=180
        jb frame

        jmp start ; just keeps running

; Draws the red box
draw:   mov di, bx
        mov dx, 20
.row:   mov cx, 20
        rep stosb
        add di, 320-20
        dec dx
        jnz .row
        ret

read_input:
        in al, 0x60        ; read the latest scancode
        cmp al, 0x1E       ; 'A' make code
        je  .left
        cmp al, 0x20       ; 'D' make code
        je  .right
        ret
.left:
        mov al, 0          ; erase then rest
        call draw
        mov bx, 100*320 + 150   ; top-left corner: y=100, x=150
        mov ah, 1
        ret
.right:
        mov ah, 5
        ret


; Pads size to 512 bytes and adds the 0x55AA boot signature
        times 510 - ($ - $$) db 0
        dw 0xAA55
