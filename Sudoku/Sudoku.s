	AREA	Sudoku, CODE, READONLY
	EXPORT	start


	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start
 	LDR		R4, =1
testStageOne
 	CMP		R4, #9
 	BGT	testStageTwo
	LDR		R0, =testGridOne
	STRB 	R4, [R0]
	LDR		R1, =0
 	LDR		R2, =0
	MOV 	R10,R4
	BL	isValid
	ADD		R4, R4, #1	; put a break point here - only 1 should be valid
	B	testStageOne

testStageTwo
	LDR		R0, =testGridTwo
	LDR		R1, =0
	LDR		R2, =0
	BL	sudoku
	LDR		R0, =testGridTwo
	LDR		R1, =testSolutionTwo
	BL	compareGrids

testStageThree
	LDR		R0, =testGridThree
	LDR		R1, =0
	LDR		R2, =0
	BL	sudoku
	LDR		R0, =testGridThree
	LDR		R1, =testSolutionThree
	BL	compareGrids

stop	B	stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



compareGrids
	STMFD	sp!, {R4-R6, LR}
	LDR		R4, =0
forCompareGrids
	CMP		R4, #(9*9)
	BGE	endForCompareGrids
	LDRB	R5, [R0, R4]
	LDRB	R6, [R1, R4]
	CMP		R5, R6
	BNE	endForCompareGrids
	ADD		R4, R4, #1
	B	forCompareGrids
endForCompareGrids

	CMP		R4,#(9*9)
	BNE	elseCompareGridsFalse
	MOV		R0, #1
	B	endIfCompareGridsTrue
elseCompareGridsFalse
	MOV		R0, #0
endIfCompareGridsTrue
	LDMFD	sp!, {R4-R6, PC}





; getSquare subroutine
;			R1= row
;			R2= column
;			R8= returned value stored in a register
getSquare
	STMFD 	SP!,{R3,R5,LR}
	LDR 	R3,=9				;length of row
	MUL 	R5,R1,R3			;index= <index> = (<row>x<row size>) + <column>
	ADD 	R5,R5,R2			;R5= index
	LDRB 	R8,[R0,R5,LSL#0]	;R8=grid[row][column]
	LDMFD 	SP!,{R3,R5,PC}




; setSquare subroutine
;			R1= row
;			R2= column
;			R10= value to store
setSquare
	STMFD 	SP!,{R3,R5,LR}
	LDR 	R3,=9				;length of row
	MUL 	R5,R1,R3			;index= <index> = (<row>x<row size>) + <column>
	ADD 	R5,R5,R2			;R5= index
	STRB 	R10,[R0,R5,LSL#0]	;grid[row][column]=R10
	LDMFD 	SP!,{R3,R5,PC}



; isValid subroutine
;			R1= row
;			R2= column
;			R4= start address of select 3x3 box
;			R5= index
;			R6= tmp row
;			R7= tmp value to be compared against R8
;			R8= grid[row][column]
;			R9= boolean isValid
;			R10= encounterCount
;			R11= tmp column
;			R12= tmp index
isValid
	STMFD 	SP!,{R0-R4,R6-R8,R10-R12,LR}
	LDR 	R9,=1				;isValid=true
	LDR 	R3,=9				;length of row
	BL 		getSquare			;R8=value to be compared
	
	
;checks if passed number appears only once in its row
	LDR 	R12,=0				;tmp index
	LDR 	R11,=0				;tmp column
	LDR 	R10,=0				;encounterCount
loop
	CMP		R11,#9				;for(int tmpColumn=0; tmpColumn<MAX_COLUMN; tmpColumn++){
	BEQ		endLoop				;
	MUL 	R12,R1,R3			;	R12=tmpIndex
	ADD 	R12,R12,R11			;	
	LDRB 	R7,[R0,R12,LSL#0]	;	tmpValue= grid[row][tmpColumn]
	CMP 	R7,#0				;	if(tmpValue!=0){		
	BEQ		endif2				;			
	CMP		R8,R7				;		if(value==tmpValue){
	BNE 	endif				;
	ADD 	R10,R10,#1			;			encounterCounter++
endif							;		}
	CMP 	R10,#2				;	}
	BNE		endif2				;	if(encounterCounter==2){
	LDR 	R9,=0				;		isValid=false
	B 		end1				;	}
endif2
	ADD 	R11,R11,#1			;			
	B 		loop				;}
endLoop
		
		
;checks if passed number appears only once in its column
	LDR 	R12,=0				;tmp index
	LDR 	R6,=0				;tmp row=0
	LDR 	R10,=0				;encounterCount=0
loop2
	CMP		R6,#9				;for(int tmpRow=0; tmpRow<MAX_ROW; tmpRow++){
	BEQ		endLoop2			;
	MUL 	R12,R6,R3			;	R12=index
	ADD 	R12,R12,R2			;
	LDRB 	R7,[R0,R12,LSL#0]	;	tmpValue=grid[tmpRow][column]
	CMP 	R7,#0				;	if(tmpValue!=0){
	BEQ		endif4				
	CMP		R8,R7				;		if(value==tmpValue){
	BNE 	endif3
	ADD 	R10,R10,#1			;			encounterCounter++
endif3							;		}
	CMP 	R10,#2				;	}
	BNE		endif4				;	if(encounterCount==2){
	LDR 	R9,=0				;		isValid=false
	B		end1				;	}
endif4
	ADD 	R6,R6,#1
	B 		loop2				;}
endLoop2


;checks if passed number appears only once in its 3x3 box
;first need to find which 3x3 box it is

	MOV R4,R0					;as to not alter R0 directly
	CMP R1,#2					;if(row<=2)
	BLS case1					;	first row of 3x3 boxes
	CMP	R1,#5					;else if(row<=5)
	BLS	case2					; 	second row of 3x3 boxes
	CMP	R1,#8					;else
	BLS	case3					;	third row of 3x3 boxes
	
case1
	CMP R2,#2					;if(column<=2){
	BHI case12					;	first 3x3 box
	LDR R6,=0					;	tmpRow=0
	LDR R11,=0					;	tmpCol=0
	B continue					;}
case12
	CMP R2,#5					;else if (column<=5){
	BHI case13					;	second 3x3 box
	ADD R4,R4,#3				;	update start address
	LDR R6,=0					;	tmpRow=0
	LDR R11,=3					;	tmpCol=3
	B continue					;}
case13							;else{
	ADD R4,R4,#6				;	third 3x3 box, update start address
	LDR R6,=0					;	tmpRow=0
	LDR R11,=6					;	tmpCol=6
	B continue					;}

case2							
	CMP R2,#2					;if(column<=2){
	BHI case22					;	fourth 3x3 box
	ADD R4,R4,#27				;	update start address	
	LDR R6,=3					;	tmpRow=3
	LDR R11,=0					;	tmpCol=0
	B continue					;}
case22							
	CMP R2,#6					;else if(column<=5){
	BHI case23					;	fifth 3x3 box
	ADD R4,R4,#30				;	update start address
	LDR R6,=3					;	tmpRow=3
	LDR R11,=3					;	tmpCol=3
	B continue					;}
case23							;else{
	ADD R4,R4,#33				;	sixth 3x3 box, update start address	
	LDR R6,=3					;	tmpRow=3
	LDR R11,=6					;	tmpCol=6
	B continue					;}
	
case3			
	CMP R2,#2					;if(column<=2){
	BHI case32					;	seventh 3x3 box
	ADD R4,R4,#54				;	update start address
	LDR R6,=6					;	tmpRow=6
	LDR R11,=0					;	tmpCol=0
	B continue					;}
case32
	CMP R2,#5					;else if(column<=5){
	BHI case33					;	eighth 3x3 box
	ADD R4,R4,#57				;	update start address
	LDR R6,=6					;	tmpRow=6
	LDR R11,=3					;	tmpCol=3
	B continue					;}
case33							;else{
	ADD R4,R4,#60				;	ninth 3x3 box, update start address
	LDR R6,=6					;	tmpRow=6
	LDR R11,=6					;	tmpColumn=6
	B continue					;}
	
continue
	ADD		R1,R6,#3			;tmpRowMax= tmpRow+3
	ADD		R2,R11,#3			;tmpColMax= tmpCol+3
	LDR 	R10,=0				;encounterCounter=0
loop3							
	CMP 	R11,R2				;for(tmpRow; tmpRow<tmpRowMax; tmpRow++){
	BLO		endif7				;
	SUB		R11,R11,#3			;	for(tmpColumn;	tmpColumn<tmpColumnMax; tmpColumn++){
	ADD 	R6,R6,#1			;		// when tmpColumn reaches tmpColumnMax, reset it back to 
	CMP 	R6,R1				;		// original value, and add 1 to tmpRow
	BHS		end1				;		
endif7							;
	MUL 	R12,R6,R3			;		
	ADD 	R12,R12,R11			;		R12=tmpIndex
	LDRB 	R7,[R0,R12,LSL#0]	;		R7=tmpValue		//grid[tmpRow][tmpColumn]
	CMP 	R7,#0				;		if(tmpValue!=0){
	BEQ		endif5				;		
	CMP		R8,R7				;			if(tmpValue==value){
	BNE 	endif6				;
	ADD 	R10,R10,#1			;				encounterCounter++
endif6							;			}
	CMP 	R10,#2				;		}
	BNE		endif5				;		if(encounterCounter==2){
	LDR 	R9,=0				;			isValid=false
	B		end1				;		}
endif5							;	}
	ADD 	R11,R11,#1			;}	
	B 		loop3
end1
	LDMFD 	SP!,{R0-R4,R6-R8,R10-R12,PC}



; sudoku subroutine
;			R0=start address
;			R1= row
;			R2= column
;			R3= lenght of row (9)
;			R4= stores original value of row
;			R6= tmp row
;			R7= stores original value of column
;			R9= boolean isValid
;			R10= value to be set in memory (try)
;			R11= tmp column
;			R12= boolean result
sudoku
	STMFD 	SP!,{R1-R4,R6-R8,R10-R12,LR}
	LDR R3,=9
	LDR R12,=0			;boolean result=false;
	LDR R11,=0			;nxtcol
	LDR R6,=0			;nxtrow
	ADD R11,R2,#1		;nxtcol=col+1
	MOV R6,R1			;nxtrow=row
	MOV R4,R1			;R4= stores original value of row
	MOV R7,R2			;R7= stores original value of column
	
	CMP R11,R3			;if(nxtcol>8){
	BLO	endif8				
	LDR R11,=0			;	nxtcol=0
	ADD R6,R6,#1		;	nxtrow++
endif8					;}
	BL 	getSquare
	CMP	R8,#0			;if(getSquare!=0){
	BEQ endif10
	CMP R1,#8			;	if(row==8 && column==8){
	BNE endif9			;
	CMP R2,#8			;	
	BNE endif9			;
	LDR R12,=1			;		result=true 
	B	returnResult	;	}
endif9					;	
	MOV R1,R6			;	else{	
	MOV R2,R11			;
	BL sudoku			;		result=sudoku(grid,nxtrow,nxtcol)
	MOV R12,R9			;	}
	B returnResult
	
endif10					;}
	LDR R10,=0			;else{
loop4					;
	ADD R10,R10,#1		;
	CMP R10,#9			;	for(try=1;try<=9 && !result){
	BHI	endLoop4		;
	CMP R12,#1			;		
	BEQ endLoop4		;
	BL setSquare		;		setSquare(grid,row,column,try)
	BL isValid			;		if(isValid(grid,row,column)){
	CMP	R9,#0			;
	BEQ loop4			;			//value works so far
	CMP R1,#8			;			if(row=8 (last row) && column=8 (last col)){
	BNE endif11			;
	CMP R2,#8			;
	BNE endif11
	LDR R12,=1			;				result=true
	B	loop4			;			}
						;		}
endif11					;		else{
	MOV R1,R6			;		//row = nxtrow
	MOV R2,R11			;		//column = nxtcolumn
	BL sudoku			;			result=sudoku(grid,nxtrow,nxtcol)
	MOV R12,R9			;		}
	MOV R1,R4			;		//restore back original row
	MOV R2,R7			;		//restore back original column
	B loop4				;	}
endLoop4				;}
	CMP R12,#1			;if(!result)
	BEQ	returnResult	;
	LDR R10,=0			;	
	MOV R1,R4			;	//restore back original row
	MOV R2,R7			;	//restore back original column
	BL setSquare		;	setSquare(grid,column,row,0)
returnResult			;}
	MOV R9,R12			;return result in R9
	LDMFD 	SP!,{R1-R4,R6-R8,R10-R12,PC}



	AREA	Grids, DATA, READWRITE

testGridOne
	DCB	0,0,0,0,0,5,6,7,0
	DCB	0,2,3,0,0,0,0,0,0
	DCB	0,4,0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0,0,0
	DCB	8,0,0,0,0,0,0,0,0
	DCB	9,0,0,0,0,0,0,0,0

testGridTwo
	DCB	0,2,7,6,0,0,0,0,3
	DCB	3,0,0,0,0,9,0,0,0
	DCB	8,0,0,0,4,0,5,0,0
	DCB	6,0,0,0,0,2,0,4,0
	DCB	0,0,2,0,0,0,8,0,0
	DCB	0,4,0,7,0,0,0,0,1
	DCB	0,0,3,0,1,0,0,0,7
	DCB	0,0,0,8,0,0,0,0,9
	DCB	9,0,0,0,0,6,2,8,0

testSolutionTwo
	DCB	1,2,7,6,5,8,4,9,3
	DCB	3,5,4,2,7,9,1,6,8
	DCB	8,9,6,3,4,1,5,7,2
	DCB	6,3,9,1,8,2,7,4,5
	DCB	7,1,2,4,9,5,8,3,6
	DCB	5,4,8,7,6,3,9,2,1
	DCB	2,8,3,9,1,4,6,5,7
	DCB	4,6,5,8,2,7,3,1,9
	DCB	9,7,1,5,3,6,2,8,4

testGridThree
	DCB	0,0,0,9,0,0,0,5,0
	DCB	0,0,3,0,4,0,1,0,6
	DCB	0,4,0,2,0,0,0,8,0
	DCB	7,0,8,0,0,0,0,0,0
	DCB	0,3,0,0,0,0,0,6,0
	DCB	0,0,0,0,0,0,5,0,4
	DCB	0,6,0,0,0,1,0,7,0
	DCB	4,0,2,0,5,0,3,0,0
	DCB	0,9,0,0,0,8,0,0,0

testSolutionThree
	DCB	1,2,7,9,8,6,4,5,3
	DCB	9,8,3,5,4,7,1,2,6
	DCB	5,4,6,2,1,3,7,8,9
	DCB	7,5,8,3,6,4,2,9,1
	DCB	2,3,4,1,9,5,8,6,7
	DCB	6,1,9,8,7,2,5,3,4
	DCB	8,6,5,4,3,1,9,7,2
	DCB	4,7,2,6,5,9,3,1,8
	DCB	3,9,1,7,2,8,6,4,5
	
	

	END