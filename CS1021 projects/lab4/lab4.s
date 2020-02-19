;
; CS1021 2018/2019	Lab 4
; 

	AREA	RESET, CODE, READONLY
	ENTRY

;
; add your code here
;

;Q1
;(i)0x12345678


   LDR R1, =0x12345678; R1 = 0x12345678
   MOV R0,#0          ; R0 =0
L0 CMP R1,#0          ;if R1==0?
   BEQ L1             ;finished
   MOVS R1,R1,LSR#1   ;shift LS bit into CARRY flag
   ADC R0,R0,#0       ;add CARRY to R0
   B   L0
L1 AND R0, R0,#0x1 
;R0 =1 so odd number 

;(ii)  0xF0F0F0F0 
  LDR R1, = 0xF0F0F0F0
   MOV R0,#0          ; R0 =0
L2 CMP R1,#0          ;if R1==0?
   BEQ L3             ;finished
   MOVS R1,R1,LSR#1   ;shift LS bit into CARRY flag
   ADC R0,R0,#0       ;add CARRY to R0
   B   L2
L3 AND R0, R0,#0x1
;R0 =0 so even number 

;(iii)) 42
   LDR R1, = 0x42
   MOV R0,#0          ; R0 =0
L4 CMP R1,#0          ;if R1==0?
   BEQ L5             ;finished
   MOVS R1,R1,LSR#1   ;shift LS bit into CARRY flag
   ADC R0,R0,#0       ;add CARRY to R0
   B   L4
L5 AND R0, R0,#0x1
;R0 =0 so even number 

;Q2
;Algorithm1
;(i) 27/7
;Q(R0) =3, R(R1) =6

  MOV R0,#27
  MOV R1,#7
  MOV R2,#0
L6 CMP R0,R1         ;R0>=R1
  BLO L7             ;if R0<R1, go to L7
  ADD R2,R2,#1       ;R2=R2+1(Q+1)
  SUB R0,R0,R1       ;R0=R0-R1(N-D)
  B   L6
L7 MOV R1,R0
  MOV R0,R2
  
;(ii)  444444/23
;Q(R0) = 4B7B = 19323 in binary, R(R1) = F = 15 in binary
  LDR R0,=444444
  MOV R1,#23
  MOV R2,#0
L8 CMP R0,R1         ;R0>=R1
  BLO L9             ;if R0<R1, go to L7
  ADD R2,R2,#1       ;R2=R2+1(Q+1)
  SUB R0,R0,R1       ;R0=R0-R1(N-D)
  B   L8
L9 MOV R1,R0
  MOV R0,R2
  
;(iii)  33,554,432 / 506
;Q(R0) = 10309 = 66313 in binary, R(R1) = 36 = 54 in binary
  LDR R0,=33554432
  LDR R1,=506
  MOV R2,#0
L10 
  CMP R0,R1         ;R0>=R1
  BLO L11             ;if R0<R1, go to L7
  ADD R2,R2,#1       ;R2=R2+1(Q+1)
  SUB R0,R0,R1       ;R0=R0-R1(N-D)
  B   L10
L11 
  MOV R1,R0
  MOV R0,R2
  
;Algorithm2
;(i)27/7
;Q(R0) =3, R(R1) =6
  LDR R0,=0x0000001B
  MOV R1,#7
  MOV R5,R0
L20           
  MOVS R5, R5, LSL#1
  ADD R6,R6,#1
  ADC R4,R4,#0   
  CMP R4,#0
  BEQ L20
L21  MOVS R5,R5,LSL#1
  ADD R6,R6,#1
  ADD R4,R4,#1
  LDR R7,=32
  CMP R6,R7
  BNE L21       ;so far these processe are leding to the number of bits in N 
                ;27 = 11011 so 5bits
  
  MOV R2,#0         ;Q=0
  MOV R3,#0         ;R=0    --initialise quotient and remainder to zero
           
   
L12 SUB R4,R4,#1    ;for i:n-1...0 do
  CMP R4, #0
  BLT L13
  MOV R3,R3,LSL#1   ;left-shift R by 1 bit
  
  MOV R5,R0
  MOV R6,#0
  
  MOV R9,#32
  SUB R9,R9,R4
  
 
  CMP R4,#0
  BEQ L16
  BLT L17  
  
  MOVS R5, R5,LSL R9
  ADC R6,R6,#0

  B   L17  
L16   MOVS R5, R5,LSL R9
  ADC R6,R6,#0  
L17
  ORR R3,R6        ;set the least-significant bit of R equal to bit i of the numerator
  
  MOV R8,#0  
L18  CMP R3,R1        ;if R >= D
  BLO L14 
L19  SUB R3, R3, R1   ;R = R-D
  ADD R8, R8,#1       ;Q(i) =1
  CMP R3,R1
  BHS L19
  B   L18
L14
  CMP R8,#0
  BEQ L22
  MOV R8,R8,LSL R4
  ADD R2,R2,R8
  
  
L22  B   L12 
L13 MOV R0,R2
  MOV R1,R3
  
;(ii)444444/23
;Q(R0) = 4B7B = 19323 in binary, R(R1) = F = 15 in binary
  LDR R0,=0x0006C81C    ;444444=  0x0006C81C
  MOV R1,#23
  MOV R5,R0
L34           
  MOVS R5, R5, LSL#1
  ADD R6,R6,#1
  ADC R4,R4,#0   
  CMP R4,#0
  BEQ L34
L24  MOVS R5,R5,LSL#1
  ADD R6,R6,#1
  ADD R4,R4,#1
  LDR R7,=32
  CMP R6,R7
  BNE L24       ;so far these processe are leding to the number of bits in N 
                ;27 = 11011 so 5bits
  
  MOV R2,#0         ;Q=0
  MOV R3,#0         ;R=0    --initialise quotient and remainder to zero
           
   
L25 SUB R4,R4,#1    ;for i:n-1...0 do
  CMP R4, #0
  BLT L26
  MOV R3,R3,LSL#1   ;left-shift R by 1 bit
  
  MOV R5,R0
  MOV R6,#0
  
  MOV R9,#32
  SUB R9,R9,R4
  
 
  CMP R4,#0
  BEQ L27
  BLT L28  
  
  MOVS R5, R5,LSL R9
  ADC R6,R6,#0

  B   L28  
L27   MOVS R5, R5,LSL R9
  ADC R6,R6,#0  
L28
  ORR R3,R6        ;set the least-significant bit of R equal to bit i of the numerator
  MOV R8,#0 
L30  CMP R3,R1        ;if R >= D
  BLO L29 
    
L31  SUB R3, R3, R1   ;R = R-D
  ADD R8, R8,#1       ;Q(i) =1
  CMP R3,R1
  BHS L31
  B   L30
L29
  CMP R8,#0
  BEQ L32
  MOV R8,R8,LSL R4
  ADD R2,R2,R8
  
  
L32  B   L25 
L26 MOV R0,R2
  MOV R1,R3
  
;(iii)33,554,432 / 506
;Q(R0) = 10309 = 66313 in binary, R(R1) = 36 = 54 in binary
  LDR R0,=0x02000000    ;33554432= 0x02000000
  LDR R1,=506
  MOV R5,R0
L54           
  MOVS R5, R5, LSL#1
  ADD R6,R6,#1
  ADC R4,R4,#0   
  CMP R4,#0
  BEQ L54
L44  MOVS R5,R5,LSL#1
  ADD R6,R6,#1
  ADD R4,R4,#1
  LDR R7,=32
  CMP R6,R7
  BNE L44       ;so far these processe are leding to the number of bits in N 
                ;27 = 11011 so 5bits
  
  MOV R2,#0         ;Q=0
  MOV R3,#0         ;R=0    --initialise quotient and remainder to zero
           
 
L45 SUB R4,R4,#1    ;for i:n-1...0 do
  CMP R4, #0
  BLT L46
  MOV R3,R3,LSL#1   ;left-shift R by 1 bit
  
  MOV R5,R0
  MOV R6,#0
  
  MOV R9,#32
  SUB R9,R9,R4
  
 
  CMP R4,#0
  BEQ L47
  BLT L48  
  
  MOVS R5, R5,LSL R9
  ADC R6,R6,#0

  B   L48  
L47   MOVS R5, R5,LSL R9
  ADC R6,R6,#0  
L48
  ORR R3,R6        ;set the least-significant bit of R equal to bit i of the numerator
  MOV R8,#0
L50  CMP R3,R1        ;if R >= D
  BLO L49 
 
L51  SUB R3, R3, R1   ;R = R-D
  ADD R8, R8,#1       ;Q(i) =1
  CMP R3,R1
  BHS L51
  B   L50
L49
  CMP R8,#0
  BEQ L52
  MOV R8,R8,LSL R4
  ADD R2,R2,R8
  
  
L52  B   L45 
L46 MOV R0,R2
  MOV R1,R3 
  
  
  
  
	
	
L	B	L		; infinite loop to end

        END
