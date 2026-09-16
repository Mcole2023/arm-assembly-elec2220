// Red LED    (PD14): blink every 1/4 sec
// Orange LED (PD13): blink every 1 sec
// Green LED  (PD12): blink every 2 sec
// Blue LED   (PD15): blink every ~1 sec
//
// TIM4 interrupts every 1/4 second. Red toggles every IRQ,
// Orange every 4th IRQ, Green every 8th IRQ.
//
// Clock:1 6 MHz .
// For 1/4 sec: PSC=1599, ARR=2499 -> 16MHz/1600/2500 = 4 Hz.


//OrangeLED period: 2.000 secs
//Measured edges- 1.8885s and 3.8885 s
//BlueLED period: 1.8532
//Measured edges- 10.6190s and 12.4722 s
//The orange LED is driven by the TIM4 hardware timer
//and interrupts every ¼ second.
//This gives us an exact 2.000 second full cycle.
//The blue LED is driven by the software_delay called with R0=1000.
//This measured to 1.8532s per cycle, which is about 147 ms shorter than the hardware timer.
//That has about a 7.3% error, showing that software delay loops drift because the iteration
//count is calibrated by inspection and does not account for the timing of the CPU.
//Hardware timers run off a divided clock and produce precise intervals.


.syntax unified
.cpu cortex-m4
.thumb

.include "../Src/stm32f411_equates.s"

// Data Section
.section .data
.align 2
.global RedLED
.global OrangeLED
.global GreenLED
.global BlueLED

RedLED:         .byte 0
OrangeLED:      .byte 0
GreenLED:       .byte 0
BlueLED:        .byte 0
interrupt_count:.byte 0

// Code Section
.section .text
.align 2

.global main
.type main, %function

// main: initialize peripherals.Red/Orange/Green are driven by the TIM4 interrupt handler.
main:
    PUSH    {LR}
    BL      GPIO_Init               // Configure PD12-15 as outputs
    BL      TIM4_Init               // Configure TIM4 for 1/4 sec IRQ

main_loop:
    CPSIE   i

    // Toggle BlueLED
    LDR     R0, =BlueLED
    LDRB    R1, [R0]
    EORS    R1, #1
    STRB    R1, [R0]


    MOV     R0, #BLUE
    CMP     R1, #0
    BEQ     blue_off
    BL      LED_On
    B       blue_done
blue_off:
    BL      LED_Off
blue_done:

    // Software delay
    LDR     R0, =1000
    BL      software_delay
    B       main_loop
    POP     {PC}

//Enable GPIOD clock, set PD12-15 as outputs, turn all four LEDs off.
.type GPIO_Init, %function
GPIO_Init:
    PUSH    {LR}


    LDR     R0, =RCC
    LDR     R1, [R0, #AHB1ENR]
    ORR     R1, R1, #GPIODEN
    STR     R1, [R0, #AHB1ENR]

    LDR     R0, =GPIOD
    LDR     R1, [R0, #MODER]
    LDR     R2, =0xFF000000
    BIC     R1, R1, R2
    LDR     R2, =0x55000000
    ORR     R1, R1, R2
    STR     R1, [R0, #MODER]

    LDR     R1, =0xF0000000
    STR     R1, [R0, #BSRR]

    POP     {PC}

// Configure Timer 4 to interrupt every 1/4 sec
// APB1 timer clock = 16 MHz
// PSC=1599 = 10 kHz
// ARR=2499 = 0.25 sec
.type TIM4_Init, %function
TIM4_Init:
    PUSH    {LR}

    LDR     R0, =RCC
    LDR     R1, [R0, #APB1ENR]
    ORR     R1, R1, #TIM4EN
    STR     R1, [R0, #APB1ENR]

    // Disable timer
    LDR     R0, =TIM4
    MOV     R1, #0
    STR     R1, [R0, #CR1]

    // 10 kHz timer tick
    LDR     R1, =1599
    STR     R1, [R0, #PSC]

    // 0.25 sec period
    LDR     R1, =2499
    STR     R1, [R0, #ARR]

    MOV     R1, #1
    STR     R1, [R0, #EGR]

    LDR     R1, [R0, #SR]
    BIC     R1, R1, #1
    STR     R1, [R0, #SR]

    // update interrupt
    MOV     R1, #1
    STR     R1, [R0, #DIER]

    // ISER0 bit 30
    LDR     R0, =NVIC_ISER0
    MOV     R1, #1
    LSL     R1, R1, #TIM4_BIT
    STR     R1, [R0]

    // Start the timer
    LDR     R0, =TIM4
    MOV     R1, #1
    STR     R1, [R0, #CR1]

    POP     {PC}

// TIM4_IRQHandler- fires every 1/4 second.
//   Red LED    =  toggle every IRQ
//   Orange LED =  toggle every 4th IRQ
//   Green LED  =  toggle every 8th IRQ
.global TIM4_IRQHandler
.type TIM4_IRQHandler, %function
TIM4_IRQHandler:
    PUSH    {R4, LR}

    LDR     R0, =TIM4
    LDR     R1, [R0, #SR]
    BIC     R1, R1, #1
    STR     R1, [R0, #SR]

    // interrupt counter
    LDR     R0, =interrupt_count
    LDRB    R1, [R0]
    ADD     R1, R1, #1
    STRB    R1, [R0]
    MOV     R4, R1                  // Save count in R4
    // Red LED
     LDR     R0, =RedLED
    LDRB    R1, [R0]
    EORS    R1, #1
    STRB    R1, [R0]

    MOV     R0, #RED
    CMP     R1, #0
    BEQ     red_off
    BL      LED_On
    B       red_done
red_off:
    BL      LED_Off
red_done:

    // Orange LED
    AND     R1, R4, #3
    CMP     R1, #0
    BNE     orange_done

    LDR     R0, =OrangeLED
    LDRB    R1, [R0]
    EORS    R1, #1
    STRB    R1, [R0]

    MOV     R0, #ORANGE
    CMP     R1, #0
    BEQ     orange_off
    BL      LED_On
    B       orange_done
orange_off:
    BL      LED_Off
orange_done:

    // Green LED
    AND     R1, R4, #7
    CMP     R1, #0
    BNE     green_done

    LDR     R0, =GreenLED
    LDRB    R1, [R0]
    EORS    R1, #1
    STRB    R1, [R0]

    MOV     R0, #GREEN
    CMP     R1, #0
    BEQ     green_off
    BL      LED_On
    B       green_done
green_off:
    BL      LED_Off
green_done:

    // Wrap counter at 8
    CMP     R4, #8
    BLT     isr_done
    LDR     R0, =interrupt_count
    MOV     R1, #0
    STRB    R1, [R0]
isr_done:

    POP     {R4, PC}

// LED_On:  turn on LED
// LED_Off: turn off LED
// LED index =  PD pin number is +12
// Bits 0-15 set pins, bits 16-31 reset pins.
.type LED_On, %function
LED_On:
    PUSH    {R1, R2, LR}
    ADD     R0, R0, #12             // convert index to PD pin number
    MOV     R1, #1
    LSL     R1, R1, R0
    LDR     R2, =GPIOD
    STR     R1, [R2, #BSRR]
    POP     {R1, R2, PC}

.type LED_Off, %function
LED_Off:
    PUSH    {R1, R2, LR}
    ADD     R0, R0, #12             // PD pin number
    ADD     R0, R0, #16
    MOV     R1, #1
    LSL     R1, R1, R0
    LDR     R2, =GPIOD
    STR     R1, [R2, #BSRR]
    POP     {R1, R2, PC}

// software_delay
// R0 = number of delay
// Calibrated for 16 MHz core.
.type software_delay, %function
software_delay:
    PUSH    {R4, R5, LR}
    MOV     R4, R0
    LDR     R5, =4940               // inner loop count per ms
delay_outer:
    CMP     R4, #0
    BEQ     delay_done
    MOV     R0, R5
delay_inner:
    SUBS    R0, #1
    BNE     delay_inner
    SUBS    R4, #1
    B       delay_outer
delay_done:
    POP     {R4, R5, PC}

.size main, .-main
.end
