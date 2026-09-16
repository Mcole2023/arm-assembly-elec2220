.syntax unified
.data
x: .word 30
y: .word 0
.text
.global main
main:
LDR R0, =x
LDR R1, [R0]        @ R1 = x

// 65*x / 100
MOV R2, #65
MUL R2, R2, R1
MOV R3, #100
SDIV R2, R2, R3

// 323 * x^2 / 100
MUL R4, R1, R1
MOV R5, #323
MUL R4, R5, R4
MOV R5, #100
SDIV R4, R4, R5

// 157 * x^3 / 100
MUL R5, R1, R1
MUL R5, R5, R1
MOV R6, #157
MUL R5, R6, R5
MOV R6, #100
SDIV R5, R5, R6

// y = term1 - term2 + term3
SUB R2, R2, R4
ADD R2, R2, R5

LDR R0, =y
STR R2, [R0]
DONE:
B DONE

/* Debugger verification:
   x = 30  ->  y = 39502   (matches hand calculation)
   x = -30 ->  y = -45316
   x = 3000 -> y = 12554411 (INCORRECT: 32-bit signed overflow, since
               x^3 = 3000^3 = 27,000,000,000 exceeds the 32-bit range.
               Noted in the submission as an overflow case, not a bug
               in the arithmetic sequence itself.)
*/
