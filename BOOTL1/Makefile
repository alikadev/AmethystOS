SRC := BOOTL1.ASM
OUT ?= BOOTL1.BIN

$(OUT): always
	nasm $(SRC) -o $(OUT)

always: 
	rm -f $(OUT)
