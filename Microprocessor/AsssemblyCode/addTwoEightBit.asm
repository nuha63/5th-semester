ORG 100h ; Standard 8086 program start address

MOV AL, 0x75 ; First BCD number (example: 75 in BCD)
MOV BL, 0x29 ; Second BCD number (example: 29 in BCD)

; Initialize carry flag to 0
CLC

; Add the two BCD numbers
ADD AL, BL

; Check if there's a carry (greater than 9)
AAM ; AL will now contain the BCD result (lower nibble is units, higher nibble is tens)

; Display the BCD result in AH and AL (ASCII characters)
ADD AX, 3030h ; Convert BCD to ASCII
MOV DL, AH
MOV AH, 02h ; DOS function to display a character
INT 21h ; DOS interrupt to display the tens digit
MOV DL, AL
MOV AH, 02h ; DOS function to display a character
INT 21h ; DOS interrupt to display the units digit

MOV AH, 4Ch ; DOS function to terminate the program
INT 21h ; DOS interrupt to terminate the program

RET
