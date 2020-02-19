;
; CS1021 2018/2019	Lab 1
; 

	AREA	RESET, CODE, READONLY
	ENTRY

;
; start of code
;
	LDR	R1, =5 	
	LDR	R2, =6	
    LDR R3, =2
;
; compute 3*x*x + 5x (35 or 0x23)
;
	MOV R0, R1 	    ; R0 = x
	MUL R0, R1, R0	; R0 = x*x 
	MOV R4, #3	    ; R4 = 3
	MUL R0, R4, R0  ; R0 = 3x*x
	MOV R4, #5      ; R4 = 5
	MUL R4, R1, R4  ; R4 = 5x
	ADD R0, R0, R4  ; R0 = 3x*x + 5x
	
;
; compute 2*x*x + 6*xy + 3y*y
;
	MUL R0, R1, R1  ; R0 = x*x
	MOV R4, #2      ; R4 = 2
	MUL R0, R4, R0  ; R0 = 2x*x
    MUL R4, R1, R2  ; R4 = xy
	MOV R5, #6      ; R5 = 6
	MUL R4, R5, R4  ; R4 = 6xy
	ADD R0, R0, R4  ; R0 = 2x*x + 6x*y
	MUL R4, R2, R2  ; R4 = y*y
	MOV R5, #3      ; R5 = 3
	MUL R4, R5, R4  ; R4 = 3y*y
	ADD R0, R0, R4  ; R0 = 2x*x + 6x*y + 3y*y
	
	
;
; compute x*x*x -4*x*x + 3*x +8
;

	MUL R0, R1, R1  ; R0 = x*x
	MUL R0, R1, R0  ; R0 = x*x*x
	MOV R4, #4      ; R4 = 4
	MUL R4, R1, R4  ; R4 = 4x
	MUL R4, R1, R4  ; R4 = 4x*x
	SUB R0, R0, R4  ; R0 = x*x*x - 4x*x
	MOV R4, #3      ; R4 = 3
	MUL R4, R1, R4  ; R4 = 3x
	ADD R0, R0, R4  ; R0 = x*x*x - 4x*x + 3x
	MOV R4, #8      ; R4 = 8
	ADD R0, R0, #8  ; R0 = x*x*x -4x*x + 3x + 8
	
	
	
;
; compute 3x*x*x*x - 5x - 16y*y*y*y*z*z*z*z
;
	
	MOV R0, #3     ; R0 = 3
    MUL R4, R1, R1 ; R4 = x*x
    MUL R0, R4, R0 ; R0 = 3x*x 
	MUL R0, R4, R0 ; R0 = 3x*x*x*x
    MOV R4, #5     ; R4 = 5
    MUL R4, R1, R4 ; R4 = 5x
    SUB R0, R0, R4 ; R0 = 3x*x*x*x - 5x
    ADD R4, R2, R2 ; R4 = 2y
    MUL R4, R3, R4 ; R4 = 2y*z
    MUL R5, R4, R4 ; R5 = 4y*y*z*z
    MUL R4, R5, R5 ; R4 = 16y*y*y*y*z*z*z*z
    SUB R0, R0, R4 ; R0 = 3x*x*x*x - 5x - 16y*y*y*y*z*z*z*z


L	B	L		; infinite loop to end programme

        END
