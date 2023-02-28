.include "include/stm32f411ve.s"
.include "include/macro.s"

.global reset
.global tim2

.section .data

counter:
.space 4

.section .text

.thumb_func
reset:
    store32 rcc_ahb1enr, 0x00000008
    store32 rcc_apb1enr, 0x00000001
    store32 gpiod_moder, 0x55000000
    store32 gpioa_moder, 0x00000001     @PA0 - input
    store32 tim2_cr1,    0x00000181
    store32 tim2_dier,   0x00000001
    store32 tim2_psc,    0x0000FFFF
    store32 tim2_arr,    0x0000000F
    store32 tim2_egr,    0x00000001
    store32 counter, 1
    store32 nvic_iser0,  0x10000000
    b .

.thumb_func
tim2:
    readreg r1, gpioa_idr
    movw r2, #0xFFFF
    and r1, r1, r2
    be button_diode

    readreg r1, counter
    add r1, r1, #1          
    movw r2, #0xFFFF    
    storereg counter, r1
    cmp r1, r2
    beq next_diode
    bx lr

next_diode:
    store32 counter, 0      
    readreg r1, gpiod_odr
        
    movw r2, #0x1000     
    cmp r1, r2         
    beq second_diode

    movw r2, #0x2000     
    cmp r1, r2          
    beq third_diode

    movw r2, #0x4000     
    cmp r1, r2        
    beq fourth_diode

    movw r2, #0x1000
    storereg gpiod_odr, r2
    bx lr

second_diode:
    movw r2, #0x2000
    storereg gpiod_odr, r2
    bx lr

third_diode:
    movw r2, #0x4000
    storereg gpiod_odr, r2
    bx lr

fourth_diode:
    movw r2, #0x8000
    storereg gpiod_odr, r2
    bx lr

button_diode:
    movw r2, #0x8000
    storereg gpiod_odr, r2
    bx lr
