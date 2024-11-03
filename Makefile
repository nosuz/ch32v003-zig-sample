PKG_NAME=ch32v003_blink
BIN_NAME=firmware.bin

SRC=main.zig
INIT=init.S
LINKER_SCRIPT=ch32v.ld

# -flto removes busy loop
# -fstrip

# -mcpu=baseline_rv32-d subtract D feature from IMACD (baseline_rv32)
# -mcpu=generic_rv32-i+e+c \
# -mcpu=generic+32bit+e+c \
# -m feature makes big binary whic *

all: ${BIN_NAME}

${PKG_NAME}.elf: $(SRC) $(INIT) $(LINKER_SCRIPT)
	../zig/build/stage3/bin/zig build-exe \
		-fstrip \
		-fsingle-threaded \
		-target riscv32-freestanding \
		-mcpu=generic+32bit+e+c \
		-Dopitimze=ReleaseSmall \
		-femit-asm \
		--name ${PKG_NAME}.elf \
		--script $(LINKER_SCRIPT) \
		$(SRC) $(INIT)

${BIN_NAME}: ${PKG_NAME}.elf
	rm ${PKG_NAME}.elf.o && \
	riscv64-unknown-elf-objcopy -O binary ${PKG_NAME}.elf ${BIN_NAME} && \
	riscv64-unknown-elf-objdump --disassemble-all ${PKG_NAME}.elf > ${PKG_NAME}.s

flash: all
	wlink flash --address 0x08000000 ${BIN_NAME}

clean:
	rm -f ${BIN_NAME} *.elf *.s
