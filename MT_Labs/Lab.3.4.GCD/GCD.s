	AREA	GCD, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR R2,=20
	LDR R3,= 10
while
	CMP R2,R3
	BEQ endwhile
	CMP R2, R3
	BLS else
	SUB R0, R2,R3
	B while
else
	SUB R0, R3,R2
	B while
endwhile
	
stop	B	stop

	END	