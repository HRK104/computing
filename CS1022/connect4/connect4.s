;
; CS1022 Introduction to Computing II 2018/2019
; Mid-Term Assignment - Connect 4 - SOLUTION
;
; get, put and puts subroutines provided by jones@scss.tcd.ie
;

PINSEL0	EQU	0xE002C000
U0RBR	EQU	0xE000C000
U0THR	EQU	0xE000C000
U0LCR	EQU	0xE000C00C
U0LSR	EQU	0xE000C014


	AREA	globals, DATA, READWRITE
BOARD	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0


	AREA	RESET, CODE, READONLY
	ENTRY

	; initialise SP to top of RAM
	LDR	R13, =0x40010000	; initialse SP

	; initialise the console
	BL	inithw

	;
	; your program goes here
	;
    
	MOV R7,#9                  ;R7(lastMake of computer) = 9
	LDR R0,=str_go             ;R0 = "Let's play Connect4!!"
	BL  puts                   ;present str_go
	B   preRunprogram          ;go to preRunprogram
restart
    LDR R0,=changeLine2        
	BL  puts                   ;change line
    LDR R0,=str_go_again       ;R0 = "Let's play Connect4 again!!"
	BL  puts                    
preRunprogram	
	LDR R0,=BOARD              ;R0 = board
	BL  initialiseBoard        ;go to initialiseBoard subroutine
	LDR R0,=BOARD              ;R0 = board
	BL  printBoard             ;go to printBoard subroutine
	MOV R6,#1                  ;R6 = currentPlayer    1-yellowPlayer, 2-redPlayer
choosePlayer
    CMP R6,#1                  ;R6 = 1?
	BEQ selectYellow           ;if so, go to selectYellow
	BNE selectRed	           ;if not, go to selectRed
selectYellow	
	LDR R0,=yellowPlayer       ;R0 = yellowPlayer
	BL  puts 
	B   runProgram             ;go to runProgram
selectRed
    ;LDR R0,=redPlayer         ;original version
	;BL  puts
	LDR R0,=computerTurn       ;R0 = computerTurn
	BL  puts
	LDR R0,=BOARD              ;R0 = BOARD
	MOV R1,R7                  ;R1 = R7 as a parameter
	BL  computerMove           ;go to computerMove subroutine
	MOV R7,R0                  ;R7 = R1
	ADD R0,R0,#0x31            ;R0 =R0+0x31
	B   computerStaringPoint   ;go to computerStartingPoint
runProgram	
	BL	get			           ; get character
computerStaringPoint		
    BL	put			           ; put character
	CMP R0,#0x71               ;R0 ='q' ?
	BEQ restart                ;if so, go to "restart"
	CMP R0,#0x30
	BLE invalidInput
	CMP R0,#0x38
	BGE invalidInput
    MOV R4,R0                  ;R4 = R0 at a moment
	LDR R0,=changeLine2    
	BL  puts                   ;change line
	MOV R0,R4                  ;R0 = the location user input
	LDR R1,=BOARD              ;R1 = the address of board
	MOV R2,R6                  ;R2 = R6 = currentPlayer
	BL  makeMove               ;go to makeMove subroutine
    
	LDR R0,=BOARD              ;R0 = BOARD
	BL  checkWinning           ;go to checkWinning subroutine
	MOV R5,R0                  ;R5 = R0 = boolean choosePlayer
	CMP R5,#0                  ;R5 = 0?
	BEQ nobodyWin              ;if so, go to nobodyWin
	CMP R5,#1                  ;R5 = 1?
	BEQ winYellow              ;if so, go to winYellow
	BNE winRed                 ;if not, go to winRed
nobodyWin
    LDR R0,=BOARD              ;R0 = BOARD
	BL  printBoard             ;go to printBoard subroutine
	CMP R6,#1                  ;R6 = 1?
	BEQ changeToRed            ;if so, go to changeToRed
	BNE changeToYellow         ;if not, go to changeToYellow
changeToRed
    MOV R6,#2                  ;R6=2
    B   choosePlayer	       ;go to choosePlayer
changeToYellow
    MOV R6,#1                  ;R6 =1
    B   choosePlayer	       ;go to choosePlayer
winYellow
    LDR R0,=BOARD             
	BL  printBoard	           ;go to printBoard subroutine
    LDR R0,=yellowWin          ;R0 = yellowWin
	BL  puts                   ;present yellowWin
	B   finishLine             ;go to finisheLine
winRed
    LDR R0,=BOARD              
	BL  printBoard	           ;go to printBoard subroutine
    LDR R0,=redWin             ;R0 = redWin  
	BL  puts                   ;present redWin
    B   finishLine             ;go to finishLine
finishLine	

invalidInput
    LDR R0,=errorMessage
	BL  puts 
	B   selectYellow
    

stop	B	stop


;
; your subroutines go here
;


; initialiseBoard subroutine
; change all of the content within a board into 0
; parameters
;    r0: address of board
; return
;    nothing
initialiseBoard
   PUSH{R4-R11,LR}
   MOV R4,R0                    ;R4 = R0 = board
   MOV R5,#0                    ;R5 = count
   MOV R6,#0                    ;R6: fixedNumber =0
initialiseBoard1     
   CMP R5,#49                   ;R5 = 49?
   BEQ initialiseBoardEnd       ;if so, go to  initialiseBoardEnd
   STRB R6,[R0,R5,LSL #0]
   ADD R5,R5,#1                 ;count++
   B   initialiseBoard1
initialiseBoardEnd
   POP{R4-R11,PC}

; printBoard subroutine
; print the content of a board
; parameters
;    r0: address of board
; return
;    nothing
printBoard
   PUSH{R4-R11,LR}
   MOV R4,R0                      ;R4 = R1 = BOARD
   LDR R0,=row                    ;R0 = row
   BL  puts 
printBoard1
   MOV R5,#0                      ;R5 = row   =0
   MOV R6,#0                      ;R6 = column =0 
   MOV R7,#7                      ;R7 = length =7
   MOV R8,#0x30                   ;R8 = '0'
   LDR R11,=1                     ;R10 = rowNumberCount =1
printBoard2
   LDR R0, =changeLine            ;R0 -> ""
   BL  puts                       ;put string
   CMP R5,R7                      ;for(row =0;
   BEQ printBoardEnd              ;           row<length(7);row++)
   MOV R0,R8                      ;R0 = R8
   ADD R0,R0,R11                  ;R0 = R0 + R11
   BL  put            
   ADD R11,R11,#1                 ;R11 = R11+1 
printBoard5
   CMP R6,R7                      ;for(column =0;
   BEQ printBoard4                ;              column<length(7);column++){
   MUL R9,R5,R7                   ;index(Board[row]) = row * length
   ADD R9,R9,R6                   ;index(Board[row][column) = index(Board[row]) + column
   LDRB R0,[R4,R9,LSL #0]         ;elem(Board[row,column]) = Memory.Word[Board + (index*4)]
   CMP R0,#0                      ;R0 = 0?
   BNE printbord6                 ;if not, go to printBoard6
   ADD R0,R0,#0x30                ;elem(Board[row,column]) toASCIIcode
   BL  put
   B   printBord7                 ;go to printboard7
printbord6
   CMP R0,#1                      ;R0 = 1?
   BNE printbord8                 ;if not, go to printbord8
   MOV R0, #0x59                  ;R0 = 'Y'
   BL  put
   B   printBord7                 ;go to printBoard7 
printbord8
   MOV R0, #0x52                  ;R0 = 'R'
   BL  put
   B   printBord7                 ;go to printBoard7 
printBord7 
   ADD R6,R6,#1                   ;R6++
   LDR R0,=0x20                   ;R0 = 0x20
   BL  put                        
   B   printBoard5                ;go to printBoard5
printBoard4
   MOV R6,#0                      ;R6 = column =0 
   ADD R5,R5,#1                   ;R5++
   B   printBoard2                ;go to printBoard2
printBoardEnd    
   POP{R4-R11,PC}

; makeMOve subroutine
; nake a move at the location an user input
; parameters
;    r0: the location an user input
;    r1: address of board
;    r2: currentPlayerColor  1-yellowPlayer, 2-redPlayer
; return
;    nothing
makeMove
   PUSH{R4-R12,LR}
   MOV R4,R1                        ;R4 = R1 = address of board
   SUB R5,R0,#1                     ;R5 = R0 -1 = the location an user input -1
   SUB R5,R5,#0x30                  ;R5inAsciiToHexdecimalForm
   MOV R6,R2                        ;R6 = R2 = current player color
   MOV R8,#6                        ;rowIndex
   MOV R9,#7                        ;rowLength
makeMove1   
   
makeMove4
   MUL R10,R8,R9                    ;index(Board[row]) = rowIdex* length
   ADD R10,R10,R5                   ;index(Board[row][column) = index(Board[row]) + column
   LDRB R11,[R4,R10,LSL #0]         ;elem(Board[row,column]) = Memory.Word[Board + (index*4)]
   CMP R11,#0                       ;R11=0?
   BNE makeMove5                    ;if not, go to makeMove5
   STRB R6,[R4,R10,LSL #0] 
   B   makeMoveEnd                  ;go to makeMoveEnd
makeMove5 
   SUB R8,R8,#1                     ;R8--
   CMP R8,#0                        ;R8>=0?
   BGE makeMove4                    ;if so, go to makeMove4
makeMoveEnd
   POP{R4-R12,PC}

; checkWinning subroutine
; check whether a player win or not
; parameters
;    r0: address of board
; return
;    r0: boolean of this subroutine's result
;         0 - nobody win
;         1 - yellowPlayer wins
;         2 - redPlayer wins
checkWinning
   PUSH{R4-R12,LR}
   MOV R4,R0                        ;R4 = R0 =  address of board
   MOV R8,#0                        ;R8 = (boolean found = false;)
   MOV R5,#0                        ;R5 = row   =0
   MOV R6,#0                        ;R6 = column =0 
   MOV R7,#7                        ;R7 = length =7
checkWinning1
   CMP R5,R7                        ;for(row =0;
   BEQ checkingNegResult            ;           row<length(7);row++){
checkWinning2
   CMP R6,R7                        ;for(column =0;
   BEQ checkWinning4                ;              column<length(7);column++){
   MUL R9,R5,R7                     ;index(Board[row]) = row * length
   ADD R9,R9,R6                     ;index(Board[row][column) = index(Board[row]) + column
   LDRB R10,[R4,R9,LSL #0]          ;elem(Board[row,column]) = Memory.Word[Board + (index*4)]
   CMP R10,#0                       ;elem(Board[row,column]) = 0?
   BNE checkingHorizontal1          ;if not, go to checkingHorizontal1
checkWinningNextNumber   
   ADD R6,R6,#1                     ;column++
   B   checkWinning2                ;}
checkWinning4
   ADD R5,R5,#1                     ;row++
   MOV R6,#0                        ;column =0
   B   checkWinning1                ;}
   
   
checkingHorizontal1   
   MOV R9,#0                        ; R9 = count
   MOV R11,#0                       ;R11 = columnIndex
checkHorizontalResetCount
   MOV R9,#0                        ; R9 = count
checkinghorizontal2   
   CMP R9,#3                        ;R9 = 3?
   BEQ checkingPosResult            ;if so go to correctHorizontal
   MUL R10,R5,R7                    ;index(Board[row]) = row * length
   ADD R10,R10,R11                  ;index(Board[row][column) = index(Board[row]) + columnIndex
   LDRB R10,[R4,R10,LSL #0]         ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)] 
   ADD R11,R11,#1                   ;columnIndex++
   CMP R11,#7                       ;columnIndex = 7?
   BEQ checkingVertical1            ;if so, go to checkingVertical1
   MUL R12,R5,R7                    ;index(Board[row]) = row * length
   ADD R12,R12,R11                  ;index(Board[row][column) = index(Board[row]) + columnIndex
   LDRB R12,[R4,R12,LSL #0]         ;secondElem(Board[row,column]) = Memory.Word[Board + (index*4)]
   
   CMP R10,#0                       ;firstElem = 0?
   BEQ checkHorizontalResetCount    ;if so, go to checkinghorizontal2
   
   CMP R10,R12                      ;firstElem = secondElem ?
   BNE checkHorizontalResetCount
   ADD R9,R9,#1                     ;count++
   B   checkinghorizontal2
checkingVertical1
   MOV R9,#0                        ; R9 = count
   MOV R11,#0                       ;R11 = rowIndex
checkVerticalResetCount
   MOV R9,#0                        ; R9 = count   
checkingVertical2
   CMP R9,#3                        ;R9 = 3?
   BEQ checkingPosResult            ;if so go to correctHorizontal
   MUL R10,R11,R7                   ;index(Board[row]) = rowIndex * length
   ADD R10,R10,R6                   ;index(Board[row][column) = index(Board[row]) + column
   LDRB R10,[R4,R10,LSL #0]         ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)] 
   ADD R11,R11,#1                   ;columnIndex++
   CMP R11,#7                       ;columnIndex = 7?
   BEQ checkingDiagnal              ;if so, go to checkingDiagnal
   MUL R12,R11,R7                   ;index(Board[row]) = rowIndex * length
   ADD R12,R12,R6                   ;index(Board[row][column) = index(Board[row]) + column
   LDRB R12,[R4,R12,LSL #0]         ;secondElem(Board[row,column]) = Memory.Word[Board + (index*4)]
   CMP R10,#0                       ;firstElem = 0?
   BEQ checkVerticalResetCount      ;if so, go to checkingVertical2
   CMP R10,R12                      ;firstElem = secondElem ?
   BNE checkVerticalResetCount      ;if not, go to checkVerticalResetCount
   ADD R9,R9,#1                     ;count++
   B   checkingVertical2
checkingDiagnal  
   MOV R0,R4                        ;R0 = R4 = board
   MOV R1,R5                        ;R1 = R5 = row
   MOV R2,R6                        ;R2 = R6 = column
   BL  diagnalCheck                 ;go to diagnalCheck subroutine
   CMP R0,#0                        ;R0 =0?
   BEQ preCheckWinningNextNumber    ;if so, go to preCheckWinningNextNumber
   BNE checkWinningEnd              ;if not, go to checkWinningEnd
preCheckWinningNextNumber   
   MOV R9,#0                        ;R9 =0
   B   checkWinningNextNumber       ; go to checkWinningNextNumber
checkingPosResult
   MOV R0,R10                       ;R0 = R10
   B   checkWinningEnd              ; go to checkWinningEnd
checkingNegResult
   MOV R0,#0                        ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)]LDR R0,LDRB
checkWinningEnd
   POP{R4-R12,PC}

; diagnalCheck subroutine
; check whether a player win or not in diag
; parameters
;    r0: address of board
; return
;    r0: boolean of this subroutine's result
;         0 - nobody win
;         1 - yellowPlayer wins
;         2 - redPlayer wins
diagnalCheck
   PUSH{R4-R12,LR}
   MOV R4,R0                         ;R4 = board
   MOV R5,#0                         ;R5 = row
   MOV R6,#0                         ;R6 = column
   MOV R7,#7                         ;R7 = length =7
   MOV R8,#0                         ;R8 = (boolean found = false;)
   MOV R9,#0                         ;R9 = count
diagnalCheck1   
   MOV R5,#0                         ;R5 = row
   MOV R6,#0                         ;R6 = column
   MOV R9,#0                         ;R9 = count
   MOV R11,R6                        ;R11 =indexcolumn
diagnalCheck11
   CMP R6,#4                         ;for(column =0;column<4;
   BEQ diagnalCheck12                ;if so, go to diagnalCheck3Part2
diagnalCheck16   
   CMP R5,#3                         ;for(row =0;row<3;
   BEQ diagnalCheck13                ;if so, go to diagnalCheck3Part3
   MUL R8,R5,R7                      ;index(Board[row]) = row * length
   ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
   LDRB R0,[R4,R8,LSL #0]            ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)]
   ADD R11,R11,#1                    ;secondColumn =column + 1
   ADD R10,R5,#1                     ;secondRow =row +1
   
   MUL R8,R10,R7                     ;index(Board[row]) = row * length
   ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
   LDRB R1,[R4,R8,LSL #0]            ;secondElem(Board[row,column]) = Memory.Word[Board + (index*4)]
  
   CMP R0,#0                         ;firstElem = 0?
   BEQ diagnalCheck01                ;if so, go to diagnalCheck01
  
   CMP R0,R1                         ;R0(firstElem) = R1(secondElem)?
   BEQ diagnalCheck14                ;if so, go to diagnalCheck3Part4
diagnalCheck01   
   MOV R9,#0                         ;reset count as 0
   B diagnalCheck15                  ;go to diagnalCheck3Part5
diagnalCheck14
   ADD R9,R9,#1                      ;count++;
diagnalCheck15
   ADD R5,R5,#1                      ;row++
   CMP R9,#3                         ;R9=3?
   BEQ diagnalCheckPosResult         ;if so, go to diagnalCheckPosResult
   B   diagnalCheck16                ;go to diagnalCheck16
diagnalCheck13
   MOV R5,#0                         ;R5 = row
   MOV R9,#0                         ;R9 = count
   ADD R6,R6,#1                      ;column++
   MOV R11,R6                        ;indexcolumn = column
   B   diagnalCheck11
diagnalCheck12  
   B   diagnalCheck2
   
   
diagnalCheck2   
   MOV R5,#0                         ;R5 = row
   MOV R6,#3                         ;R6 = column
   MOV R9,#0                         ;R9 = count
   MOV R11,R6                        ;R11 =indexcolumn
diagnalCheck21
   CMP R6,#7                         ;for(column = 3;column<7;
   BEQ diagnalCheck22                ;if so, go to diagnalCheck3Part2
diagnalCheck26   
   CMP R5,#3                         ;for(row = 0; row<3;
   BEQ diagnalCheck23                ;if so, go to diagnalCheck3Part3
   MUL R8,R5,R7                      ;index(Board[row]) = row * length
   ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
   LDRB R0,[R4,R8,LSL #0]            ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)]
   SUB R11,R11,#1                    ;secondColumn =column - 1
   ADD R10,R5,#1                     ;secondRow =row +1
   MUL R8,R10,R7                     ;index(Board[row]) = row * length
   ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
   LDRB R1,[R4,R8,LSL #0]            ;secondElem(Board[row,column]) = Memory.Word[Board + (index*4)]
   CMP R0,#0                         ;firstElem = 0?
   BEQ diagnalCheck02                ;if so, go to diagnalCheck02
   CMP R0,R1                         ;R0(firstElem) = R1(secondElem)?
   BEQ diagnalCheck24                ;if so, go to diagnalCheck3Part4
diagnalCheck02   
   MOV R9,#0                         ;reset count as 0
   B diagnalCheck25                  ;go to diagnalCheck3Part5
diagnalCheck24
   ADD R9,R9,#1                      ;count++;
diagnalCheck25
   ADD R5,R5,#1                      ;row++
   CMP R9,#3
   BEQ diagnalCheckPosResult  
   B   diagnalCheck26
diagnalCheck23
   MOV R5,#0                         ;R5 = row
   MOV R9,#0                         ;R9 = count
   ADD R6,R6,#1                      ;column++
   MOV R11,R6                        ;indexcolumn = column
   B   diagnalCheck21
diagnalCheck22  
   B   diagnalCheck3
   
   
diagnalCheck3   
   MOV R5,#6                         ;R5 = row
   MOV R6,#0                         ;R6 = column
   MOV R9,#0                         ;R9 = count
   MOV R11,R6                        ;R11 =indexcolumn
diagnalCheck31
   CMP R6,#4                         ;for(column = 0;column<4;
   BEQ diagnalCheck32                ;if so, go to diagnalCheck3Part2
diagnalCheck36   
   CMP R5,#3                         ;for(row=6;3<row;
   BEQ diagnalCheck33                ;if so, go to diagnalCheck3Part3
   MUL R8,R5,R7                      ;index(Board[row]) = row * length
   ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
   LDRB R0,[R4,R8,LSL #0]            ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)]
   ADD R11,R11,#1                    ;secondColumn =column + 1
   SUB R10,R5,#1                     ;secondRow =row -1
   
   MUL R8,R10,R7                     ;index(Board[row]) = row * length
   ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
   LDRB R1,[R4,R8,LSL #0]            ;secondElem(Board[row,column]) = Memory.Word[Board + (index*4)]
   CMP R0,#0                         ;firstElem = 0?
   BEQ diagnalCheck03                ;if so, go to diagnalCheck03
   CMP R0,R1                         ;R0(firstElem) = R1(secondElem)?
   BEQ diagnalCheck34                ;if so, go to diagnalCheck3Part4
diagnalCheck03   
   MOV R9,#0                         ;reset count as 0
   B diagnalCheck35                  ;go to diagnalCheck3Part5
diagnalCheck34
   ADD R9,R9,#1                      ;count++;
diagnalCheck35
   SUB R5,R5,#1                      ;row--
   CMP R9,#3
   BEQ diagnalCheckPosResult  
   B   diagnalCheck36
diagnalCheck33
   MOV R5,#6                         ;R5 = row
   MOV R9,#0                         ;R9 = count
   ADD R6,R6,#1                      ;column++
   MOV R11,R6                        ;indexcolumn = column
   B   diagnalCheck31
diagnalCheck32  
   B   diagnalCheck4
   
   
diagnalCheck4   
   MOV R5,#6                         ;R5 = row
   MOV R6,#3                         ;R6 = column
   MOV R9,#0                         ;R9 = count
   MOV R11,R6                        ;R11 = R6 =  indexcolumn
diagnalCheck41
   CMP R6,#7                         ;for(column=3;column<7;
   BEQ diagnalCheck42                ;if so, go to diagnalCheck4.2
diagnalCheck46   
   CMP R5,#3                         ;for(row=6;3<row;
   BEQ diagnalCheck43                ;if so, go to diagnalCheck4.3
   MUL R8,R5,R7                      ;index(Board[row]) = row * length
   ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
   LDRB R0,[R4,R8,LSL #0]            ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)]
   SUB R11,R11,#1                    ;secondColumn =column - 1
   SUB R10,R5,#1                     ;secondRow =row -1=
   MUL R8,R10,R7                     ;index(Board[row]) = row * length
   ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
   LDRB R1,[R4,R8,LSL #0]            ;secondElem(Board[row,column]) = Memory.Word[Board + (index*4)]
   CMP R0,#0                         ;firstElem = 0?
   BEQ diagnalCheck04                ;if so, go to diagnalCheck04
   CMP R0,R1                         ;R0(firstElem) = R1(secondElem)?
   BEQ diagnalCheck44                ;if so, go to diagnalCheck4.4
diagnalCheck04   
   MOV R9,#0                         ;reset count as 0
   B diagnalCheck45                  ;go to diagnalCheck4.5
diagnalCheck44
   ADD R9,R9,#1                      ;count++;
diagnalCheck45
   SUB R5,R5,#1                      ;row--
   CMP R9,#3
   BEQ diagnalCheckPosResult  
   B   diagnalCheck46
diagnalCheck43
   MOV R5,#6                         ;R5 = row
   MOV R9,#0                         ;R9 = count
   ADD R6,R6,#1                      ;column++
   MOV R11,R6                        ;indexColumn = column
   B   diagnalCheck41
diagnalCheck42  
   B   diagnalCheckNegaticeResult  
   
diagnalCheckPosResult
  MOV R0,R1                          ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)]LDR R0,LDRB
  B diagnalCheckEnd
diagnalCheckNegaticeResult
  MOV R0,#0   
diagnalCheckEnd
   POP{R4-R12,PC}
   
   
; computerMove subroutine
; determine which position computer makes move
; parameters
;    r0: address of board
;    r1: last move computer made
; return
;    r0: the number of column computer chose

computerMove
   PUSH{R4-R12,LR}
   MOV R4,R0                        ;R4 = the address of board
   MOV R8,#0                        ;R8 = (boolean found = false;)
   MOV R5,#0                        ;R5 = row   =0
   MOV R6,#0                        ;R6 = column =0 
   MOV R7,#7                        ;R7 = length =7
computerMove1
   CMP R5,R7                        ;for(row =0;
   BEQ computerMoveNegResult        ;           row<length(7);row++){
computerMove2
   CMP R6,R7                        ;for(column =0;
   BEQ computerMove4                ;              column<length(7);column++){
   MUL R9,R5,R7                     ;index(Board[row]) = row * length
   ADD R9,R9,R6                     ;index(Board[row][column) = index(Board[row]) + column
   LDRB R10,[R4,R9,LSL #0]          ;elem(Board[row,column]) = Memory.Word[Board + (index*4)]
   CMP R10,#0                       ;elem(Board[row,column]) = 0?
   BNE computerMoveCheckHorizontal1 ;if not, go to computerMoveCheckHorizontal1
computerMoveNextNumber   
   ADD R6,R6,#1                     ;column++
   B   computerMove2                ;}
computerMove4
   ADD R5,R5,#1                     ;row++
   MOV R6,#0                        ;column =0
   B   computerMove1                ;} 
   
   
computerMoveCheckHorizontal1
   MOV R2,#0                        ;R2 = startingNot0
   MOV R9,#0                        ; R9 = count
   MOV R11,#0                       ;R11 = columnIndex
computerMoveCheckHorizontalResetCount
   MOV R9,#0                        ; R9 = count
   MOV R2,#0                        
computerMoveCheckinghorizontal2   
   CMP R9,#2                        ;R9 = 2?
   BEQ computerMovePosHorizontalResult ;if so go to computerMovePosHorizontalResult
   MUL R10,R5,R7                    ;index(Board[row]) = row * length
   ADD R10,R10,R11                  ;index(Board[row][column) = index(Board[row]) + columnIndex
   LDRB R10,[R4,R10,LSL #0]         ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)] 
   ADD R11,R11,#1                   ;columnIndex++
   CMP R11,#7                       ;columnIndex = 7?
   BEQ computerMoveCheckingVertical1 ;if so, go to computerMoveCheckingVertical1
   MUL R12,R5,R7                    ;index(Board[row]) = row * length
   ADD R12,R12,R11                  ;index(Board[row][column) = index(Board[row]) + columnIndex
   LDRB R12,[R4,R12,LSL #0]         ;secondElem(Board[row,column]) = Memory.Word[Board + (index*4)]
   
   CMP R10,#0                       ;firstElem = 0?
   BEQ computerMoveCheckHorizontalResetCount    ;if so, go to computerMoveCheckHorizontalResetCount
   
   CMP R10,R12                      ;firstElem = secondElem ?
   BNE computerMoveCheckHorizontalResetCount
   ADD R9,R9,#1                     ;count++
   SUB R2,R11,#1                    ;startingNot0 = columnIndex - 1
   B   computerMoveCheckinghorizontal2

computerMovePosHorizontalResult
   ADD R11,R11,#1                   ;columnIndex++
   CMP R11,#7                       ;R11 =7? 
   BEQ computerMovePosHorizontalResult2 ;if so , go to computerMovePosHorizontalResult2
   MUL R10,R5,R7                    ;index(Board[row]) = row * length
   ADD R10,R10,R11                  ;index(Board[row][column) = index(Board[row]) + columnIndex
   LDRB R10,[R4,R10,LSL #0]         ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)] 
   CMP R10,#0
   BNE computerMovePosHorizontalResult2
   MOV R0,R11                       ;returnColumnNumber = columnIndex
   B   computerMoveEnd
computerMovePosHorizontalResult2  
   CMP R2,#0
   BLT computerMoveCheckingVertical1
   MUL R10,R5,R7                    ;index(Board[row]) = row * length
   ADD R10,R10,R2                   ;index(Board[row][column) = index(Board[row]) + columnIndex
   LDRB R10,[R4,R10,LSL #0]         ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)] 
   CMP R10,#0
   BNE computerMoveCheckingVertical1
   MOV R0,R2                       ;returnColumnNumber = startingNot0
   B   computerMoveEnd
   
computerMoveCheckingVertical1
   MOV R2,#0                        ;R2 = startingNot0
   MOV R9,#0                        ; R9 = count
   MOV R11,#0                       ;R11 = rowIndex
computerMoveCheckVerticalResetCount
   MOV R9,#0                        ; R9 = count   
   MOV R2,#0  
computerMoveCheckingVertical2
   CMP R9,#2                        ;R9 = 2?
   BEQ computerMovePosVertical1Result ;if so go to computerMovePosVertical1Result
   MUL R10,R11,R7                   ;index(Board[row]) = rowIndex * length
   ADD R10,R10,R6                   ;index(Board[row][column) = index(Board[row]) + column
   LDRB R10,[R4,R10,LSL #0]         ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)] 
   ADD R11,R11,#1                   ;columnIndex++
   CMP R11,#7                       ;columnIndex = 7?
   BEQ preComputerMoveNextNumber  ;if so, go to checkingDiagnal
   MUL R12,R11,R7                   ;index(Board[row]) = rowIndex * length
   ADD R12,R12,R6                   ;index(Board[row][column) = index(Board[row]) + column
   LDRB R12,[R4,R12,LSL #0]         ;secondElem(Board[row,column]) = Memory.Word[Board + (index*4)]
   
   CMP R10,#0                       ;firstElem = 0?
   BEQ computerMoveCheckVerticalResetCount      ;if so, go to checkingVertical2
   
   
   CMP R10,R12                      ;firstElem = secondElem ?
   BNE computerMoveCheckVerticalResetCount
   ADD R9,R9,#1                     ;count++
   SUB R2,R11,#1                    ;startingNot0 = rowIndex - 1
   B   computerMoveCheckingVertical2

computerMovePosVertical1Result
computerMovePosVertical1Result2
   CMP R2,#0
   BLT preComputerMoveNextNumber
   MUL R10,R5,R7                    ;index(Board[row]) = row * length
   ADD R10,R10,R2                   ;index(Board[row][column) = index(Board[row]) + columnIndex
   LDRB R10,[R4,R10,LSL #0]         ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)] 
   CMP R10,#0
   BNE preComputerMoveNextNumber
   MOV R0,R2                        ;returnColumnNumber = startingNot0
   B   computerMoveEnd
 
;computerMoveCheckingDiagnal  
;   MOV R0,R4                        ;R0 = R4 = board
;   BL  computerMoveNegResult2       ;
;   CMP R0,#9
;   BEQ preComputerMoveNextNumber
;   BNE computerMoveEnd
   
   
preComputerMoveNextNumber
   MOV R9,#0
   B   computerMoveNextNumber
computerMoveFixFirstNumber
   MOV R1,#-1
   B   computerMoveNegResult5
   
computerMoveNegResult
   MOV R5,#0                        ;R5 = row   =0
   CMP R1,#9                        ;R1 =9?
   BEQ computerMoveFixFirstNumber
computerMoveNegResult5
   CMP R1,#6                        ;R1 =6?
   BNE computerMoveNegResult4       ;if so, go to computerMoveNegResult4
   MOV R1,#-1                        ;R1 =0
computerMoveNegResult4   
   ADD R6,R1,#1                        ;R6 = column =R1
   MOV R7,#7                        ;R7 = length =7
computerMoveNegResult2
   MUL R10,R5,R7                    ;index(Board[row]) = row * length
   ADD R10,R10,R6                   ;index(Board[row][column) = index(Board[row]) + column
   LDRB R10,[R4,R10,LSL #0]         ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)] 
   CMP R10,#0                       ;R10 =0?
   BNE computerMoveNegResult3       ;if not, go to computerMoveNegResult3
   MOV R0,R6                        ;R0 = R6
   B   computerMoveEnd              ;go to computerMoveEnd
computerMoveNegResult3
   ADD R6,R6,#1                     ;R6++
   B   computerMoveNegResult2       ;go to computerMoveNegResult2
computerMoveEnd
   POP{R4-R12,PC}
   
   

; diagnalCheck subroutine
; check whether a player win or not in diag
; parameters
;    r0: address of board
; return
;    r0: if there is a position where computer can make move to win easily, if not return #9

;supplemental   
;computerMoveDiagnalCheck
 ;  PUSH{R4-R12,LR}
 ;  MOV R4,R0                         ;R4 = board
 ;  MOV R5,#0                         ;R5 = row
 ;  MOV R6,#0                         ;R6 = column
 ;  MOV R7,#7                         ;R7 = length =7
 ;  MOV R9,#0                         ;R9 = count
;computerMoveDiagnalCheck1   
;   MOV R5,#0                         ;R5 = row
;   MOV R6,#0                         ;R6 = column
;   MOV R9,#0                         ;R9 = count
;   MOV R11,R6                        ;R11 =indexcolumn
;   MOV R2,#0                         ;R2 = startingNot0Row
;   MOV R3,#0                         ;R3 = startingNot0Column
;computerMoveDiagnalCheck11
;   CMP R6,#4                         ;for(column =0;column<4;
;   BEQ computerMoveDiagnalCheck12                ;if so, go to diagnalCheck3Part2
;computerMoveDiagnalCheck16   
;   CMP R5,#3                         ;for(row =0;row<3;
;   BEQ computerMoveDiagnalCheck13                ;if so, go to diagnalCheck3Part3
;   MUL R8,R5,R7                      ;index(Board[row]) = row * length
;   ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
;   LDRB R0,[R4,R8,LSL #0]            ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)]
;   ADD R11,R11,#1                    ;secondColumn =column + 1
;   ADD R10,R5,#1                     ;secondRow =row +1
   
;   MUL R8,R10,R7                     ;index(Board[row]) = row * length
;   ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
;  LDRB R1,[R4,R8,LSL #0]            ;secondElem(Board[row,column]) = Memory.Word[Board + (index*4)]
  
;   CMP R0,#0                         ;firstElem = 0?
;   BEQ computerMoveDiagnalCheck01                ;if so, go to diagnalCheck01
  
;   CMP R0,R1                         ;R0(firstElem) = R1(secondElem)?
;   BEQ computerMoveDiagnalCheck14                ;if so, go to diagnalCheck3Part4
;computerMoveDiagnalCheck01   
;   MOV R9,#0                         ;reset count as 0
;   B computerMoveDiagnalCheck15                  ;go to diagnalCheck3Part5
;computerMoveDiagnalCheck14
;   ADD R9,R9,#1                      ;count++
;   MOV R2,R5                         ;startingNot0Row = row
;   SUB R3,
;computerMoveDiagnalCheck15
;   ADD R5,R5,#1                      ;row++
;   CMP R9,#3
;   BEQ computerMoveDiagnalCheckPosResult   
;   B   computerMoveDiagnalCheck16
;computerMoveDiagnalCheck13
;   MOV R5,#0                         ;R5 = row
;   MOV R9,#0                         ;R9 = count
;   ADD R6,R6,#1                      ;column++
;   MOV R11,R6                        ;indexcolumn = column
;   B   computerMoveDiagnalCheck11
;computerMoveDiagnalCheck12  
;   B   computerMoveDiagnalCheck2
   
   
;computerMoveDiagnalCheck2   
;   MOV R5,#0                         ;R5 = row
;   MOV R6,#3                         ;R6 = column
;   MOV R9,#0                         ;R9 = count
;   MOV R11,R6                        ;R11 =indexcolumn
;computerMoveDiagnalCheck21
;   CMP R6,#7                         ;for(column = 3;column<7;
;   BEQ computerMoveDiagnalCheck22                ;if so, go to diagnalCheck3Part2
;computerMoveDiagnalCheck26   
;   CMP R5,#3                         ;for(row = 0; row<3;
;   BEQ computerMoveDiagnalCheck23                ;if so, go to diagnalCheck3Part3
;   MUL R8,R5,R7                      ;index(Board[row]) = row * length
;   ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
;   LDRB R0,[R4,R8,LSL #0]            ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)]
;   
;   SUB R11,R11,#1                    ;secondColumn =column - 1
;   ADD R10,R5,#1                     ;secondRow =row +1
;   
;   MUL R8,R10,R7                     ;index(Board[row]) = row * length
;   ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
;   LDRB R1,[R4,R8,LSL #0]            ;secondElem(Board[row,column]) = Memory.Word[Board + (index*4)]
;  
;   CMP R0,#0                         ;firstElem = 0?
;   BEQ computerMoveDiagnalCheck02                ;if so, go to diagnalCheck02
;  
;   CMP R0,R1                         ;R0(firstElem) = R1(secondElem)?
;;   BEQ computerMoveDiagnalCheck24                ;if so, go to diagnalCheck3Part4
;computerMoveDiagnalCheck02   
;   MOV R9,#0                         ;reset count as 0
;   B computerMoveDiagnalCheck25                  ;go to diagnalCheck3Part5
;computerMoveDiagnalCheck24
;   ADD R9,R9,#1                      ;count++;
;computerMoveDiagnalCheck25
;   ADD R5,R5,#1                      ;row++
;   CMP R9,#3
;   BEQ computerMoveDiagnalCheckPosResult  
 ;  B   computerMoveDiagnalCheck26
;computerMoveDiagnalCheck23
;   MOV R5,#0                         ;R5 = row
;   MOV R9,#0                         ;R9 = count
;   ADD R6,R6,#1                      ;column++
;   MOV R11,R6                        ;indexcolumn = column
 ;  B   computerMoveDiagnalCheck21
;computerMoveDiagnalCheck22  
;   B   computerMoveDiagnalCheck3
   
   
;computerMoveDiagnalCheck3   
;   MOV R5,#6                         ;R5 = row
;   MOV R6,#0                         ;R6 = column
;   MOV R9,#0                         ;R9 = count
;   MOV R11,R6                        ;R11 =indexcolumn
;computerMoveDiagnalCheck31
;   CMP R6,#4                         ;for(column = 0;column<4;
;   BEQ computerMoveDiagnalCheck32                ;if so, go to diagnalCheck3Part2
;computerMoveDiagnalCheck36   
;   CMP R5,#3                         ;for(row=6;3<row;
;   BEQ computerMoveDiagnalCheck33                ;if so, go to diagnalCheck3Part3
;   MUL R8,R5,R7                      ;index(Board[row]) = row * length
;   ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
;   LDRB R0,[R4,R8,LSL #0]            ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)]
;   ADD R11,R11,#1                    ;secondColumn =column + 1
;   SUB R10,R5,#1                     ;secondRow =row -1
;   
;   MUL R8,R10,R7                     ;index(Board[row]) = row * length
;   ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
;   LDRB R1,[R4,R8,LSL #0]            ;secondElem(Board[row,column]) = Memory.Word[Board + (index*4)]
;  
;   CMP R0,#0                         ;firstElem = 0?
;   BEQ computerMoveDiagnalCheck03                ;if so, go to diagnalCheck03
;  
;   CMP R0,R1                         ;R0(firstElem) = R1(secondElem)?
;   BEQ computerMoveDiagnalCheck34                ;if so, go to diagnalCheck3Part4
;computerMoveDiagnalCheck03   
;   MOV R9,#0                         ;reset count as 0
;   B   computerMoveDiagnalCheck35                  ;go to diagnalCheck3Part5
;computerMoveDiagnalCheck34
;   ADD R9,R9,#1                      ;count++;
;computerMoveDiagnalCheck35
;   SUB R5,R5,#1                      ;row--
;   CMP R9,#3
;   BEQ computerMoveDiagnalCheckPosResult  
;   B   computerMoveDiagnalCheck36
;computerMoveDiagnalCheck33
;   MOV R5,#6                         ;R5 = row
;   MOV R9,#0                         ;R9 = count
;   ADD R6,R6,#1                      ;column++
;   MOV R11,R6                        ;indexcolumn = column;
;   B   computerMoveDiagnalCheck31
;computerMoveDiagnalCheck32  
;   B   computerMoveDiagnalCheck4
   
   
;computerMoveDiagnalCheck4   
;   MOV R5,#6                         ;R5 = row
;   MOV R6,#3                         ;R6 = column
;   MOV R9,#0                         ;R9 = count
;   MOV R11,R6                        ;R11 = R6 =  indexcolumn
;computerMoveDiagnalCheck41
;   CMP R6,#7                         ;for(column=3;column<7;
;   BEQ computerMoveDiagnalCheck42                ;if so, go to diagnalCheck4.2
;computerMoveDiagnalCheck46   
;   CMP R5,#3                         ;for(row=6;3<row;
;   BEQ computerMoveDiagnalCheck43                ;if so, go to diagnalCheck4.3
;   MUL R8,R5,R7                      ;index(Board[row]) = row * length
 ;  ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
 ;  LDRB R0,[R4,R8,LSL #0]            ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)]
   
;   SUB R11,R11,#1                    ;secondColumn =column - 1
;   SUB R10,R5,#1                     ;secondRow =row -1
   
;   MUL R8,R10,R7                     ;index(Board[row]) = row * length
;   ADD R8,R8,R11                     ;index(Board[row][column) = index(Board[row]) + column
;   LDRB R1,[R4,R8,LSL #0]            ;secondElem(Board[row,column]) = Memory.Word[Board + (index*4)]
  
;   CMP R0,#0                         ;firstElem = 0?
;   BEQ computerMoveDiagnalCheck04                ;if so, go to diagnalCheck04
  
;   CMP R0,R1                         ;R0(firstElem) = R1(secondElem)?
;   BEQ computerMoveDiagnalCheck44                ;if so, go to diagnalCheck4.4
;computerMoveDiagnalCheck04   
;   MOV R9,#0                         ;reset count as 0
;   B   computerMoveDiagnalCheck45                  ;go to diagnalCheck4.5
;computerMoveDiagnalCheck44
;   ADD R9,R9,#1                      ;count++;
;computerMoveDiagnalCheck45
;   SUB R5,R5,#1                      ;row--
;   CMP R9,#3
;   BEQ computerMoveDiagnalCheckPosResult  
;   B   computerMoveDiagnalCheck46
;computerMoveDiagnalCheck43
;   MOV R5,#6                         ;R5 = row
;   MOV R9,#0                         ;R9 = count
;   ADD R6,R6,#1                      ;column++
;   MOV R11,R6                        ;indexColumn = column
 ;  B   computerMoveDiagnalCheck41
;computerMoveDiagnalCheck42  
;   B   computerMoveDiagnalCheckNegaticeResult  
   
;computerMoveDiagnalCheckPosResult
;  MOV R0,R1                          ;firstElem(Board[row,column]) = Memory.Word[Board + (index*4)]LDR R0,LDRB
;  B   computerMoveDiagnalCheckEnd
;computerMoveDiagnalCheckNegaticeResult
;  MOV R0,#0   
;computerMoveDiagnalCheckEnd
;  POP{R4-R12,PC}
   





;
; inithw subroutines
; performs hardware initialisation, including console
; parameters:
;	none
; return value:
;	none
;
inithw
	LDR	R0, =PINSEL0		; enable UART0 TxD and RxD signals
	MOV	R1, #0x50
	STRB	R1, [R0]
	LDR	R0, =U0LCR		; 7 data bits + parity
	LDR	R1, =0x02
	STRB	R1, [R0]
	BX	LR

;
; get subroutine
; returns the ASCII code of the next character read on the console
; parameters:
;	none
; return value:
;	R0 - ASCII code of the character read on teh console (byte)
;
get	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
get0	LDR	R0, [R1]		; wait until
	ANDS	R0, #0x01		; receiver data
	BEQ	get0			; ready
	LDR	R1, =U0RBR		; R1 -> U0RBR (Receiver Buffer Register)
	LDRB	R0, [R1]		; get received data
	BX	LR			; return

;
; put subroutine
; writes a character to the console
; parameters:
;	R0 - ASCII code of the character to write
; return value:
;	none
;
put	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
	LDRB	R1, [R1]		; wait until transmit
	ANDS	R1, R1, #0x20		; holding register
	BEQ	put			; empty
	LDR	R1, =U0THR		; R1 -> U0THR
	STRB	R0, [R1]		; output charcter
put0	LDR	R1, =U0LSR		; R1 -> U0LSR
	LDRB	R1, [R1]		; wait until
	ANDS	R1, R1, #0x40		; transmitter
	BEQ	put0			; empty (data flushed)
	BX	LR			; return

;
; puts subroutine
; writes the sequence of characters in a NULL-terminated string to the console
; parameters:
;	R0 - address of NULL-terminated ASCII string
; return value:
;	R0 - ASCII code of the character read on teh console (byte)
;
puts	STMFD	SP!, {R4, LR} 		; push R4 and LR
	MOV	R4, R0			; copy R0
puts0	LDRB	R0, [R4], #1		; get character + increment R4
	CMP	R0, #0			; 0?
	BEQ	puts1			; return
	BL	put			; put character
	B	puts0			; next character
puts1	LDMFD	SP!, {R4, PC} 		; pop R4 and PC


;
; hint! put the strings used by your program here ...
;

str_go
	DCB	"Let's play Connect4!!",0xA, 0xD, 0xA, 0xD, 0
	
str_go_again
	DCB	"Let's play Connect4 again!!",0xA, 0xD, 0xA, 0xD, 0	
	
yellowPlayer
    DCB "YELLOW: choose a column for your next move (1-7, q to restart):",0x0a,0,0

yellowWin
    DCB "Yellow Player wins!!",0, 0, 0, 0, 0
	
redPlayer 
    DCB "RED: choose a column for your next move (1-7, q to restart):",0x0a,0,0

computerTurn
    DCB "This is a computer turn:",0xA, 0xD, 0xA, 0xD, 0

redWin
    DCB "Red Player wins!!",0, 0, 0, 0, 0
	
	
row DCB " 1 2 3 4 5 6 7",0, 0, 0, 0, 0
    
column
    DCB 1,2,3,4,5,6,7
	
changeLine	DCB "",0x0a,0,0

changeLine2 DCB "",0xA, 0xD, 0xA, 0xD, 0

errorMessage DCB "Invalid input",0xA, 0xD, 0xA, 0xD, 0

;createSpace DCB " ",0, 0, 0, 0, 0

str_newl
	DCB	0xA, 0xD, 0x0

	END
