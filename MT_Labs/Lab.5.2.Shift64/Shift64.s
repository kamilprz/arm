	AREA	Shift64, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R0, =0x13131313
	LDR	R1, =0x13131313
	LDR	R2, =0
	LDR R5, =0x80000000
	LDR R4, =0			; shiftCount = 0;
	; your program goes here
	CMP R2, #0
	BLT whileneg
while 
	CMP R4, R2			; while(shiftCount < numTimesToShift(r2)) {
	BHS endwh			; {
	MOV R0, R0, LSR #1	;		LSB >> 1
	MOVS R1, R1, LSR #1	;		MSB >> 1
	BCC	endif			;		if(carry) {
	ORR R0, R0, R5		;			set MSB of LSBytes to 1
						;		}
endif							
	ADD R4, R4, #1		;		shiftCount++
	B 	while	 		; }
endwh
	B 	stop
whileneg				; same as above but decrement count because r2 is negative and
	CMP R4, R2			; shift left instead of right
	BLE endwh2
	MOV R0, R0, LSL #1
	MOVS R1, R1, LSL #1
	BCC	endif2
	ORR R0, R0, #0x00000001
endif2
	SUB R4, R4, #1
	B 	whileneg	 
endwh2
stop	B	stop


	END
		