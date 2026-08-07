ORG 100h  ; Set the origin to 100h (standard for .COM programs)

MOV AX, 1239h  ; Load the first 16-bit number into AX
MOV BX, 5670h  ; Load the second 16-bit number into BX

ADD AX, BX     ; Add AX and BX

; Display the result using DOS interrupt 21h (function 2)
MOV DX, AX     ; Move the result to DX
MOV AH, 2      ; Function to display a character in DL
INT 21h        ; Call DOS to display the result

INT 20h        ; Terminate the program

RET
