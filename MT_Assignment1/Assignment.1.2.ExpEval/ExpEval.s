	AREA	ExpEval, CODE, READONLY
	IMPORT	main
	IMPORT	getkey
	IMPORT	sendchar
	EXPORT	start
	PRESERVE8
					
start
	MOV R4,#0
	MOV R8,#10
	MOV R6,#0

firstNumber
	BL	getkey					; read 1st number from console
	CMP	R0, #'+' 				; while (key != '+')
	BEQ	endFirstNumber				
	CMP R0, #'-'				; ||(key!='-')
	BEQ endFirstNumber
	CMP R0, #'*'				; ||(key!='*')
	BEQ endFirstNumber			; {
	BL	sendchar				; print key back in console
	MUL R4,R8,R4				; result=resultx10
	SUB R0,R0,#0x30				; convert value from ASCII
	ADD R4,R0,R4				; result=result+value
	B firstNumber				; } loop back to firstNumber
endFirstNumber

	BL sendchar					; print sign back in console
	MOV R7,R0					; move the sign to a different register

secondNumber
	BL	getkey					; read 2nd number from console
	CMP	R0, #0x0D  				; while (key != enter)
	BEQ	endSecondNumber			; {
	BL	sendchar				; print key back to console
	MUL R6,R8,R6				; result=resultx10
	SUB R0,R0,#0x30				; convert value from ASCII
	ADD R6,R0,R6				; result=result+value
	B	secondNumber			; } loop back to secondNumber
endSecondNumber
	
	CMP R7,#'+'					; check if the sign is '+'
	BNE else1					; if not, branch to else1
	ADD R5,R4,R6				; if(sign=='+') do firstNumber+secondNumber
	B	endProgram					
else1
	CMP R7,#'-'					; check if the sign is '-'
	BNE else2					; if not, branch to else2
	SUB R5,R4,R6				; if(sign=='-') do firstNumber-secondNumber
	B	endProgram					
else2
	CMP R7,#'*'					; check if the sign is '*'
	BNE endProgram				; if not, end the program
	MUL R5,R4,R6				; if(sign=='*') do firstNumber*secondNumber
	B	endProgram					
endProgram
stop	B	stop

	END	
