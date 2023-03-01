.include "include/stm32f411ve.s"
.include "include/macro.s"

.global reset
.global tim2

.section .data

counter:
.space 4

program:
.space 1

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
    store32 counter, 1
    store32 nvic_iser0,  0x10000000
    store32 gpiod_odr,   0x80000000
    b .

.thumb_func
tim2:
    readreg r1, counter
    add r1, r1, #1          
    movw r2, #0xFFFF    
    storereg counter, r1
    cmp r1, r2
    beq next_diode

    readreg r1, gpioa_idr
    movw r2, #1            
    and r1, r1, r2
    bne button_diode

    bx lr

next_diode:
    store32 counter, 0      
    readreg r1, gpiod_odr

    movw r2, #0x0000  
    cmp r1, r2
    beq reset_state_diodes

    movw r2, #0x1000  
    cmp r1, r2
    beq reset_state_diodes

    lsr r1, r1, #1
    storereg gpiod_odr, r1
    bx lr

reset_state_diodes:
    movw r2, #0x8000
    storereg gpiod_odr, r2
    bx lr

button_diode:
    store32 counter, 0 

    readreg r1, program
    add r1, r1, #1  
    cmp r1, r2
    @beq next_program   
    store32 program, 1 

    movw r2, #0xc000
    storereg gpiod_odr, r2
    bx lr
