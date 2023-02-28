.global empty_handler

.macro	vector name
    .weak \name
    .set \name, empty_handler
    .word \name + 1
.endm

.section .interrupts
interrupt_vectors:
    .word stack_top
    vector reset
    vector nmi
    vector hardfault
    vector memmanage
    vector busfault
    vector usagefault
    .word 0
    .word 0
    .word 0
    .word 0
    vector svc
    vector debugmon
    .word 0
    vector pendsv
    vector systick

    vector wwdg
    vector pvd
    vector tamper_timestamp
    vector rtc_wakeup
    vector flash
    vector rcc
    vector exti0
    vector exti1
    vector exti2
    vector exti3
    vector exti4
    vector dma1_stream0
    vector dma1_stream1
    vector dma1_stream2
    vector dma1_stream3
    vector dma1_stream4
    vector dma1_stream5
    vector dma1_stream6
    vector adc
    .word 0
    .word 0
    .word 0
    .word 0
    vector exti9_5
    vector tim1_brk
    vector tim1_up
    vector tim1_trigger
    vector tim1_capture_compare
    vector tim2
    vector tim3
    vector tim4
    vector i2c1_event
    vector i2c1_error
    vector i2c2_event
    vector i2c2_error
    vector spi1
    vector spi2
    vector uart1
    vector uart2

.align
.thumb_func
empty_handler:
    b .
