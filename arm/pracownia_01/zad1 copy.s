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
    readreg r1, counter
    add r1, r1, #1          ; r1 = r1 counter + 1
    movw r2, #0xFFFF    
    storereg counter, r1
    cmp r1, r2
    beq next_diode
    bx lr

next_diode:
    store32 counter, 0      ; counter = 0
    readreg r1, gpiod_odr   ; state of diodes

    cmp r1, #0x1000         ; if diode 1 is on
    beq second_diode

    cmp r1, #0x2000         ; if diode 2 is on
    beq third_diode

    cmp r1, #0x4000         ; if diode 3 is on
    beq fourth_diode

    movw r2, #0x1000        ; if diode 4 is on
    eor r1, r1, r2
    storereg gpiod_odr, r1
    bx lr

second_diode:
    movw r2, #0x2000
    eor r1, r1, r2
    storereg gpiod_odr, r1
    bx lr

third_diode:
    movw r2, #0x4000
    eor r1, r1, r2
    storereg gpiod_odr, r1
    bx lr

fourth_diode:
    movw r2, #0x8000
    eor r1, r1, r2
    storereg gpiod_odr, r1
    bx lr