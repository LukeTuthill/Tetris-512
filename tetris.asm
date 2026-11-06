; Tells assembler to emit 16-bit code and where code will load
        bits 16
        org 0x7C00

BLOCK_SIZE equ 20
ROWS equ 20
COLS equ 10

; Colors for tetronimos
T_COLOR equ 9 ; Light blue
L_COLOR equ 14 ; Yellow
J_COLOR equ 5 ; Magenta
I_COLOR equ 3 ; Cyan
O_COLOR equ 4 ; Red
S_COLOR equ 2 ; Green
Z_COLOR equ 1 ; Blue

WALL_COLOR equ 7 ; Light gray

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
        mov si, 0
start:
        mov al, 0               ; erase before running
        call draw_piece
        mov bx, 100*320 + 150   ; top-left corner: y=100, x=150

        ; Test going through all 7 pieces
        inc si
        cmp si, 7
        jb frame
        xor si, si

frame:  hlt
        mov al, 0               ; black to erase
        call draw_piece

        call read_input

        add bx, 320
        mov al, ah               ; Loads color
        call draw_piece


        cmp bx, 180*320 + 150   ; stop when box reachs y=180
        jb frame

        jmp start ; just keeps running

draw_piece:
        push si
        push bx
        shl si, 1
        mov si, [pieces + si]
        mov bp, 16

.cell:
        ; Tests the current bit and shifts for next one
        shl si, 1
        jnc .empty
        call draw
.empty:
        add bx, BLOCK_SIZE

        ; Runs for all 16 points in 4 x 4 grid
        dec bp
        jz .done

        ; Runs for 4 columns
        test bp, 3
        jnz .cell

        ; After 4 columns, move down one and back four columns
        add bx, BLOCK_SIZE * (320 - 4)
        jmp .cell

.done:
        pop bx
        pop si
        ret


; Draws a single block
draw:   mov di, bx
        mov dx, BLOCK_SIZE
.row:   mov cx, BLOCK_SIZE
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
        sub bx, 10
        ret
.right:
        add bx, 10
        ret

; I, O, T, S, Z, J, L
pieces: dw 0x0F00, 0x6600, 0x4E00, 0x6C00, 0xC600, 0x8E00, 0x2E00
; Pads size to 512 bytes and adds the 0x55AA boot signature
        times 510 - ($ - $$) db 0
        dw 0xAA55
