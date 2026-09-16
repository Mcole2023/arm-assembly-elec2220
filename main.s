// Four tasks controlled by User Button and TIM4

.syntax unified
.cpu cortex-m4
.thumb

.include "../Src/stm32f411_equates.s"

// Timer: 16MHz / 16000 / 500 = 2Hz (0.5s)
.equ TIM_PSC_VAL,  15999
.equ TIM_ARR_HALF, 499

// LED pin numbers on GPIOD
.equ LED_GREEN,  12
.equ LED_ORANGE, 13
.equ LED_RED,    14
.equ LED_BLUE,   15

// Data section
@ X_SWV and Y_SWV go first so they are at 0x20000000 and 0x20000004
.section .data
.align 2

.global X_SWV
.global Y_SWV
X_SWV:  .word 0
Y_SWV:  .word 0

.global STEP
STEP:   .word 0

LED_NUM:   .word 0
PHASE:     .word 0
DCOUNT:    .word 15
FIDX:      .word 0
MODE:      .word 0

.global A
A:
.word 227,219,208,217,218,213,223,243,224,229
.word 215,230,238,261,336,405,375,383,395,363
.word 382,387,365,319,310,333,268,310,240,217

.global Y
Y: .space 120

.global STRG
STRG: .asciz "ASCII string &*^%$# 12345 of Characters."
.align 2

// Code
.section .text
.align 2

.global main
.type main, %function
main:
    BL   GPIO_Init
    BL   LEDs_Off
    BL   EXTI_Init
    BL   TIM4_Init

    BL   Task0
    BL   Task1
    BL   Task2
    BL   Task3

Here:
    B    Here


@ Task0: wait for button press
Task0:
    PUSH {LR}
T0_loop:
    LDR  R0, =STEP
    LDR  R1, [R0]
    CMP  R1, #0
    BEQ  T0_loop
    POP  {PC}


@ Task1: cycle B-R-O-G LEDs (on then off each), moving average filter
Task1:
    PUSH {LR}

    @ Reset state variables
    MOV  R1, #0
    LDR  R0, =LED_NUM
    STR  R1, [R0]
    LDR  R0, =PHASE
    STR  R1, [R0]
    LDR  R0, =FIDX
    STR  R1, [R0]
    LDR  R0, =X_SWV
    STR  R1, [R0]
    LDR  R0, =Y_SWV
    STR  R1, [R0]

    BL   LEDs_Off

    @ Y[0] = A[0] and Y[29] = A[29]
    @Endpoints
    LDR  R0, =A
    LDR  R1, =Y
    LDR  R2, [R0]
    STR  R2, [R1]
    LDR  R2, [R0, #116]
    STR  R2, [R1, #116]

    @ Set mode and start timer
    MOV  R1, #1
    LDR  R0, =MODE
    STR  R1, [R0]
    BL   TIM4_Start

T1_loop:
    LDR  R0, =STEP
    LDR  R1, [R0]
    CMP  R1, #1
    BEQ  T1_loop

    BL   TIM4_Stop
    MOV  R1, #0
    LDR  R0, =MODE
    STR  R1, [R0]
    BL   LEDs_Off

    POP  {PC}


@ Task2: 4-bit down-counter on LEDs plus sort STRG
Task2:
    PUSH {LR}

    @ Sort the string first
    BL   Sort_String

    @ All LEDs on
    MOV  R1, #15
    LDR  R0, =DCOUNT
    STR  R1, [R0]
    MOV  R0, #15
    BL   Display_Nibble

    MOV  R1, #2
    LDR  R0, =MODE
    STR  R1, [R0]
    BL   TIM4_Start

T2_loop:
    LDR  R0, =STEP
    LDR  R1, [R0]
    CMP  R1, #2
    BEQ  T2_loop

    BL   TIM4_Stop
    MOV  R1, #0
    LDR  R0, =MODE
    STR  R1, [R0]
    BL   LEDs_Off

    POP  {PC}


@ Task3: turn everything off, all LEDs on
Task3:
    PUSH {LR}
    BL   TIM4_Disable
    BL   EXTI0_Disable
    BL   LEDs_On
    POP  {PC}


@ Bubble sort STRG in ascending ASCII order
Sort_String:
    PUSH {R4-R7, LR}

    @ Find length
    LDR  R4, =STRG
    MOV  R5, #0
len_loop:
    LDRB R6, [R4, R5]
    CMP  R6, #0
    BEQ  len_done
    ADD  R5, R5, #1
    B    len_loop
len_done:

    MOV  R6, #0
outer:
    SUB  R0, R5, #1
    CMP  R6, R0
    BGE  sort_done

    MOV  R7, #0
inner:
    SUB  R0, R5, #1
    SUB  R0, R0, R6
    CMP  R7, R0
    BGE  outer_next

    LDRB R1, [R4, R7]
    ADD  R2, R7, #1
    LDRB R3, [R4, R2]
    CMP  R1, R3
    BLS  no_swap
    STRB R3, [R4, R7]
    STRB R1, [R4, R2]
no_swap:
    ADD  R7, R7, #1
    B    inner

outer_next:
    ADD  R6, R6, #1
    B    outer

sort_done:
    POP  {R4-R7, PC}


@ Compute one filter value Y[n]
@ R0 = n
Filter_Step:
    PUSH {R4-R7, LR}

    MOV  R4, R0

    CMP  R4, #0
    BNE  fs_check_last
    @ n=0: publish A[0] to SWV
    LDR  R5, =A
    LDR  R6, [R5]
    LDR  R0, =X_SWV
    STR  R6, [R0]
    LDR  R0, =Y_SWV
    STR  R6, [R0]
    B    fs_done

fs_check_last:
    CMP  R4, #29
    BNE  fs_middle
    @ n=29: publish A[29] to SWV
    LDR  R5, =A
    LDR  R6, [R5, #116]
    LDR  R0, =X_SWV
    STR  R6, [R0]
    LDR  R0, =Y_SWV
    STR  R6, [R0]
    B    fs_done

fs_middle:
    @ Y[n] = (A[n-1] + A[n] + A[n+1]) / 3
    SUB  R0, R4, #1
    LSL  R0, R0, #2
    LDR  R5, =A
    ADD  R5, R5, R0
    LDR  R1, [R5]
    LDR  R2, [R5, #4]
    LDR  R3, [R5, #8]
    ADD  R6, R1, R2
    ADD  R6, R6, R3
    MOV  R7, #3
    UDIV R6, R6, R7

    @ Store Y[n]
    LSL  R0, R4, #2
    LDR  R1, =Y
    STR  R6, [R1, R0]

    @ Publish to SWV
    LDR  R0, =X_SWV
    STR  R2, [R0]
    LDR  R0, =Y_SWV
    STR  R6, [R0]

fs_done:
    POP  {R4-R7, PC}


@ All LEDs off
LEDs_Off:
    PUSH {R0-R1, LR}
    LDR  R0, =GPIOD
    LDR  R1, =0xF0000000
    STR  R1, [R0, #BSRR]
    POP  {R0-R1, PC}


@ All LEDs on
LEDs_On:
    PUSH {R0-R1, LR}
    LDR  R0, =GPIOD
    MOV  R1, #0xF000
    STR  R1, [R0, #BSRR]
    POP  {R0-R1, PC}


@ Turn on or off a single LED
@ R0 = index (0=Blue, 1=Red, 2=Orange, 3=Green)
@ R1 = 1 for on, 0 for off
LED_Set:
    PUSH {R2-R4, LR}
    LDR  R2, =GPIOD

    @ pin = 15 - index
    MOV  R3, #15
    SUB  R3, R3, R0

    CMP  R1, #0
    BEQ  led_off_path

    @ On
    MOV  R4, #1
    LSL  R4, R4, R3
    STR  R4, [R2, #BSRR]
    B    led_set_done

led_off_path:
    @ Off
    ADD  R3, R3, #16
    MOV  R4, #1
    LSL  R4, R4, R3
    STR  R4, [R2, #BSRR]

led_set_done:
    POP  {R2-R4, PC}


@ Display
@ Bit 3 = Blue, Bit 2 = Red, Bit 1 = Orange, Bit 0 = Green
@ R0 = 0-15
Display_Nibble:
    PUSH {R1-R4, LR}
    MOV  R4, R0

    @ Clear all LEDs first
    LDR  R1, =GPIOD
    LDR  R2, =0xF0000000
    STR  R2, [R1, #BSRR]

    @ Build set mask
    MOV  R2, #0
    TST  R4, #0x8
    IT   NE
    ORRNE R2, R2, #(1 << LED_BLUE)
    TST  R4, #0x4
    IT   NE
    ORRNE R2, R2, #(1 << LED_RED)
    TST  R4, #0x2
    IT   NE
    ORRNE R2, R2, #(1 << LED_ORANGE)
    TST  R4, #0x1
    IT   NE
    ORRNE R2, R2, #(1 << LED_GREEN)

    STR  R2, [R1, #BSRR]
    POP  {R1-R4, PC}


@ Enable GPIOA and GPIOD, set PD12-15 as output
GPIO_Init:
    PUSH {R0-R1, LR}
    LDR  R0, =RCC
    LDR  R1, [R0, #AHB1ENR]
    ORR  R1, R1, #0x09
    STR  R1, [R0, #AHB1ENR]

    LDR  R0, =GPIOD
    LDR  R1, [R0, #MODER]
    BIC  R1, R1, #0xFF000000
    ORR  R1, R1, #0x55000000
    STR  R1, [R0, #MODER]
    POP  {R0-R1, PC}


@ PA0 button, falling edge
EXTI_Init:
    PUSH {R0-R1, LR}
    LDR  R0, =RCC
    LDR  R1, [R0, #APB2ENR]
    ORR  R1, R1, #0x4000
    STR  R1, [R0, #APB2ENR]

    LDR  R0, =SYSCFG
    LDR  R1, [R0, #EXTICR1]
    BIC  R1, R1, #0x0F
    STR  R1, [R0, #EXTICR1]

    LDR  R0, =EXTI
    LDR  R1, [R0, #FTSR]
    ORR  R1, R1, #0x01
    STR  R1, [R0, #FTSR]

    LDR  R1, [R0, #IMR]
    ORR  R1, R1, #0x01
    STR  R1, [R0, #IMR]

    LDR  R0, =NVIC_ISER0
    MOV  R1, #(1 << 6)
    STR  R1, [R0]
    POP  {R0-R1, PC}


@ Turn off EXTI0
EXTI0_Disable:
    PUSH {R0-R1, LR}
    LDR  R0, =EXTI
    LDR  R1, [R0, #IMR]
    BIC  R1, R1, #0x01
    STR  R1, [R0, #IMR]

    LDR  R0, =NVIC_ICER0
    MOV  R1, #(1 << 6)
    STR  R1, [R0]
    POP  {R0-R1, PC}


@ TIM4 init
TIM4_Init:
    PUSH {R0-R1, LR}
    LDR  R0, =RCC
    LDR  R1, [R0, #APB1ENR]
    ORR  R1, R1, #0x04
    STR  R1, [R0, #APB1ENR]

    LDR  R0, =TIM4
    MOV  R1, #0
    STR  R1, [R0, #CR1]
    LDR  R1, =TIM_PSC_VAL
    STR  R1, [R0, #PSC]
    LDR  R1, =TIM_ARR_HALF
    STR  R1, [R0, #ARR]

    MOV  R1, #1
    STR  R1, [R0, #EGR]
    MOV  R1, #0
    STR  R1, [R0, #SR]

    MOV  R1, #1
    STR  R1, [R0, #DIER]

    LDR  R0, =NVIC_ISER0
    LDR  R1, =(1 << 30)
    STR  R1, [R0]
    POP  {R0-R1, PC}


@ Start TIM4
TIM4_Start:
    PUSH {R0-R1, LR}
    LDR  R0, =TIM4
    MOV  R1, #0
    STR  R1, [R0, #CNT]
    STR  R1, [R0, #SR]
    MOV  R1, #1
    STR  R1, [R0, #CR1]
    POP  {R0-R1, PC}


@ Stop TIM4
TIM4_Stop:
    PUSH {R0-R1, LR}
    LDR  R0, =TIM4
    MOV  R1, #0
    STR  R1, [R0, #CR1]
    POP  {R0-R1, PC}


@ Fully disable TIM4
TIM4_Disable:
    PUSH {R0-R1, LR}
    LDR  R0, =TIM4
    MOV  R1, #0
    STR  R1, [R0, #CR1]
    STR  R1, [R0, #DIER]

    LDR  R0, =NVIC_ICER0
    LDR  R1, =(1 << 30)
    STR  R1, [R0]
    POP  {R0-R1, PC}


@ EXTI0 handler
@ Increment STEP up to 3
.global EXTI0_IRQHandler
.type EXTI0_IRQHandler, %function
EXTI0_IRQHandler:
    PUSH {R0-R2, LR}

    LDR  R0, =STEP
    LDR  R1, [R0]
    CMP  R1, #3
    BGE  exti0_ack
    ADD  R1, R1, #1
    STR  R1, [R0]

exti0_ack:
    LDR  R0, =EXTI
    MOV  R1, #1
    STR  R1, [R0, #PR]

    LDR  R0, =NVIC_ICPR0
    MOV  R1, #(1 << 6)
    STR  R1, [R0]

    POP  {R0-R2, PC}


@ Branches on MODE
.global TIM4_IRQHandler
.type TIM4_IRQHandler, %function
TIM4_IRQHandler:
    PUSH {R0-R4, LR}

    LDR  R0, =TIM4
    MOV  R1, #0
    STR  R1, [R0, #SR]

    LDR  R0, =MODE
    LDR  R1, [R0]
    CMP  R1, #1
    BEQ  tim_t1
    CMP  R1, #2
    BEQ  tim_t2
    B    tim_exit

tim_t1:
    @  0 = light current LED, 1 = extinguish and advance
    LDR  R0, =PHASE
    LDR  R1, [R0]
    CMP  R1, #0
    BNE  t1_off

    @ Phase 0: turn on LED_NUM
    LDR  R0, =LED_NUM
    LDR  R2, [R0]
    MOV  R0, R2
    MOV  R1, #1
    BL   LED_Set

    LDR  R0, =PHASE
    MOV  R1, #1
    STR  R1, [R0]
    B    t1_filter

t1_off:
    @ Phase 1: turn off LED_NUM and advance
    LDR  R0, =LED_NUM
    LDR  R2, [R0]
    MOV  R0, R2
    MOV  R1, #0
    BL   LED_Set

    LDR  R0, =LED_NUM
    LDR  R2, [R0]
    ADD  R2, R2, #1
    CMP  R2, #4
    BLT  t1_num_ok
    MOV  R2, #0
t1_num_ok:
    STR  R2, [R0]

    LDR  R0, =PHASE
    MOV  R1, #0
    STR  R1, [R0]

t1_filter:
    @ One filter step per tick ->done
    LDR  R0, =FIDX
    LDR  R1, [R0]
    CMP  R1, #30
    BGE  tim_exit
    MOV  R0, R1
    BL   Filter_Step
    LDR  R0, =FIDX
    LDR  R1, [R0]
    ADD  R1, R1, #1
    STR  R1, [R0]
    B    tim_exit

tim_t2:
    @ Down-counter
    LDR  R0, =DCOUNT
    LDR  R1, [R0]
    SUB  R1, R1, #1
    CMP  R1, #0
    BGE  t2_cnt_ok
    MOV  R1, #15
t2_cnt_ok:
    STR  R1, [R0]
    MOV  R0, R1
    BL   Display_Nibble

tim_exit:
    POP  {R0-R4, PC}

.end
