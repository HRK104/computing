;
; CS1022 Introduction to Computing II 2018/2019
; Lab 1 - Addressing Modes
;

N	EQU	10

	AREA	globals, DATA, READWRITE

; N word-size values

ARRAY	SPACE	N*2		; N half-words (2 bytes each)


	AREA	RESET, CODE, READONLY
	ENTRY

	; for convenience, let's initialise test array [0, 1, 2, ... , N-1]



	LDR	R0, =ARRAY
	LDR	R1, =0
L1	CMP	R1, #N
	BHS	L2
	STR R1, [R0, R1, LSL #2]
    ADD	R1, R1, #1	
	B	L1
L2



	; initialise registers for your program

	LDR	R0, =ARRAY	; array start address
	LDR	R1, =N		; size of array (half-words)

	; your program goes here

;(i)

;Sample Answer
;   MOV	R4, #0
;L3	CMP	R4, R1
;	BHS	L4
;	LDR	R5, [R0]
;	MUL	R6, R5, R5
;	STR	R6, [R0]
;	ADD	R0, R0, #4
;	ADD	R4, R4, #1
;	B	L3
;L4


	LDR	R0, =ARRAY
	LDR	R1, =0
L3	CMP	R1, #N
	BHS	L4
	LDR R4,[R0]
    MOV R5,R4
    MUL R4,R5,R4
	STR R4,[R0]
    ADD R1,R1,#1
    ADD R0,R0,#4
	B	L3
L4

;(ii)

    LDR R1, =ARRAY
    LDR R2,=0
    LDR R3,=1
L5 CMP R3,#10
    BHI L6
    LDR R4,[R1,R2]
    MOV R5,R4
    MUL R4,R5,R4
    STR R4,[R1,R2]
    ADD R3,R3,#1
    ADD R2,R2,#4
    B L5
L6

;(iii)

    LDR R1, =ARRAY
    LDR R2, =0
    LDR R3, =1
L7 CMP R3,#10
    BHI L8
    LDR R4,[R1,R2,LSL#2]
    MOV R5,R4
    MUL R4,R5,R4
    STR R4,[R1,R2,LSL#2]
    ADD R3,R3,#1
    ADD R2,R2,#1
    B L7
L8

;(iv)

   LDR R1, =ARRAY
   LDR R2, =0
   LDR R3, =1
L9 CMP R3,#10
   BHI L10
   LDR R4,[R1],#4
   MOV R5,R4
   MUL R4,R5,R4
   STR R4,[R1,#-4]
   ADD R3,R3,#1
   B L9
L10
STOP	B	STOP

	END
