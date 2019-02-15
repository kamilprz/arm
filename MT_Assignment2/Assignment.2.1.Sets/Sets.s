	AREA	Sets, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR R1,=ASize
	LDR R1,[R1]
	LDR R2,=AElems
	LDR R3,[R2]
	LDR R4,=BSize
	LDR R4,[R4]
	LDR R8,=CElems
	LDR R10,=CSize
	LDR R11,=0 			;CSize=0
	
; COMPARING SET A TO B
while		
	CMP R1,#0			;while(ASize!=0)
	BEQ endwhile		;{
	LDR R12,=0			;areEqual=false
	MOV R7,R4   		;move BSize into a temp register, reset every loop
	LDR R5,=BElems		
	LDR R6,[R5]			;BElem=Memory.Word(adrB)
while2 
	CMP R7,#0			;	while(BSizeTmp!=0)
	BEQ endwhile2		;	{
	CMP R3,R6			;		if(AElem==BElem)
	BNE endAreEqual		;		{
areEqual
	LDR R12,=1			;		areEqual=true
	B endwhile2			;		}
endAreEqual				
	SUB R7,R7,#1		;	BSizeTmp--
	ADD R5,R5,#4		;	adrB++
	LDR R6,[R5]			;	BElem=Memory.Word(adrB)
	B while2			;	}
endwhile2
	CMP R12,#1			;if(!areEqual)
	BEQ dontAddToC
	STR R3,[R8]			;store AElem in C
	ADD R8,R8,#4		;adrC++
	ADD R11,R11,#1		;CSize++
	STR R11,[R10]
dontAddToC	
	SUB R1,R1,#1		;ASize--
	ADD R2,R2,#4		;adrA++
	LDR R3,[R2]
	B while				;}
endwhile


; COMPARING SET B TO A
	LDR R1,=ASize
	LDR R1,[R1]
	LDR R2,=AElems
	LDR R3,[R2]
	LDR R4,=BSize
	LDR R4,[R4]
	LDR R5,=BElems		
	LDR R6,[R5]			;BElem=Memory.Word(adrB)
while3		
	CMP R4,#0			;while(BSize!=0)
	BEQ endwhile3		;{
	LDR R12,=0			;areEqual=false
	MOV R7,R1   		;move ASize into a temp register, reset every loop
	LDR R2,=AElems		
	LDR R3,[R2]			;AElem=Memory.Word(adrA)
while4
	CMP R7,#0			;while(ASizeTmp!=0)
	BEQ endwhile4		;{
	CMP R6,R3			;	if(AElem==BElem)
	BNE endAreEqual1		;	{
areEqual1
	LDR R12,=1			;		areEqual=true
	B endwhile4			;	}
endAreEqual1				
	SUB R7,R7,#1		;ASizeTmp--
	ADD R2,R2,#4		;adrA++
	LDR R3,[R2]			;AElem=Memory.Word(adrA)
	B while4			;}
endwhile4
	CMP R12,#1			;if(!areEqual)
	BEQ dontAddToC1
	STR R6,[R8]			;store BElem in C
	ADD R8,R8,#4		;adrC++
	ADD R11,R11,#1		;CSize++
	STR R11,[R10]
dontAddToC1	
	SUB R4,R4,#1		;BSize--
	ADD R5,R5,#4		;adrB++
	LDR R6,[R5]			;BElem=Memory.Word(adrB)
	B while3				;}
endwhile3
stop	B	stop


	AREA	TestData, DATA, READWRITE
	
ASize	DCD	8			; Number of elements in A
AElems	DCD	4,6,2,13,19,7,1,3	; Elements of A

BSize	DCD	6			; Number of elements in B
BElems	DCD	13,9,1,9,5,8		; Elements of B

CSize	DCD	0			; Number of elements in C
CElems	SPACE	56			; Elements of C

	END	
