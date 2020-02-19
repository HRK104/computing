;
; CS1022 Introduction to Computing II 2018/2019
; Blinky Example
;

; TIMER0 registers
T0TCR		EQU	0xE0004004
T0MR0		EQU	0xE0004018
T0MCR		EQU	0xE0004014

; Pin Control Block registers
PINSEL4		EQU	0xE002C010

; GPIO registers
FIO2DIR1	EQU	0x3FFFC041
FIO2PIN1	EQU	0x3FFFC055
FIO2SET1	EQU	0x3FFFC059
FIO2CLR1	EQU	0x3FFFC05D


	AREA	RESET, CODE, READONLY
	ENTRY

	; Enable P2.10 for GPIO
	LDR	R5, =PINSEL4	; load address of PINSEL4
	LDR	R6, [R5]	; read current PINSEL4 value
	BIC	R6, #(0x3 << 20); modify bits 20 and 21 to 00
	STR	R6, [R5]	; write new PINSEL4 value

	; Set P2.10 for output
	LDR	R5, =FIO2DIR1	; load address of FIO2DIR1
	LDRB	R6, [R5]	; read current FIO2DIR1 value
	ORR	R6, #(0x1 << 2)	; modify bit 2 to 1 for output, leaving other bits unmodified
	STRB	R6, [R5]	; write new FIO2DIR1

	; Set match register for 5 secs using Match Register
	;   Assuming a 1Mhz clock input to TIMER0, set MR
	;   MR0 (0xE0004018) to 5,000,000
	LDR	R4, =T0MR0
	LDR	R5, =5000000
	STR	R5, [R4]

	; Stop on match using Match Control Register
	;   Set bit 2 of MCR (0xE0004014) to 1 to stop the counter after
	;   match (5 secs)
	LDR	R4, =T0MCR
	LDR	R5, =0x04
	STRH	R5, [R4]

whBlink
	; Reset TIMER0 using Timer Control Register
	;   Set bit 0 of TCR to 0 to stop TIMER
	;   Set bit 1 of TCR to 1 to reset TIMER
	LDR	R5, =T0TCR
	LDR	R6, =0x2
	STRB	R6, [R5]

	; Start TIMER0 using the Timer Control Register
	;   Set bit 0 of TCR to enable the timer
	LDR	R4, =T0TCR
	LDR	R5, =0x01
	STRB	R5, [R4]

	; Keep testing TCR until the timer has stopped
whWait
	LDRB	R5, [R4]
	TST	R5, #1
	BNE	whWait

	;
	; Timer finished ... invert the LED
	;   Another Read-Modify-Write operation!!
	;

	; read current P2.10 output value
	;   0 or 1 in bit 2 of FIO2PIN1
	LDR	R4, =0x04		;   setup bit mask for P2.10 bit in FIO2PIN1
	LDR	R5, =FIO2PIN1		;
	LDRB	R6, [R5]		;   read FIO2PIN1

	; modify P2.10 output (leaving other pin outputs controlled by
	;   FIO2PIN1 with their original value)
	TST	R6, R4			;   if (LED off)
	BNE	elsOff			;   {
	ORR	R6, R6, R4		;     set bit 2 (turn LED on)
	B	endIf			;   }
elsOff					;   else {
	BIC	R6, R6, R4		;     clear bit 2 (turn LED on)
endIf					;   }

	; write new FIO2PIN1 value
	STRB	R6, [R5]

	; repeat forever
	B	whBlink

	END
