ORG 100h  ; Set the origin to 100h (standard for .COM programs)

MOV CX, 11       ; Set the loop counter to 11 (for 11 bits in the binary_input)
LEA SI, [101]  ; Load the offset address of binary_input into SI
MOV AX, 0        ; Clear AX to store the decimal result

convert_loop:
    SHL AX, 1    ; Shift AX left by 1 (multiply by 2)
    MOV DL, [SI] ; Load the current character from the string
    SUB DL, '0'  ; Convert ASCII character to numeric value
    ADD AX, DX   ; Add the numeric value to AX
    INC SI       ; Move to the next character in the string
    LOOP convert_loop  ; Repeat the loop until CX becomes zero

; Display the decimal result
MOV BX, 10      ; Set BX to 10 for decimal conversion
MOV CX, 5       ; Set CX to 5 (maximum number of decimal digits)
LEA DI, [decimal_result + 4] ; Point DI to the end of the decimal_result string

decimal_loop:
    XOR DX, DX       ; Clear DX for division
    DIV BX           ; Divide AX by 10, result in AX, remainder in DX
    ADD DL, '0'      ; Convert the remainder to ASCII
    DEC DI           ; Move DI to the left in the string
    MOV [DI], DL     ; Store the ASCII character in the string
    LOOP decimal_loop ; Repeat until CX becomes zero

; Display the decimal result
MOV AH, 9      ; Function to print a string
MOV DX, DI     ; DX points to the beginning of the decimal_result string
INT 21h        ; Call DOS to print the string

INT 20h  ; Terminate the program

binary_input DB "10101111101$"  ; Binary input string (11 bits)
decimal_result DB "0000$"       ; String to store the decimal result

RET
