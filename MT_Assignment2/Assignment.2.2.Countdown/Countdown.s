	AREA	Countdown, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R1, =cdWord			;Load start address of word
	LDRB R3,[R1]			;R3 = letter of word
	LDR R0,=0 				;canBeFormed=false;
	LDR R5,='!'
	
;CHECKS IF THERES 9 LETTERS IN THE GIVEN LIST	
	LDR	 R2, =cdLetters		;Load start address of list
	LDRB R4,[R2]			;R4 = first letter of list
	LDR R6,=0 				;counter=0
while4
	CMP R4,#0				;while(letter!=0)
	BEQ endwhile4			;{
	ADD R6,R6,#1			;counter++
	ADD R2,R2,#1 			;adrB++
	LDRB R4,[R2]			;BElem=Memory.Word(adrB)
	B while4				;}
endwhile4
	CMP R6,#9				;if(counter!=9)
	BNE stop				;end program
	
;COMPARES LETTERS FROM WORD TO LETTERS FROM LIST	
while
	CMP  R3,#0				;while(letter of word != 0)
	BEQ endwhile			;{
	LDR	 R2, =cdLetters		; 	Load start address of list
	LDRB R4,[R2]			;	R4 = first letter of list
while2						;	while(letter from list !=0)
	CMP  R4,#0				;	{
	BEQ endwhile2
	CMP  R3,R4
	BNE endEqual			;		if(letter from word = letter from list)
equal						;		{
	STRB R5,[R1]			;		letter from word=!
	STRB R5,[R2]			;		letter from list=!
	B endwhile2
endEqual					;		}
	ADD R2,R2,#1 			;	adrB++
	LDRB R4,[R2]			;	BElem=Memory.Word(adrB)
	B while2				;	}
endwhile2
	ADD R1,R1,#1			;adrA++
	LDRB R3,[R1]			;AElem=Memory.Word(adrA)
	B while					;}
endwhile					

;CHECKS WHETHER EVERY LETTER IS MATCHED; AKA SETS R0

	LDR	R1, =cdWord			;Load start address of word
	LDRB R3,[R1]			;R3 = letter of word
while3
	CMP R3,#0				;while(letter from word!=0)
	BEQ endwhile3			;{
	CMP R3,#'!'				;	if(letter from word != '!')
	BEQ endCantBeFormed		;	{	
cantBeFormed			
	LDR R0,=0				;	R0 set to false	
	B stop					; 	program ends
endCantBeFormed				;	}
	LDR R0,=1				;R0 set to true
	ADD R1,R1,#1			;adrA++
	LDRB R3,[R1]			;AElem=Memory.Word(adrA)
	B while3				;}
endwhile3
	
stop	B	stop



	AREA	TestData, DATA, READWRITE
	
cdWord
	DCB	"beets",0

cdLetters
	DCB	"daetebzs",0
	
	END	
