;
; CS1021 2018/2019	Lab 2
; 


	AREA	RESET, CODE, READONLY
	ENTRY

;
; add your code for Q1 here
;
	MOV	R2, #16   	; R2( = n) = 16
	MOV R1, #0      ; R1( = Fn-2) = 0 
	MOV R0, #1      ; R0( = Fn-1) = 1

L1  CMP R2, #1      ; R2 > 1 ?
    BLE L2          ; <= (opposite condition to > in pseudo code)
	MOV R3, R0      ; R3( = tmp) = R0
    ADD R0, R1, R0  ; R0 = R1 + R0
    MOV R1, R3	    ; R1 = R3
	SUB R2, R2, #1  ; R2 = R2 - 1
	B   L1
L2    

;F16 = 0x000003DB = 987

    
	MOV R2, #32     ; R2( = n) = 32
	MOV R1, #0      ; R1( = Fn-2) = 0
	MOV R0, #1      ; R0( = Fn-1) = 1
   
L3  CMP R2, #1      ; R2 > 1 ?
    BLE L4          ; <= (opposite condition to > in pseudo code)
	MOV R3, R0      ; R3( = tmp) = R0
    ADD R0, R1, R0  ; R0 = R1 + R0
    MOV R1, R3	    ; R1 = R3
	SUB R2, R2, #1  ; R2 = R2 - 1
	B   L3
L4

;F32 = 0x00213D05 = 2178309




;
; add your code for Q2 here
;(i)unsigned
    MOV R5, #4294967295      ; R5 = 4294967295 ( = 0xFFFFFFFF = Max number )

    MOV R2, R5      ; R2 = R5
	MOV R1, #0      ; R1( = Fn-2) = 0
	MOV R0, #1      ; R0( = Fn-1) = 1
	MOV R4, #1      ; R4( = count) =1
	
	
L5  SUB R6, R5, R0  ; R6 = R5 - R0(R6 = Max - Fn-1) 
    CMP R6, R1      ; R6 >= R1?  (Max-Fn-1 >= Fn-2 ?)  
    BLO L7          ; < (opposite condition)
    CMP R2, #1      ; R2 > 1 ?
    BLS L6          ; <= (opposite condition)
	MOV R3, R0      ; R3 = R0( R4 = Fn-1)
    ADD R0, R1, R0  ; R0 = R1 + R0 ( Fn = Fn-2 + Fn -1)
    MOV R1, R3	    ; R1 = R3 ( Fn-2 = Fn-1)
	SUB R2, R2, #1  ; R2 = R2 - 1
	ADD R4, R4, #1  ; R4 = R4 + 1 (Count = count + 1)
	B   L5
L6  
L7

;Fn = 0xB11924E1 = 2971215073 = the largest number in unsigned arithmatic
;n = 0x00000002F = 47





;(ii) signed
    MOV R5, #2147483647      ;R5 = 2147483647 ( = 0xFFFFFFFF = Max number)
	
	MOV R2, R5       ; R2 = R5
	MOV R1, #0       ; R1( = Fn-2) = 0
	MOV R0, #1       ; R0( = Fn-1) = 1
	MOV R4, #1       ; R4( = count) =1
	
	
L8  SUB R6, R5, R0  ; R6 = R5 - R0(R6 = Max - Fn-1)
    CMP R6, R1      ; R6 >= R1?  (Max-Fn-1 >= Fn-2 ?)  
    BLT L10         ; < (opposite condition)	
	CMP R2, #1      ; R2 > 1 ?
    BLE L9          ; <= (opposite condition)
	MOV R3, R0      ; R3 = R0( R4 = Fn-1)
    ADD R0, R1, R0  ; R0 = R1 + R0 ( Fn = Fn-2 + Fn -1)
    MOV R1, R3	    ; R1 = R3 ( Fn-2 = Fn-1
	SUB R2, R2, #1  ; R2 = R2 - 1
	ADD R4, R4, #1  ; R4 = R4 + 1 (Count = count + 1)
	B   L8
L9	
L10

;Fn = 0x6D73E55F = 1836311903   = the largest number in signed arithmatic
;n = 0x0000002E = 46

	
    
    
	
	
STOP	B	STOP		; infinite loop to end

        END
