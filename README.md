# Tetris 512

Tetris 512 is an attempt to fit a playable Tetris game into a single 512-byte x86 boot sector. It is written in 16-bit NASM assembly and boots directly through the BIOS. The 512-byte budget includes the two-byte boot signature, leaving 510 bytes for code, data, and any padding.

## Build and run

Install `make`, `nasm`, and `qemu-system-i386`, then run this from the repository root:

```sh
make run
```

This assembles `tetris.asm` into `tetris.bin` and boots it as a raw disk image in QEMU. With the QEMU window focused, press **A** to move the piece left, **D** to move it right **.** to rotate left, and **/** to rotate right.

| Command | What it does |
| --- | --- |
| `make` | Builds `tetris.bin`. |
| `make run` | Builds the image if needed and boots it in QEMU. |
| `make size` | Prints the image size in bytes. A successful build is padded to 512 bytes. |
| `make clean` | Removes `tetris.bin`. |

## Current status

The prototype switches to 320 × 200 VGA graphics and repeatedly drops all 7 pieces, cycling between them. Moving left and right work, as well as rotations. All seven tetromino shapes are stored as four 16-bit masks, one mask per rotation, with one bit per cell in a 4 × 4 grid. Collision detection, piece stacking, line clearing, and scoring  are still to be implemented.
