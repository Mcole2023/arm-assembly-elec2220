// Bit:  15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
//        V  P  T  3  2  1 0 L3 L2 L1 L0
// Sensors            4-bit LEDS
.syntax unified
.data
GPIO: .hword 0x4AD4
.text
.global main
main:
LDR R0, =GPIO

// Set L3(bit 3)=1, L2(bit 2)=0
LDRH R1, [R0]
ORR  R1, R1, #0x0008
BIC  R1, R1, #0x0004
STRH R1, [R0]

// If V(bit 15)=1, set L1(bit 1)=1
LDRH R1, [R0]
TST  R1, #0x8000
BEQ  skip_v
ORR  R1, R1, #0x0002
STRH R1, [R0]
skip_v:

// If P(bit 14)=1 and T(bit 13)=0, toggle L0(bit 0)
LDRH R1, [R0]
AND  R2, R1, #0x6000
CMP  R2, #0x4000
BNE  skip_pt
EOR  R1, R1, #0x0001
STRH R1, [R0]
skip_pt:

// Replace CODE(bits 10:7) with 0xA
LDRH R1, [R0]
BIC  R1, R1, #0x0780
ORR  R1, R1, #0x0500
STRH R1, [R0]

done:
B done
.end

/* Debugger verification:
   Initial GPIO = 0x4AD4  ->  Result = 0x4D59
   Second test case (different initial value) -> Result = 0xB52A
*/
