# ARM Assembly — ELEC 2220 (Computer Systems)

**Auburn University — ELEC 2220, Spring 2026**

A progression of ARM Cortex-M4 assembly assignments written and debugged on the
STM32F411E-Discovery board using STM32CubeIDE, moving from basic register/memory
operations through addressing modes, arithmetic, branching, subroutines, GPIO/hardware
register access, timer interrupts, and a final multi-task embedded project.

Each assignment folder contains the assembly source as submitted, with debugger-verified
results (register/memory values from the STM32CubeIDE Expressions/Registers views) noted
in a comment block at the end of the file.

---

## Assignments

| # | Topic | Key Concepts |
|---|-------|--------------|
| [HW03](#hw03--setup-example) | Toolchain setup | Literal pools, `.data`/`.text` sections, basic MOV/LDR/STR/ADD/SUB |
| [HW07](#hw07--addressing-modes) | Addressing modes | Scaled-index and auto-increment addressing |
| [HW08](#hw08--arithmetic-operators) | Arithmetic operators | MUL, SDIV, multi-term formulas, signed overflow |
| [HW09](#hw09--logical-operators) | Logical operators | ORR/BIC/AND/EOR/TST for bitfield manipulation |
| [HW10](#hw10--branching) | Conditional branches | Character classification, decimal string conversion |
| [HW11](#hw11--subroutines) | Subroutines & stacks | BL/BX/LR, multi-register LDM/STM, PUSH/POP |
| [HW12](#hw12--subroutines-ii) | Subroutines II | ASCII-to-binary conversion, parameterized sort subroutine |
| [HW13](#hw13--hardware-registers) | Hardware registers | RCC/GPIO memory-mapped register addresses, direct register I/O |
| [HW14](#hw14--gpio-driver) | Layered GPIO driver | Init/Check/Set subroutines, button-controlled LED cycling |
| [HW16](#hw16--timer-interrupts) | Timer interrupts | TIM4 hardware interrupt vs. software delay loop, SWV timing |
| [FinalProject](#final-project) | Semester project | 4-task design: button input, moving-average filter, down-counter, bubble sort |

---

## HW03 — Setup Example
Builds and debugs a short example program: loads constants via literal pools, performs
register arithmetic, and stores a result to a computed memory address. Confirms
understanding of the toolchain, `.data`/`.text` layout, and Flash (0x0800...) vs.
SRAM (0x2000...) memory regions.

## HW07 — Addressing Modes
Two loops over parallel `int`/`short` arrays using **scaled-index addressing**
(`[R0, R3, LSL #2]`) and **auto-increment addressing** (`[R0], #4`) to compute
per-element results without a separate index-to-byte-offset calculation each iteration.

## HW08 — Arithmetic Operators
Two programs exercising `MUL`/`SDIV`: a multi-array formula evaluated in a loop, and a
polynomial evaluation (`y = 0.65x - 3.23x² + 1.57x³`, scaled to integer arithmetic).
The polynomial program's writeup also documents a genuine 32-bit signed overflow case
(`x = 3000`) and explains why the result is incorrect — not a code bug, a data-range issue.

## HW09 — Logical Operators
Bitfield manipulation on a simulated 16-bit GPIO register using `ORR`/`BIC`/`AND`/`TST`/`EOR`
to set, clear, test, and conditionally toggle individual bits and multi-bit fields.

## HW10 — Branching
Two programs built around conditional branches: classifying characters in a string as
upper/lowercase without a lookup table, and converting a signed binary value to a decimal
ASCII string (including sign handling) using repeated-subtraction division.

## HW11 — Subroutines
Two programs introducing `BL`/`BX LR`: a `km2miles` conversion subroutine called from a
loop, and a register-swap exercise using multi-register `LDM`/`STM` (`STMIA`/`STMDB`) with
values saved across a `PUSH`/`POP`.

## HW12 — Subroutines II
A string-to-integer conversion subroutine (`ASC2BIN`) feeding a parameterized `SortArray`
subroutine that dispatches to `Ascend` or `Descend` bubble-sort routines depending on which
converted value is larger — subroutines calling subroutines, with all parameters passed on
the stack.

## HW13 — Hardware Registers
Written answers identifying the STM32F411's memory map, RCC/GPIO base addresses and
register offsets, and the Discovery board's LED/button pin assignments, plus a program
using those addresses directly to enable clocks, configure GPIO direction, and read/write
pins without any HAL/vendor library calls.

## HW14 — GPIO Driver
Builds on HW13 with a small layered driver (`InitLED`, `InitButton`, `CheckButton`, `LEDon`,
`LEDoff`, `Delay`) and a main loop that cycles through the four board LEDs each time the
user button is pressed.

## HW16 — Timer Interrupts
Compares **hardware-timer-driven** LED blinking (TIM4 interrupt, exact frequency division
from the 16 MHz clock) against a **software delay loop**, measuring both with the Serial
Wire Viewer (SWV) and calculating the drift between them (~7.3% error on the software-timed
LED) — the direct lead-in to the final project's interrupt-driven design.

## Final Project
A four-task embedded system on the STM32F411E-Discovery board, advanced by the user button:
- **Task 0** — wait for button press
- **Task 1** — cycle the four LEDs with a moving-average filter applied to a data array
- **Task 2** — drive a 4-bit binary down-counter on the LEDs, then bubble-sort an ASCII string
- **Task 3** — all LEDs on, then off

Built entirely with direct memory-mapped register access (RCC, GPIO, EXTI, SYSCFG, NVIC,
TIM4) — no HAL calls — with button input handled through an EXTI/NVIC interrupt rather than
polling.

---

## Author
**Michael Cole** — Computer Engineering, Auburn University
[LinkedIn](https://www.linkedin.com/in/michael-cole-b948b0280/) | [GitHub](https://github.com/lapizliluzi)
