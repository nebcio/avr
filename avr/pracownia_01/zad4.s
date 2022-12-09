.org 0x0000
	jmp start			;Reset handler
.org 0x0016
	jmp pcint1_irq		;Pin Change Interrupt 1
.org 0x0040
	jmp timer0_ovf_irq 	;Timer0 Overflow Handler

.include "include/atmega328p.s"
.include "include/macros.s"

.set timer_cycles_zad1, 15625			
.set timer_cycles_zad2, 12500			
.set timer_cycles_zad3, 6250			

.section .data
current_timer_dead_cycles:
	.space 2

.section .text

load_current_timer_dead_cycles_to_Z:
	load_register_X current_timer_dead_cycles
	ld r30, X+
	ld r31, X
	ret

pcint1_irq:
	load_register_X current_timer_dead_cycles
	lds r17, PINC

pcint1_irq_zad1:
	sbrc r17, 1
	rjmp pcint1_irq_zad2
	ldi r19, 0x01
	ldi r23, 0xDF
	load_register_8 TCCR0B, 0x02
	ldi r16, lo8(timer_cycles_zad1)
	st X+, r16
	ldi r16, hi8(timer_cycles_zad1)
	st X, r16																																	;
	;sts PORTB, r23
	rjmp pcint1_irq_exit

pcint1_irq_zad2:
	sbrc r17, 2
	rjmp pcint1_irq_zad3

	ldi r19, 0x02
	ldi r23, 0x9F																									;
	sts PORTB, r23

	load_register_8 TCCR0B, 0x01
	ldi r16, lo8(timer_cycles_zad2)
	st X+, r16
	ldi r16, hi8(timer_cycles_zad2)
	st X, r16	
	rjmp pcint1_irq_exit

pcint1_irq_zad3:
	sbrc r17, 3
	rjmp pcint1_irq_exit
	ldi r19, 0x03
	ldi r23, 0xFF													
	;sts PORTB, r23
	load_register_8 TCCR0B, 0x01
	ldi r16, lo8(timer_cycles_zad3)
	st X+, r16
	ldi r16, hi8(timer_cycles_zad3)
	st X, r16	

pcint1_irq_exit:
	reti

timer0_ovf_irq:
	sbiw Z, 1
	brne timer0_ovf_irq_exit
	call load_current_timer_dead_cycles_to_Z

	cpi r19, 0x01
	breq zad1
	cpi r19, 0x02
	breq zad2
	cpi r19, 0x03
	breq zad3

timer0_ovf_irq_exit:
	reti									;interrupt return stack->PC

zad1:
	cpi r23, 0xFD							
	breq reload																								;
	sts PORTB, r23
	com r23							
	lsr r23							
	com r23									
	reti

reload:
	ldi r23, 0xDF

zad2:	
	sts PORTB, r23	
	com r23									
	lsr r23									
	com r23									
	cpi r23, 0xFE							
	breq reload2																									;
	reti																							

reload2:
	ldi r23, 0x3F

zad3:
	dec r23
	lsl r23
	lsl r23														
	sts PORTB, r23	
	lsr r23
	lsr r23	
	reti												

start:
	load_register_16 SPH, SPL, _stack_top	

	load_register_8 DDRB, 0x3C				
	ldi r23, 0xFF
	sts PORTB, r23							

	load_register_8 TCCR0B, 0x01			
	load_register_8 TIMSK0, 0x01 			
	load_register_8 TCNT0, 0x00				

	load_register_8 PCICR, 0x02
	load_register_8 PCMSK1, 0x0E

	load_register_X current_timer_dead_cycles
	ldi r16, lo8(timer_cycles_zad3)
	st X+, r16
	ldi r16, hi8(timer_cycles_zad3)
	st X, r16

	call load_current_timer_dead_cycles_to_Z

	sei
sleep:
	sleep
	jmp sleep
