		
		; Definitions  -- references to 'UM' are to the User Manual.


; Timer Stuff -- UM, Table 173

T0	equ	0xE0004000		; Timer 0 Base Address
T1	equ	0xE0008000

IR	equ	0			; Add this to a timer's base address to get actual register address
TCR	equ	4
MCR	equ	0x14
MR0	equ	0x18

TimerCommandReset	equ	2
TimerCommandRun	equ	1
TimerModeResetAndInterrupt	equ	3
TimerResetTimer0Interrupt	equ	1
TimerResetAllInterrupts	equ	0xFF

; VIC Stuff -- UM, Table 41
VIC	equ	0xFFFFF000		; VIC Base Address
IntEnable	equ	0x10
VectAddr	equ	0x30
VectAddr0	equ	0x100
VectCtrl0	equ	0x200

Timer0ChannelNumber	equ	4	; UM, Table 63
Timer0Mask	equ	1<<Timer0ChannelNumber	; UM, Table 63
IRQslot_en	equ	5		; UM, Table 58

	AREA	InitialisationAndMain, CODE, READONLY
	IMPORT	main

; (c) Mike Brady, 2014 -- 2019.

	EXPORT	start
start
; initialisation code
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN 	EQU	0xE0028010
	
IO0DIR      EQU 0xE0028008
IO0SET      EQU 0xE0028004	
IO0CLR      EQU 0xE002800C
IO0PIN      EQU 0xE0028000	
	
; PWM 
PWM_BASE        EQU	 	0xE0014000 
PWMIR		EQU		0xE0014000 
PWMTCR        	EQU		0xE0014004 
PWMTC         	EQU		0xE0014008 
PWMPR         	EQU		0xE001400C 
PWMPC         	EQU		0xE0014010 
PWMMCR        	EQU		0xE0014014 
PWMMR0        	EQU		0xE0014018 
PWMMR1        	EQU		0xE001401C 
PWMMR2        	EQU		0xE0014020 
PWMMR3        	EQU		0xE0014024 
PWMMR4        	EQU		0xE0014040 
PWMMR5        	EQU		0xE0014044 
PWMMR6        	EQU		0xE0014048 
PWMPCR        	EQU		0xE001404C 
PWMLER        	EQU		0xE0014050 

	
; Initialise the VIC
	ldr	r0,=VIC			; looking at you, VIC!

	ldr	r1,=irqhan
	str	r1,[r0,#VectAddr0] 	; associate our interrupt handler with Vectored Interrupt 0

	mov	r1,#Timer0ChannelNumber+(1<<IRQslot_en)
	str	r1,[r0,#VectCtrl0] 	; make Timer 0 interrupts the source of Vectored Interrupt 0

	mov	r1,#Timer0Mask
	str	r1,[r0,#IntEnable]	; enable Timer 0 interrupts to be recognised by the VIC

	mov	r1,#0
	str	r1,[r0,#VectAddr]   	; remove any pending interrupt (may not be needed)

; Initialise Timer 0
	ldr	r0,=T0			; looking at you, Timer 0!

	mov	r1,#TimerCommandReset
	str	r1,[r0,#TCR]

	mov	r1,#TimerResetAllInterrupts
	str	r1,[r0,#IR]

    ldr	r1,=(14745600/1600)-1	 ; 625 ms = 1/1600 second
	;ldr	r1,=(14745600/200)-1	 ; 5 ms = 1/200 second
	str	r1,[r0,#MR0]

	mov	r1,#TimerModeResetAndInterrupt
	str	r1,[r0,#MCR]

	mov	r1,#TimerCommandRun
	str	r1,[r0,#TCR]

;from here, initialisation is finished, so it should be the main body of the main program

while 
    ldr	r1,=IO0DIR
	ldr	r2,=0x00260000	;select P1.19--P1.16
	;ldr	r2,=0x02600000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO0SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO0CLR
	;ldr R4,=0x00220000; colour6
    ;BL lightup
	;B  while
while2
    ;800 = 0.5s
	ldr R5,=timecounter
	ldr R5,[R5]
	CMP R5,#0x0320
	BEQ colour1
	CMP R5,#0x0640
	BEQ colour2
	CMP R5,#0x0960
	BEQ colour3
	CMP R5,#0x0C20
	BEQ colour4
	CMP R5,#0x0FA0
	BEQ colour5
	LDR R7,=0x12C0
	CMP R5,R7
	BEQ colour6
	LDR R7,=0x1600
	CMP R5,R7
	BEQ colour7
	LDR R7,=0x1900
	CMP R5,R7
	BEQ colour8
	
	B   while2
	
colour1
    ldr R4,=0x00020000; colour1
    BL lightup
	B  while2
colour2	
	ldr R4,=0x00040000; colour2
    BL lightup
	B  while2
colour3
	ldr R4,=0x00060000; colour3
    BL lightup
	B  while2
colour4	
	ldr R4,=0x00200000; colour4
    BL lightup
	B  while2
colour5	
	ldr R4,=0x00220000; colour5
    BL lightup
	B  while2
colour6	
	ldr R4,=0x00240000; colour6
    BL lightup
	B  while2
colour7	
	ldr R4,=0x00260000; colour7
    BL lightup
	B  while2
colour8	
    ldr R4,=0x00000000; colour8
    BL lightup
	;MOV R8,#0
	;LDR R9,=timecounter
    ;STR R8,[R9]	

	B  while2

    ;LDR R2,=IO0PIN
	;LDR  R3,[R2]
	;ldr R3,=0x00000002
	;STR R3,[R2]
	
	
	
	
	
	;ldr	r1,=IO0DIR
	;ldr	r2,=0x000f0000	;select P1.19--P1.16
	;str	r2,[r1]		;make them outputs
	;ldr	r1,=IO0SET
	;str	r2,[r1]		;set them to turn the LEDs off
	;ldr	r2,=IO0CLR


;while
;   ldr R4,=0x00040000
;   BL lightup
;   ;BL irqhan
;   ldr R4,=0x00020000
;   BL lightup
;   ;BL irqhan
;   B  while



lightup 
    STMFD SP!,{R3}
    ldr	r1,=IO0DIR
	ldr	r2,=0x00260000	;select P1.19--P1.16
	;ldr	r2,=0x02600000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO0SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO0CLR
; r1 points to the SET register
; r2 points to the CLEAR register
    str	r4,[r2]	   	; clear the bit -> turn on the LED
		
	LDMFD SP!,{R3}
	BX R14
	
	
	
;wloop	b	wloop  		; branch always
;main program execution will never drop below the statement above.

	AREA	InterruptStuff, CODE, READONLY
irqhan	sub	lr,lr,#4
	stmfd	sp!,{r0-r2,lr}	; the lr will be restored to the pc

;this is the body of the interrupt handler

;here you'd put the unique part of your interrupt handler
;all the other stuff is "housekeeping" to save registers and acknowledge interrupts
				
    LDR R0,=timecounter;
	
	LDR R1,[R0];
	ADD R1,R1,#1;
	CMP R1,#0x1900
	BLS next
	MOV R1,#0
next	
	STR R1,[R0];

;this is where we stop the timer from making the interrupt request to the VIC
;i.e. we 'acknowledge' the interrupt
	ldr	r0,=T0
	mov	r1,#TimerResetTimer0Interrupt
	str	r1,[r0,#IR]	   	; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	ldr	r0,=VIC
	mov	r1,#0
	str	r1,[r0,#VectAddr]	; reset VIC

	ldmfd	sp!,{r0-r2,pc}^	; return from interrupt, restoring pc from lr
				; and also restoring the CPSR
				
   area inthhanstuff,data,readwrite
counter space 4
seconds space 4
timecounter     DCD     0		
	
	END	
	
