;
; CS1022 Introduction to Computing II 2018/2019
; Lab 1 - Array Move
;

N	EQU	16		; number of elements

	AREA	globals, DATA, READWRITE

; N word-size values

ARRAY	SPACE	N*4		; N words


	AREA	RESET, CODE, READONLY
	ENTRY

	; for convenience, let's initialise test array [0, 1, 2, ... , N-1]

	LDR	R0, =ARRAY
	LDR	R1, =0
L1	CMP	R1, #N
	BHS	L2
	STR	R1, [R0, R1, LSL #2]
	ADD	R1, R1, #1
	B	L1
L2

	; initialise registers for your program

	LDR	R0, =ARRAY
	LDR	R1, =6
	LDR	R2, =3
	LDR	R3, =N

	; your program goes here
	
;	LDR R4,[R0,R1,LSL #2]    ;R4 = Memory.word[R0+R1*4]
;	SUB R1,R1,#1             ;R1 = R1-1
;	MOV R6,R2                ;R6 = R2 =3
;	
;L4	CMP R2,R1                ;R2>R1 ?
;	BHI L3                   ; go to L3
;	LDR R5,[R0,R1, LSL #2]   ;R5 = Memory.word[R0+R1*4]
;	ADD R1,R1,#1             ;R1 = R1+1
;	STR R5,[R0,R1, LSL #2]   ;Memory.word[R0+R1*4] = R5
;	SUB R1,R1,#2             ;R1 = R1-2
;	
;	B  L4                    ; go to L4
;L3	
;   STR R4,[R0,R6,LSL #2]    ;Memory.word[R0+R6*4] 
	
	
	
    LDR R4,[R0,R1,LSL #2]    ;R4 = Memory.word[R0+R1*4]	
	MOV R8,R2                ;R6 = R2 =3
	
	
	
	LDR R5,[R0,R2,LSL #2]    ;R5 = Memory.word[R0+R1*4]
L4	CMP R2,R1
	BHS L5
	ADD R2,R2,#1
	LDR R6,[R0,R2,LSL #2]
	STR R5,[R0,R2,LSL #2]
	MOV R5,R6  
	B   L4
L5
    STR R4,[R0,R8,LSL#2]
	LDR R9,=0xFFFFFFFE
	LDR R4,[R0,R8,LSL #4]

STOP	B	STOP

	END
