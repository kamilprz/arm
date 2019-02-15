	AREA	AsciiValue, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R4, ='2'	; Load '2','0','3','4' into R4...R1
	LDR	R3, ='0'	;
	LDR	R2, ='3'	;
	LDR	R1, ='4'	;
	
	; your program goes here
	SUB R5, R4, 0x30 	; r5= 2(DEC)
	SUB R6, R3, 0x30 	; r6 = 0 (dec)
	SUB R7, R2, 0x30 	; r7 = 3 (dec)
	SUB R8, R1, 0x30 	; r8 = 4 (dec)
	
	LDR R9 , =1000
	LDR R10, = 100
	LDR R11, = 10
	
	MUL R5, R9, R5	; R5 = 2000
	MUL R6, R10, R6 ; R6 = 0
	MUL R7, R11, R7 ; R7 = 30
	
	ADD R0, R5, R6
	ADD R0, R0, R7
	ADD R0, R0, R8 ; R0 = 2034
	
stop	B	stop

	END	