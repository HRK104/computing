	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2011 -- 2019.

	EXPORT	start
start

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN 	EQU	0xE0028010
	
start_clac
   BL All_LED_OFF

   MOV R0,#0           ;the current number
   MOV R1,#0           ;the previous inputed number
   MOV R12,#0          ;R12=0 -> change current number into the previous number
                       ;R12=1 -> allow to calculate addition
					   ;R12=2 -> allow to calculate subtraction
					   ;R12=3 -> allow to clear display
   
   LDR R2,=IO1PIN
waitingForPressed
   LDR  R3,[R2]
checkP1_20
   AND  R4,R3,#0x00100000
   CMP  R4,#0
   BNE  checkP1_21
   B  pressed_MostLeft  ;R4=0
checkP1_21
   AND  R4,R3,#0x00200000
   CMP  R4,#0
   BNE  checkP1_22
   B  pressed_SecondLeft ;R4=0
checkP1_22
   AND  R4,R3,#0x00400000
   CMP  R4,#0
   BNE  checkP1_23
   B  pressed_SecondRight ;R4=0 
checkP1_23
   AND  R4,R3,#0x00800000
   CMP  R4,#0
   BNE  end_Loop
   B  pressed_MostRight  ;R4=0 
end_Loop   
   B    waitingForPressed


pressed_MostRight  
   ;CMP R0,#7
   ;BEQ pressed_MostRight2
   CMP R12,#3
   BEQ clearDisplay
   ADD R0,R0,#1
pressed_MostRight2  
   BL  All_LED_OFF
   BL  expressNumber

pressed_MostRight_while
   LDR R10,=1000000
wait2
   subs R10,R10,#1
   BNE wait2
   LDR  R3,[R2]
   AND  R4,R3,#0x00800000
   CMP  R4,#0
   BEQ  pressed_MostRight_while
   MOV R9,R0
   B    waitingForPressed
 




pressed_SecondRight
   CMP R12,#3
   BEQ clearDisplay
   SUB R0,R0,#1
pressed_SecondRight2  
   BL  All_LED_OFF
   BL  expressNumber

pressed_SecondRight_while
   LDR R10,=1000000
wait
   subs R10,R10,#1
   BNE wait
   LDR  R3,[R2]
   AND  R4,R3,#0x00400000
   CMP  R4,#0
   BEQ  pressed_SecondRight_while
   MOV R9,R0
   B    waitingForPressed 
   
   
   
   
   
   
pressed_SecondLeft
   MOV R11,#0
   LDR R8, =0x00F42400 
pressed_SecondLeft_while
   LDR R10,=1000000
   ADD  R11,R11,#1
wait3
   subs R10,R10,#1
   ADD  R11,R11,#1
   BNE wait3
   LDR  R3,[R2]
   AND  R4,R3,#0x00200000
   CMP  R4,#0
   BEQ  pressed_SecondLeft_while
   CMP  R11,R8                  ;press more than 2seconds
   BHS  P1_21_longPressed
   ;B   pressed_MostRight
   CMP R12,#1
   BEQ calculate_add
   CMP R12,#2
   BEQ calculate_sub
   CMP R12,#3
   BEQ waitingForPressed
   ;B   pressed_MostRight
   MOV R1,R0
   MOV R0,#0
   MOV R12,#1
   BL  All_LED_OFF
   B   pressed_SecondLeft_end
calculate_add
   ;B   pressed_MostRight
   ADD R0,R0,R1
   BL  expressNumber
   MOV R12,#3
pressed_SecondLeft_end   
   B   waitingForPressed

P1_21_longPressed        ;around 3 seconds
   MOV R0, R1
   MOV R1, #0
   MOV R12,#0
   BL  All_LED_OFF
   B   waitingForPressed
   
   
   
pressed_MostLeft
   MOV R11,#0;timer
   LDR R8, =0x00F42400
pressed_MostLeft_while
   LDR R10,=1000000
   ADD  R11,R11,#1
wait4
   subs R10,R10,#1
   ADD  R11,R11,#1
   BNE wait4
   LDR  R3,[R2]
   AND  R4,R3,#0x00100000
   CMP  R4,#0
   BEQ  pressed_MostLeft_while
   CMP  R11,R8                  ;press more than 2seconds
   BHS  P1_20_longPressed

   CMP R12,#1
   BEQ calculate_add
   CMP R12,#2
   BEQ calculate_sub
   CMP R12,#3
   BEQ waitingForPressed
   MOV R1,R0
   MOV R0,#0
   MOV R12,#2
   BL  All_LED_OFF
   B   pressed_MostLeft_end
calculate_sub
   SUB R0,R1,R0
   BL  expressNumber
   MOV R12,#3
pressed_MostLeft_end   
   B   waitingForPressed
   
   
P1_20_longPressed   ;around 3 seconds
   B   start_clac
  

clearDisplay          
   BL  All_LED_OFF
   ;MOV R0,#0
   MOV R12,#0
   LDR R10,=4000000
wait5
   subs R10,R10,#1
   BNE wait5
   B   waitingForPressed
   



;expressNumber subroutine
;parameter
; R0: the number to be expressed by the LEDs
expressNumber
    ;STMFD SP!,{R1-R12,LR}
	;STMFD SP!,{R1-R12}
	STMFD SP!,{R1-R3,R9}
	;MOV R4,R0              ;R4 = original number
	
	;AND R8,R4,#0x80000000
	;CMP R8,#0x80000000
	;BNE positive_number
	;MOV R0,R12
	;BL  negative_number
	;MOV R4,R0
positive_number	
	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register

	ldr	r3,=0x00010000	; start with P1.16.
;	MOV R10,R3
	
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
	BNE end_expressNumber
	str	r3,[r2]	   	; clear the bit -> turn on the LED
end_expressNumber
;    MOV R0,R4
	
	;LDMFD SP!,{R1-R12,PC}
	;LDMFD SP!,{R1-R12}
	LDMFD SP!,{R1-R3,R9}
	BX R14
  
  
  
  
;negative_number subroutine
;parameter
; R0: the original minus number
;return
; R0: the modified number
;negative_number
;    STMFD SP ! , {R4-R5 }
;	MOV R4,R0;
;	MOV R5,#0xFFFFFFFF;
;	EOR R4,R4,R5
;	ADD R4,R4,#1
;	MOV R0,R4
;	LDMFD SP ! , {R4-R5 }
;	BX R14


;All_LED_OFF subroutine
All_LED_OFF
    STMFD SP ! , {R1-R3 }
	


	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register
	LDMFD SP ! , {R1-R3 }
	BX R14

	END