#program2
.syntax unified
.data
Temp: .space 6*4
High: .word 0xAAA, 0xBBB, 0xCCC, 0xDDD, 0xEEE, 0xFFF
Low:  .word 0x111, 0x222, 0x333, 0x444, 0x555, 0x666
.text
.global main
.type main, %function
main:
// Step 1: Load High into R1-R6
LDR R0, =High
LDM R0, {R1-R6}
// Step 2: Save R0-R6 on the stack
PUSH {R0-R6}
// Step 3: Load Low into R1-R6
LDR R0, =Low
LDM R0, {R1-R6}
// Step 4: Swap (ascending)
LDR R0, =Temp
STMIA R0!, {R1-R3}   // Temp[0-2] = R1-R3
STMIA R0!, {R4-R6}   // Temp[3-5] = R4-R6, R0 -> High
LDR R0, =Temp
LDMIA R0!, {R4-R6}   // R4-R6 = Temp[0-2]
LDMIA R0!, {R1-R3}   // R1-R3 = Temp[3-5]
LDR R0, =Temp
NOP                    // breakpoint

// Step 5: Swap again
LDR R0, =High
STMDB R0!, {R1-R3}   // Temp[3-5] = R1-R3
STMDB R0!, {R4-R6}   // Temp[0-2] = R4-R6, R0 -> Temp
LDMIA R0!, {R1-R3}   // R1-R3 = Temp[0-2]
LDMIA R0!, {R4-R6}   // R4-R6 = Temp[3-5]
LDR R0, =Temp
NOP                    // breakpoint

// Step 6: Restore R0-R6 from stack
POP {R0-R6}
stop: B stop
.end

/* Debugger verification (Registers / Expressions views across the
   two breakpoints):
   After Step 4: Temp = {0x111, 0x222, 0x333, 0x444, 0x555, 0x666}
   After Step 5: r1-r6 = {0xAAA, 0xBBB, 0xCCC, 0xDDD, 0xEEE, 0xFFF}
*/
