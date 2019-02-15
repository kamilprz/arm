	AREA	Divide, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR R2, =20 ; a
	LDR R3, =3 ; b
	LDR R0, =0 ; quotient
	MOV R1, R2 ; remainder = a
	CMP R3, #0 ; checks if b =0
	BEQ endwhile
while
	CMP R1, R3 ; while(remainder >= b) 
	BLO endwhile ;{
	ADD R0,R0,#1 ;  quotient += 1  
	SUB R1, R1, R3 ; remainder -= b }
	B while
endwhile	

	
stop	B	stop

	END	