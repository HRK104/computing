;
; CS1021 2018/2019	Lab 5
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
	MOV	R1, #0x50		;
	STRB	R1, [R0]		;
	LDR	R0, =U0LCR		; R0 - > U0LCR (line control register)
	LDR	R1, =0x02		; 7 data bits + parity
	STRB	R1, [R0]		;

;
; output "ECHO ECho echo ..." to console
; echo typed characters (type CTRL j for a line feed)
;
; replace this with your code
;
;	LDR	R0, =STR0		; R0 -> "ECHO ECho echo ..."
;	BL	PUTS			; put string
;L	BL	GET			; get character
;	BL	PUT			; put character
;	B	L			; forever
	
	
;STR0	DCB	"ECHO ECho echo...", 0x0a, 0, 0

;From here, this is my answer code.

    LDR R4,=0x40000000     ; R4 ->0x40000000
    LDR R5,=0x40000100     ; R5 ->0x40000100
    MOV R6, #0             ; R6 = count
    LDR	R0, =STR0		   ; R0 -> "Please input string."
    BL	PUTS			   ; put string
L1  BL	GET			       ; get character
    BL	PUT			       ; put character
    CMP R0,#0x0D           ; enter?
    BEQ L5                 ; if "enter", go to L5
    CMP R0,#0x08           ; delete ?
    BEQ L4                 ; if "delete", go to L2
    CMP R0,#0x20           ; space?
    BEQ L24                ; if "space", go to L24
    CMP R0,#0x7A           ; R0 > 0x7A
    BGT L1                 ; if R0 > 0x7A, go to L1
    CMP R0,#0x60           ; R0 > 0x61?
    BGT L2                 ; if R0 > 0x61, go to L2
    CMP R0,#0x41           ; R0 < 0x41 ?
    BLT L1                 ; if R0 < 0x41, go to L1
    CMP R0,#0x5B           ; R0 < 0x5B ?
    BLT L3                 ; if  R0 < 0x5B, go to L3   
L2                         ; the case of small letter 
    STRB R0,[R4]           ; MBYTE[R4] = R0
    STRB R0,[R5]           ; MBYTE[R5] = R0
    ADD R4, R4,#1          ; R4 = R4 + 1
    ADD R5, R5,#1          ; R5 = R5 + 1
    SUB R0,R0,#0x20        ; R0 = R0 - 0x20
    STRB R0,[R4]           ; MBYTE[R4] = R0
    STRB R0,[R5]           ; MBYTE[R5] = R0
    ADD R4, R4,#1          ; R4 = R4 + 1
    ADD R5, R5,#1          ; R5 = R5 + 1
    B  L0                  ; go to L0    
L3                         ; the case of small letter 
    STRB R0,[R4]           ; MBYTE[R4] = R0
    STRB R0,[R5]           ; MBYTE[R5] = R0
    ADD R4, R4,#1          ; R4 = R4 + 1
    ADD R5, R5,#1          ; R5 = R5 + 1
    ADD R0,R0,#0x20        ; R0 = R0 + 0x20
    STRB R0,[R4]           ; MBYTE[R4] = R0
    STRB R0,[R5]           ; MBYTE[R4] = R0
    ADD R4, R4,#1          ; R4 = R4 + 1
    ADD R5, R5,#1          ; R5 = R5 + 1
    B  L0                  ; go to L0   
L0  ADD R6, R6, #1         ; count=count + 1
    B  L1                  ; go to L1    
L4                         ; the case of delete 
    SUB R4,R4,#1           ; R4 = R4 -1
    SUB R5,R5,#1           ; R5 = R5 -1
    LDR R7,=0x00           ; R7 = 0x00
    STRB R7,[R4]           ; MBYTE[R4] = R7
    STRB R7,[R5]           ; MBYTE[R5] = R7
    SUB R4,R4,#1           ; R4 = R4 -1
    SUB R5,R5,#1           ; R5 = R5 -1
    STRB R7, [R4]          ; MBYTE[R4] = R7
    STRB R7,[R5]           ; MBYTE[R5] = R7
    LDR R0,=0x00           ; R0 = 0x00
    BL PUT                 ; put character
	LDR R0,=0x08           ; R0 = "backspace"
	BL PUT                 ; put character
    B   L1                 ; go to L1
L24                        ; the case of space
    B  L1                  ; go to L1	
L5                         ; the case of enter
    STRB R0,[R4]           ; MBYTE[R4] = R0
    STRB R0,[R5]           ; MBYTE[R5] = R0
    LDR R0, =0x40000000    ; R0 -> 0x40000000
    LDRB R0,[R0]           ; R0 = R0
    CMP R0, #0x0D          ; if(isEmpty(s0))
    BEQ L1                 ; go to L1
                           ; From here, this program does compare two words.	
L21 LDR R0, =STR4          ; R0 -> ""
    BL PUTS                ; put string
L6  LDR R5, =0x40000200    ; R5 ->0x40000200
L7  BL GET                 ; get character
    BL PUT                 ; put character
    CMP R0,#0x0D           ; enter?  
    STRB R0,[R5]           ; MBYTE[R5] = R0
    BEQ L35                ; if "enter", go to L35
    CMP R0,#0x08           ; "backspace"?
    BEQ L8                 ; if "backspace", go to L8
    CMP R0,#0x20           ; "space"?
    BEQ L25                ; if "space", go to L25
    CMP R0,#0x7A           ; R0 > 0x7A ?
    BGT L21                ; if R0 > 0x7A, go to L21
    CMP R0,#0x60           ; R0 > 0x61?
    BGT L22                ; go to L22
    CMP R0,#0x41           ; R0 < 0x41 ?
    BLT L21                ; if R0 < 0x41, go to L21
    CMP R0,#0x5B           ; R0 < 0x5B?
    BLT L23                ; if R0 < 0x5B, go to L23    
L22                        ; the case of small letter
    STRB R0,[R5]           ; MBYTE[R5] = R0     
    ADD R5, R5,#1          ; R5 = R5 + 1
    SUB R0,R0,#0x20        ; R0 = R0 - 0x20
    STRB R0,[R5]           ; MBYTE[R5] = R0
    ADD R5, R5,#1          ; R5 = R5 + 1
    B  L7                  ; go to L7  
L23                        ; the case of capital letter
    STRB R0,[R5]           ; MBYTE[R5] = R0 
    ADD R5, R5,#1          ; R5 = R5 + 1
    ADD R0,R0,#0x20        ; R0 = R0 + 0x20
    STRB R0,[R5]           ; MBYTE[R5] = R0
    ADD R5, R5,#1          ; R5 = R5 + 1
    B  L7                  ; go to L7    
L8                         ; the case of "delete"
    SUB R5,R5,#1           ; R5 = R5 -1
    LDR R7,=0x00           ; R7 = 0x00
    STRB R7,[R5]           ; MBYTE[R5] = R7 
    SUB R5,R5,#1           ; R5 = R5 -1
    STRB R7,[R5]           ; MBYTE[R5] = R7
    LDR R0,=0x00           ; R0 = 0x00
    BL PUT                 ; put string
	LDR R0,=0x08           ; R0 = 0x08
	BL PUT                 ; put string
    B   L7                 ; go to L7
L25                        ; the case of "space"
    B  L7                  ; go to L7
L35                        ; the case of "enter"
    STRB R0,[R5]           ; MBYTE[R5] = R0
    LDR R0, =0x40000200    ; R0 -> 0x40000200
    LDRB R0,[R0]           ; R0 = R0
    CMP R0, #0x0D          ; if(isEmpty(s1))
    BEQ L6                 ; go to L6        
L9  LDR R4, =0x40000200    ; R4 -> 0x40000200
L10 LDRB R5, [R4]          ; MBYTE[R5] = R4
    MOV R7,R6, LSL#1	   ; R7 = 2 *R6(count)
    LDR R0, =0x40000000    ; R0 -> 0x40000000
L11 CMP R7,#0              ; R7 =0?
    BEQ L14                ; ifR7=0, go to L7
    LDRB R8,[R0]           ; MBYTE[R0] = R8
    CMP R5, R8             ; R5 = R8?
    BEQ L12                ; if R4 = R0, go to L5
    ADD R0,R0,#1           ; R0 = R0 +1
    SUB R7,R7,#1           ; R7 = R7 -1 
    B   L11                ; go to L11
L12 MOV R9, #0x00          ; R9 = 0x00
    STRB R9,[R0]           ; MBYTE[R0] = R9
    ADD R4,R4,#1           ; R4 = R4 +1
    LDRB R8,[R4]           ; MBYTE[R4] = R8
    CMP R8,#0x0D           ; R8 =0x0D?
    BEQ L13                ; if R8 =0x0D, go to L13
    BNE L10                ; if not R8 =0x0D, go to L10
L13 LDR R0, =STR4          ; R0 -> ""  
    BL PUTS                ; put string
    LDR R0, =STR2          ; R0->"Y"
    BL PUTS                ; put string
    B  L15                 ; go to L15
L14 LDR R0, =STR4          ; R0 -> "" 
    BL PUTS                ; put string
    LDR R0, =STR3          ; R0->"N"
    BL PUTS                ; put string
L15 LDR R4,=0x40000000     ; R4 -> 0x40000000
    LDR R8,=0x40000000     ; R8 -> 0x40000000
    MOV R7,R6, LSL#1	   ; R7 = 2 *R6(count)
    LDR R5, =0x00          ; R5 = 0x00
L20 STRB R5,[R4]           ; MBYTE[R4] = R5
    ADD R4, R4, #1         ; R4 = R4 + 1
    SUB R7,R7,#1           ; R7 = R7 + 1
    CMP R7,#0              ; R7 = 0?
    BNE L20                ; if not R7 = 0, go to L20
    
    LDR R5,=0x40000100     ; R5 -> 0x40000100
L16 LDRB R6,[R5]           ; MBYTE[R5] = R6
    STRB R6,[R8]           ; MBYTE[R8] = R6
    ADD R8,R8,#1           ; R8 = R8 + 1
    ADD R5,R5,#1           ; R5 = R5 + 1
    CMP R6,#0x0D           ; R6 = 0x0D?
    BNE L16                ; if not R6 = 0x0D, go to L16 

    LDR R4, =0x40000200    ; R4 -> 0x40000200
L17 LDRB R5,[R4]           ; MBYTE[R4] = R5
    CMP R5,#0              ; R5 = 0?
    BEQ L6                 ; if R5 = 0, go to L6
    MOV R5,#0              ; R5 =0
    ADD R4,R4,#1           ; R4 = R4 +1
    B   L17
		
STR0	DCB	"Please input string.", 0x0a, 0, 0
STR2    DCB "Y",0x0a,0,0
STR3    DCB "N",0x0a,0,0
STR4    DCB "",0x0a,0,0

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