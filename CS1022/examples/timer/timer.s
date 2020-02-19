;
; CS1022 Introduction to Computing II 2018/2019
; Timer Example
;

T0TCR	EQU	0xE0004004
T0MR0	EQU	0xE0004018
T0MCR	EQU	0xE0004014

	AREA	RESET, CODE, READONLY
	ENTRY

	; Set match register for 5 secs using Match Register
	; Assuming a 1Mhz clock input to TIMER0, set MR
	; MR0 (0xE0004018) to 5,000,000
	LDR	R4, =T0MR0
	LDR	R5, =5000000
	STR	R5, [R4]

	; Stop on match using Match Control Register
	; Set bit 2 of MCR (0xE0004014) to 1 to stop the counter after
	; match (5 secs)
	LDR	R4, =T0MCR
	LDR	R5, =0x04
	STRH	R5, [R4]

	; Start TIMER0 using the Timer Control Register
	; Set bit 0 of TCR (0xE0004004) to enable the timer
	LDR	R4, =T0TCR
	LDR	R5, =0x01
	STRB	R5, [R4]


	; Keep testing bit 0 of the Timer Control Register (0xE0004004)
	; until the 1 that we set above becomes 0 again, indicating that
	; the timer has stopped
whWait
	LDRB	R5, [R4]
	TST	R5, #1
	BNE	whWait

	; timer finished!

STOP	B	STOP

	END
