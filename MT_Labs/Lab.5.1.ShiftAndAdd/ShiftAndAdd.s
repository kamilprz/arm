	AREA	ShiftAndAdd, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R1, =9
	LDR	R2, =10
	MOV R0, #0		; result = 0
	LDR R3, =0		; count = 0
	MOV R4, R1		; tmp = value
while
	CMP R4, #0		;while( tmp != 0)
	BEQ endwh		; {
	MOVS R4, R4, LSR #1; tmp = tmp >> 1
	BCC endif			; if(carry) {
	MOV R5, R2, LSL R3	;		result += (value << count)
	ADD R0, R0, R5		; }
endif					; count++
	ADD R3, R3, #1
	B while				;}
endwh
	; your program goes here

	
stop	B	stop


	END	
	