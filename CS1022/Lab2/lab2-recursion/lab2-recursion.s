;
; CS1022 Introduction to Computing II 2018/2019
; Lab 2 - Recursion
;

N	EQU	10

	AREA	globals, DATA, READWRITE

; N word-size values

SORTED	SPACE	N*4		; N words (4 bytes each)


	AREA	RESET, CODE, READONLY
	ENTRY

	;
	; copy the test data into RAM
	;

	LDR	R4, =SORTED
	LDR	R5, =UNSORT
	LDR	R6, =0
whInit	CMP	R6, #N
	BHS	eWhInit
	LDR	R7, [R5, R6, LSL #2]
	STR	R7, [R4, R6, LSL #2]
	ADD	R6, R6, #1
	B	whInit
eWhInit


	;
	; call your sort subroutine to test it
	;

   LDR R0, =SORTED
   LDR R1, =N
   BL  sort
STOP	B	STOP


	;
	; your swap subroutine goes here
	;

; swap subroutine
; Swap two elements in a 1-dimensional array of word-size integers
; parameters
;    R0: the adress of array
;    R1: the index of first element
;    R2: the index of second index
; return
;    nothing

swap
   PUSH{R4,R5}
swap1
   LDR R4,[R0, R1, LSL #2]
   LDR R5,[R0, R2, LSL #2]
   STR R5,[R0, R1, LSL #2]
   STR R4,[R0, R2, LSL #2]
endSwap
   POP{R4,R5}
   BX LR
   
	;
	; your sort subroutine goes here
	;

; sort subroutine
; Call swap subroutines at fixed times
; parameters
;    R0: the adress of array
;    R1: the number of calling swap subroutines
sort
   PUSH{R4,R5,R6,R7,R8,R10,LR}
   MOV R10,R1
sort1
   MOV R4,#0                ;boolean swapped = false
   MOV R5,#1                ;for(i=1
sort4
   CMP R5,R10               ;        ;i<N
   BHS sort2                ;{
   SUB R6,R5,#1             ;i-1
   LDR R7,[R0, R6, LSL #2]  ;array[i-1] 
   LDR R8,[R0, R5, LSL #2]  ;array[i] 
   CMP R7,R8                ;if(array[i-1] >array[i])
   BLT sort3                ;{
   MOV R1,R6                ;R1 = i-1 as a parameter of swap subroutines
   MOV R2,R5                ;R2 = i as a parameter of swap subroutines
   BL  swap
   MOV R4,#1                 ;boolean swapped = true
sort3                        ;}
   ADD R5,R5, #1		     ;i++	
   B   sort4                 ;}
sort2   
   CMP R4,#1                 ;while(swapped)
   BEQ sort1                 ;
endSort
   POP{R4,R5,R6,R7,R8,R10,PC}
   

UNSORT	DCD	9,3,0,1,6,2,4,7,8,5

	END
