.org 0x0000
	jmp start		; Reset handler
.org 0x0048
	jmp uart_rx_irq		; UART RX transfer complete
.org 0x0050
	jmp uart_tx_irq		; UART TX transfer complete

.include "include/atmega328p.s"
.include "include/macros.s"

.section .data

tx_buffer:
	.space 64

rx_buffer:
	.space 64

tx_buffer_index:
	.space 1

tx_buffer_top:
	.space 1

tx_busy:
	.space 1

rx_buffer_index:
	.space 1

.section .text

;; Interrupt handlers
; UART TX transfer complete handler
uart_tx_irq:
	load_register_Y tx_buffer_index
	load_register_Z tx_buffer

	; Load and Increment current character index
	; Loop at 64 (buffer size)
	ld r16, Y
	inc r16
	andi r16, 0x3F
	st Y, r16

	; Calculate pointer to the character
	clc
	add r30, r16
	ldi r16, 0x00
	adc r31, r16

	; Load current character
	ld r16, Z

	; Stop if current character is \x00
	cpi r16, 0
	breq uart_tx_irq_release

	; Send current character
	sts UDR0, r16
	jmp uart_tx_irq_end

uart_tx_irq_release:
	load_register_Z tx_busy
	ldi r16, 0x00
	st Z, r16
uart_tx_irq_end:
	reti

; UART RX transfer complete handler
uart_rx_irq:
	; Get and store received character
	lds r16, UDR0

	cpi r16, 0x0D
	brne uart_rx_irq_normal_key

	load_register_Z newline
	call console_send_flash

	call console_execute_command

	load_register_Z prompt
	call console_send_flash

	ldi r16, 0x00
	load_register_Z rx_buffer_index
	st Z, r16
	load_register_Z rx_buffer
	st Z, r16

	jmp uart_rx_irq_end

uart_rx_irq_normal_key:
	load_register_Y rx_buffer_index
	load_register_Z rx_buffer

	; Load current character index
	ld r17, Y

	; If current character index bigger than buffer, skip
	cpi r17, 64
	brge uart_rx_irq_end

	; Calculate pointer to the current character
	clc
	add r30, r17
	ldi r17, 0x00
	adc r31, r17

	; Save current
	st Z, r16

	ld r16, Y
	inc r16
	st Y, r16

	; Store \x00 after received character
	ldi r17, 0x00
	std Z+1, r17

	call console_send_sram
uart_rx_irq_end:
	reti

; Reset Interrupt handler
start:
	load_register_16 SPH, SPL, _stack_top

	ldi r16, 103
	sts UBRR0L, r16

	ldi r16, 0xD8
	sts UCSR0B, r16

	ldi r16, 0x06
	sts UCSR0C, r16

	ldi r16, 0x00
	load_register_Z tx_buffer_index
	st Z, r16
	load_register_Z tx_buffer_top
	st Z, r16
	load_register_Z tx_buffer
	st Z, r16
	load_register_Z tx_busy
	st Z, r16
	load_register_Z rx_buffer_index
	st Z, r16
	load_register_Z rx_buffer
	st Z, r16

	load_register_Z reset_message
	call console_send_flash
	load_register_Z prompt
	call console_send_flash

	sei
idle:
	call console_idle
	sleep
	jmp idle

;; Functions

; Send message stored in flash memory
; Parameters:
; 	Z - address of message (should end with byte 0x00)
; Returns: None
; Clobbers: r16, r17, X, Y, Z
console_send_flash:
	; Load top index
	load_register_X tx_buffer_top
	ld r16, X

console_send_flash_loop:

	; Calculate pointer to the top
	load_register_Y tx_buffer
	clc
	add r28, r16
	ldi r17, 0x00
	adc r29, r17

	; Increment buffer top pointer
	inc r16
	andi r16, 0x3F

	; Store message byte on the top of the buffer
	lpm r17, Z+
	st Y, r17

	; If character is not \x00 loop
	cpi r17, 0
	brne console_send_flash_loop

	; Store top index
	dec r16
	andi r16, 0x3F
	st X, r16

	ret

; Send message stored in sram memory
; Parameters:
; 	Z - address of message (should end with byte 0x00)
; Returns: None
; Clobbers: r16, r17, X, Y, Z
console_send_sram:
	; Load top index
	load_register_X tx_buffer_top
	ld r16, X

console_send_sram_loop:

	; Calculate pointer to the top
	load_register_Y tx_buffer
	clc
	add r28, r16
	ldi r17, 0x00
	adc r29, r17

	; Increment buffer top pointer
	inc r16
	andi r16, 0x3F

	; Store message byte on the top of the buffer
	ld r17, Z+
	st Y, r17

	; If character is not \x00 loop
	cpi r17, 0
	brne console_send_sram_loop

	; Store top index
	dec r16
	andi r16, 0x3F
	st X, r16

	ret

; Check if uart is busy, and there is anything in buffer
; if not send first character
; Use on idle only, do not use in interrupt
; Parameters: None
; Returns: None
; Clobbers: r16, r17, Z
console_idle:
	; Disable interrupt
	cli

	; Check if uart UDR is empty
	lds r16, UCSR0A
	sbrs r16, 5
	jmp console_refresh_end

	; Check if uart is busy
	load_register_Z tx_busy
	ld r16, Z
	cpi r16, 0
	brne console_refresh_end

	; Calculate pointer to the index character
	load_register_Z tx_buffer_index
	ld r16, Z
	load_register_Z tx_buffer
	clc
	add r30, r16
	ldi r16, 0x00
	adc r31, r16

	; Load current character
	ld r16, Z

	; Stop if current character is \x00
	cpi r16, 0
	breq console_refresh_end

	; Send character
	sts UDR0, r16

	; Set uart busy
	load_register_Z tx_busy
	ldi r16, 0xFF
	st Z, r16

console_refresh_end:
	sei
	ret

; Compare 2 command one in flash and one in sram
; Parameters:
;	Y - command in sram
;	Z - command in flash
; Returns:
;	r16 - 0xFF if commands are identical
; Clobbers: r17, r18, Y, Z
console_compare:
	ld r17, Y+
	lpm r18, Z+
	cp r17, r18
	brne console_compare_false
	cpi r18, 0x00
	brne console_compare
	ldi r16, 0xFF
	ret
console_compare_false:
	ldi r16, 0x00
	ret

; Check if command is one of known commands
; Parameters: None
; Returns: None
; Clobbers: r16, r17, X, Y, Z
console_execute_command:

	load_register_Y rx_buffer
	load_register_Z help_command
	call console_compare
	cpi r16, 0xFF
	brne 1f
	call console_command_help
	jmp console_execute_command_end
1:
	load_register_Y rx_buffer
	load_register_Z hello_command
	call console_compare
	cpi r16, 0xFF
	brne 1f
	call console_command_hello
	jmp console_execute_command_end

1:
	call console_command_unknown

console_execute_command_end:
	ret

; Console command help
; Parameters: None
; Returns: None
; Clobbers: r16, r17, X, Y, Z
console_command_help:
	load_register_Z help_message
	call console_send_flash
	ret

; Console command hello
; Parameters: None
; Returns: None
; Clobbers: r16, r17, X, Y, Z
console_command_hello:
	load_register_Z hello_message
	call console_send_flash
	ret

; Console unknown command
; Parameters: None
; Returns: None
; Clobbers: r16, r17, X, Y, Z
console_command_unknown:
	load_register_Z unknown_message
	call console_send_flash
	ret

;; Constants

; Reset message on uart
reset_message:
	.asciz "\rWelcome on Arduino Uno R3 board\r\n"

help_command:
	.asciz "help"

help_message:
	.asciz "Known commands: help, hello\r\n"

hello_command:
	.asciz "hello"

hello_message:
	.asciz "Hello, How are you?\r\n"

unknown_message:
	.asciz "Unknown command, please try \"help\"\r\n"

newline:
	.asciz "\r\n"

; Prompt
prompt:
	.asciz "> "
