.syntax unified
.global main
.data
.align 2
AA:    .word 1000, 2000, -1000, -2000
BB:    .hword 10000, 20000, 40000, 50000
.align 2
SCALE: .word 0, 0, 0, 0
AUTO:  .word 0, 0, 0, 0
.text
.align 2
main:

@ Loop 1: SCALE[n] = AA[n]/8 - 16*BB[n] using scaled-index addressing
LDR R0, =AA
LDR R1, =BB
LDR R2, =SCALE
MOV R3, #0
loop1:
LDR   R4, [R0, R3, LSL #2]
LDRH  R5, [R1, R3, LSL #1]
ASR   R6, R4, #3
LSL   R5, R5, #4
SUB   R6, R6, R5
STR   R6, [R2, R3, LSL #2]
ADD   R3, R3, #1
CMP   R3, #4
BLT   loop1

@ Loop 2: AUTO[n] = 2*AA[n] + BB[n]/4 using auto-increment addressing
LDR R0, =AA
LDR R1, =BB
LDR R2, =AUTO
MOV R3, #0
loop2:
LDR   R4, [R0], #4
LDRH  R5, [R1], #2
LSL   R6, R4, #1
LSR   R5, R5, #2
ADD   R6, R6, R5
STR   R6, [R2], #4
ADD   R3, R3, #1
CMP   R3, #4
BLT   loop2

stop:
B stop
.end

/* Debugger verification (Expressions view):
   AA  = {1000, 2000, -1000, -2000}
   BB  = {10000, 20000, 40000, 50000}
   SCALE = {-159875, -319750, -640125, -800250}
   AUTO  = {4500, 9000, 8000, 8500}
*/
