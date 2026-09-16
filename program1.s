.syntax unified
.data
STRG:  .asciz "1r3GH%$ 41ht,abc*0k9TU3A"
LOWER: .word 0   // number of lowercase letters
UPPER: .word 0   // number of uppercase letters
.text
.global main
.type main, %function
main:
LDR R0, =STRG      // R0 = pointer to current character
MOV R1, #0         // R1 = lowercase count
MOV R2, #0         // R2 = uppercase count
loop:
LDRB R3, [R0], #1  // load next character, post-increment pointer
CMP  R3, #0         // check for null terminator
BEQ  done            // if null, exit loop
CMP  R3, #'A'
BLT  loop            // if < 'A', not a letter, next char
CMP  R3, #'Z'
BLE  is_upper        // if <= 'Z', it's uppercase
CMP  R3, #'a'
BLT  loop            // if < 'a', not lowercase, next char
CMP  R3, #'z'
BGT  loop            // if > 'z', not lowercase, next char
// It's a lowercase letter
ADD  R1, R1, #1
B    loop
is_upper:
ADD  R2, R2, #1
B    loop
done:
// Store results to memory
LDR R4, =LOWER
STR R1, [R4]       // store lowercase count
LDR R4, =UPPER
STR R2, [R4]       // store uppercase count
stop:
B stop
.end

/* Debugger verification:
   STRG = "1r3GH%$ 41ht,abc*0k9TU3A"
   LOWER = 7, UPPER = 5
*/
