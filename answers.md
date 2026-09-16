# HW13 — Microcontroller Hardware and I/O Ports

1. Memory map:
   - Flash memory: 0x08000000 - 0x0807FFFF (512 KB)
   - SRAM: 0x20000000 - 0x2001FFFF (128 KB)
   - STM peripherals: 0x40000000 - 0x5006 03FF
   - Cortex-M4 peripherals: 0xE0000000 - 0xE00FFFFF

2. RCC base address: 0x40023800

3. RCC_AHB1ENR (AHB1 peripheral clock enable register)
   - Offset: 0x30
   - Full address: 0x40023830

4. GPIO base addresses:
   - GPIOA: 0x40020000
   - GPIOD: 0x40020C00

5. GPIO register offsets:
   - GPIOx_MODER: 0x00
   - GPIOx_ODR: 0x14
   - GPIOx_IDR: 0x10
   - GPIOx_BSRR: 0x18

6. Discovery board pin mapping:
   - Green LED (LD4): PD12 (GPIOD pin 12)
   - Orange LED (LD3): PD13 (GPIOD pin 13)
   - Red LED (LD5): PD14 (GPIOD pin 14)
   - Blue LED (LD6): PD15 (GPIOD pin 15)
   - User Button: PA0 (GPIOA pin 0)
