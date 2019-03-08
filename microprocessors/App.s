	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; calculator with input buttons

	EXPORT	start
start

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN  EQU 	0XE0028010
LONGPRESS EQU	5000000
	
	;LIST OF REGISTERS
	;R0 buttonNumber
	;R1 IO1DIR
	;R2 IO1SET
	;R3 IO1PIN
	;R5 inputNumber
	;R10 lastOperand => (1 = +)  |  (2 = -)
	;R11 operatorPressed
	
	MOV R0, #0					; R0 = total sum
	MOV R5, #0
	MOV R10, #0					; lastOperand = null 
	MOV R11, #0
	
	LDR R1,=IO1DIR					; R1 points to the SET register
	LDR R2,=0x000f0000				; select P1.19--P1.16
	STR R2,[R1]					; make them outputs
	LDR R1,=IO1SET
	STR R2,[R1]					; set them to turn the LEDs off
	LDR R2,=IO1CLR					; R2 points to the CLEAR register
	LDR R3,=IO1PIN		 			; R3 points to the PIN register


loop
	MOV R9, #0
	BL buttonRead
	CMP R9,#20
	BEQ pin20
	CMP R9,#21
	BEQ pin21
	CMP R9,#22
	BEQ operandPin
	CMP R9,#23
	BEQ operandPin
	CMP R9,#-22
	BEQ pin22Long
	CMP R9,#-23
	BEQ pin23Long


pin20							; add to inputNumber
	BL delay
	MOV R11, #0 					; operatorPressed = false;
	ADD R5, R5, #1					; inputNumber++
	;MOV R12, R5					; tmp = inputNumber
	;BL displayNumber				; display(tmp)
	B loop



pin21							; subtract from inputNumber
	BL delay
	MOV R11, #0 				; operatorPressed = false;
	SUB R5, R5, #1				; inputNumber--
	;MOV R12, R5					; tmp = inputNumber
	;BL displayNumber			; display(tmp)
	B loop



operandPin
	BL delay
	CMP R11, #1					; if(operandPressed == true)
	BEQ loop					;	do nothing - prevents spamming of the operands

	CMP R10,#0
	BEQ noOperand
	CMP R10,#1
	BEQ plus
	CMP R10,#2
	BEQ subtract
noOperand
	MOV R0,R5
	B noDisplay
plus
	ADD R0, R0, R5
	B display
subtract						
	SUB R0, R0, R5					
display	
	MOV R12, R0					
	BL displayNumber								
noDisplay
	MOV R11, #1							
	MOV R5, #0 					; reset inputNumber
	CMP R9, #22
	MOVEQ R10, #1
	CMP R9, #23
	MOVEQ R10, #2
	B loop						



pin22Long
	BL delay
	LDR R7,= 0x000f0000
	STR R7,[R1]
	
	MOV R5, #0
	MOV R9, #0
;	MOV R10, #0
	MOV R11, #0
	B loop
	
	
	
pin23Long
	BL delay
	LDR R7,= 0x000f0000
	STR R7,[R1]

	MOV R0, #0					; clear sum
	MOV R5, #0					; clear current number
	MOV R9, #0					
	MOV R10, #0					; operandPressed = false
	MOV R11, #0
	B loop
	
	
	
	B loop						; infinite loop	
stop	B	stop






; buttonRead subroutine
; returns number of button pressed, stored in R9
buttonRead
	STMFD SP!, {R4-R8,R10-R11 , LR}
	LDR R4,=0x00f00000
	
	
	
waitForPress
	LDR R5,[R3]					; load in IO1PIN
	AND R5, R5, R4					; isolate button bits
	CMP R5,R4					; if same, no button pressed
	BEQ waitForPress
	
	; button pressed
	MOV R6,#0					; counter = 0
	LDR R11 ,= LONGPRESS


pressedLoop
	LDR R7, [R3]					; R7 = IO1PIN
	AND R7, R7, R4					; isolate button bits
	ADD R6, R6, #1					; counter++
pressed 
	CMP R7, R4
	BNE pressedLoop					; button still pressed down
	
	; button released i.e R7 = 0x000f0000
	CMP	R5, #0x00700000
	MOVEQ	R9, #23
	CMP	R5, #0x00B00000
	MOVEQ	R9, #22
	CMP	R5, #0x00D00000
	MOVEQ	R9, #21
	CMP	R5, #0x00E00000
	MOVEQ	R9, #20
	
	; check if long press
	CMP R6, R11
	BLE notLong
	MVN R9,R9					; convert to 2s complement
	ADD R9, R9, #1
notLong
	LDMFD SP!, {R4-R8,R10-R11 , PC}



; displayNumber subroutine
; 	R1 = SET register
; 	R2 = CLEAR register
;	R12 = number to be displayed
;
displayNumber
	STMFD SP!,{R3,R12, LR}

	LDR R3,= 0x000f0000
	STR R3,[R1]

	;MOV R12, R12, LSL #16				; shift into LED bit positions
	BL reverse

	STR R12,[R2]	   				; clear the bit -> turn on the LED
	LDMFD SP!,{R3,R12, PC}

; delay subroutine
; just a timer
delay
	STMFD SP!,{R4, LR}
	;delay for about a half second
	LDR	R4,=5000000
timerLoop
	SUBS R4,R4,#1
	BNE	timerLoop

	LDMFD SP!,{R4, PC}


; bit reverse subroutine
; reverse the bits to be displayed
reverse
	STMFD SP!, {R4 - R6, LR}
	MOV R4, R12;
	MOV R5, #0
	MOV R6, #4
	
forReverse
	MOVS R4, R4, LSR #1
	LSL R5, #1
	ADC R5, R5, #0
	SUB R6, R6, #1
	CMP R6, #0
	BNE forReverse
	
	LSL R5, #16
	MOV R12, R5
	LDMFD SP!, {R4 - R6, PC}
	
	AREA	TestData, DATA, READWRITE
	
			
	END