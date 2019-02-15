	AREA	StringLength, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R1, =str1
	MOV R0, #0		; int length = 0
while
	LDRB R2, [R1]	; current_char = Memory.byte[address]
	CMP R2, #0x00	; while(current_char != 0)
	BEQ endwhile	;     
	ADD	R0, R0, #1  ;    length++
	ADD R1, R1, #1	; 	 adr++
	B 	while
endwhile

                                                                                                                                                                                                                                                                                            	
stop	B	stop



	AREA	TestData, DATA, READWRITE

str1	DCB	"Friday",0

	END	
