	AREA	ConsoleInput, CODE, READONLY
	IMPORT	main
	IMPORT	getkey
	IMPORT	sendchar
	EXPORT	start
	PRESERVE8


;***Stores number in R4***
start	
	MOV R4,#0
	MOV R5,#10
read
	BL	getkey			; read input key from console
	CMP	R0, #0x0D  		; while (key != enter)
	BEQ	endRead			; {
	BL	sendchar		; print key back in console console
	MUL R4,R5,R4		; result=resultx10
	SUB R0,R0,#0x30		; convert value from ASCII
	ADD R4,R0,R4		; result=result+value


	B	read			; } loop back to read
	
endRead


stop	B	stop


endRead

stop	B	stop

