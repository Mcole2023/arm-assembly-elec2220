//================================================
//  STM32F4xx Register Addresses and Constants

// Peripheral register addresses/offsets
	.EQU	RCC		,0x40023800		//RCC base address
	.EQU	AHB1ENR ,0x30			//AHB1ENR offset
	.EQU	APB1ENR	,0x40			//APB1ENR offset
	.EQU	APB2ENR	,0x44			//APB2ENR offset
	.EQU	GPIOAEN	,0x01			//GPIOA clock enable - bit 0
	.EQU	GPIODEN	,0x08			//GPIOD clock enable - bit 3
	.EQU	RCC_DAC_EN,0x20000000	//DAC enable = bit 29
	.EQU	TIM2EN	,0x01			//Timer 2 enable = bit 0
	.EQU	TIM3EN	,0x02			//Timer 3 enable = bit 1
	.EQU	TIM4EN	,0x04			//Timer 4 enable = bit 2
	.EQU	TIM5EN	,0x08			//Timer 5 enable = bit 3

//GPIO registers
	.EQU	GPIOA	,0x40020000		//GPIOA base address
	.EQU	GPIOB	,0x40020400		//GPIOB base address
	.EQU	GPIOC	,0x40020800		//GPIOC base address
	.EQU	GPIOD	,0x40020C00		//GPIOD base address
	.EQU	MODER	,0x00			//mode selection register
	.EQU	OTYPER	,0x04			//output type register
	.EQU	OSPEEDR	,0x08			//output speed register
	.EQU	PUPDR	,0x0C			//pull-p/pull-down register
	.EQU	IDR		,0x10			//input data register
	.EQU	ODR		,0x14			//output data register
	.EQU	BSRR	,0x18			//BSSR bit set/reset register
	.EQU	BSRRL	,0x18			//bits 15-0 of BSSR set pins
	.EQU	BSRRH	,0x1A			//bits 31-16 of BSSR reset pins
	.EQU	AFRL	,0x20			//alt function low (pins 0-7)
	.EQU	AFRH	,0x24			//alt function high (pins 8-15)
	.EQU	PA4		,0x0300			//PA4 configuration bits
	.EQU	PA5		,0x0C00			//PA5 configuration bits

//NVIC Registers
	.EQU	NVIC_ISER0	,0xE000E100	//Interrupt Set-Enable (0-7)
	.EQU	NVIC_ICER0	,0xE000E180	//Interrupt Clear-Enable (0-7)
	.EQU	NVIC_ISPR0	,0xE000E200	//Interrupt Set-Pending (0-7)
	.EQU	NVIC_ICPR0	,0xE000E280	//Interrupt Clear-Pending (0-7)
	.EQU	NVIC_IABR0	,0xE000E300	//Interrupt Active Bit (0-7)
	.EQU	NVIC_IPR0	,0xE000E400	//Interrupt Priority (0-59)
	.EQU	NVIC_IPR1	,0xE000E404	//Interrupt Priority (0-59)
	.EQU	STIR		,0xE000EF00	//Software Tigger Interrupt

//TIM4 constants for NVIC
	.EQU	TIM4IRQ		,30			//TIM4 IRQ number
	.EQU	TIM4_OFF	,0			//Offset to ISER0/ICER0/ISPR0/ICPR0/IABR0 (30/32 = 0) x 4
	.EQU	TIM4_BIT	,30			//Bit# 30 in the above registers (30%32 = 30)
	.EQU	TIM4_POFF	,28			//Offset to IPR7 (30/4 = 7) x 4
	.EQU	TIM4_PBIT	,16			//Bit start within IPR7 (30%4 = 2) x 8


//TIMER registers
	.EQU	TIM2	,0x40000000		//Timer 2 registers
	.EQU	TIM3	,0x40000400		//Timer 3 registers
	.EQU	TIM4	,0x40000800		//Timer 4 registers
	.EQU	TIM5	,0x40000C00		//Timer 5 registers
	.EQU	TIM9	,0x40014800		//Timer 9 registers
	.EQU	TIM10	,0x40014800		//Timer 10 registers
	.EQU	TIM11	,0x40014800		//Timer 11 registers
	.EQU	CR1		,0x00			//Control register 1
	.EQU	CR2		,0x04			//Control register 2
	.EQU	SMCR	,0x08			//Slave mode control register
	.EQU	DIER	,0x0C			//DMA/interrupt enable register
	.EQU	SR		,0x10			//Status register
	.EQU	EGR		,0x14			//Event generation register
	.EQU	CCMR1	,0x18			//Capture/compare mode register 1
	.EQU	CCMR2	,0x1C			//Capture/compare mode register 2
	.EQU	CCER	,0x20			//Capture/compare enable register
	.EQU	CNT		,0x24			//Counter
	.EQU	PSC		,0x28			//Prescaler
	.EQU	ARR		,0x2C			//Auto-Reload Register
	.EQU	CCR1	,0x34			//Capture/compare register 1
	.EQU	CCR2	,0x38			//Capture/compare register 2
	.EQU	CCR3	,0x3C			//Capture/compare register 3
	.EQU	CCR4	,0x40			//Capture/compare register 4
	.EQU	DCR		,0x48			//DMA control register
	.EQU	DMAR	,0x4C			//DMA address for full transfer

//System Configuration Registers
	.EQU	SYSCFG	,0x40013800		//System Configuration Module
	.EQU	EXTICR1	,0x08			//clock enables for GPIO ports

//External Interrupt Registers
	.EQU	EXTI,0x40013C00
	.EQU	IMR	,0x00				//Interrupt Mask Register
	.EQU	EMR	,0x04				//Event Mask Register
	.EQU	RTSR,0x08				//Rising Trigger Select
	.EQU	FTSR,0x0C				//Falling Trigger Select
	.EQU	SWIR,0x10				//Software Interrupt Event
	.EQU	PR	,0x14				//Pending Register

// LED numbers
	.EQU	GREEN,0					//Green  LED on PD12 = LED #0
	.EQU	ORANGE,1				//Orange LED on PD13 = LED #1
	.EQU	RED,2					//Red    LED on PD14 = LED #2
	.EQU	BLUE,3					//Blue   LED on PD15 = LED #3
