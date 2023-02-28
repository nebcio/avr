.PRECIOUS: binary/%.o binary/library/%.o binary/%.bin
.DEFAULT_GOAL := flash

LIBRARY_SRC = $(wildcard library/*.s)
LIBRARY_OBJ = $(patsubst library/%.s, binary/library/%.o, $(LIBRARY_SRC))

binary/%.o: %.s $(wildcard include/*.s)
	@mkdir -p binary
	arm-none-eabi-as -g -mcpu=cortex-m4 -march=armv7-m -mthumb $< -o $@

binary/library/%.o: library/%.s
	@mkdir -p binary/library
	arm-none-eabi-as -g -mcpu=cortex-m4 -march=armv7-m -mthumb $< -o $@

binary/%.bin: binary/%.o $(LIBRARY_OBJ)
	arm-none-eabi-ld -T script.ld $^ -o $@

clean:
	rm -rf binary

flash:
	openocd
