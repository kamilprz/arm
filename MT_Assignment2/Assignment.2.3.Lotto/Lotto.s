	AREA	Lotto, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR R9,=6			;tmp (amount of numbers per ticket)
	LDR R0,= COUNT
	LDRB R0,[R0]
	MUL R0,R9,R0		;amount of tickets*numbers per ticket
	LDR	R1, =TICKETS
	LDRB R2,[R1]
;	LDR R7,=MATCH4
	LDR R8,=0			;match4Count
;	LDR R9,=MATCH5	
	LDR R10,=0			;match5Count
;	LDR R11,=MATCH6
	LDR R12,=0			;match6Count
	LDR R5,=0			;numbers matched on ticket to draw count 
	LDR R6,=0 			;count of numbers per ticket (6) (to know when the ticket ends)
	LDR R7,=0			;count for R0

while
	CMP R6,#6			;while(count of numbers on ticket < 6)
	BEQ checkMatch		;{
	CMP R0,R7			;	if(count R0 == amount of tickets*numbers per ticket)
	BEQ ending			;		end program
	LDR R3,= DRAW		;
	LDRB R4,[R3]		; R4 = first number of draw
while2					
	CMP R4,#0			;	while(R4!=0)
	BEQ endwhile2		;	{
	CMP R2,R4			;	if(number on ticket matches draw)
	BNE endMatchNumber	;		{
matchNumber
	ADD R5,R5,#1		;	 	matchCounter++
	B endwhile2			;		}
endMatchNumber
	ADD R3,R3,#1		;	adrB++	
	LDRB R4,[R3]		;	BElem=Memory.Byte(adrB)
	B while2			;	}
endwhile2
	ADD R1,R1,#1		;adrA++
	LDRB R2,[R1]		;AElem=Memory.Byte(adrA)
	ADD R6,R6,#1		;count of numbers per ticket++
	ADD R7,R7,#1		;count for R0 ++
	B while				;}
endwhile

;CHECKS WHETHER THE TICKET MATCHED 4 5 OR 6

checkMatch
	LDR R6,=0
	CMP R5,#4			;if(numbers matched on ticket to draw count == 4)
	BNE endMatchFour	;{
	ADD R8,R8,#1		;	match4Count++
	LDR R5,=0			;	reset count
	B while				;}
endMatchFour
	CMP R5,#5			;if(numbers matched on ticket to draw count == 5)
	BNE endMatchFive	;{
	ADD R10,R10,#1		;	match5Count++
	LDR R5,=0			;	reset count
	B while				;}
endMatchFive
	CMP R5,#6			;if(numbers matched on ticket to draw count == 6)
	BNE noMatch			;{
	ADD R12,R12,#1		;	match6Count++
	LDR R5,=0			;	reset count
	B while				;}
noMatch					;else
	LDR R5,=0			;	reset count	
	B while
endCheckMatch

ending
	LDR R7,=MATCH4
	STR R8,[R7]			;store match4Count in main memory
	LDR R9,=MATCH5
	STR R10,[R9]		;store match5Count in main memory
	LDR R11,=MATCH6
	STR R12,[R11]		;store match6Count in main memory
	
stop	B	stop 

	AREA	TestData, DATA, READWRITE
	
COUNT	DCD	3						; Number of Tickets
TICKETS	DCB	3, 8, 11, 21, 22, 31	; Tickets								;match 2 
		DCB	7, 23, 25, 28, 29, 32											;match 0
		DCB	10, 11, 12, 22, 26, 30											;match 6
	

DRAW	DCB	10, 11, 12, 22, 26, 30	; Lottery Draw

MATCH4	DCD	0
MATCH5	DCD	0
MATCH6	DCD	0

	END	
