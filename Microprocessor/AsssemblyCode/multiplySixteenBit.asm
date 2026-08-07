ORG 100h

mov ah, 0Ah     ; AH=0Ah is the "read string" function
mov dx, buffer  ; DX points to the buffer
int 21h         ; Call the interrupt to read the string

; Convert the binary string to decimal
mov si, buffer + 2  ; SI points to the length byte
mov cx, 0          ; CX will hold the decimal result

convert_loop:
    mov al, [si]   ; Load the current character
    cmp al, '0'
    jl  end_convert; Jump to the end if not a valid character
    cmp al, '1'
    jg  end_convert
    sub al, '0'    ; Convert ASCII to binary
    shl cx, 1      ; Multiply the current result by 2
    add cx, al     ; Add the new bit
    inc si         ; Move to the next character
    jmp convert_loop ; Repeat the process

end_convert:
; Now, CX contains the decimal result

; Display the result using emu8086's specific output function
mov dx, offset result_string
mov ah, 9       ; AH=9 is the "print string" function
int 21h         ; Call the emu8086 interrupt

int 20h         ; Terminate the program

section .bss
buffer resb 16      ; Buffer to store user input
result_string resb 256  ; Buffer to store the result message
