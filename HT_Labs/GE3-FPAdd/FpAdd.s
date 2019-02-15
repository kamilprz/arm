	AREA	FpAdd, CODE, READONLY
	IMPORT	main
	EXPORT	start

start

	LDR	R0, =0xBF000000		; fpval1 = 0.5
	LDR	R1, =0xBE800000		; fpval2 = 0.4375
	
	BL	fpadd

stop	B	stop

; fpadd subroutine
; Adds two IEEE754 single precision floating point values
; Parameters:
;   R0: first floating point value
;   R1: second floating point value
; Return value:
;   R0: floating point result
;
fpadd
	STMFD sp!, {R4- R12, lr}
	MOV R8,R0
	MOV R10,R1
	MOV	R2, R0
	BL	getFraction
	;BL	checkSign					;commented this out because it didnt work when it wasnt commented
	MOV R4, R3
	BL	getExponent
	MOV	R5, R3
	
	MOV	R2, R1
	BL	getFraction
	;BL	checkSign					;same reason as above
	MOV	R6, R3
	BL	getExponent
	MOV	R7, R3
							
	CMP	R5, R7
	BEQ	addFractions
	CMP	R5, R7				;if R5 is higher than R7 (exponents)
	BLT	changeOtherExponent
	SUB	R9, R5, R7			;find difference between R5 and R7
	MOV	R6, R6, LSR R9		;shift the fraction R6 (with exponent R7) to the right by the difference to equal exponents
	ADD R7,R9,R7			;make exponents equal
	B	addFractions
changeOtherExponent
	SUB	R9, R7, R5
	MOV	R4, R4, LSR R9
	ADD R5,R9,R5			;make exponents equal - important for later
addFractions	
	ADD R0, R4, R6			;adds 2 fractions of equal exponent	
	BL	countLeadingZeros	;checks if normalised form, normalises if not
	
	LDR R12,=0xFF7FFFFF		;mask to clear hidden one
	AND R0,R12,R0			;clear the hidden one
	ADD R5,R5,#0x7F			;exponent = exponent +127
	MOV R5,R5,LSL#23		;shift left by 23
	ORR R0,R0,R5			;add to fraction
	
	MOVS R8, R8, LSL #1		;check if R0 is negative
	BCC endAdd
	MOVS R10, R10, LSL#1	;check if R1 is negative
	BCC endAdd
	LDR R12,=0x80000000		;if theyre both negative, sets 1 as the msb
	ORR R0,R0,R12
endAdd
	
	
	LDMFD	sp!, {R4- R12, pc}
	

getFraction
	STMFD sp!, {R4, lr}
	
	LDR R4, =0x007FFFFF		;mask for isolating fraction

	AND R3, R4, R2			;isolate fraction
	MOV	R4, #0x00800000		
	ORR	R3, R3, R4			;add back missing 1
	
	LDMFD sp!, {R4, pc}
	

getExponent
	STMFD sp!, {R4, lr}
	
	LDR	R4, =0x7F800000		;mask for isolating exponent
	AND	R3, R4, R2			;isolate exponent
	MOV	R3, R3, LSR #23		;get rid of 0's on the right side
	SUB	R3, R3, #0x7F		;exponent= exponent-127
	
	LDMFD sp!, {R4, pc}


countLeadingZeros
	STMFD	sp!, {R4,R7-R9, lr}
	LDR R7,=8
	MOV	R4, #0				;counterOfZeros
	MOV R8,R0				;move R0 to external register

loop
	MOVS R8,R8,LSL #1		;shift tmp R0 value left until carry set
	BCS shiftRight				
	ADD R4,R4,#1			;counterOfZeros++
	B loop
shiftRight
	SUB R9,R7,R4			;(8-counterOfZeros) = how much we need to shift right by to have desired 8 starting 0s
	MOV R0,R0,LSR R9		;shift right by (8-counterOfZeros)
	ADD R5,R5,R9			;update the exponent accordingly
	
	
	LDMFD	sp!, {R4,R7-R9, pc}


;Subroutine	
checkSign
	STMFD	sp!, {R5 ,lr}

	MOVS	R5, R2, LSL #1
	BCC	endCheck
	
	MVN	R3, R3
	ADD R3, R3, #1
	
endCheck
	LDMFD	sp!, {R5, pc}

	END