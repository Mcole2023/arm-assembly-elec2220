/* Assembly language setup example for STM32F411E-Discovery
   Simple program to be built and debugged.
     R/O memory at 0x08000000 (code area)
     R/W memory at 0x20000000 (data area)
*/

// Code section - to begin following startup code
        .syntax unified
        .text				//could also use: .section .text.main
        .global  main
main:   mov  r0,#300        //set r0 = 300 = 0x012
        movt r0,#0xBA98     //set top of r0 (upper 16 bits) = 0xBA98
        ldr  r1,=Const      //address of Const to r1 from literal pool
        ldr  r2,[r1]        //load value of Const to r2 using pointer in r1
        add  r3,r0,r2       //set r3 = r0 + r2
        mov  r4,#-200       //set r4 = -200
        sub	 r5,r3,r4       //set r5 = r3 - r4
        ldr	 r6,=Data1      //address of Data1 to r6 from literal pool
        ldr  r7,[r6]        //load value of Data1 to r7 using pointer in r6
        add  r8,r5,r7       //set r8 = r5 + r7
        str  r8,[r6,#4]     //store r8 at Data2 (4 bytes after Data1, Data1 ptr in r6)
Here:   b    Here           //effectively halts the program

//Place a 32-bit constant in code memory area address Const1
Const:	.word 500           //constant to use in calculations

//literal pool will be placed here by the assembler
//   address of Const (literal =Const)
//   address of Data1 (literal =Data1)

// Data section - to begin at 0x20000000
// Initial data values copied from flash to RAM by startup program
        .data
Data1:  .word -10            //4 bytes for 32-bit word, initialize to -10
Data2:  .word 20             //4 bytes for 32-bit word, initialize to 20
List1:  .word 5,-8,7         //3 32-bit words, initialized to 5,-8,7,-2
List2:  .byte 4,0x32,-7,'a'  //4 8-bit bytes, initialized to 4,0x32,-7,ASCII a
        .end                 //end of assembly language source file

/* Debugger verification:
   r0 = 0xBA98012C (300 + 0xBA980000)
   r2 = 500 (0x000001F4)
   r3 = r0 + r2 = 0xBA980320
   r4 = -200 (0xFFFFFF38)
   r5 = r3 - r4 = 0xBA9803E8
   r7 = -10 (0xFFFFFFF6)
   r8 = r5 + r7 = 0xBA9803DE
   Data2 = 0xBA9803DE
   Hand-calculated value matched the register values shown in the debugger.
*/
