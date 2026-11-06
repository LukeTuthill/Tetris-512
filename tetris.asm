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
        and si, -4
        add si, 4
        cmp si, 28
        jb frame
        xor si, si

frame:  hlt
        hlt
        hlt
        hlt
        mov al, 0               ; black to erase
        call draw_piece

        ; Input is done after previous piece is erased
        ; so no cleanup needs to be done
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
        in al, 0x60       ; read the latest scancode
        cmp al, 0x1E      ; 'A' make code
        je  .left
        cmp al, 0x20      ; 'D' make code
        je  .right
        cmp al, 0x34      ; '.' for left rotate
        je  .left_rotate
        cmp al, 0x35      ; '/' for right rotate
        je  .right_rotate
        ret
.left:
        sub bx, BLOCK_SIZE
        ret
.right:
        add bx, BLOCK_SIZE
        ret
.left_rotate:
        mov dx, si
        dec dx      ; -1 for left rotation
        and dx, 3   ; limits dx to 0..3
        and si, -4  ; clears low 2 bits for the piece rotation
        or si, dx   ; adds the base in si with rotation in dx
        ret
.right_rotate:
        mov dx, si
        inc dx      ; +1 for right rotation
        and dx, 3
        and si, -4
        or si, dx
        ret

;       deg   0      90     180     270
pieces:
        dw 0x0F00, 0x2222, 0x00F0, 0x4444 ; I
        dw 0x6600, 0x6600, 0x6600, 0x6600 ; O
        dw 0x4E00, 0x4640, 0x0E40, 0x4C40 ; T
        dw 0x6C00, 0x4620, 0x06C0, 0x8C40 ; S
        dw 0xC600, 0x2640, 0x0C60, 0x4C80 ; Z
        dw 0x8E00, 0x6440, 0x0E20, 0x44C0 ; J
        dw 0x2E00, 0x4460, 0x0E80, 0xC440 ; L

; Pads size to 512 bytes and adds the 0x55AA boot signature
        times 510 - ($ - $$) db 0
        dw 0xAA55
