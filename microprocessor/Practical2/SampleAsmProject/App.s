	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2011 -- 2019.

;	EXPORT	start
;start

;IO1DIR	EQU	0xE0028018
;IO1SET	EQU	0xE0028014
;IO1CLR	EQU	0xE002801C

;	ldr	r1,=IO1DIR
;	ldr	r2,=0x000f0000	;select P1.19--P1.16
;	str	r2,[r1]		;make them outputs
;	ldr	r1,=IO1SET
;	str	r2,[r1]		;set them to turn the LEDs off
;	ldr	r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register

;	ldr	r5,=0x00100000	; end when the mask reaches this value
;wloop	ldr	r3,=0x00010000	; start with P1.16.
;floop	str	r3,[r2]	   	; clear the bit -> turn on the LED

;delay for about a half second
;	ldr	r4,=4000000
;dloop	subs	r4,r4,#1
;	bne	dloop

;	str	r3,[r1]		;set the bit -> turn off the LED
;	mov	r3,r3,lsl #1	;shift up to next bit. P1.16 -> P1.17 etc.
;	cmp	r3,r5
;	bne	floop
;	b	wloop
;stop	B	stop

;	END
		
    EXPORT	start
start

sample1 EQU 0xFFFFEB43 ;=1049
sample2 EQU 0xFFFFFBE7 ;=-1049
sample3 EQU 0x000062DA ;=25306

RESULT_ADD EQU 0x00040000

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C


start_light
    ;LDR R6,=RESULT_ADD
	MOV R11,#0       ;R11: 0 = the number is positive, 1 = number is negative
    MOV R5,#0        ;counter of digits
	LDR R12,=sample1 ;r12= original number
	AND R9,R12,#0x80000000
	CMP R9,#0x80000000
	BNE positive_number
	MOV R0,R12
	BL  negative_number
	MOV R12,R0
	MOV R11,#1
positive_number
	MOV R0,R12       ;r0 = numerator
while_digit               ;check the number of digits
    MOV r1,#10       ;r1 = 10(divisor)
    ADD R5,R5,#1
	BL   UDIV0
	CMP R0,#0
	BNE while_digit
	
	CMP R11,#1
	BNE pushing
	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		    ;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		    ;set them to turn the LEDs off
	ldr	r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register   
	ldr	r3,=0x00010000	; start with P1.16.
	str	r3,[r2]	   	    ; clear the bit -> turn on the LED at P1.16
	mov	r3,r3,lsl #1	;shift up to next bit. P1.16 -> P1.17 etc.
	mov	r3,r3,lsl #1	;shift up to next bit. P1.17 -> P1.18 etc.
	str	r3,[r2]	   	    ; clear the bit -> turn on the LED at P1.18
	mov	r3,r3,lsl #1	;shift up to next bit. P1.18 -> P1.19 etc.
	str	r3,[r2]	   	    ; clear the bit -> turn on the LED P1.19
	
	ldr	r4,=16000000
n_loop	subs	r4,r4,#1
	bne	n_loop
	
	
	
pushing	
	CMP R5,#0
	BEQ blank_time;end_pushing
	MOV R0,R5     ;R0 = parameter for divisor subroutine
    BL   divisor
	MOV R7,R0         ;R7 = divisor
    MOV R1,R0     ;R1 = parameter divisor for UDIV subroutine
	MOV R0,R12    ;R0 = parameter numerator for UDIV subroutine
	BL   UDIV0
	MOV R6,R0     ;R6 = quotinent
	
  
	
	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register

	ldr	r3,=0x00010000	; start with P1.16.
	MOV R10,R3
	
	
	AND R9,R0,#0x0000000F
	CMP R9,#0x00000000
	BEQ lightall        ;the number is 0
	MUL R6,R7,R6        ;R6 = quotinent * divisor
	SUB R12,R12,R6      ;original number -= quotinent * divisor
firstbit	
	AND R9,R0,#0x00000008 ;
	CMP R9,#0x00000008
	BNE secondbit
	str	r3,[r2]	   	; clear the bit -> turn on the LED
secondbit	
	mov	r3,r3,lsl #1	;shift up to next bit. P1.16 -> P1.17 etc.
	AND R9,R0,#0x00000004
	CMP R9,#0x00000004
	BNE thirdbit
	str	r3,[r2]	   	; clear the bit -> turn on the LED
thirdbit	
	mov	r3,r3,lsl #1	;shift up to next bit. P1.17 -> P1.18 etc.
	AND R9,R0,#0x00000002
	CMP R9,#0x00000002
	BNE fourthbit
	str	r3,[r2]	   	; clear the bit -> turn on the LED
fourthbit
    mov	r3,r3,lsl #1	;shift up to next bit. P1.18 -> P1.19 etc.
	AND R9,R0,#0x00000001
	CMP R9,#0x00000001
	BNE time_count
	str	r3,[r2]	   	; clear the bit -> turn on the LED
	B   time_count
	
lightall
    MOV R9,#4
lightall_2	
	CMP R9,#0
	BEQ time_count
	str	r3,[r2]	   	; clear the bit -> turn on the LED
	mov	r3,r3,lsl #1	;shift up to next bit. P1.16 -> P1.17 etc.
	SUB R9,R9,#1
	B lightall_2
	
time_count
    ;delay for about a half second
	ldr	r4,=16000000
dloop	subs	r4,r4,#1
	bne	dloop
	
	MOV R3,R10
	;B   while_light
	
;end_light

    SUB  R5,R5,#1
	B   pushing
	
	
blank_time	
    ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO1CLR
time_count_for_blank
    ;delay for about a half second
	ldr	r4,=16000000
blankloop	subs	r4,r4,#1
	bne	blankloop
    B   start_light
	
	
stop B	stop

	

;divisor subroutine
;parameter
; R0 = number
;return
; R0 = 10 ^ number
divisor
   ;STMFD SP ! , {R4-R13 , LR}
   STMFD SP!,{R4-R12,LR}
   ;PUSH {R4-R13, LR}
   ;MOV R4,R0
   CMP R0,#1
   BEQ divisor_is_1
   SUB R4,R0,#1
   MOV R0,#1
   MOV R5,#10
whi_div
   MUL R0,R5,R0
   SUB R4,R4,#1
   CMP R4,#0
   BNE whi_div
divisor_end
   ;LDMFD SP ! , {R4-R13 , PC}
   LDMFD SP!,{R4-R12,PC}
   ;POP {R4-R13, LR}
divisor_is_1
   MOV R0,#1
   B   divisor_end



;division subroutine
;parameter
;  R0 = N (numerator)
;  R1 = D (divisor)
;return
;  R0 = Q (quotient)
;  R1 = R (reminder)
;
UDIV0 
   ;PUSH {R4, R5, R6, LR} ; push R4, R5, R6 and return address
   STMFD SP ! , {R4-R12 , LR}
   ;PUSH {R4-R13, LR}
   MOV R2, R0 ; R2 = N
   MOV R3, R1 ; R3 = D
   MOV R0, #0 ; R0 = Q = 0
   MOV R1, #0 ; R1 = R = 0
   MOV R4, #31 ; R4 = i = 31
   MOV R5, #1 ; R5 = 1 (used as a mask)
UDIV1 
   CMP R4, #0 ; i == 0 ?
   BLT UDIV3 ; finished
   MOV R1, R1, LSL #1 ; R = R << 1
   AND R6, R5, R2, LSR R4 ; R[0] = N[i]
   ORR R1, R1, R6 ;
   CMP R1, R3 ; R >= D?
   BLT UDIV2 ;
   SUB R1, R1, R3 ; R = R - D
   ORR R0, R0, R5, LSL R4 ; Q[i] = 1
UDIV2
   SUB R4, R4, #1 ; i = i - 1
   B UDIV1 ; next bit
UDIV3 
   ;POP {R4, R5, R6, PC} ; pop into R4, R5, R6 and return
   LDMFD SP ! , {R4-R12 , PC}
   ;POP {R4-R13, LR}


;negative_number subroutine
;parameter
; R0: the original minus number
;return
; R0: the modified number
negative_number
    STMFD SP ! , {R4-R12 , LR}
	MOV R4,R0;
	MOV R5,#0xFFFFFFFF;
	EOR R4,R4,R5
	ADD R4,R4,#1
	MOV R0,R4
	LDMFD SP ! , {R4-R12 , PC}
	
	
	END
