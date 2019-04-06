T0	equ	0xE0004000						; Timer 0 Base Address
T1	equ	0xE0008000

IR	equ	0								; Add this to a timer's base address to get actual register address
TCR	equ	4
MCR	equ	0x14
MR0	equ	0x18

TimerCommandReset	equ	2
TimerCommandRun	equ	1
TimerModeResetAndInterrupt	equ	3
TimerResetTimer0Interrupt	equ	1
TimerResetAllInterrupts	equ	0xFF

; VIC Stuff -- UM, Table 41
VIC	equ	0xFFFFF000						; VIC Base Address
IntEnable	equ	0x10
VectAddr	equ	0x30
VectAddr0	equ	0x100
VectCtrl0	equ	0x200

IO0DIR1	EQU	0xE0028008
IO0SET1	EQU	0xE0028004
IO0CLR1	EQU	0xE002800C
PINS1	EQU 0x00260000
	
IO1DIR2	EQU	0xE0028018
IO1SET2	EQU	0xE0028014
IO1CLR2	EQU	0xE002801C

	
Timer0ChannelNumber	equ	4				; UM, Table 63
Timer0Mask	equ	1<<Timer0ChannelNumber	; UM, Table 63
IRQslot_en	equ	5						; UM, Table 58

	AREA	InitialisationAndMain, CODE, READONLY
	IMPORT	main


	EXPORT	start
start

; Initialise the VIC
	ldr	r0,=VIC							; looking at you, VIC!

	ldr	r1,=irqhan
	str	r1,[r0,#VectAddr0] 				; associate our interrupt handler with Vectored Interrupt 0

	mov	r1,#Timer0ChannelNumber+(1<<IRQslot_en)
	str	r1,[r0,#VectCtrl0] 				; make Timer 0 interrupts the source of Vectored Interrupt 0

	mov	r1,#Timer0Mask
	str	r1,[r0,#IntEnable]				; enable Timer 0 interrupts to be recognised by the VIC

	mov	r1,#0
	str	r1,[r0,#VectAddr]   			; remove any pending interrupt (may not be needed)

; Initialise Timer 0
	ldr	r0,=T0							; looking at you, Timer 0!

	mov	r1,#TimerCommandReset
	str	r1,[r0,#TCR]

	mov	r1,#TimerResetAllInterrupts
	str	r1,[r0,#IR]

	ldr	r1,=(14745600/200)-1	 		; 5 ms = 1/200 second
	str	r1,[r0,#MR0]

	mov	r1,#TimerModeResetAndInterrupt
	str	r1,[r0,#MCR]

	mov	r1,#TimerCommandRun
	str	r1,[r0,#TCR]
	

	; intialise runThread to 0
	MOV R1, #0
	LDR R3, =runThread
	STR R1, [R3]
		
	; go to user mode
	MSR CPSR_C, #0x10
	
self b self

stop B stop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; blinky LEDs
LEDprogram
	ldr	r4,=IO1DIR2
	ldr	r5,=0x000f0000					;select P1.19--P1.16
	str	r5,[r4]							;make them outputs
	ldr	r4,=IO1SET2
	str	r5,[r4]							;set them to turn the LEDs off
	ldr	r5,=IO1CLR2

	ldr	r7,=0x00100000					; end when the mask reaches this value
whloop	ldr	r6,=0x00010000				; start with P1.16.
floop	str	r6,[r5]	   					; clear the bit -> turn on the LED

;delay for about a half second
	ldr	r8,=4000000
	
dloop2	subs	r8,r8,#1
	bne	dloop2

	str	r6,[r4]							; set the bit -> turn off the LED
	mov	r6,r6,lsl #1					; shift up to next bit. P1.16 -> P1.17 etc.
	cmp	r6,r7
	bne	floop
	b	whloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; RBG LED only green
RGBprogram
	LDR R4, =0 							; counter
	LDR R5, =0 							; colour
	
	LDR R6, =IO0DIR1
	LDR R7, =PINS1 						
	STR R7,[R6]							; make pins outputs
	LDR R6,=IO0SET1 					; R6 turns off LEDS
	STR R7,[R6]							
	LDR R7,=IO0CLR1 					; R7 turns on LEDS
	

wloop	
	LDR R8,=0x00200000
	STR R8,[R6] 						; turn on green
	
	; turns on / off every around half second
	LDR	R9,=4000000
	
dloop	
	SUBS	R9,R9,#1
	BNE	dloop
	
	LDR R8, =IO0SET1
	STR R8,[R7] 						; turn off
	
	ldr	r9,=4000000
	
dloop3	subs	r9,r9,#1
	bne	dloop3
	
	B wloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; INTERRUPT HANDLER

	AREA	InterruptStuff, CODE, READONLY
irqhan	
	SUB	LR,LR,#4
	STMFD SP!,{R0}	
			
	LDR R0, =runThread 					; check value in runThread
	LDR R0, [R0]
	CMP R0, #0
	BNE notZero 						; if 0, initialise both stacks

	LDR R0, =threadOneStack 			; stack one (Stack Pointer)
	LDR LR, =RGBprogram 				; set LR to first thread
	STMIA R0, {R0 - R12, LR} 			; store in memory
	
	LDR R0, =threadTwoStack 			; stack two (Stack Pointer)
	LDR LR, =LEDprogram 				; set LR to second thread
	STMIA R0, {R0 - R12, LR} 			; store in memory
	
	LDR R0, =1 							; change runThread to 1
	LDR R1, =runThread
	STR R0, [R1]
	B returnOne
	
notZero		   
	CMP R0, #1 							; if 1 change from thread one to thread two
	BNE two

	LDR R0, =threadOneStack 			; get stack one ready to go
	ADD R0, R0, #0x00000004 			; offset by a word to leave space for the contents of R0
	STMIA R0, {R1 - R12, LR} 			; store from  R1 - R12, and LR
	MRS R12, SPSR 						; save the contents of SPSR
	STR R12, [R0], #4 					; put at end of stack
	LDR R1, =threadOneStack 			; get original address of stack (R1 already stored so can corrupt it)
	LDMFD SP!, {R0} 					; get original value of R0
	STM R1, {R0} 						; store the contents of R0 at the start of the stack where a space has been left for it
	
	MOV R1, #2 							; update runThread 
	LDR R0, =runThread
	STR R1, [R0]						; store in memory
	B returnTwo
	
two
	LDR R0, =threadTwoStack 			; get stack two ready to go
	ADD R0, R0, #0x00000004 			; offset by a word to leave space for the contents of R0
	STMIA R0, {R1 - R12, LR}		 	; store from  R1 - R12, and LR
	MRS R12, SPSR 						; save the contents of SPSR
	STR R12, [R0], #4 					; put at end of stack
	LDR R1, =threadTwoStack 			; get original address of stack	(R1 already stored so can corrupt it)
	LDMFD SP!, {R0} 					; get original value of R0
	STM R1, {R0} 						; store the contents of R0 at the start of the stack where a space has been left for it
	
	MOV R1, #1							; update runThread
	LDR R0, =runThread
	STR R1, [R0]						; store in memory
	B returnOne
	

returnOne
	LDR	R0,=T0
	MOV	R1,#TimerResetTimer0Interrupt
	STR	R1,[R0,#IR]	   					; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	LDR	R0,=VIC
	MOV	R1,#0
	STR	R1,[R0,#VectAddr]				; reset VIC				
	
	LDR R0, =threadOneStack 			; get address of stack one
	ADD R0, R0, #60 					; go to end of stack	( 4 * 15 = 60) no need to save R13, so only 15 registers
	LDR R1, [R0] 						; load SPSR into R1
	MSR SPSR_CXFS, R1 					; load SPSR from R1 into SPSR
	LDR R0, =threadOneStack 			; go back to start of stack
	LDMIA	R0,{R0-R12,PC}^ 			; load all values into their respective postions - will now run thread thread one
	
returnTwo
	LDR	R0,=T0
	MOV	R1,#TimerResetTimer0Interrupt
	STR	R1,[R0,#IR]	   					; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	LDR	R0,=VIC
	MOV	R1,#0
	STR	R1,[R0,#VectAddr]				; reset VIC

	LDR R0, =threadTwoStack 			; get address of stack one
	ADD R0, R0, #60 					; go to end of stack	( 4 * 15 = 60) no need to save R13, so only 15 registers
	LDR R1, [R0] 						; load SPSR into R1
	MSR SPSR_CXFS, R1 					; load SPSR from register into SPSR
	LDR R0, =threadTwoStack				; go back to start of stack
	LDMIA	R0,{R0-R12,PC}^ 			; load all values into their respective postions - will now run thread thread two	
		


	AREA MEM, DATA, READWRITE
			
runThread		DCD 0
threadOneStack		DCD 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
threadTwoStack		DCD 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
		
	END
