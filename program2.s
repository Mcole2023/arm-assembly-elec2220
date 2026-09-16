.syntax unified
.data
BinVal:  .word 0x1234
DecStrg: .space 12
.text
.global main
.type main, %function
main:
LDR R0, =BinVal
LDR R0, [R0]        // R0 = signed integer value
LDR R1, =DecStrg    // R1 = pointer to output string

// Check if negative
CMP R0, #0
BGE positive
// Negative: store '-' sign and negate
MOV R3, #'-'
STRB R3, [R1], #1   // store '-', advance pointer
MOV R3, #0
SUB R0, R3, R0       // R0 = 0 - R0 (absolute value)

positive:
// Special case: if value is 0, just store "0\0"
CMP R0, #0
BNE not_zero
MOV R3, #'0'
STRB R3, [R1], #1
MOV R3, #0
STRB R3, [R1]
B stop

not_zero:
// Step 1: Find largest power of 10 that fits in the value
MOV R4, #1          // R4 = power of 10 (start at 1)
find_power:
// Multiply R4 by 10, check if it exceeds R0
MOV R5, R4                 // save current power
ADD R4, R4, R4, LSL #2     // R4 = R4 * 5
LSL R4, R4, #1             // R4 = R4 * 2 (total: *10)
CMP R4, R0
BHI power_found            // if R4 > R0, previous power was the one
B   find_power
power_found:
MOV R4, R5           // R4 = largest power of 10 <= R0

// Step 2: Extract each digit by repeated subtraction (division)
extract_loop:
CMP R4, #0
BEQ null_term        // safety check
// Divide R0 by R4 using repeated subtraction
MOV R6, #0            // R6 = digit (quotient)
sub_loop:
CMP R0, R4
BLT digit_done
SUB R0, R0, R4        // R0 -= R4
ADD R6, R6, #1        // digit++
B   sub_loop
digit_done:
// Convert digit to ASCII and store
ADD R6, R6, #'0'
STRB R6, [R1], #1     // store digit, advance pointer
MOV R5, #0             // quotient
MOV R7, #10
div10_loop:
CMP R4, R7
BLT div10_done
SUB R4, R4, R7
ADD R5, R5, #1
B   div10_loop
div10_done:
MOV R4, R5             // R4 = R4 / 10
CMP R4, #0
BNE extract_loop        // continue if more digit positions
null_term:
MOV R3, #0
STRB R3, [R1]
stop:
B stop
.end

/* Debugger verification:
   BinVal = 4660  (0x1234)  -> DecStrg = "4660"
   BinVal = -4660           -> DecStrg = "-4660"
*/
