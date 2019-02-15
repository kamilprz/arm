	AREA	Sets, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R0, =Array				;Array.address
	LDR	R3, =6					;originIndex
	LDR R4, =3					;endIndex
	LDR	R5, =1					;modifier = 1

	LDR	R1, [R0, R3, LSL #2]			;toStore = Memory.word[Array.address + (originIndex * 2)]
	LDR	R2, [R0, R4, LSL #2]			;toStoreAfter = Memory.word[Array.address + (endIndex * 2)]
	
	CMP R3, R4					;if(originIndex > endIndex) {
	BGT	for
	LDR	R5, =0xFFFFFFFF				;modifier = -1}
for
	CMP R3, R4					;while(originIndex == endIndex) {
	BEQ efor
	STR R1, [R0, R4, LSL #2]			;Memory.word[Array.address + (endIndex * 2)] = toStore
	ADD	R4, R4, R5				;	endIndex += modifier
	MOV R1, R2					;	toStore = toStoreAfter
	LDR R2, [R0, R4, LSL #2]			;toStoreAfter = Memory.word[Array.address + (endIndex * 2)]
	B 	for					;}
efor
	STR R1, [R0, R4, LSL #2]			;Memory.word[Array.address + (endIndex * 2)] = toStore

stop	B	stop


	AREA	TestData, DATA, READWRITE
	
Array		DCD	7, 2, 5, 9, 1, 3, 2, 3, 4	; Elements of Array



	END	