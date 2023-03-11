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

.section .text

.thumb_func
reset:
    @store32 gpiod_odr,   0x80000000
    store32 rcc_ahb1enr, 0x00000009
    store32 rcc_apb1enr, 0x00000001
    store32 gpiod_moder, 0x55000000
    store32 tim2_cr1,    0x00000181
    store32 tim2_dier,   0x00000001
    store32 tim2_psc,    0x0000FFFF
    store32 tim2_arr,    0x0000000F
    store32 tim2_egr,    0x00000001
    store32 counter, 1
    store32 program, 0
    store32 nvic_iser0,  0x10000000
    b .

.thumb_func
tim2:
    readreg r1, counter
    add r1, r1, #1          
    movw r2, #0xFFFF    
    storereg counter, r1
    cmp r1, r2
    beq sequence

    bx lr

button_off:
    storereg button_state, r2
    bx lr

sequence:
    store32 counter, 0 

    readreg r1, gpioa_idr

    movw r2, #0             @ read and save button state off
    cmp r1, r2
    beq button_off

    movw r2, #1             @ read and handle button state on    
    and r1, r1, r2
    bne button_diode

    readreg r1, program
    @ if program 0
    movw r2, #0    
    cmp r1, r2
    beq seq_one

    @ if program 1
    movw r2, #1 
    cmp r1, r2
    beq seq_sec

button_diode:
    store32 counter, 0 

    readreg r4, button_state
    readreg r3, gpioa_idr       @ state 1 
    movw r2, #0xFFFF            @ for delay
    eor r4, r4, r3              @ r4 = r4 ^ r3
    beq delay                   @ if r4 == r3 then delay
    storereg button_state, r3   @ else save button state

    readreg r1, program
    add r1, r1, #1              @ increment program
    movw r2, #2                 @ max program   
    cmp r1, r2                  @ if program > 3 then reset program
    beq reset_program 

    storereg program, r1        @ else save program

    @ if program 0
    movw r2, #0x8000    
    storereg gpiod_odr, r2

    @ if program 1
    movw r2, #0xC000
    storereg gpiod_odr, r2

    movw r2, 0xFFFF
    cmp r2, r2
    beq delay

delay:
    sub r2, r2, #1
    cmp r2, #0
    bne delay

    bx lr

reset_program:
    store32 program, 0
    bx lr

seq_one:
    readreg r1, gpiod_odr    

    movw r2, #0x0000  
    cmp r1, r2
    beq reset_state_one

    movw r2, #0x1000  
    cmp r1, r2
    beq reset_state_one

    lsr r1, r1, #1
    storereg gpiod_odr, r1
    bx lr

reset_state_one: 
    movw r2, #0x8000
    storereg gpiod_odr, r2
    bx lr

seq_sec:
    readreg r1, gpiod_odr    

    lsr r1, r1, #1
    movw r2, #0x1800    @ 0001 1000 0000 0000
    cmp r1, r2
    beq conversion_one   

    movw r2, #0x4800    @ 0100 1000 0000 0000       
    cmp r1, r2
    beq conversion_two

    storereg gpiod_odr, r1
    bx lr

conversion_one:
    movw r2, #0x9000    @ 1001 0000 0000 0000
    storereg gpiod_odr, r2
    bx lr

conversion_two:
    movw r2, #0xC000    @ 1100 0000 0000 0000
    storereg gpiod_odr, r2
    bx lr
