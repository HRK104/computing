;
; CS1021 2018/2019	Lab 6
;
; RAM @ 0x4000000 sz = 0x10000 (64K)
;

;
; hardware registers
;

PINSEL0	EQU	0xE002C000
	
U0RBR	EQU	0xE000C000
U0THR	EQU	0xE000C000
U0LCR	EQU	0xE000C00C
U0LSR	EQU	0xE000C014
	
	
	AREA	RESET, CODE, READONLY
	ENTRY	
	
;	
; hardware initialisation
;
   	LDR	R13, =0x40010000	; initialse SP
	LDR	R0, =PINSEL0		; enable UART0 TxD and RxD signals
	MOV	R1, #0x50
	STRB	R1, [R0]
	LDR	R0, =U0LCR		; 7 data bits + parity
	LDR	R1, =0x02
	STRB	R1, [R0]

;
; add your code here for the Sieve of Eratosthenes
;

;
;N =10 # primes =
;N =100 # primes =23 (R5 = 0x19)
;N =1000 # primes = 195
;N =10000 # primes =
;N =100000 # primes =
   LDR R4,=0x40000001       ;R4 -> 0x40000001
   MOV R5,#0x11             ;R5 = 0x11
   LDR R6,=0x4            ;R6 =0xC34F(=49=(100-1)/2=(100+1-2)/2)
   MOV R11,R6               ;R11 =R6
L  STRB R5,[R4],#1          ;R5 = R4, R4=R4+1
   SUB R6,R6,#1             ;R6 = R6-1
   CMP R6,#0                ;R6 = 0 ?
   BNE L                    ;if not R6 = 0, go to L
   LDR R6,=0x01             ;R = 0x01
   STRB R6,[R4]             ;R6 = a byte of R4
   ADD R11,R11,#1            ;R11 = R11+1
   
   MOV R7,R4                ;R7 = R4   (R7=last memory)
   MOV R5,#0                ;R5 =0(count of prime)
L1 MOV R2,#0
   MOV R8,#0                ;R8 = 0
   LDR R4,=0x40000000       ;R4 -> 0x40000000
   LDRB R6,[R4]             ;R6 = byte of R4
   B   L3                   ;go to L2
L2 ADD R4,R4,#1             ;R4 = R4+1
   ADD R8,R8,#1             ;R8 = R8+1   (R8 = count number until R6=0x00)
  
   LDRB R6,[R4]             ;R6 = byte of R4
   B   L3   
                           
                            ;CASE OF "2"
L12 ADD R5,R5,#1             ;R5 =R5+1 (count++) 
   MOV R10, R4             ;R10 = R4 
   LDRB R6,[R4]             ;R6 = byte of R4
   
L13 
   
   MOV R9,#0x01             ;R9 = 0xFF
   BIC R6,R6,R9             ;clear byte of R4
   STRB R6,[R4]             ;R6 = the byte of R4 
   ADD R4,R4,R8             ;R4 = R4 + R8(count refered to line)
   CMP R4,R7                ;R8 >= R7?
   BGE L14                   ;if R8>=R7, go to L13
   LDRB R6,[R4]             ;R6 = byte of R4
   B   L13                   ;go to L12
                            ;CASE OF "10"
L14 MOV R4, R10             ;R4 =R10
   ADD R8,R8,#2             ;R8 = R8+
   B L30

L30   ADD R5,R5,#1            ;R5 = R5 +1(count++)
   LDRB R6,[R4]             ;R6 = byte of R4
   
   MOV R9,#0x10              ;R9 = 0xFF
   BIC R6,R6,R9             ;clear byte of R4
   STRB R6,[R4]             ;R6 = the byte of R4 
   MOV R10,#0               ;R10 =0
   
L15 
   MOV R9,#0x10             ;R9 = 0x10
   MOV R10,#0x01            ;R10 = 0x01
   
L20 ADD R2,R2,R8           ;R2 = R2+R8
   
   LDRB R6,[R4]             ;R6 = byte of R4
   AND R12, R2,#0x1 
   CMP R12, #0
   BNE L21
   BIC R6,R9       ;R4 && R9 <<R10
   B  L22
L21 BIC R6,R10       ;R4 && R9 <<R10   
L22 STRB R6,[R4]             ;R6 = the byte of R4 
   ADD R4,R4,R8             ;R4 = R4+1
   CMP R4,R7                ;R8 >= R7?
   BGE L1                   ;if R8>=R7, go to L4
   B   L20                  ;go to L13
   
L18  ADD R8,R8,#1
L40   ADD R5,R5,#1            ;R5 = R5 +1(count++)
   LDRB R6,[R4]             ;R6 = byte of R4
   
   MOV R9,#0x10              ;R9 = 0xFF
   BIC R6,R6,R9             ;clear byte of R4
   STRB R6,[R4]             ;R6 = the byte of R4 
   MOV R10,#0               ;R10 =0
   
L41 
   MOV R9,#0x10         ;R9 = 0x10
   MOV R10,#0x01           ;R10 = 0x01
   
L42 ADD R2,R2,R8           ;R2 = R2+R8
   
   LDRB R6,[R4]             ;R6 = byte of R4
   AND R12, R2,#0x1 
   CMP R12, #0
   BNE L43
   BIC R6,R9       ;R4 && R9 <<R10
   B  L44
L43 BIC R6,R10       ;R4 && R9 <<R10   
L44 STRB R6,[R4]             ;R6 = the byte of R4 
   ADD R4,R4,R8             ;R4 = R4+1
   CMP R4,R7                ;R8 >= R7?
   BGE L1                   ;if R8>=R7, go to L4
   B   L42                  ;go to L13
L16  
   B   L5                   ;go to L5

L3 CMP R6,#0x00             ;R6 = 0x00 ?
   BEQ L2                   ;if R4 = 0x01, go to L1
   CMP R6,#0x10             ;R6 = 0x10?
   BEQ L18                  ;if R6 = 0x10, go to L11
   CMP R6,#0x11             ;R6 = 0x11?
   BEQ L12                  ;if R6 = 0x11, go to L12
   CMP R6,#0x01              ;if R4 = 0x11, go to L1
   BEQ L16                  ;if R6 = 0x01, go to L16
   
      
L5 LDR R0,=STR0             ;"There are "
   BL PUTS
L6 BL SUB1
L7 BL  PUT                   ;put character 
   BL SUB0
   CMP R4,#0                 ;R4(Divider) >0?
   BGT L7
   LDR R0,=STR1             ;" primes int the first 100 integers."
   BL PUTS   
   
STOP	B	STOP



;
;this part of program is for outputing an integer as decimal number, using ASCII code
;
SUB1 
   LDR R4,=1000000000        ;R4 = 1000000000
SUB2 CMP R4,R5               ;R4(Divider) >R5(Quotinent)?
   BLS SUB6                  ;if R5 =< R4, go to L7
                             ;D = D/10
                             ;R4 = Numerator 
   MOV R11,#10               ;R11 =10 Divider=R11
SUB3 MOV R6,#0               ;R6 =0   Quotinent =R6
   MOV R7,#0                 ;R7 =0 Remainder=R7
   MOV R8,#31                ;R8 = 31,     i=R8                
   MOV R9,#1                 ;R9 =1(used as mask)
SUB4 CMP R8,#0               ;i==0?
   BLT SUB13                 ;if i<0, go to SUB13
   MOV R7,R7,LSL#1           ;R = R<<1
   AND R10,R9,R4,LSR R8      ;R[0] = N[i]
   ORR R7,R7,R10
   CMP R7,R11                ;R>=D?
   BLT SUB5                  ;if R<D, go to SUB5
   SUB R7,R7,R11             ;R = R-D
   ORR R6,R6,R9,LSL R8       ;Q[i] =1
SUB5 SUB R8,R8,#1            ;i = i-1
   B   SUB4                  ;go to SUB4
SUB13 MOV R4,R6              ;R4 = R6
   B  SUB2                   ;go to SUB2
   
SUB6 MOV R6,#0               ;R6 =0 
   CMP R4,#0                 ;R4(Divider) >0?
   BLS SUB7                  ;if R4 =< 0, go to SUB7
   MOV R8,R4                 ;R8 = R4
   AND R6,R5,R4              ;R6 = R5%R4    
                             ;Q = Q / D; ; quotient
   MOV R7,#0                 ;R7(Quotinent) = 0
SUB8 CMP R5,R4               ;R5(Remainder) >= R4(Divider)?
   BLT SUB9                  ;if R5 < R4, go to SUB9                   
   ADD R7,R7,#1              ;R7(Quotinent) = R7 +1
   SUB R5,R5,R4              ;R5 = R5-R4
   B   SUB8                  ;go to SUB8
SUB9 ADD R0,R7,#0x30         ;R0 = R7 + 0x30
   BX  LR                    ;return
   
   
SUB0 MOV R7,R5               ;Q = R5
                             ;D = D/10
                             ;R4 = Numerator 
   MOV R11,#10               ;R11 =10 Divider=R11
SUB10 MOV R6,#0              ;R6 =0   Quotinent =R6
   MOV R7,#0                 ;R7 =0 Remainder=R7
   MOV R8,#31                ;R8 = 31,     i=R8                
   MOV R9,#1                 ;R9 =1(used as mask)
SUB11 CMP R8,#0              ;i==0?
   BLT SUB14
   MOV R7,R7,LSL#1           ;R = R<<1
   AND R10,R9,R4,LSR R8      ;R[0] = N[i]
   ORR R7,R7,R10
   CMP R7,R11                ;R>=D?
   BLT SUB12
   SUB R7,R7,R11             ;R = R-D
   ORR R6,R6,R9,LSL R8       ;Q[i] =1
SUB12 SUB R8,R8,#1           ;i = i-1
   B   SUB11                 ;go to SUB11 
SUB14 MOV R4,R6              ;R4 = R6
   B   SUB6                  ;go to SUB6
SUB7 
   BX  LR                    ;return



STR0 DCB  "There are ",0,0,0
STR1 DCB  " primes in the first 10 integers.",0x0a,0,0


;
; subroutines
;	
; GET
;
; leaf function which returns ASCII character typed in UART #1 window in R0
;
GET	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
GET0	LDR	R0, [R1]		; wait until
	ANDS	R0, #0x01		; receiver data
	BEQ	GET0			; ready
	LDR	R1, =U0RBR		; R1 -> U0RBR (Receiver Buffer Register)
	LDRB	R0, [R1]		; get received data
	BX	LR			; return

;	
; PUT
;
; leaf function which sends ASCII character in R0 to UART #1 window
;
PUT	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
	LDRB	R1, [R1]		; wait until transmit
	ANDS	R1, R1, #0x20		; holding register
	BEQ	PUT			; empty
	LDR	R1, =U0THR		; R1 -> U0THR
	STRB	R0, [R1]		; output charcter
PUT0	LDR	R1, =U0LSR		; R1 -> U0LSR
	LDRB	R1, [R1]		; wait until 
	ANDS	R1, R1, #0x40		; transmitter
	BEQ	PUT0			; empty (data flushed)
	BX	LR			; return

;	
; PUTS
;
; sends NUL terminated ASCII string (address in R0) to UART #1 window
;
PUTS	PUSH	{R4, LR} 		; push R4 and LR
	MOV	R4, R0			; copy R0
PUTS0	LDRB	R0, [R4], #1		; get character + increment R4
	CMP	R0, #0			; 0?
	BEQ	PUTS1			; return
	BL	PUT			; put character
	B	PUTS0			; next character
PUTS1	POP	{R4, PC} 		; pop R4 and PC
	
	END