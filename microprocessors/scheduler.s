; Definitions  -- references to 'UM' are to the User Manual.

IO0DIR	EQU	0xE0028008
IO0SET	EQU	0xE0028004
IO0CLR	EQU	0xE002800C
IO0PIN	EQU	0xE0028000
	
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN	EQU	0xE0028010

; Timer Stuff -- UM, Table 173

T0	equ	0xE0004000		; Timer 0 Base Address
T1	equ	0xE0008000

IR	equ	0			; Add this to a timer's base address to get actual register address
TCR	equ	4
MCR	equ	0x14
MR0	equ	0x18

TimerCommandReset	equ	2
TimerCommandRun	equ	1
TimerModeResetAndInterrupt	equ	3
TimerResetTimer0Interrupt	equ	1
TimerResetAllInterrupts	equ	0xFF

; VIC Stuff -- UM, Table 41
VIC	equ	0xFFFFF000		; VIC Base Address
IntEnable	equ	0x10
VectAddr	equ	0x30
VectAddr0	equ	0x100
VectCtrl0	equ	0x200

Timer0ChannelNumber	equ	4	; UM, Table 63
Timer0Mask	equ	1<<Timer0ChannelNumber	; UM, Table 63
IRQslot_en	equ	5		; UM, Table 58

	AREA	InitialisationAndMain, CODE, READONLY
	IMPORT	main

; (c) Mike Brady, 2014 -- 2019.

	EXPORT	start
start
; initialisation code
	LDR R12,= 0			;counter
	LDR R11,= 1			;determines colour
	ldr	r10,=IO0DIR
	ldr	r9,=0x00260000	;select P0.21, 0.18. 0.17
	str	r9,[r10]		;make them outputs
	ldr	r10,=IO0SET
	str	r9,[r10]		;set them to turn the LEDs off
	ldr	r9,=IO0CLR
; r10 points to the SET register
; r9 points to the CLEAR register

	
	


; Initialise the VIC
	ldr	r0,=VIC			; looking at you, VIC!

	ldr	r1,=irqhan
	str	r1,[r0,#VectAddr0] 	; associate our interrupt handler with Vectored Interrupt 0

	mov	r1,#Timer0ChannelNumber+(1<<IRQslot_en)
	str	r1,[r0,#VectCtrl0] 	; make Timer 0 interrupts the source of Vectored Interrupt 0

	mov	r1,#Timer0Mask
	str	r1,[r0,#IntEnable]	; enable Timer 0 interrupts to be recognised by the VIC

	mov	r1,#0
	str	r1,[r0,#VectAddr]   	; remove any pending interrupt (may not be needed)

; Initialise Timer 0
	ldr	r0,=T0			; looking at you, Timer 0!

	mov	r1,#TimerCommandReset
	str	r1,[r0,#TCR]

	mov	r1,#TimerResetAllInterrupts
	str	r1,[r0,#IR]

	ldr	r1,=(14745600/200)-1	 ; 5 ms = 1/200 second
	str	r1,[r0,#MR0]

	mov	r1,#TimerModeResetAndInterrupt
	str	r1,[r0,#MCR]

	mov	r1,#TimerCommandRun
	str	r1,[r0,#TCR]
	
self B self	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
blinkyProgramFirst
	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register

	ldr	r5,=0x00100000	; end when the mask reaches this value
wloop1	ldr	r3,=0x00010000	; start with P1.16.
floop	str	r3,[r2]	   	; clear the bit -> turn on the LED

;delay for about a half second
	ldr	r4,=4000000
dloop	subs	r4,r4,#1
	bne	dloop

	str	r3,[r1]		;set the bit -> turn off the LED
	mov	r3,r3,lsl #1	;shift up to next bit. P1.16 -> P1.17 etc.
	cmp	r3,r5
	bne	floop
	b	wloop1
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;RBG PROGRAM HERE
rgbProgramFirst	
	;R11 = 1 - red
	;	   2 - blue 
	;      3 - green
	LDR R4,= counterRGB
	LDR R5,[R4]
	MOV R12, R5
	ADD R12, R12, #100
wloop	
	; there are 200 of 5ms interrupts in a second, R12 incremented each time in interrupt handler
	LDR R5,[R4]
	CMP R12, R5
	BEQ updateColour
	B wloop
updateColour
	ADD R12, R12, #100
	ADD R11, R11, #1
	CMP R11, #4
	BLO display
	MOV R11, #1
display
	CMP R11, #1
	BEQ red
	CMP R11, #2
	BEQ blue
	CMP R11, #3
	BEQ green
red
	LDR R8,= 0x00260000
	STR R8,[R10]			; turn them all off
	LDR R8,= 0x00020000
	STR R8, [R9] 			; turn on red
	B wloop
blue
	LDR R8,= 0x00260000
	STR R8,[R10]			; turn them all off
	LDR R8,= 0x00040000
	STR R8, [R9] 			; turn on blue
	B wloop
green
	LDR R8,= 0x00260000
	STR R8,[R10]			; turn them all off
	LDR R8,= 0x00200000
	STR R8, [R9] 			; turn on green
	B wloop
;from here, initialisation is finished, so it should be the main body of the main program

	b	wloop  		; branch always
;main program execution will never drop below the statement above.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	AREA	InterruptStuff, CODE, READONLY
irqhan	sub	lr,lr,#4
	stmfd	sp!,{r0-r1,r4-r5,lr}	; the lr will be restored to the pc

;this is the body of the interrupt handler

;here you'd put the unique part of your interrupt handler
;all the other stuff is "housekeeping" to save registers and acknowledge interrupts


;this is where we stop the timer from making the interrupt request to the VIC
;i.e. we 'acknowledge' the interrupt
	ldr	r0,=T0
	mov	r1,#TimerResetTimer0Interrupt
	str	r1,[r0,#IR]	   	; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	ldr	r0,=VIC
	mov	r1,#0
	LDR R4,=counterRGB
	LDR R5,[R4]
	ADD R5,R5,#1
	STR R5,[R4]
	
	
	MSR _c 0x10			;change to user mode???
	STMFD SP!, {R0-R15 , LR}
	;boolean for which thread, load in other thread's SP
	LDR R2 ,= threadRunning
	LDR R4,[R2]
	CMP R4,#1
	BNE running2
	
	; if threadRunning = 1
	LDR R0,= thread2SP
	MOV R13, R0
	LDR R1,= thread2LR
	MOV R14, R1
	MOV R3 , #2
	STR R3, [R2]
	LDMFD SP!, {R0-R15, PC}
	B swapBackToIRQ

running2	
	; else if threadRunning == 2
	LDR R0,= thread1SP
	MOV R13, R0
	LDR R1,= thread1LR
	MOV R14, R1
	MOV R3 , #1
	STR R3, [R2]
	LDMFD SP!, {R0-R15, PC}^
	
swapBackToIRQ	
	MSR _c 0x13
	
	str	r1,[r0,#VectAddr]	; reset VIC
	ldmfd	sp!,{r0-r1,r4-r5,pc}^	; return from interrupt, restoring pc from lr
									; and also restoring the CPSR


	AREA	TestData, DATA, READWRITE
counterRGB DCD 0
firstRun DCB 0		; for first time execution

threadRunning DCB 0

thread1SP DCD 0
thread1LR DCD 0
thread2SP DCD 0
thread2LR DCD 0
	END