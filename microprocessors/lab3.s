	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; calculator with input buttons

	EXPORT	start
start

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN  EQU 0XE0028010
	
	;LIST OF REGISTERS
	;R0 sum
	;R1 IO1DIR
	;R2 IO1SET
	;R3 IO1PIN
	;R4 copy IO1PIN
	;R5 inputNumber
	;R10 lastOperand => (1 = +)  |  (2 = -)
	;R11 operatorPressed
	;R12 tmp copy of either R0 or R5 depending on what needs to be displayed
	
	MOV R0, #0					; R0 = total sum
	MOV R10, #0					; lastOperand = null 
	
	LDR	R1,=IO1DIR				; R1 points to the SET register
	LDR	R2,=0x000f0000			; select P1.19--P1.16
	STR	R2,[R1]					; make them outputs
	LDR	R1,=IO1SET
	STR	R2,[R1]					; set them to turn the LEDs off
	LDR	R2,=IO1CLR				; R2 points to the CLEAR register
	
	LDR R3,=IO1PIN		 		; R3 points to the PIN register
								


loop
	MOV R4, R3					; make copy of IO1PIN ------ maybe have this line before each check if too slow
	MOVS R4, R4, LSR #21	
	BCC pin20					; pin20 ( 0 if pressed , 1 if not)
	MOVS R4, R4, LSR#1
	BCC pin21					; pin21
	MOVS R4, R4, LSR#1
	BCC pin22					; pin22 short press
	MOVS R4, R4, LSR#1
	BCC pin23					; pin23 short press
	B loop
	


pin20							; add to inputNumber
	BL delay
	MOV R11, #0 				; operatorPressed = false;
	ADD R5, R5, #1				; inputNumber++
	MOV R12, R5					; tmp = inputNumber
	BL displayNumber			; display(tmp)
	B loop



pin21							; subtract from inputNumber
	BL delay
	MOV R11, #0 				; operatorPressed = false;
	SUB R5, R5, #1				; inputNumber--
	MOV R12, R5					; tmp = inputNumber
	BL displayNumber			; display(tmp)
	B loop



pin22							; plus operand
	BL delay
	MOV R4, R3					; make copy of IO1PIN ------ maybe have this line before each check if too slow
	MOVS R4, R4, LSR #23
	BCC pin22Long
	
	CMP R11, #1					; if(operandPressed == true)
	BEQ loop					;	do nothing - prevents spamming of the operands
								; else{ 
	ADD R0, R0, R5				; 	sum = sum + inputNumber
	MOV R12, R0					; 	tmp = sum
	BL displayNumber			; 	display(tmp)
	MOV R10, #1					; 	lastOperand = + (for clear)
	MOV R11, #1					; 	operandPressed = true;
	MOV R6, R5					; 	copy of last entered number (for clear)
	MOV R5, #0 					; 	reset input number
	B loop						; }	



pin23							; minus operand
	BL delay
	MOV R4, R3					; make copy of IO1PIN ------ maybe have this line before each check if too slow
	MOVS R4, R4, LSR #24
	BCC pin23Long

	CMP R11, #1					; if(operandPressed == true)
	BEQ loop					;	do nothing - prevents spamming of the operands
								; else{
	SUB R0, R0, R5				; 	sum = sum - inputNumber				
	MOV R12, R0					;	tmp = sum
	BL displayNumber			;	display(tmp)
	MOV R10, #2					; 	lastOperand = - (for clear)
	MOV R11, #1					; 	operandPressed = true;
	MOV R6, R5					; 	copy of last entered number (for clear)
	MOV R5, #0 					; 	reset input number
	B loop						; }



pin22Long
	BL delay
	CMP R10,#0					; no operands, do nothing
	BEQ loop	
	CMP R10,#1					; if(lastOperand == +)
	BNE minus					
	SUB R0,R0,R6				; to clear + and last number
	MOV R5, #0					; subtract that number from sum and clear it
	MOV R6, #0
	MOV R10,#0					; lastOperand = null
	MOV R11,#0					; operandPressed = false
	B loop
minus
	ADD R0,R0,R6
	MOV R5, #0					; subtract that number from sum and clear it
	MOV R6, #0
	MOV R10,#0					; lastOperand = null
	MOV R11,#0					; operandPressed = false
	B loop
	
	
	
pin23Long
	BL delay
	MOV R0, #0					; clear sum
	MOV R5, #0					; clear current number
	MOV R11, #0					; operandPressed = false
	B loop

	B loop						; infinite loop
	
stop	B	stop



; displayNumber subroutine
; 	R1 = SET register
; 	R2 = CLEAR register
;	R12 = number to be displayed
;
displayNumber
	STMFD SP!,{R3,R4, LR}
	
	LDR R3,= 0x000F0000
	STR R3,[R1]					; turn off previous LEDS???

	MOV R12, R12, LSL #20		; shift into LED bit positions
	BL reverseBits

	STR	R12,[R2]	   			; clear the bit -> turn on the LED

	LDMFD SP!,{R3, R4, PC}



; delay subroutine
delay
	STMFD SP!,{R4, LR}
	;delay for about a half second
	LDR	R4,=5000000
timerLoop
	SUBS R4,R4,#1
	BNE	timerLoop

	LDMFD SP!,{R4, PC}



; reverseBits subroutine
;	need to reverse them for the LEDs to display them in the right order
; 	essentially the subroutine isolates each bit, shifts to the correct position and merges them all back into one
;	R12 = number to reverse
;	returns a reversed R12 (the 4 bits that matter)
reverseBits
	STMFD SP!, {R6-R11 ,LR}
		LDR R6,= 0x00080000			; mask for msb
		LDR R8,= 0x00010000			; mask for lsb
		AND R7 , R6, R12			
		AND R9 , R8, R12			
		MOV R7 , R7, LSR #2			; swap mbs and lsb
		MOV R9 , R9, LSL #2
		LDR R6,= 0x00040000			; mask for bit 3
		LDR R8,= 0x00020000			; mask for bit 2
		AND R10, R6, R12
		AND R11, R8, R12
		MOV R10, R10, LSR #1		; swap bit 2 and 3
		MOV R11, R11, LSL #1
		MOV R12, #0					; set R12 to all 0s
		AND R12, R12, R7			; join back all isolated bits into R12
		AND R12, R12, R9
		AND R12, R12, R10
		AND R12, R12, R11
	LDMFD SP!, {R6-R11 ,PC}
	
	AREA	TestData, DATA, READWRITE
	
			
	END