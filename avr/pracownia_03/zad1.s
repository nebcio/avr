.org 0x0000
	jmp start			; Reset handler
.org 0x0050
	jmp uart_tx_irq		; UART TX transfer complete

.include "include/atmega328p.s"
.include "include/macros.s"

.section .data
current_character_index:
	.space 1

current_number_of_beers:
    .space 2

tx_buffer:
	.space 64
;
.section .text
;; Interrupt handlers
; UART TX transfer complete handler
uart_tx_irq:
	load_register_Y current_character_index
	load_register_Z tx_buffer

	; Load and Increment current character index
	ld r16, Y					; r16 = *current_character_index
	inc r16						; r16 = r16 + 1
	st Y, r16 					; *current_character_index = r16

	; Calculate pointer to the character
	clc							; Clear carry flag
	add r30, r16				; r30:r31 = r30:r31 + r16
	ldi r16, 0x00				; r16 = 0x00
	adc r31, r16				; r31 = r31 + r16 + carry

	; Load current character
	ld r16, Z					; r16 = *r30:r31

	; Stop if current character is \x00
	tst r16					; if r16 == 0x00
	breq uart_tx_irq_end	; jump to uart_tx_irq_end

	; Send current character
	sts UDR0, r16
	reti

uart_tx_irq_end:
	call send_message
	reti

; Reset Interrupt handler
start:
	load_register_16 SPH, SPL, _stack_top

	ldi r16, 103
	sts UBRR0L, r16	; 9600 baud

	ldi r16, 0x48
	sts UCSR0B, r16 ; Enable TX

	ldi r16, 0x06
	sts UCSR0C, r16 ; 8N1 ??

	load_register_Z current_character_index
	ldi r16, 0x00
	st Z, r16	; *current_character_index = 0x00

    load_register_Z current_number_of_beers
	ldi r16, 0x09	; tens
	st Z+, r16 		
	ldi r16, 0x09	; ones
	st Z, r16

	call send_message
	sei

sleep:
	sleep
	jmp sleep

copy_z_to_y: 						; Copy string from Z to Y
	lpm r16, Z+
	tst r16						
	breq copy_z_to_y_end 			; if r16 == 0x00
	
	cpi r16, 0x40					; if r16 == 0x40 ('@')
	breq insert_number				; jump to insert_number

	cpi r16, 0x23					; if r16 == 0x23 ('#')
	breq decrement_number_of_beers

	st Y+, r16
	jmp copy_z_to_y

insert_number: 						
	load_register_X current_number_of_beers

	ld r16, X+	; tens
	ld r17, X	; ones
	ldi r18, 0x30

	cpi r16, 0x00	; if tens == 0x00
	breq ones

	add r16, r18 
	add r17, r18	

	st Y+, r16	
	st Y+, r17

	jmp copy_z_to_y

ones:
	add r17, r18
	st Y+, r17
	jmp copy_z_to_y

decrement_number_of_beers:
	load_register_X current_number_of_beers
	ld r16, X+						; tens
	ld r17, X						; ones
	cpi r17, 0						; if r17 == 0
	breq decrement_tens

	dec r17
	jmp save_number_of_beers
decrement_tens:
	dec r16
	ldi r17, 0x09
save_number_of_beers:
	st X, r17
	st -X, r16
	jmp copy_z_to_y

copy_z_to_y_end:
	ret
;
send_message:
	load_register_Y tx_buffer

	; Copy message
	load_register_Z pattern
	call copy_z_to_y	

	; Insert 0
	ldi r16, 0x00					; 0x00 = '\x00'
	st Y+, r16						

	; Restart tx_buffer
	load_register_Z current_character_index
	ldi r16, 0x00					; 0x00 = '\x00'
	st Z, r16						; *current_character_index = 0x00

send_message_first:
	load_register_Y tx_buffer
	ld r16, Y	
	sts UDR0, r16	

send_message_end:
	ret

; Message on uart
pattern:
	.asciz "\r\n@ bottles of beer on the wall, @ bottles of beer.\r\nTake one down and pass it around, #@ bottles of beer on the wall.\r\n"