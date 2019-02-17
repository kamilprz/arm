	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2011 -- 2019.

	EXPORT	start
start

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C

	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000			;select P1.19--P1.16
	str	r2,[r1]					;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]					;set them to turn the LEDs off
	ldr	r2,=IO1CLR
								; r1 points to the SET register
								; r2 points to the CLEAR register
								
goAgain

	LDR R0 ,= number
	BL checkSign				; branch to checkSign subroutine
	MOV R10,#10					; R10 = 10
	
	; Finding how many digits the number stored in R0 has.
	LDR R12, =1 				; denominator
	LDR R11, =0 				; quotient
	; Calculates the greatest power of 10 that fits into the number, i.e finds the amount of digits
	; This is then used as index in the table
countDigits
	CMP R12, R0 				; while(denominator<number) 
	BHI endCountDigits 			; (if denominator is greater than number branch to endCountDigits){
	ADD R11,R11,#1 				; 	quotient += 1   
	MUL R12,R10,R12				; 	denominator = denominator x 10
	B countDigits				; } 
endCountDigits	
	; R11 = number of digits
	SUB R11, R11, #1			; index for table = #(digits) - 1
	
	MOV R12,#0					; index in table
	MOV R9,#0					; counter
	MOV R8,#4					; R8 = 4
	LDR R7 ,= table
	MUL R12, R11, R8
	ADD R12, R7, R12
	
nextDigit
	MOV R9,#0					; counter
	LDR R6, [R12]				; R6 = table[index]
	
loop
	CMP R0, #0					; if(number == 0)
	BEQ displayLast
	CMP R0, R6					; if(number < maxPowerOfTen)
	BLO endLoop
	SUB R0,R0,R6				; number=number-maxPowerOfTen
	ADD R9,R9,#1				; counter++
	B loop
endLoop
	SUB R12, R12, #4			; index -= 4
	BL displayDigit				; branch to displayDigit subroutine
	B nextDigit
displayLast						; display the last digit
	BL displayDigit				; branch to displayDigit subroutine
	
	B goAgain
stop	B	stop



; checkSign subroutine
;	R0 = number
; 	R1 = SET register
; 	R2 = CLEAR register
;
checkSign
	STMFD SP!,{R3,R4,R6,LR}
	MOV R6,R0					; make copy of number
	MOVS R6, R6, LSL#1			; shift left by 1 bit
	BCC positive				; if carry clear -> positive number		- = 1011
	SUB R0,R0,#1				; if carry set -> negative number		+ = 1010
	MVN R0,R0					; subtract 1 and invert bits, to convert from 2s complement
	LDR R3,=0x000B0000
	B displaySign
positive
	LDR R3,=0x000A0000
	
displaySign	
	STR	R3,[R2]	   				; clear the bit -> turn on the LED
								;delay for about a half second
	LDR	R4,=4000000
timerLoop
	SUBS R4,R4,#1
	BNE	timerLoop
	
	LDMFD SP!,{R3,R4,R6,PC}



; displayDigit subroutine
; 	R1 = SET register
; 	R2 = CLEAR register
;	R9 = digit to be displayed
;
displayDigit
	STMFD SP!, {R3,R4 ,LR}
	; switch statement to figure out which digit to display
	CMP R9,#0					
	BNE compare1
	LDR R3,=0x000F0000			; R9 == 0	(0 = 1111)
	B displayDigitLED
compare1		
	CMP R9,#1
	BNE compare2
	LDR R3,=0x00010000			; R9 == 1
	B displayDigitLED
compare2
	CMP R9,#2
	BNE compare3
	LDR R3,=0x00020000			; R9 == 2
	B displayDigitLED
compare3
	CMP R9,#3
	BNE compare4
	LDR R3,=0x00030000			; R9 == 3
	B displayDigitLED
compare4
	CMP R9,#4
	BNE compare5
	LDR R3,=0x00040000			; R9 == 4
	B displayDigitLED
compare5
	CMP R9,#5
	BNE compare6
	LDR R3,=0x00050000			; R9 == 5
	B displayDigitLED
compare6
	CMP R9,#6
	BNE compare7
	LDR R3,=0x00060000			; R9 == 6
	B displayDigitLED
compare7
	CMP R9,#7
	BNE compare8
	LDR R3,=0x00070000			; R9 == 7
	B displayDigitLED
compare8
	CMP R9,#8
	BNE compare9
	LDR R3,=0x00080000			; R9 == 8
	B displayDigitLED
compare9
	CMP R9,#9
	BNE endCompare
	LDR R3,=0x00090000			; R9 == 9
	B displayDigitLED
endCompare
	LDR R3,=0x000E0000			; R9 == ERROR  (ERROR = 1110)
displayDigitLED	
	STR	R3,[R2]	   				; clear the bit -> turn on the LED
								;delay for about a half second
	LDR	R4,=4000000
timerLoop1
	SUBS R4,R4,#1
	BNE	timerLoop1
		
;	str	r3,[r1]					;set the bit -> turn off the LED
	LDMFD SP!,{R3,R4,PC}

	
	
	AREA	TestData, DATA, READWRITE
	
number	EQU	-1049	; number to be tested

table 	DCD 1
		DCD	10
		DCD	100
		DCD	1000
		DCD	10000
		DCD	100000
		DCD	1000000
		DCD	10000000
		DCD	100000000
		DCD 1000000000
			
	END