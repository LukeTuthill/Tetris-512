ASM    = nasm
QEMU   = qemu-system-i386
SRC    = tetris.asm
BIN    = tetris.bin

.PHONY: all run size clean

all: $(BIN)

$(BIN): $(SRC)
	$(ASM) -f bin $(SRC) -o $(BIN)

run: $(BIN)
	$(QEMU) -drive format=raw,file=$(BIN)

size: $(BIN)
	@wc -c < $(BIN)

clean:
	rm -f $(BIN)
