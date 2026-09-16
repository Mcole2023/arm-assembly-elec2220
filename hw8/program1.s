.syntax unified
.data
A: .word 50, -60
B: .word -100, 200
C: .word 600, -800
D: .word -300, 400
E: .word 20, -20
.text
.global main
main:
MOV R10, #0        @ k = 0
MOV R11, #2        @ loop limit
LOOP:
CMP R10, R11
BGE DONE
LDR R0, =A
LDR R1, =B
LDR R2, =C
LDR R3, =D
LDR R4, =E
LDR R5, [R0, R10, LSL #2]  @ A[k]
LDR R6, [R1, R10, LSL #2]  @ B[k]
LDR R7, [R2, R10, LSL #2]  @ C[k]
LDR R8, [R3, R10, LSL #2]  @ D[k]
LDR R9, [R4, R10, LSL #2]  @ E[k]

//20 * A[k] / B[k]
MOV R12, #20
MUL R12, R12, R5
SDIV R12, R12, R6

//C[k] * D[k] / 10
MUL R5, R7, R8
MOV R6, #10
SDIV R5, R5, R6

// E[k]^2
MUL R6, R9, R9

// A[k] = Term1 + Term2 - Term3
ADD R12, R12, R5
SUB R12, R12, R6

LDR R0, =A
STR R12, [R0, R10, LSL #2]

ADD R10, R10, #1
B LOOP
DONE:
B DONE

/* Debugger verification (Expressions view):
   A[0] = -18410, A[1] = -32406
   B = {-100, 200}, C = {600, -800}, D = {-300, 400}, E = {20, -20}
*/
