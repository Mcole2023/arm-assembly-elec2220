#program1
.syntax unified
.data
KM:    .word 50, 85, 175, 340
MILES: .word 0, 0, 0, 0
.text
.global main
.type main, %function
main:
LDR R4, =KM
LDR R5, =MILES
MOV R6, #0          // n = 0
for_loop:
CMP R6, #4
BGE done
LDR R0, [R4, R6, LSL #2]  // R0 = KM[n]
BL  km2miles
STR R0, [R5, R6, LSL #2]  // MILES[n] = result
ADD R6, R6, #1
B   for_loop
done:
stop: B stop

// Subroutine: km2miles
// Input:  R0 = kilometers
// Output: R0 = miles (rounded to nearest mile)
// miles = (km * 1000 + 804) / 1609
km2miles:
PUSH {R1-R3, LR}
MOV R1, #1000
MUL R0, R0, R1      // km * 1000
ADD R0, R0, #804    // + 804 for rounding
MOV R1, #0
LDR R2, =1609
div_loop:
CMP R0, R2
BLT div_done
SUB R0, R0, R2
ADD R1, R1, #1
B   div_loop
div_done:
MOV R0, R1
POP {R1-R3, LR}
BX  LR
.end

/* Debugger verification:
   KM = {50, 85, 175, 340}
   MILES = {31, 53, 109, 211}
   MILES[0] = 31 - rounded down (31.07)
   MILES[1] = 53 - rounded up (52.82)
   MILES[2] = 109 - rounded up (108.74)
   MILES[3] = 211 - rounded down (211.27)
*/
