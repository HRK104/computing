;
; CS1022 Introduction to Computing II 2018/2019
; Polling Example
;

; Pin Control Block registers
PINSEL4		EQU	0xE002C010

; GPIO registers
FIO2DIR1	EQU	0x3FFFC041
FIO2PIN1	EQU	0x3FFFC055

	AREA	RESET, CODE, READONLY
	ENTRY

	; Enable P2.10 for GPIO
	LDR	R4, =PINSEL4	; load address of PINSEL4
	LDR	R5, [R4]	; read current PINSEL4 value
	BIC	R5, #(0x3 << 20); modify bits 20 and 21 to 00
	STR	R5, [R4]	; write new PINSEL4 value

	; Set P2.10 for input
	LDR	R4, =FIO2DIR1	; load address of FIO2DIR1
	LDRB	R5, [R4]	; read current FIO2DIR1 value
	BIC	R5, #(0x1 << 2)	; modify bit 2 to 0 for input, leaving other bits unmodified
	STRB	R5, [R4]	; write new FIO2DIR1

	LDR	R4, =FIO2PIN1	; load address of FIO2PIN1

	MOV	R7, #0		; count = 0

whRepeat			; while (forever) {
	LDRB	R6, [R4]	;   lastState = FIO2DIR1 & 0x4
	AND	R6, R6, #0x4	;

	; keep testing pin state until it changes

whPoll				;   do {
	LDRB	R5, [R4]	;     currentState = FIO2DIR1 & 0x4
	AND	R5, R5, #0x4	;
	CMP	R5, R6		;
	BEQ	whPoll		;   } while (currentState == lastState)

	; pin state has changed ... but has it changed to 0?

	CMP	R5, #0		;   if (currentState == 0) {
	BNE	eIf		;

	ADD	R7, R7, #1	;     tmp++
eIf
	B	whRepeat	; }

	END
