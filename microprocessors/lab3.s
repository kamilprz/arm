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
	;R5 input number
	;R10 lastOperand => (1 = +)  |  (2 = -)
	;R11 operatorPressed
	;R12 tmp copy of either R0 or R5 depending on what needs to be displayed
	
	MOV R0, #0					; R0 = total sum
	MOV R10, #0
	
	LDR	R1,=IO1DIR				; R1 points to the SET register
	LDR	R2,=0x000f0000			; select P1.19--P1.16
	STR	R2,[R1]					; make them outputs
	LDR	R1,=IO1SET
	STR	R2,[R1]					; set them to turn the LEDs off
	LDR	R2,=IO1CLR				; R2 points to the CLEAR register
	
	LDR R3,=IO1PIN		 		; R3 points to the PIN register
								

loop
	MOV R4, R3					; make copy of IO1PIN ------ maybe have this line before each check if too slow
	MOVS R4, R4, LSR #20	
	BCC pin20					; carry clear, meaning pin20 pressed
	MOVS R4, R4, LSR#1
	BCC pin21					; pin21 pressed           ( 0 if pressed , 1 if not)
	MOVS R4, R4, LSR#1
	BCC pin22					; pin22 pressed
	MOVS R4, R4, LSR#1
	BCC pin23					; pin23 pressed
	B loop
	

pin20							; add to number button
	MOV R11, #0 				; operatorPressed = false;
	ADD R5, R5, #1
	MOV R12, R5
	BL displayNumber
	B loop

pin21							; subtract from number button
	MOV R11, #0 				; operatorPressed = false;
	SUB R5, R5, #1
	MOV R12, R5
	BL displayNumber
	B loop

pin22							; plus operand
	CMP R11, #1					; if(operandPressed == true)
	BEQ loop					;	break
	MOV R10, #1					; lastOperand = +
	ADD R0, R0, R5
	MOV R12, R0
	BL displayNumber
	MOV R11, #1					; operandPressed = true;
	MOV R6, R5					; copy of last entered number (for clear)
	MOV R5, #0 					; reset input number
	B loop

pin23							; minus operand									
	CMP R11, #1					; if(operandPressed == true)
	BEQ loop					;	break;
	MOV R10, #2					; lastOperand = -
	SUB R0, R0, R5		
	MOV R12, R0
	BL displayNumber
	MOV R11, #1					; operandPressed = true;
	MOV R6, R5					; copy of last entered number (for clear)
	MOV R5, #0 					; reset input number
	B loop

pin22Long
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
								;delay for about a half second
	LDR	R4,=4000000
timerLoop1
	SUBS R4,R4,#1
	BNE	timerLoop1

	LDMFD SP!,{R3, R4, PC}




; reverseBits subroutine
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
		MOV R12, #0
		AND R12, R12, R7			; join back all isolated bits
		AND R12, R12, R9
		AND R12, R12, R10
		AND R12, R12, R11
	LDMFD SP!, {R6-R11 ,PC}
	
	AREA	TestData, DATA, READWRITE
	
			
	END