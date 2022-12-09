.org 0x0000
	jmp start								;Reset handler
.org 0x0040
	jmp timer0_ovf_irq 						;Timer0 Overflow Handler

.include "include/atmega328p.s"
.include "include/macros.s"

.set timer_cycles_per_second, 12500			;set ustawia wartosc

.section .text

; Interrupt handler
timer0_ovf_irq:
	sbiw Z, 1								;Z(rejestry R31:R30) - 1 
	brne timer0_ovf_irq_exit				;if Z(flaga)=0 to idziemy dalej
	load_register_Z timer_cycles_per_second
	
	sts PORTB, r23	
	com r23									;negacja ze wzg na przesuniecie
	lsr r23									;przesuniecie bitowe
	com r23									
	cpi r23, 0xFE							;porownanie
	breq reload								;powrot do 1 diody																	;

timer0_ovf_irq_exit:
	reti									;interrupt return stack->PC

reload:
	ldi r23, 0x3F
	reti

; Interrupt handler
start:
	load_register_16 SPH, SPL, _stack_top	;inicjacja wskaznika stosu

	load_register_8 DDRB, 0x3C				;ustawiamy rejestr DDRB (by pin od diody dostawal sygnal) 1-output, na start wszystko to input (0)
	ldi r23, 0x9F
	sts PORTB, r23							;r23 przechowuje stan diody

	load_register_8 TCCR0B, 0x01			;wybor zegara (bity 2:0) jako clk (bez preskalera)
	load_register_8 TIMSK0, 0x01 			;enable: przerwanie przy overflow timer/counter0
	load_register_8 TCNT0, 0x00				;rejestr timera ustawia na zera / tcnt0 daje dostep do etycji i odczytywania wartosci timera

	load_register_Z timer_cycles_per_second

	sei
sleep:
	sleep
	jmp sleep
