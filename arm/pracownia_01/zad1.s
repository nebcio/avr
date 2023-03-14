.include "include/stm32f411ve.s"
.include "include/macro.s"

.global reset
.global tim2

.section .data

counter:
.space 4

program:
.space 4

button_state:
.space 4

led_state:
.space 4

.section .text

.thumb_func
reset:
    store32 rcc_ahb1enr, 0x00000009
    store32 rcc_apb1enr, 0x00000001
    store32 gpiod_moder, 0x55000000
    store32 tim2_cr1,    0x00000181
    store32 tim2_dier,   0x00000001
    store32 tim2_psc,    0x0000FFFF
    store32 tim2_arr,    0x0000000F
    store32 tim2_egr,    0x00000001
    store32 counter,        1
    store32 program,        0
    store32 button_state,   0
    store32 led_state,      0x8000
    store32 nvic_iser0,  0x10000000
    b .

.thumb_func
tim2:
    readreg r3, counter
    add r3, r3, #1          
    movw r4, #0xFFFF 
    add r4, r4, r4   
    storereg counter, r3
    cmp r3, r4
    beq after_cycle

    bx lr

after_cycle:
    store32 counter, 0 

    readreg r3, gpioa_idr
    movw r4, #1   
    and r3, r3, r4          @ r3 = 1 | 0

    readreg r4, button_state             
    cmp r3, r4
    bne button_changed_state

    b seq_shift_bits

    bx lr

button_changed_state:
    storereg button_state, r3   @ save new state
    store32 counter, 0 

    movw r4, #0
    cmp r3, r4
    beq seq_shift_bits      @ button state 1->0 : shift bits

    readreg r3, program
    add r3, r3, #1              @ increment program
    movw r4, #3                 @ max program   
    cmp r3, r4                  @ if program = 3 then reset program
    beq reset_program 
    storereg program, r3        @ else save program

init_program_0:
    movw r4, #0
    cmp r3, r4
    bne init_program_1

    store32 led_state, 0x8000  
    b seq_shift_bits

init_program_1:
    movw r4, #1
    cmp r3, r4
    bne init_program_2

    store32 led_state, 0xC000   @ 1100
    b seq_shift_bits

init_program_2:
    movw r4, #2
    cmp r3, r4
    bne reset_program
    store32 led_state, 0xE000   @ 1110
    b seq_shift_bits

reset_program:
    store32 program, 0
    store32 led_state, 0x8000  
    b seq_shift_bits

seq_shift_bits:
    readreg r3, led_state
    lsr r3, r3, #1
    movw r4, #0x0800  
    and r4, r3, r4
    bne move_bit_to_begin

    b save_moved

move_bit_to_begin: 
    movw r4, #0x8000
    add r3, r3, r4
    movw r4, #0x0800 
    and r4, r3, r4
    beq save_moved
remove_shifted_bit:
    sub r3, r3, r4
save_moved:
    storereg gpiod_odr, r3
    storereg led_state, r3
    bx lr
