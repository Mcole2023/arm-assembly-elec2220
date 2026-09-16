.syntax unified
// Register addresses
.equ RCC_BASE,      0x40023800
.equ RCC_AHB1ENR,   0x40023830   // RCC AHB1 clock enable
.equ GPIOA_BASE,    0x40020000
.equ GPIOA_MODER,   0x40020000   // GPIOA mode register
.equ GPIOA_IDR,     0x40020010   // GPIOA input data register
.equ GPIOD_BASE,    0x40020C00
.equ GPIOD_MODER,   0x40020C00   // GPIOD mode register
.equ GPIOD_ODR,     0x40020C14   // GPIOD output data register
.equ GPIOD_BSRR,    0x40020C18   // GPIOD bit set/reset register
.text
.global main
.type main, %function
main:
// 7a. Enable clocks for GPIOA and GPIOD
LDR R0, =RCC_AHB1ENR
LDR R1, [R0]
ORR R1, R1, #0x09      // set bits 0 and 3 (GPIOA and GPIOD)
STR R1, [R0]

// 7b. Configure PD12-PD15 as outputs
LDR R0, =GPIOD_MODER
LDR R1, [R0]
BIC R1, R1, #0xFF000000  // clear MODER bits for pins 12-15
ORR R1, R1, #0x55000000  // set pins 12-15 to output mode (01)
STR R1, [R0]

// 7c. Turn on Green LED by writing 1 to ODR bit 12
LDR R0, =GPIOD_ODR
LDR R1, [R0]
ORR R1, R1, #0x1000
STR R1, [R0]

// 7d. Turn off Green LED using BSRR
LDR R0, =GPIOD_BSRR
MOV R1, #0x1000
LSL R1, R1, #16         // shift to upper half
STR R1, [R0]            // bit 28 resets pin 12

// 7e. Configure PA0 as input
LDR R0, =GPIOA_MODER
LDR R1, [R0]
BIC R1, R1, #0x03       // clear MODER bits for pin 0
STR R1, [R0]

// 7f-7g. Read button (PA0) and loop until button value is 0
wait_btn:
LDR R0, =GPIOA_IDR
LDR R1, [R0]
TST R1, #0x01           // test bit 0
BNE wait_btn

// 7h. Turn on Orange (PD13), Red (PD14), Blue (PD15) using BSRR
LDR R0, =GPIOD_BSRR
LDR R1, =0x0000E000     // set bits 13, 14, 15
STR R1, [R0]

// 7i. Turn off Orange, Red, Blue LEDs by clearing bits in ODR
LDR R0, =GPIOD_ODR
LDR R1, [R0]
BIC R1, R1, #0xE000     // clear bits 13, 14, 15
STR R1, [R0]

stop: B stop
.end
