MEMORY {
    flash (rx) : ORIGIN = 0x08000000, LENGTH = 512K
    ram  (rwx) : ORIGIN = 0x20000000, LENGTH = 128K
}

stack_size = 2048;

SECTIONS {
    .text : {
        *(.interrupts)
        *(.text)
        *(.text.*)
    } > flash

    .data : {
        *(.data)
        *(.data.*)
        stack_end = .;
        . = . + stack_size;
        stack_top = .;
    } > ram AT > flash
}
