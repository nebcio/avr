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
    store32 button_state, 0
    store32 led_state, 0x8000
    store32 nvic_iser0,  0x10000000
    b .

.thumb_func
tim2:
    readreg r1, counter
    add r1, r1, #1          
    movw r2, #0xFFFF    
    storereg counter, r1
    cmp r1, r2
    beq tim2_go
    bx lr

tim2_go:
    store32 counter, 0 

    readreg r1, gpioa_idr
    movw r3, 1   
    and r1, r1, r3
    readreg r2, button_state

    cmp r1, r2
    bne button_changed_state
    b button_changed_state_end
button_changed_state:
    storereg button_state, r1
    movw r3, 1   
    cmp r1, r3
    bne button_changed_state_end

    readreg r1, program
    add r1, r1, #1
    movw r3, 3
    cmp r1, r3
    bne button_changed_state_store
    movw r1, 0
button_changed_state_store:
    storereg program, r1

program_1:
    movw r2, 0
    cmp r1, r2
    bne program_2

    store32 led_state, 0x8000
    b button_changed_state_end

program_2:
    movw r2, 1
    cmp r1, r2
    bne program_3

    store32 led_state, 0x9000
    b button_changed_state_end

program_3:
    movw r2, 2
    cmp r1, r2
    bne program_3

    store32 led_state, 0xB000

button_changed_state_end:
    readreg r1, led_state

    lsl r1, r1, #1

    mov r2, r1
    movw r3, 0x8000
    lsl r3, r3, #1
    and r3, r3, r2
    beq sequence_no_bit_left
    movw r3, 0x1000
    orr r1, r1, r3
sequence_no_bit_left:
    storereg gpiod_odr, r1
    storereg led_state, r1

    bx lr
