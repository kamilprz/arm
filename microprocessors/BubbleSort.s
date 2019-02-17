	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2011 -- 2019.

	EXPORT	start
start
	LDR R0 ,= number
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
	BL displayDigit
	B nextDigit
displayLast
	BL displayDigit
stop	B	stop








;;;;;;;;;;; LAB 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;IO1DIR	EQU	0xE0028018
;IO1SET	EQU	0xE0028014
;IO1CLR	EQU	0xE002801C

;	ldr	r1,=IO1DIR
;	ldr	r2,=0x000f0000				;select P1.19--P1.16
;	str	r2,[r1]						;make them outputs
;	ldr	r1,=IO1SET
;	str	r2,[r1]						;set them to turn the LEDs off
;	ldr	r2,=IO1CLR
;									; r1 points to the SET register
;									; r2 points to the CLEAR register

;	ldr	r5,=0x00100000				; end when the mask reaches this value
;wloop	
;	ldr	r3,=0x00010000			; start with P1.16.
;floop	
;	str	r3,[r2]	   				; clear the bit -> turn on the LED

;									;delay for about a half second
;	ldr	r4,=4000000
;dloop	
;	subs r4,r4,#1
;	bne	dloop

;	str	r3,[r1]						;set the bit -> turn off the LED
;	mov	r3,r3,lsl #1				;shift up to next bit. P1.16 -> P1.17 etc.
;	cmp	r3,r5
;	bne	floop
;	b	wloop
	
	

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