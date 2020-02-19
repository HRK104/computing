;
; CS1022 Introduction to Computing II 2018/2019
; Lab 2 - Subroutines
;


N	EQU	4
BUFLEN	EQU	32

PINSEL0	EQU	0xE002C000
U0RBR	EQU	0xE000C000
U0THR	EQU	0xE000C000
U0LCR	EQU	0xE000C00C
U0LSR	EQU	0xE000C014


	AREA	globals, DATA, READWRITE

; char buffer
BUFFER	SPACE	BUFLEN		; BUFLEN bytes

; result array
ARR_R	SPACE	N*4		; N words (4 bytes each)


	AREA	RESET, CODE, READONLY
	ENTRY

	BL	inithw

	;
	; invoke your max subroutine to test it
	;
	
   LDR R0,=0x40000001    ;set parameter int a
   LDR R1,=0x40000002    ;set parameter int b
   BL  max
     
	;
	; invoke your gets subroutine to test it
	;
   
   LDR R0,=BUFFER        ;set parameter char [] buffer
   LDR R1,=BUFLEN        ;set parameter unsigned int len
   BL gets   
	

	;
	; invoke your matmul subroutine to test it
	;

   LDR R0, =ARR_A        ;set parameter int [][] matrix_a
   LDR R1, =ARR_B        ;set parameter int [][] matrix_b
   LDR R2, =ARR_R        ;parameter int [][] result
   LDR R3, =N            ;set parametr int N
   BL  matmul

STOP	B	STOP


;
; your max subroutine goes here
;

; max subroutine
; determine the maximumnumber
; parameters
;    r0: a – address of first number
;    r1: b – address of second number
; return 
;    r0: maximum - address of maximum number
max
   CMP R0,R1
   BLT max2
   BGT max3
   B   max4
max2
   MOV R0,R1
   B   emdMax
max3
   MOV R0,R0
   B   emdMax
max4
   MOV R0,#0
emdMax
   BX LR   
;   PUSH {R4-R8}
;   MOV R4,#31
;   MOV R5,#0
;   MOV R6,#0
;   MOV R7,#0
;   MOV R8,#0
;   LDR R9,=0xFFFFFFFE
;max1  
;   CMP R4,#0
;   BEQ max4
;   LDR R7,[R5,R0, LSR #31]
;   BIC R7,R7,R9
;   LDR R8,[R6,R1, LSR #31]
;   BIC R8,R8,R9
;   SUB R4,R4,#1
;   CMP R7,R8
;   BEQ max1
;   BHS max2
;   BLS max3
;max2
;   MOV R0,R0
;   B   max5
;max3
;   MOV R0,R1
;   B   max5
;max4
;   MOV R0,#0
;max5
;   POP {R4-R8}
;  BX LR



;
; your gets subroutine goes here
;

; gets subroutine
; read up to len-1 chars from from the console, storing the resulting NULL-terminated string in buffer and returning the number of characters read
; parameters
;    r1: char[] buffer – array are going to contain NULL-terminated string 
;    r0: unsigned int len – address of the conter read up from console
; return
;    r0: number - number of characters read
gets 
   PUSH{R4,R5,LR}
   MOV R4,R0          ;R4 = R0 = address of the buffer array
   MOV R5,R1          ;R5 = R4 = length of console
   MOV R0,#0          ;R0 = 0
   MOV R1,#0          ;R1 =0
   SUB R5,R5,#1       ;R5--
   MOV R6,#1          ;R6 = 1 count
gets1 
   CMP R6,R5         ;R6>R5?
   BGT endGets       ;if so, go to endGets
   BL get
   BL put	   
   STRB R0,[R4],#1   ;storing the resulting NULL-terminated string in buffer
   CMP R0,0x00
   BEQ endGets
   ADD R6,R6,#1      ;R6++
   B   gets1
endGets
   MOV R0,R5         ;return the number of characters read
   POP {R4,R5,PC}
   

;
; your matmul subroutine goes here
;

; matmul subroutine
; multiply two N × N matrices, storing the result in a third matrix)
; parameters
;    r0: int[][] matrix a – address of first array (first matrix) 
;    r1: int[][] matrix b – address of second array (second matrix) 
;    r2: int[][] result - address of third array (third matrix) 
;    r3: unsigned int N - the size of row and column
;return
;    nothing
matmul
   PUSH{R4-R9}
matmul1
    LDR R4, =0            ;i=0
	LDR R5, =0            ;j=0
	LDR R6, =0            ;k=0
	
matmul2  
    CMP R4,R3             ;for(i=0;
    BHS endMatmul         ;         i<N;i++){
matmul3	
    CMP R5,R3             ;for(j=0;
	BHS matmul6           ;         j<N;j++){
	LDR R7,=0             ; r=0;
matmul4	
    CMP R6,R3             ;for(k=0;
	BHS matmul5           ;        k<N;k++){
	MUL R8,R4,R3          ;index(A[i]) = row * row_size
	ADD R8,R8,R6          ;index(A[i,k]) = index(A[i]) + column
	LDR R8,[R0,R8,LSL #2] ;elem(A[i,k]) = Memory.Word[ARR_A + (index*4)]
	MUL R9,R6,R3          ;index(B[k]) = row * row_size
	ADD R9,R9,R5          ;index(B[k,j]) = index(B[k]) + column
	LDR R9,[R1,R9,LSL #2] ;elem(B[k,j]) = Memory.Word[ARR_B + (index*4)]
	MUL R8,R9,R8          ; ( A[ i , k ] * B[ k , j ] )
	ADD R7,R7,R8          ;r = r + ( A[ i , k ] * B[ k , j ] ) ;
	ADD R6,R6,#1          ;k++;
	B   matmul4           ;}
matmul5	
    MUL R8,R4,R3          ;index(R[i]) = row * row_size
	ADD R8,R8,R5          ;index(R[i,j]) = index(R[i]) + column
	STR R7,[R2,R8,LSL #2] ;elem(R[i,j]) = Memory.Word[ARR_R + (index*4)]
	ADD R5,R5,#1          ;j++
	LDR R6, =0            ;k=0
	B   matmul3           ;}
matmul6	
    ADD R4,R4,#1          ;i++
    LDR R5, =0            ;j=0
	B   matmul2           ;}
endMatmul
    POP {R4-R9}
    BX  LR


;
; inithw subroutines
; performs hardware initialisation, including console
; parameters:
;	none
; return value:
;	none
;
inithw
	LDR	R0, =PINSEL0		; enable UART0 TxD and RxD signals
	MOV	R1, #0x50
	STRB	R1, [R0]
	LDR	R0, =U0LCR		; 7 data bits + parity
	LDR	R1, =0x02
	STRB	R1, [R0]
	BX	LR

;
; get subroutine
; returns the ASCII code of the next character read on the console
; parameters:
;	none
; return value:
;	R0 - ASCII code of the character read on teh console (byte)
;

get	
	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
get0	LDR	R0, [R1]		; wait until
	ANDS	R0, #0x01		; receiver data
	BEQ	get0			; ready
	LDR	R1, =U0RBR		; R1 -> U0RBR (Receiver Buffer Register)
	LDRB	R0, [R1]		; get received data
	BX	LR			; return

;
; put subroutine
; writes a character to the console
; parameters:
;	R0 - ASCII code of the character to write
; return value:
;	none
;
put	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
	LDRB	R1, [R1]		; wait until transmit
	ANDS	R1, R1, #0x20		; holding register
	BEQ	put			; empty
	LDR	R1, =U0THR		; R1 -> U0THR
	STRB	R0, [R1]		; output charcter
put0	LDR	R1, =U0LSR		; R1 -> U0LSR
	LDRB	R1, [R1]		; wait until
	ANDS	R1, R1, #0x40		; transmitter
	BEQ	put0			; empty (data flushed)
	BX	LR			; return

;
; puts subroutine
; writes the sequence of characters in a NULL-terminated string to the console
; parameters:
;	R0 - address of NULL-terminated ASCII string
; return value:
;	R0 - ASCII code of the character read on teh console (byte)
;
puts	STMFD	SP!, {R4, LR} 		; push R4 and LR
	MOV	R4, R0			; copy R0
puts0	LDRB	R0, [R4], #1		; get character + increment R4
	CMP	R0, #0			; 0?
	BEQ	puts1			; return
	BL	put			; put character
	B	puts0			; next character
puts1	LDMFD	SP!, {R4, PC} 		; pop R4 and PC


;
; test arrays
;

ARR_A	DCD	 1,  2,  3,  4
	DCD	 5,  6,  7,  8
	DCD	 9, 10, 11, 12
	DCD	13, 14, 15, 16

ARR_B	DCD	 1,  2,  3,  4
	DCD	 5,  6,  7,  8
	DCD	 9, 10, 11, 12
	DCD	13, 14, 15, 16
		
STR0 DCB "Please input string.", 0x0a, 0, 0

	END
