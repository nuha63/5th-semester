ORG 100h ; Set the origin address

MOV AL, 75 ; Load the first BCD number (75 in BCD: 0111 0101)
MOV BL, 32 ; Load the second BCD number (32 in BCD: 0011 0010)

; Subtract BL from AL
SUB AL, BL

; Check for borrow and adjust the result if needed
MOV AH, 0   ; Clear AH
SBB AH, AH  ; Set AH to 0 or 1 based on borrow

; Adjust result if there was a borrow
DAA

; AH contains the borrow, AL contains the result
; You can print the result or use it as needed

; Exit the program
MOV AH, 4Ch
INT 21h

INT 20h ; End of program
