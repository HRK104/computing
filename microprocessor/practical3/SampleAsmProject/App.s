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





start_clac
   BL All_LED_OFF
   
   
   ldr	r1,=IO1DIR
   ldr	r2,=0x000f0000	;select P1.19--P1.16
   str	r2,[r1]		;make them outputs
   ldr	r1,=IO1SET
   str	r2,[r1]		;set them to turn the LEDs off
   ldr	r2,=IO1CLR
   
   ldr	r12,=0x00010000	; start with P1.16.
   
   
   MOV R2,#0           ;the current displayed number
   MOV R3,#0          ;the calculated number
   
   
   LDR R1,=IO1PIN   
waitingForPressed  
   ;MOV R4,#4
;gotoP1_20   
;   CMP R4,#0
;   mov	r12,r12,lsl #1	;shift up to next bit.   e.g) P1.16 -> P1.17 etc.
;   SUB  R4,R4,#1
;   BNE gotoP1_20
   ;r3: P1.20  the most left button
   LDR  R5,[r1]
   AND  R6,R5,#0x00100000
   CMP  R6,#0
   ;BNE  pressed_mostLeft
   ;BEQ  pressed_mostLeft
   BNE  check_P1_21
   BL   pressed_mostLeft2
check_P1_21
;   mov	r12,r12,lsl #1	;shift up to next bit.   e.g) P1.20 -> P1.21 etc. the second most left button
   LDR  R5,[r1]
   AND  R6,R5,#0x00200000
   CMP  R6,#0
   ;BEQ  pressed_secondmostLeft
   BNE  check_P1_22
   BL   pressed_secondmostLeft2
check_P1_22   
;   mov	r12,r12,lsl #1	;shift up to next bit.   e.g) P1.21 -> P1.22 etc. the second most right button
   LDR  R5,[r1]
   AND  R6,R5,#0x00400000
   CMP  R6,#0
   ;BEQ  pressed_secondmostRight
   BNE  check_P1_23
   BL   pressed_secondmostRight2
check_P1_23   
;   mov	r12,r12,lsl #1	;shift up to next bit.   e.g) P1.22 -> P1.23 etc. the most right button
   LDR  R5,[r1]
   AND  R6,R5,#0x00800000
   CMP  R6,#0
   ;BNE  pressed_mostRight
   ;BEQ  pressed_mostRight
   ;BNE  endLoop
   BEQ  endLoop
   B   pressed_mostRight  ;BNE
endLoop   
   MOV R11,R10
   MOV R10,R11

   B    waitingForPressed

;stop	B	stop

pressed_mostRight
   CMP R2,#7
   BEQ pressed_mostRight_next
   ADD R2,R2,#1
   MOV R8,R0        ;R3(tmp) = R0
   MOV R0,R2        ;R0 = the current number
   BL  expressNumber
   MOV R0,R8
pressed_mostRight_next   
   ldr	r7,=16000000
while_mostRight
   AND  R6,R5,#0x00800000
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CMP  R6,#0
   ;BEQ  while_mostRight
   CMP  R6,#0
   BEQ  while_mostRight
   BL   pressed_mostRight2
   B    waitingForPressed
	

;pressed_mostRight subroutine
;   :adding the current displayed number
;parameter 
; R2: the current displayed number
pressed_mostRight2
   
   STMFD SP!,{R4-R12,LR}
   ;CMP R2,#7
   ;BEQ end_pressed_mostRight2
   ;ADD R2,R2,#1
   MOV R3,R0        ;R3(tmp) = R0
   MOV R0,R2        ;R0 = the current number
   BL  expressNumber
end_pressed_mostRight2 
   MOV R0,R3        ;R0 = tmp
   LDMFD SP!,{R4-R12,PC}
   
 
;pressed_secondmostRight subroutine
;   :subtracting the current displayed number
;parameter 
; R2: the current displayed number
pressed_secondmostRight2
   STMFD SP!,{R4-R12,LR}
   CMP R2,#0x00000008
   BEQ end_pressed_secondmostRight2
   SUB R2,R2,#1
   MOV R3,R0        ;R3(tmp) = R0
   MOV R0,R2        ;R0 = the current number
   BL  expressNumber
end_pressed_secondmostRight2
   MOV R0,R3        ;R0 = tmp
   LDMFD SP!,{R4-R12,PC} 


;pressed_secondmostLeft subroutine
;    :adding the current displaed number to the calculated number
;parameter
; R2: the cuurent displayed number
; R3: the calculated number
;return 
; R0: the current displayed number (=0)
; R1: the calculated number
pressed_secondmostLeft2
   ;delay for about a half second
	;ldr	r8,=4000000
;dloop	subs	r8,r8,#1
	;bne	dloop
	;LDR  R5,[r1]
   ;AND  R6,R5,r12
   ;CMP  R6,#0
   ;BEQ  pressed_secondmostLeft
	
	
   STMFD SP!,{R4-R12,LR}
   MOV R4,#0x00000008
   AND R5,R2,R4          ;most significant bit of the current number
   AND R6,R3,R4          ;most significant bit of the calculated number
   CMP R5,R4
   BEQ checkOvernegative_add ;the current number < 0
   CMP R6,R4
   BNE checkOverPositive_add
   ADD R3,R3,R2          ;the calculated number += the current displayed number
   B   end_pressed_secondmostLeft2
  
checkOvernegative_add
   CMP R6,R4
   BEQ checkOvernegative_add2 ; (the current number < 0) && (the calculated number<0)
   ADD R3,R3,R2          ;the calculated number += the current displayed number
   B   end_pressed_secondmostLeft2
checkOvernegative_add2  ; (the current number < 0) && (the calculated number<0)
   ADD R3,R3,R2          ;the calculated number += the current displayed number
   AND R7,R3,R4
   CMP R7,R4
   BEQ end_pressed_secondmostLeft2
   MOV R7,#0x00000008    ;the calculated number <-8, thus make the calculated number = -8
   B   end_pressed_secondmostLeft2
  
checkOverPositive_add
   ADD R3,R3,R2          ;the calculated number += the current displayed number
   AND R7,R3,R4      
   CMP R7,R4
   BNE end_pressed_secondmostLeft2
   MOV R3,#7             ;the calculated number >7, thus make the calculated number = 7
   B   end_pressed_secondmostLeft2
end_pressed_secondmostLeft2 
  MOV R9,R0
  MOV R0,R3
  BL  expressNumber
  MOV R0,R9
  MOV R2,#0
  LDMFD SP!,{R4-R12,PC} 
  
  
  
  
;pressed_mostLeft subroutine
;    :adding the current displaed number to the calculated number
;parameter
; R2: the cuurent displayed number
; R3: the calculated number
;return 
; R2: the current displayed number (=0)
; R3: the calculated number
pressed_mostLeft2
   ADD R2,R2,#1
   STMFD SP!,{R4-R12,LR}
   MOV R4,#0x00000008
   AND R5,R2,R4          ;most significant bit of the current number
   AND R6,R3,R4          ;most significant bit of the calculated number
   CMP R5,R4
   BEQ checkOvernegative_sub ;the current number < 0
   SUB R3,R3,R2          ;the calculated number -= the current displayed number
   B   end_pressed_mostLeft2
  
checkOvernegative_sub
   CMP R6,R4
   BEQ checkOvernegative_sub2 ; (the current number < 0) && (the calculated number<0)
   SUB R3,R3,R2          ;the calculated number -= the current displayed number
   B   end_pressed_mostLeft2
checkOvernegative_sub2  ; (the current number < 0) && (the calculated number<0)
   SUB R3,R3,R2          ;the calculated number -= the current displayed number
   AND R7,R3,R4
   CMP R7,R4
   BEQ end_pressed_mostLeft2
   MOV R7,#0x00000008    ;the calculated number <-8, thus make the calculated number = -8
   B   end_pressed_mostLeft2
  
end_pressed_mostLeft2
  MOV R9,R0
  MOV R0,R3
  BL  expressNumber
  MOV R0,R9
  MOV R2,#0
  LDMFD SP!,{R4-R12,PC}   
  
 

;afterCulculate subroutine
;    : display the result of the last calculation, if any, until one of the rightmost two buttons is pressed. 
;      The first press of either of those buttons should clear the display.
;return
; R0:the current number (=0)
; R1:the calculated number (=0)
afterCulculate
   STMFD SP!,{R4-R12,LR}
while_afterCalculate
   MOV R4,#6
gotoP1_22   
   CMP R4,#0
   mov	r3,r3,lsl #1	;shift up to next bit.   e.g) P1.16 -> P1.17 etc.
   SUB  R4,R4,#1
   BNE gotoP1_22
   ;r3: P1.22  the most left button
   
   ;LDR  R5,[r1]
   ;AND  R6,R5,R3
   ;CMP  R6,#0
   ;BEQ  pressed_mostLeft
   
   ;mov	r3,r3,lsl #1	;shift up to next bit.   e.g) P1.20 -> P1.21 etc. the second most left button
   ;LDR  R5,[r1]
   ;AND  R6,R5,R3
   ;CMP  R6,#0
   ;BEQ  pressed_secondmostLeft
   ;mov	r3,r3,lsl #1	;shift up to next bit.   e.g) P1.21 -> P1.22 etc. the second most right button
   LDR  R5,[r1]
   AND  R6,R5,R3
   CMP  R6,#0
   BEQ  start_clac
   mov	r3,r3,lsl #1	;shift up to next bit.   e.g) P1.22 -> P1.23 etc. the most right button
   LDR  R5,[r1]
   AND  R6,R5,R3
   CMP  R6,#0
   BEQ  start_clac
   B    while_afterCalculate



;enerNumber subroutine
;return 
; R0: the number the user entered
;enerNumber
;    STMFD SP!,{R4-R12,LR}
;	MOV R4,#0
	

;expressNumber subroutine
;parameter
; R0: the number to be expressed by the LEDs
expressNumber
    STMFD SP!,{R4-R12,LR}
	MOV R4,R0              ;R4 = original number
	MOV R5,R1            
	MOV R6,R2
	MOV R7,R3
	
	AND R8,R4,#0x80000000
	CMP R8,#0x80000000
	BNE positive_number
	MOV R0,R12
	BL  negative_number
	MOV R4,R0
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
	;MOV R10,R3

firstbit	
	AND R8,R4,#0x00000008 ;
	CMP R8,#0x00000008
	BNE secondbit
	str	r3,[r2]	   	; clear the bit -> turn on the LED
secondbit	
	mov	r3,r3,lsl #1	;shift up to next bit. P1.16 -> P1.17 etc.
	AND R8,R4,#0x00000004
	CMP R8,#0x00000004
	BNE thirdbit
	str	r3,[r2]	   	; clear the bit -> turn on the LED
thirdbit	
	mov	r3,r3,lsl #1	;shift up to next bit. P1.17 -> P1.18 etc.
	AND R8,R4,#0x00000002
	CMP R8,#0x00000002
	BNE fourthbit
	str	r3,[r2]	   	; clear the bit -> turn on the LED
fourthbit
    mov	r3,r3,lsl #1	;shift up to next bit. P1.18 -> P1.19 etc.
	AND R8,R4,#0x00000001
	CMP R8,#0x00000001
	BNE end_expressNumber
	str	r3,[r2]	   	; clear the bit -> turn on the LED
end_expressNumber
    MOV R0,R4
	MOV R1,R5
	MOV R2,R6
	MOV R3,R7
	LDMFD SP!,{R4-R12,PC}
	
	
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
	
	
;All_LED_OFF subroutine
All_LED_OFF
    STMFD SP ! , {R4-R12 , LR}
	
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
end_All_LED_OFF	
	LDMFD SP ! , {R4-R12 , PC}
	END