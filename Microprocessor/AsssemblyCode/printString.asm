
ORG 100h ; Set the origin address

MOV AH, 09h ; DOS function to print a string
MOV DX, OFFSET MESSAGE ; Load the address of the string into DX
INT 21h ; Call the DOS interrupt

MOV AH, 4Ch ; DOS function to exit the program
INT 21h ; Call the DOS interrupt

MESSAGE DB 'Hello,This is Hasan Ahammad', '$' ; The string to be printed, terminated with '$'

INT 20h ; End of program   

