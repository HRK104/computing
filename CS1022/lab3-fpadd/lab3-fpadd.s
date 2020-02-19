;
; CS1022 Introduction to Computing II 2018/2019
; Lab 3 - Floating-Point Addition
;

	AREA	RESET, CODE, READONLY
	ENTRY

;
; Test Data
;
FP_A	EQU	0x41C40000
FP_B	EQU	0x41960000


	; initialize system stack pointer (SP)
	LDR	SP, =0x40010000
	
	
	LDR R0, =0x40600000
	BL  fpdecode
    BL  fpencode
	;LDR R0, =FP_A
	;BL  fpdecode
    ;BL  fpencode
	;LDR R0, =FP_B
	;BL  fpdecode
    ;BL  fpencode
	
    
	LDR	r0, =FP_A		; test value A
	LDR	r1, =FP_B		; test value B
	BL	fpadd
	LDR R0, =0x40700000
	LDR R1, =0x40A40000
	BL	fpadd
	

stop	B	stop


;
; fpdecode
; decodes an IEEE 754 floating point value to the signed (2's complement)
; fraction and a signed 2's complement (unbiased) exponent
; parameters:
;	r0 - ieee 754 float
; return:
;	r0 - fraction (signed 2's complement word)
;	r1 - exponent (signed 2's complement word)
;
fpdecode
   
	;
	; your decode subroutine goes here
	;
   PUSH{R4-R12,LR}
   MOV R4,R0           ;R4 =  ieee 754 float
   MOV R7,#0           ;R7 = (boolean) isPositive 
fpdecode01
   LDR R5,=0x80000000
   AND R5,R5,R4
   MOV R5,R5,LSR #31   ;if R5 = 1,  negative
   CMP R5,#0
   BEQ fpdecode1
   MVN R4,R4           ;inverse all bits
   ADD R4,R4,#1        ;add 1
   MOV R7,#1           ;R7 = 1(!isPositive) 
fpdecode1
   LDR R5,=0x7F800000  ;R5 = mask for exponent
   AND R5,R4,R5        ;and
   MOV R5,R5,LSL #1    ;R5<<1
   MOV R5,R5,LSR #24   ;R5>>24
   LDR R6,=0x007FFFFF  ;R6 = mask for fraction
   AND R6,R4,R6        ;and
fpdecodeEnd
   MOV R0,R6           ;R0 = fraction
   MOV R1,R5           ;R1 = exponent
   POP {R4-R12, PC}

;
; fpencode
; encodes an IEEE 754 value using a specified fraction and exponent
; parameters:
;	r0 - fraction (signed 2's complement word)
;	r1 - exponent (signed 2's complement word)
;   r2 - sign number
; result:
;	r0 - ieee 754 float
;
fpencode

	;
	; your encode subroutine goes here
	;
	PUSH{R4-R12,LR}
	MOV R4,R0           ;R4 = fraction
	MOV R5,R1           ;R5 = exponent
	;MOV R7,R2           ;R7 = sign number
fpencode1
    MOV R4,R4,LSL #9    ;R4 <<9
    MOV R4,R4,LSR #9    ;R4 >>9
	MOV R5,R5,LSL #23   ;R5 = exponent<<23
	;MOV R7,R7,LSL #31   ;R7 << 31
	LDR R6,=0x00000000
	ORR R6,R6,R4        ;put fraction into R6
	ORR R6,R6,R5        ;put exponent into R6
	;ORR R6,R6,R7        ;put sign into R6
fpencodeEnd
    MOV R0,R6
	POP {R4-R12,PC}

;
; fpadd
; adds two IEEE 754 values
; parameters:
;	r0 - ieee 754 float A
;	r1 - ieee 754 float B
; return:
;	r0 - ieee 754 float A+B
;
fpadd

	;
	; your add subroutine goes here
	;
   PUSH{R4-R12,LR}
   MOV R4,R0           ;R4 = float A
   MOV R5,R1           ;R5 = float B
fpadd1
   LDR R2,=0x80000000  ;R2 = mask
   AND R2,R2,R4        
   MOV R2,R2,LSR #31   ;if R2 = 1, floatA is negative
   MOV R0,R4           ;R0 = float A
   BL  fpdecode        ;go to fpdecode subroutine
   MOV R6,R0           ;R6 = fraction of float A
   MOV R7,R1           ;R7 = exponent of float A
fpadd2   
   LDR R3,=0x80000000  ;R3 = mask
   AND R3,R3,R5        ;if R3 = 1, floatB is negative
   MOV R3,R3,LSR #31   ;if R3 = 1, floatB is negative
   MOV R0,R5           ;R0 = float B
   BL  fpdecode        ;go to fpdecode subroutine
   MOV R8,R0           ;R8 = fraction of float B
   MOV R9,R1           ;R9 = exponent of float B
fpadd3
   CMP R7,R9           ;R7 = R9?
   BEQ fpadd6          ;if so, go to fpadd6
   BGT fpadd5          ;if R7 > R9, go to fpadd5
   SUB R10,R9,R7       ;R10 = R9 - R7
   ;MOV R6,R6,LSR #1    ;R6>>1
   LDR R11,=0x80000000
   ;SUB R10,R10,#1      ;R10--
   ;MOV R11,R11,LSR R10   ;R6>>R10
   ORR R6,R6,R11   
   SUB R10,R10,#1      ;R10--
   MOV R6,R6,LSR R10   ;R6>>R10
   MOV R12,R9          ;R12(common exponet) = R9
   MOV R6,R6,LSR #8    ;R6>>8
   B   fpadd4
fpadd5
   SUB R10,R7,R9       ;R10 = R7 - R9
   ;MOV R8,R8,LSR #1    ;R8>>1
   LDR R11,=0x80000000
   ;SUB R10,R10,#1      ;R10--
   ;MOV R11,R11,LSR R10   ;R11>>R10
   ORR R8,R8,R11   
   SUB R10,R10,#1      ;R10--
   MOV R8,R8,LSR R10   ;R7>>R10
   MOV R12,R7          ;R12(common exponet) = R7
   MOV R8,R8,LSR #8    ;R8>>8
   B   fpadd4
fpadd6
   MOV R12,R7          ;R12(common exponet) = R7
fpadd4  
   ;CMP R2,R3           ;R2 = R3? (Is it both positive or negative?)
   ;BNE fpadd9          ;
   ADD R6,R6,R8        ;R6 = total of each fraction's abosolute value
   B   fpaddEnd  
fpadd9
   CMP R6,R8           ;R6 = R8?
   BGT fpadd7          ;if R6 > R8, fpadd7
   BLT fpadd8          ;if R6 < R8, fpadd8
fpadd7
   SUB R6,R6,R8        ;R6 = R6-R8  R6 = total of each fraction
   B   fpaddEnd
fpadd8
   SUB R6,R8,R6        ;R6 = R8-R6
   MOV R2,R3           ;R2 = sign number
   B   fpaddEnd

fpaddEnd 
   ;MOV R6,R6,LSR #8    ;R6>>8
   MOV R0,R6          ;R0 = fraction
   MOV R1,R12         ;R1 = exponent
   BL  fpencode
   POP {R4-R12,PC}

	END
