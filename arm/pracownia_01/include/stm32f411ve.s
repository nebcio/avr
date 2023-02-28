.set sdram_base,      0x20000000
.set peripheral_base, 0x40000000
.set internal_base,   0xE0000000

.set apb1_base, peripheral_base  +  0x00000
.set apb2_base, peripheral_base  +  0x10000
.set ahb1_base, peripheral_base  +  0x20000
.set nvic_base, internal_base    +   0xE000

.set tim2_base,       apb1_base  +   0x0000
.set tim3_base,       apb1_base  +   0x0400
.set tim4_base,       apb1_base  +   0x0800
.set tim5_base,       apb1_base  +   0x0c00
.set uart2_base,      apb1_base  +   0x4400

.set uart1_base,      apb2_base  +   0x1000

.set gpioa_base,      ahb1_base  +   0x0000
.set gpiob_base,      ahb1_base  +   0x0400
.set gpioc_base,      ahb1_base  +   0x0800
.set gpiod_base,      ahb1_base  +   0x0c00
.set gpioe_base,      ahb1_base  +   0x1000
.set rcc_base,        ahb1_base  +   0x3800

.set tim2_cr1,        tim2_base  +     0x00
.set tim2_cr2,        tim2_base  +     0x04
.set tim2_smcr,       tim2_base  +     0x08
.set tim2_dier,       tim2_base  +     0x0c
.set tim2_sr,         tim2_base  +     0x10
.set tim2_egr,        tim2_base  +     0x14
.set tim2_ccmr1,      tim2_base  +     0x18
.set tim2_ccmr2,      tim2_base  +     0x1c
.set tim2_ccer,       tim2_base  +     0x20
.set tim2_cnt,        tim2_base  +     0x24
.set tim2_psc,        tim2_base  +     0x28
.set tim2_arr,        tim2_base  +     0x2c
.set tim2_ccr1,       tim2_base  +     0x34
.set tim2_ccr2,       tim2_base  +     0x38
.set tim2_ccr3,       tim2_base  +     0x3c
.set tim2_ccr4,       tim2_base  +     0x40
.set tim2_dcr,        tim2_base  +     0x48
.set tim2_dmar,       tim2_base  +     0x4c
.set tim2_or,         tim2_base  +     0x50

.set uart2_sr,        uart2_base +     0x00
.set uart2_dr,        uart2_base +     0x04
.set uart2_brr,       uart2_base +     0x08
.set uart2_cr1,       uart2_base +     0x0c
.set uart2_cr2,       uart2_base +     0x10
.set uart2_cr3,       uart2_base +     0x14
.set uart2_gtpr,      uart2_base +     0x18

.set uart1_sr,        uart1_base +     0x00
.set uart1_dr,        uart1_base +     0x04
.set uart1_brr,       uart1_base +     0x08
.set uart1_cr1,       uart1_base +     0x0c
.set uart1_cr2,       uart1_base +     0x10
.set uart1_cr3,       uart1_base +     0x14
.set uart1_gtpr,      uart1_base +     0x18

.set gpioa_moder,     gpioa_base +     0x00
.set gpioa_otyper,    gpioa_base +     0x04
.set gpioa_ospeedr,   gpioa_base +     0x08
.set gpioa_pupdr,     gpioa_base +     0x0c
.set gpioa_idr,       gpioa_base +     0x10
.set gpioa_odr,       gpioa_base +     0x14
.set gpioa_bsrr,      gpioa_base +     0x18
.set gpioa_lckr,      gpioa_base +     0x1c
.set gpioa_afrl,      gpioa_base +     0x20
.set gpioa_afrh,      gpioa_base +     0x24

.set gpiob_moder,     gpiob_base +     0x00
.set gpiob_otyper,    gpiob_base +     0x04
.set gpiob_ospeedr,   gpiob_base +     0x08
.set gpiob_pupdr,     gpiob_base +     0x0c
.set gpiob_idr,       gpiob_base +     0x10
.set gpiob_odr,       gpiob_base +     0x14
.set gpiob_bsrr,      gpiob_base +     0x18
.set gpiob_lckr,      gpiob_base +     0x1c
.set gpiob_afrl,      gpiob_base +     0x20
.set gpiob_afrh,      gpiob_base +     0x24

.set gpioc_moder,     gpioc_base +     0x00
.set gpioc_otyper,    gpioc_base +     0x04
.set gpioc_ospeedr,   gpioc_base +     0x08
.set gpioc_pupdr,     gpioc_base +     0x0c
.set gpioc_idr,       gpioc_base +     0x10
.set gpioc_odr,       gpioc_base +     0x14
.set gpioc_bsrr,      gpioc_base +     0x18
.set gpioc_lckr,      gpioc_base +     0x1c
.set gpioc_afrl,      gpioc_base +     0x20
.set gpioc_afrh,      gpioc_base +     0x24

.set gpiod_moder,     gpiod_base +     0x00
.set gpiod_otyper,    gpiod_base +     0x04
.set gpiod_ospeedr,   gpiod_base +     0x08
.set gpiod_pupdr,     gpiod_base +     0x0c
.set gpiod_idr,       gpiod_base +     0x10
.set gpiod_odr,       gpiod_base +     0x14
.set gpiod_bsrr,      gpiod_base +     0x18
.set gpiod_lckr,      gpiod_base +     0x1c
.set gpiod_afrl,      gpiod_base +     0x20
.set gpiod_afrh,      gpiod_base +     0x24

.set gpioe_moder,     gpioe_base +     0x00
.set gpioe_otyper,    gpioe_base +     0x04
.set gpioe_ospeedr,   gpioe_base +     0x08
.set gpioe_pupdr,     gpioe_base +     0x0c
.set gpioe_idr,       gpioe_base +     0x10
.set gpioe_odr,       gpioe_base +     0x14
.set gpioe_bsrr,      gpioe_base +     0x18
.set gpioe_lckr,      gpioe_base +     0x1c
.set gpioe_afrl,      gpioe_base +     0x20
.set gpioe_afrh,      gpioe_base +     0x24

.set rcc_cr,          rcc_base   +     0x00
.set rcc_pllcfgr,     rcc_base   +     0x04
.set rcc_cfgr,        rcc_base   +     0x08
.set rcc_ahb1enr,     rcc_base   +     0x30
.set rcc_ahb2enr,     rcc_base   +     0x34
.set rcc_apb1enr,     rcc_base   +     0x40
.set rcc_apb2enr,     rcc_base   +     0x44

.set nvic_iser0,      nvic_base  +    0x100
.set nvic_iser1,      nvic_base  +    0x104
.set nvic_icpr0,      nvic_base  +    0x280
.set nvic_icpr1,      nvic_base  +    0x284
