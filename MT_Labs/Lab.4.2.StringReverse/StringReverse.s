	AREA	StringReverse, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR R0, =0
	LDR	R1, =strSrc
	LDR	R2, =strDst
	MOV R4, R1	; address of 1st char
	MOV R5, R2	; address of where to store 1st char
while
	LDRB R3, [R4]	; current_char = Memory.byte[address]
	CMP R3, #0x00	; while(current_char != 0)
	BEQ endwhile	;     
	ADD	R0, R0, #1  ;    length++
	ADD R4, R4, #1	; 	 adr++
	B 	while
endwhile
	SUB R4, R4, #1

whilecopy
	CMP R4, R1
	BLO	endwhcopy
	LDRB R6, [R4]	; LAST CHAR 'O'
	STRB R6, [R5]	
	ADD R5, R5, #1
	SUB R4, R4, #1
	B 	whilecopy
endwhcopy
stop	B	stop


	AREA	TestData, DATA, READWRITE


strSrc	DCB	"hello",0
strDst	SPACE	128

	END	