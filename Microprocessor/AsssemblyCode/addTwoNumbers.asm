.model small
.data
    num1 dw 1234h
    num2 dw 5678h
    result dw ?

.code
    mov ax, @data
    mov ds, ax

    mov ax, num1
    add ax, num2
    mov result, ax

    mov ax, result
    call print_num

    mov ah, 4ch
    int 21h

print_num proc
    mov bx, 10
    mov cx, 0

reverse_loop:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz reverse_loop

print_loop:
    pop dx
    mov ah, 02h
    int 21h
    loop print_loop
    ret
print_num endp
end
