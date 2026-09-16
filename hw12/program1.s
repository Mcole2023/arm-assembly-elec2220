.syntax unified
.data
STR1: .asciz "12345678"
STR2: .asciz "87654321"
STR3: .asciz "66778899"
STR4: .asciz "22334455"
Num1: .word 0
Num2: .word 0
Num3: .word 0
Num4: .word 0
ARY1: .byte 20, -18, 97, -33, 10, -71
ARY2: .byte 22, -77, 44, -88, 11, -66, 33, -55
.text
.global main
.type main, %function
main:
// Convert STR1 -> Num1
LDR R0, =STR1
PUSH {R0}
BL   ASC2BIN
POP  {R0}
LDR R1, =Num1
STR R0, [R1]

// Convert STR2 -> Num2
LDR R0, =STR2
PUSH {R0}
BL   ASC2BIN
POP  {R0}
LDR R1, =Num2
STR R0, [R1]

// Sort ARY1 based on Num1 vs Num2
LDR R0, =Num1
LDR R0, [R0]
LDR R1, =Num2
LDR R1, [R1]
LDR R2, =ARY1
MOV R3, #6
PUSH {R0-R3}        // push Num1, Num2, array addr, size
BL   SortArray
ADD  SP, SP, #16    // clean up stack

// Convert STR3 -> Num3
LDR R0, =STR3
PUSH {R0}
BL   ASC2BIN
POP  {R0}
LDR R1, =Num3
STR R0, [R1]

// Convert STR4 -> Num4
LDR R0, =STR4
PUSH {R0}
BL   ASC2BIN
POP  {R0}
LDR R1, =Num4
STR R0, [R1]

// Sort ARY2 based on Num3 vs Num4
LDR R0, =Num3
LDR R0, [R0]
LDR R1, =Num4
LDR R1, [R1]
LDR R2, =ARY2
MOV R3, #8
PUSH {R0-R3}
BL   SortArray
ADD  SP, SP, #16

stop: B stop

// ASC2BIN: convert a null-terminated ASCII digit string to a binary value
ASC2BIN:
PUSH {R1-R4, LR}
LDR  R0, [SP, #20]   // string address (5 regs * 4 bytes)
MOV  R1, #0            // accumulator
MOV  R2, #10
asc_loop:
LDRB R3, [R0], #1
CMP  R3, #0
BEQ  asc_done
SUB  R3, R3, #'0'
MUL  R1, R1, R2
ADD  R1, R1, R3
B    asc_loop
asc_done:
STR  R1, [SP, #20]   // return result on stack
POP  {R1-R4, LR}
BX   LR

// SortArray: pick ascending or descending sort based on Num1 vs Num2
SortArray:
PUSH {R0-R3, LR}
LDR  R2, [SP, #20]   // Num1
LDR  R3, [SP, #24]   // Num2
LDR  R0, [SP, #28]   // array address
LDR  R1, [SP, #32]   // array size
CMP  R2, R3
BGT  call_descend
BL   Ascend
B    sort_done
call_descend:
BL   Descend
sort_done:
POP  {R0-R3, LR}
BX   LR

// Ascend: bubble sort signed bytes ascending
// R0 = array address, R1 = array size
Ascend:
PUSH {R0-R6, LR}
MOV R4, R0
MOV R5, R1
asc_outer:
MOV R6, #0
MOV R0, R4
SUB R1, R5, #1
asc_inner:
CMP R1, #0
BLE asc_check
LDRSB R2, [R0]
LDRSB R3, [R0, #1]
CMP R2, R3
BLE asc_noswap
STRB R3, [R0]
STRB R2, [R0, #1]
MOV R6, #1
asc_noswap:
ADD R0, R0, #1
SUB R1, R1, #1
B   asc_inner
asc_check:
CMP R6, #0
BNE asc_outer
POP {R0-R6, LR}
BX  LR

// Descend: bubble sort signed bytes descending
// R0 = array address, R1 = array size
Descend:
PUSH {R0-R6, LR}
MOV R4, R0
MOV R5, R1
desc_outer:
MOV R6, #0
MOV R0, R4
SUB R1, R5, #1
desc_inner:
CMP R1, #0
BLE desc_check
LDRSB R2, [R0]
LDRSB R3, [R0, #1]
CMP R2, R3
BGE desc_noswap
STRB R3, [R0]
STRB R2, [R0, #1]
MOV R6, #1
desc_noswap:
ADD R0, R0, #1
SUB R1, R1, #1
B   desc_inner
desc_check:
CMP R6, #0
BNE desc_outer
POP {R0-R6, LR}
BX  LR
.end

/* Debugger verification:
   STR1-4 = "12345678","87654321","66778899","22334455"
   Num1=12345678, Num2=87654321, Num3=66778899, Num4=22334455
   Num1 < Num2  -> ARY1 sorted ascending
   Num3 > Num4  -> ARY2 sorted descending
*/
