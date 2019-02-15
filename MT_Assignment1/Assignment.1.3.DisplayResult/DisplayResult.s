	AREA	DisplayResult, CODE, READONLY
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
	BL	sendchar				; print key back in console
	MUL R6,R8,R6				; result=resultx10
	SUB R0,R0,#0x30				; convert value from ASCII
	ADD R6,R0,R6				; result=result+value
	B	secondNumber			; } loop back to secondNumber
endSecondNumber
	
	CMP R7,#'+'					; check if the sign is '+'
	BNE else1					; if not, branch to else1
	ADD R5,R4,R6				; if(sign=='+') do firstNumber+secondNumber
	B	endCalculation
else1							
	CMP R7,#'-'					; check if the sign is '-'
	BNE else2					; if not, branch to else2
	SUB R5,R4,R6				; if(sign=='-') do firstNumber-secondNumber
	B	endCalculation
else2
	CMP R7,#'*'					; check if the sign is '*'
	BNE stop					; if not end the program
	MUL R5,R4,R6				; if(sign=='*') do firstNumber*secondNumber
	B	endCalculation
endCalculation
	MOV R11,R5					; ensures the answer of the calculation is left untouched in a different register
; PART THREE
; Finding how many digits the answerOfCalculation stored in R5 has.


	LDR R9, =1 					; denominator
	LDR R10, =0 				; quotient
	CMP R9, #0 					; checks if denominator =0
	BEQ endPower
power
	CMP R9, R5 					; while(denominator<answerOfCalculation) 
	BHI endPower 				; (if denominator is greater than answerOfCalculation branch to endPower){
	ADD R10,R10,#1 				; quotient += 1   
	MUL R9,R8,R9				; denominator = denominator x 10
	B power						; } branch back to power
endPower	
	
	CMP R10,#0					;if(amountOfDigits=0)
	BNE oneDigit
	LDR R10,=1					;amountOfDigits=1;
oneDigit
	
	LDR R0,='='						
	BL sendchar					; printing "="


; Printing the answer.
loop	
	LDR R4,=1
	SUB R10,R10,#1  			; amount of digits remaining - 1 = max power of 10 that goes into the value
	MOV R7,R10					; resets the value of R7 after a loop
								
powerOfTen						; finding the highest power of 10 that divides into the remaining number
	CMP R7,#0					; while(R7!=0)
	BEQ endPowerOfTen			; (if no digits remaining, branch to endPowerOfTen){
	MUL R4,R8,R4 				; power of 10 = (previous power of 10) x 10
	SUB R7,R7,#1 				; amount of digits left = amount of digits left-1
	B powerOfTen				; } branch back to powerOfTen
endPowerOfTen
	LDR R0,=0					; reset the value stored in R0 back to 0
while
	CMP R5,#0
	BEQ endwhile
	CMP R5,R4					; while(answerOfCalculation>highest power of 10)
	BLO endwhile					
	ADD R0,R0,#1				; digitToBePrinted= digitToBePrinted + 1
	SUB R5,R5,R4 				; answerofCalculation = answerOfCalculation-highestPowerOf10
	B while
endwhile
	ADD R0,R0,#0x30				; convert back to ASCII
	BL sendchar					; print next digit of the answer	
	B loop						; branch back to loop

stop	B	stop

	END	
BL sendchar					; print next digit of the answer	
	B loop						; branch back to loop


stop	B	stop
