ORG 100h    ; Origin, standard for .COM files

MOV AX, 1234h  ; Load the first 16-bit number into AX
MOV BX, 5678h  ; Load the second 16-bit number into BX

; Subtract the second number from the first
SUB AX, BX     ; Subtract BX from AX

; Check if a borrow occurred during subtraction
JC WITH_BORROW ; Jump if carry flag is set (indicating a borrow)

; Subtract without borrow result here
; You can store or display the result in AX as needed

JMP DONE

WITH_BORROW:
; Subtract with borrow result here
; You can store or display the result in AX as needed

DONE:
; Display the result on the screen
MOV AH, 09h    ; DOS function to display string
LEA DX, ResultString  ; Load the address of the result string
INT 21h

; Exit the program
MOV AH, 4Ch    ; Exit program with return code 0
INT 21h        ; DOS function call to exit program

RET

ResultString DB "Result: $", 0
