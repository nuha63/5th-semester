ORG 100h   ; This sets the origin of the program to address 100h (the default for .COM files)

MOV AX, 100   ; Load the number for which you want to find the square root into AX

; Initialize registers for the "Guess and Check" method
MOV CX, 0    ; Initialize CX to 0 (the guess)
MOV BX, 0    ; Initialize BX to 0 (the running sum)

SQRT_LOOP:
    ADD BX, CX   ; Add the current guess to the running sum in BX
    INC CX       ; Increment the guess

    ; Calculate the square of the current guess and compare it to AX
    MOV DX, 0    ; Clear DX (necessary for the 16-bit multiply)
    MOV AX, CX   ; Move the current guess to AX
    MUL CX       ; DX:AX = AX * CX (current guess squared)
    CMP AX, 100  ; Compare the squared guess to the original number (25 in this case)

    ; If the squared guess is less than the original number, continue the loop
    JL SQRT_LOOP

    ; If the squared guess is equal to or greater than the original number, we're done
    JE SQRT_FOUND

    ; If the squared guess is greater than the original number, the guess was too large
    ; Reduce the guess and continue to refine it
    DEC CX
    JMP SQRT_LOOP

SQRT_FOUND:
    ; CX now contains the square root
    ; Display the result (you can replace this with your preferred method)
    MOV AH, 2    ; Function to display a character
    MOV DL, '0'  ; Set DL to '0'
    ADD DL, CL   ; Convert the result to ASCII (use CL instead of CX)
    INT 21h      ; Display the character

    ; Exit the program
    MOV AH, 4Ch  ; Function to exit the program
    INT 21h      ; Call the DOS interrupt

; End of the program
