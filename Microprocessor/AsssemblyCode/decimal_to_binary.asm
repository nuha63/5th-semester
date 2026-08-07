ORG 100h  ; Set the origin to 100h (standard for .COM programs)

MOV CX, 16       ; Set the loop counter to 16 (for 16 bits in a word)
MOV AX, 100     ; Load the decimal number to be converted into AX
MOV BX, 0        ; Clear BX to store the binary result

convert_loop:
    SHR AX, 1    ; Shift AX right by 1 (divide by 2)
    RCL BX, 1    ; Rotate the carry bit into BX
    LOOP convert_loop  ; Repeat the loop until CX becomes zero

; Display the binary result
MOV CX, 16       ; Set the loop counter to 16 (for 16 bits)
LEA SI, [binary_result]  ; Load the address of binary_result into SI

display_loop:
    MOV DL, '0'  ; Load '0' into DL (ASCII value for 0)
    TEST BX, 1   ; Check the least significant bit of BX
    JNZ set_bit  ; If it's 1, jump to set_bit
    MOV DL, '0'  ; If it's 0, DL remains '0'
    JMP next_char  ; Jump to next_char

set_bit:
    MOV DL, '1'  ; Set DL to '1' if the least significant bit is 1

next_char:
    MOV AH, 2          ; Function to display a character in DL
    INT 21h            ; Call DOS to display the character
    SHR BX, 1          ; Shift right to check the next bit
    LOOP display_loop  ; Repeat the loop until CX becomes zero

INT 20h  ; Terminate the program

binary_result DB "0000000000000000$"  ; String to store the binary result

RET
