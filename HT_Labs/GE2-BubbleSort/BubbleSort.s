	AREA	BubbleSort, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R0, =testarr
	LDR R1,=1					;index
	LDR	R5, =N					;size of array
	LDR R7,=0 					;boolean swapped=false;
	BL 	sort


sort
;sorts the array in increasing order
;PARAMETERS:
;			R1=	index in array (i)
;			R2= i-1
;			R3= array[i]
;			R4= array[i-1]
;			R5=size of the array
;			R7= boolean swapped

while	
	LDR R7,=0 					;reset the boolean
	LDR R1,=1					;i=1
for
	CMP R1,R5
	BHS endFor
	SUB	R2,R1,#1 				;i-1
	LDR R3, [R0,R2,LSL#2]
	LDR R4, [R0,R1,LSL#2]
	CMP R3,R4
	BLS	dontSwap 
	BL swap
dontSwap	
	ADD R1,R1,#1
	B for
endFor	
	CMP R7,#0
	BEQ endWhile
	B while
endWhile	
stop	B	stop	



swap	
;swaps components i and j in an array
;PARAMETERS:
;			R0=array start address
;			R1=	i
;			R2=j
;			R6=tmp
	STMFD	SP!, {R0,R3,R4,LR}
	STR		R4,[R0,R2,LSL#2]
	STR 	R3,[R0,R1,LSL#2]
	LDR 	R7,=1				;boolean swap =true
	LDMFD 	SP!, {R0,R3,R4,PC}



	



	AREA	TestData, DATA, READWRITE
N	EQU	10
testarr	DCD	3,9,2,1,8,0,7,4,9,6
	END