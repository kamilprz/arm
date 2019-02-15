	AREA	Unique, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR R0, =1		; isUnique = true;
	LDR	R6, =VALUES	 ; CONSTANT 
	LDR R7, =VALUES	 ; TEMP	
	LDR R4, =COUNT	 ; count
	LDR R4, [R4]
	LDR R1, =VALUES	 ; TEMP
	LDR R10, =0		; encounterCount = 0;
	
	LDR R2, =0	;i
	LDR R3, =0	; j
outerloop
	CMP R2, R4	; for(int i = 0; i < A.size; i++) 
	BEQ endouterloop
	LDR R5, [R1]	; elemA = A[i];
innerloop
	CMP R3, R4
	BEQ endinnerloop
	LDR R8, [R7]	; elem2 = A[j];
	CMP R5, R8
	BNE endif 		; if(elemA == elem2)
	ADD R10, R10, #1;     encounterCount++
endif
	CMP R10, #2		; if the same number is encountered more than once
	BLO endif2		; then we know the number occurs twice so it is not a unique set
	MOV R0, #0		; isUnique = false;
endif2
	ADD R3, R3, #1 	; j++
	ADD R7, R7, #4	; elem2Address += 4
	B innerloop
endinnerloop
	MOV R7, R6
	ADD R2, R2, #1	; i++
	ADD R1, R1, #4	; elemAAddress += 4
	MOV R3, #0 		; reset j = 0
	MOV R10, #0		; reset encounterCount = 0
	B outerloop
endouterloop
	

	
stop	B	stop


	AREA	TestData, DATA, READWRITE
	
COUNT	DCD	10
VALUES	DCD	5, 2, 7, 4, 13, 4, 18, 8, 9, 12


	END	