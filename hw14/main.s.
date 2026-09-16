.syntax unified
@ STM32F411 Register Definitions
.EQU RCC,     0x40023800
.EQU AHB1ENR, 0x30
.EQU GPIOAEN, 0x01
.EQU GPIODEN, 0x08
.EQU GPIOA,   0x40020000
.EQU GPIOD,   0x40020C00
.EQU MODER,   0x00
.EQU PUPDR,   0x0C
.EQU IDR,     0x10
.EQU ODR,     0x14
.equ DELAY_COUNT, 2000000
.text
.global main
.type main, %function
main:
push {r4, lr}
bl InitLED
bl InitButton
mov r4, #0              @ start at Blue (LED 3)
main_loop:
button_wait:
bl CheckButton
cmp r0, #0
beq button_wait
@ Blink current LED once
mov r0, #3
sub r0, r0, r4
bl LEDon
bl Delay
mov r0, #3
sub r0, r0, r4
bl LEDoff
bl Delay
@ Advance to next LED
add r4, r4, #1
cmp r4, #4
blt main_loop
mov r4, #0
b main_loop
pop {r4, pc}

InitLED:
push {r0-r1, lr}
ldr r0, =RCC
ldr r1, [r0, #AHB1ENR]
orr r1, r1, #GPIODEN
str r1, [r0, #AHB1ENR]
ldr r0, =GPIOD
ldr r1, [r0, #MODER]
bic r1, r1, #0xFF000000
orr r1, r1, #0x55000000
str r1, [r0, #MODER]
ldr r1, [r0, #ODR]
bic r1, r1, #(0xF << 12)
str r1, [r0, #ODR]
pop {r0-r1, pc}

InitButton:
push {r0-r1, lr}
ldr r0, =RCC
ldr r1, [r0, #AHB1ENR]
orr r1, r1, #GPIOAEN
str r1, [r0, #AHB1ENR]
ldr r0, =GPIOA
ldr r1, [r0, #MODER]
bic r1, r1, #0x03
str r1, [r0, #MODER]
ldr r1, [r0, #PUPDR]
bic r1, r1, #0x03
str r1, [r0, #PUPDR]
pop {r0-r1, pc}

CheckButton:
push {r1, lr}
ldr r0, =GPIOA
ldr r1, [r0, #IDR]
and r1, r1, #0x01
cmp r1, #0
ite ne
movne r0, #1
moveq r0, #0
pop {r1, pc}

LEDon:
push {r1-r3, lr}
add r0, r0, #12
mov r3, #1
lsl r3, r3, r0
ldr r1, =GPIOD
ldr r2, [r1, #ODR]
orr r2, r2, r3
str r2, [r1, #ODR]
pop {r1-r3, pc}

LEDoff:
push {r1-r3, lr}
add r0, r0, #12
mov r3, #1
lsl r3, r3, r0
ldr r1, =GPIOD
ldr r2, [r1, #ODR]
bic r2, r2, r3
str r2, [r1, #ODR]
pop {r1-r3, pc}

Delay:
push {r0, r1, lr}
ldr r0, =DELAY_COUNT
delay_loop:
subs r0, r0, #1
bne delay_loop
pop {r0, r1, pc}
.end
