;
; CS1022 Introduction to Computing II 2018/2019
; Lab 1 - Matrix Multiplication
;

N	EQU	4

	AREA	globals, DATA, READWRITE

; result matrix R

ARR_R	SPACE	N*N*4		; 4 * 4 * word-size values


	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R0, =ARR_A
	LDR	R1, =ARR_B
	LDR	R2, =ARR_R
	LDR	R3, =N

	; your program goes here
	
	LDR R4, =0            ;i=0
	LDR R5, =0            ;j=0
	LDR R6, =0            ;k=0
	
L1  CMP R4,R3             ;for(i=0;
    BHS L2                ;         i<N;i++){
L6	CMP R5,R3             ;for(j=0;
	BHS L3                ;         j<N;j++){
	LDR R7,=0             ; r=0;
L5	CMP R6,R3             ;for(k=0;
	BHS L4                ;        k<N;k++){
	MUL R8,R4,R3          ;index(A[i]) = row * row_size
	ADD R8,R8,R6          ;index(A[i,k]) = index(A[i]) + column
	LDR R8,[R0,R8,LSL #2] ;elem(A[i,k]) = Memory.Word[ARR_A + (index*4)]
	MUL R9,R6,R3          ;index(B[k]) = row * row_size
	ADD R9,R9,R5          ;index(B[k,j]) = index(B[k]) + column
	LDR R9,[R1,R9,LSL #2] ;elem(B[k,j]) = Memory.Word[ARR_B + (index*4)]
	MUL R8,R9,R8          ; ( A[ i , k ] * B[ k , j ] )
	ADD R7,R7,R8          ;r = r + ( A[ i , k ] * B[ k , j ] ) ;
	ADD R6,R6,#1          ;k++;
	B   L5                ;}
L4	MUL R8,R4,R3          ;index(R[i]) = row * row_size
	ADD R8,R8,R5          ;index(R[i,j]) = index(R[i]) + column
	STR R7,[R2,R8,LSL #2] ;elem(R[i,j]) = Memory.Word[ARR_R + (index*4)]
	ADD R5,R5,#1          ;j++
	LDR R6, =0            ;k=0
	B   L6                ;}
L3	ADD R4,R4,#1          ;i++
    LDR R5, =0            ;j=0
	B   L1                ;}
L2
STOP	B	STOP

; two constant value matrices, A and B

ARR_A	DCD	 1,  2,  3,  4
	DCD	 5,  6,  7,  8
	DCD	 9, 10, 11, 12
	DCD	13, 14, 15, 16

ARR_B	DCD	 1,  2,  3,  4
	DCD	 5,  6,  7,  8
	DCD	 9, 10, 11, 12
	DCD	13, 14, 15, 16

	END
