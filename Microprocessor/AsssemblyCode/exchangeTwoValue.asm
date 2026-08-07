ORG 100h ; Standard 8086 program start address

; Initialize AX and BX with some values (you can change these)
MOV AX, 1234h
MOV BX, 5678h

; Exchange the values of AX and BX
XCHG AX, BX

; Terminate the program
MOV AH, 4Ch
INT 21h

RET
