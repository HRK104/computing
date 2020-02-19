;
; CS1021 2018/2019	Lab 3
; 

	AREA	RESET, CODE, READONLY
	ENTRY

;
; add your code here
;

;Q1
;(a,b) = (24,32)

    MOV R0, #24         ; R0 = 24
    MOV R1, #32         ; R1 = 32
L0  CMP R0, R1          ; R0 != R1?
    BEQ L1              ; if R0 = R1, go to L1
    CMP R0, R1          ; R0 > R1?
    BLS L2              ; if R0	<= R1, go to L2
    SUB R0, R0, R1      ; R0 = R0 - R1
    B   L3
L2  SUB R1, R1, R0      ; R1 = R1 - R0
L3  B   L0
L1

;R0=0x00000008 R1 = 0x00000008 = 8, so GCD =8


;(a,b) = (2415, 3289)


    LDR R0, =2415       ; R0 = 2415
    LDR R1, =3289       ; R1 = 3289
L4  CMP R0, R1          ; R0 != R1?
    BEQ L5              ; if R0 = R1, go to L1
    CMP R0, R1          ; R0 > R1?
    BLS L6              ; if R0	<= R1, go to L2
    SUB R0, R0, R1      ; R0 = R0 - R1
    B   L7
L6  SUB R1, R1, R0      ; R1 = R1 - R0
L7  B   L4
L5
;R0x00000017 R1 = 0x00000017 = 23, so GCD =23

;(a,b) = (4278, 8602)

    LDR R0, =4278       ; R0 = 2415
    LDR R1, =8602       ; R1 = 3289
L8  CMP R0, R1          ; R0 != R1?
    BEQ L9              ; if R0 = R1, go to L1
    CMP R0, R1          ; R0 > R1?
    BLS L10              ; if R0	<= R1, go to L2
    SUB R0, R0, R1      ; R0 = R0 - R1
    B   L11
L10  SUB R1, R1, R0      ; R1 = R1 - R0
L11 B   L8
L9
;R0x0000002E,  R1 = 0x0000002E = 46, so GCD =46

;(a,b) = (406, 555)

    LDR R0, =406       ; R0 = 2415
    LDR R1, =555       ; R1 = 3289
L12  CMP R0, R1          ; R0 != R1?
    BEQ L13              ; if R0 = R1, go to L1
    CMP R0, R1          ; R0 > R1?
    BLS L14              ; if R0	<= R1, go to L2
    SUB R0, R0, R1      ; R0 = R0 - R1
    B   L15
L14  SUB R1, R1, R0      ; R1 = R1 - R0
L15 B   L12
L13
;R0x00000001 R1 = 0x00000001 = 1, so GCD =1

;Q2
;F48

   MOV R6, #48       ;R6 = 48
   MOV R2, #0        ;R2 = 0
   MOV R3, #0        ;R3 = 0(Fn-2)
   MOV R0, #0        ;R0 = 0
   MOV R1, #1        ;R1 = 1(Fn-1)
L16 CMP R6, #1       ;R6 >1?
    BLE L17
    MOV R4, R0       ;R4 = R0
    MOV R5, R1       ;R5 = R1
    ADDS R1, R1, R3  ;R1 = R1 + R3
    ADC R0, R0, R2   ;R0 + R0 + R2
    MOV R2, R4       ;R2 = R4
    MOV R3, R5       ;R3 = R1
    SUB R6, R6, #1   ;R6 = R6-1
    B L16
L17
; R0=0x00000001,  R1=0x1E8D0A40 
;so F48 =4807526976

;F64
   MOV R6, #64       ;R6 = 48
   MOV R2, #0        ;R2 = 0
   MOV R3, #0        ;R3 = 0(Fn-2)
   MOV R0, #0        ;R0 = 0
   MOV R1, #1        ;R1 = 1(Fn-1)
L18 CMP R6, #1       ;R6 >1?
    BLE L19
    MOV R4, R0       ;R4 = R0
    MOV R5, R1       ;R5 = R1
    ADDS R1, R1, R3  ;R1 = R1 + R3
    ADC R0, R0, R2   ;
    MOV R2, R4
    MOV R3, R5
    SUB R6, R6, #1   ;R6 = R6-1
    B L18
L19	
;R0=0x000009A6 R1=0x61CA20BB
;so F64=10610209857723


;Q3
   LDR R6, =0x7FFFFFFF  ;Most significant of Max number
   LDR R7, =0xFFFFFFFF  ;Least significant of Max number

   
   
   MOV R2, #0        ;R2 = 0
   MOV R3, #0        ;R3 = 0(Fn-2)
   MOV R0, #0        ;R0 = 0
   MOV R1, #1        ;R1 = 1(Fn-1)
   MOV R8, #1        ;R8( = count) =1
   
L20 SUBS R9, R7, R1   ;R9 = R7 -R1(LS of Max - LS of Fn-1)
   SBC R10, R6, R0    ;R10 = R6 - R0(MS of Max - MS of Fn-2)
   CMP R10, R2        ;R10 > R2(MS of Max-Fn-1>MS of Fn-2)
   BLE L22           ;=< (opposite condition)
   MOV R4, R0       ;R4 = R0
   MOV R5, R1       ;R5 = R1
   ADDS R1, R1, R3  ;R1 = R1 + R3
   ADC R0, R0, R2   ;R0 = R0 + R2
   MOV R2, R4       ;R2 = R4
   MOV R3, R5       ;R3 = R5
   ADD R8, R9, #1   ;R9 = R9 + 1 (count = count +1)
   B   L20
L22
;R0=0x68A3DD8E R1=0x61ECCFBD so Fn = 7540113804746346429
;R9=0x0000005A =90(in decimal)  so n=92

STOP	B	STOP		; infinite loop to end

        END
