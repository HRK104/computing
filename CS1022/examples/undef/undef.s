;
; CS1022 Introduction to Computing II 2018/2019
; Undefined Instruction Exception Example
;


Undef_Stack_Size EQU	0x80

Mode_USR        EQU     0x10
Mode_UND        EQU     0x1B
I_Bit           EQU     0x80            ; when I bit is set, IRQ is disabled
F_Bit           EQU     0x40            ; when F bit is set, FIQ is disabled

	AREA	RESET, CODE, READONLY
	ENTRY

	; Exception Vectors

	B	Reset_Handler	; 0x00000000
	B	Undef_Handler	; 0x00000004
	B	SWI_Handler	; 0x00000008
	B	PAbt_Handler	; 0x0000000C
	B	DAbt_Handler	; 0x00000010
	NOP			; 0x00000014
	B	IRQ_Handler	; 0x00000018
	B	FIQ_Handler	; 0x0000001C


;
; Reset Exception Handler
;
Reset_Handler

	;
	; Initialize Stack Pointers (SP) for each mode we are using
	;

	; Stack Top
	LDR	R0, =0x40010000

	; Enter undef mode and set initial SP
	MSR     CPSR_c, #Mode_UND:OR:I_Bit:OR:F_Bit
	MOV     SP, R0
	SUB     R0, R0, #Undef_Stack_Size

	; Enter user mode and set initial SP
	MSR     CPSR_c, #Mode_USR
	MOV	SP, R0

	;
	; Rest of your program goes here
	;

	; Test the emulated POW instruction
	LDR	r4, =3	; test 3^4
	LDR	r5, =4	;

	; This is our undefined instruction opcode
	DCD	0x77F150F4	; POW r0, r4, r5 (r0 = r4 ^ r5)

STOP	B	STOP


;
; Undefined Instruction Exception Handler
; Emulates a POW instruction that computes Rd = Rm^Rn
;
Undef_Handler
	STMFD	sp!, {r0-r12, LR}	; save registers

	LDR	r4, [lr, #-4]		; load undefined instruction
	BIC	r5, r4, #0xFFF0FFFF	; clear all but opcode bits
	CMP	r5, #0x00010000		; check for undefined opcode 0x1
	BNE	endif1			; if (power instruction) {

	BIC	r5, r4, #0xFFFFFFF0	;   isolate Rm register number
	BIC	r6, r4, #0xFFFF0FFF	;   isolate Rn register number
	MOV	r6, r6, LSR #12	;
	BIC	r7, r4, #0xFFFFF0FF	;   isolate Rd register number
	MOV	r7, r7, LSR #8	;

	LDR	r1, [sp, r5, LSL #2]	;   read saved Rm from stack (don’t pop)
	LDR	r2, [sp, r6, LSL #2]	;   read saved Rn from stack (don’t pop)

	BL	power			;   call pow subroutine

	STR	r0, [sp, r7, LSL #2]	;   save result over saved Rd
endif1					; }
	LDMFD	sp!, {r0-r12, PC}^	; restore register and CPSR


;
; The remaining exception handlers are "dummy" handlers
;   that we can replace with real handlers as required by
;   our application.
;

;
; Software Interrupt Exception Handler (dummy handler / placeholder)
;
SWI_Handler
	B	SWI_Handler

;
; Prefetch Abort Exception Handler (dummy handler / placeholder)
;
PAbt_Handler
	B	PAbt_Handler

;
; Data Abort Exception Handler (dummy handler / placeholder)
;
DAbt_Handler
	B	DAbt_Handler

;
; Interrupt ReQuest (IRQ) Exception Handler (dummy handler / placeholder)
;
IRQ_Handler
	B	IRQ_Handler

;
; Fast Interrupt reQuest Exception Handler (dummy handler / placeholder)
;
FIQ_Handler
	B	FIQ_Handler


; power subroutine
; Computes x^y
; paramaters:	r1: x (value)
;		r2: y (value)
; return:	r0: result (variable)
power
	STMFD	sp!, {r1-r2,lr}	; save registers

	CMP	r2, #0			; if (y = 0)
	BNE	else2			; {
	MOV	r0, #1			;   result = 1
	B	endif2			; }
else2					; else {
	MOV	r0, r1			;   result = x
	SUBS	r2, r2, #1		;   y = y - 1
	BEQ	endif3			;   if (y != 0) {
do4					;     do {
	MUL	r0, r1, r0		;       result = result * x
	SUBS	r2, r2, #1		;       y = y - 1
	BNE	do4			;     } while (y != 0)
endif3					;   }
endif2					; }

	LDMFD	sp!, {r1-r2, pc} 	; restore registers and return

	END
