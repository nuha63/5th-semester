ORG 100h  ; Set the origin to 100h (standard for COM files)

MOV SI, 0  ; Source index to point to the first BCD number in memory
MOV DI, 1  ; Destination index to point to the second BCD number in memory
MOV CX, 2  ; Counter for the number of BCD digits (2 digits)

MOV AH, 0  ; Clear AH register to store the borrow flag

SubtractLoop:
  MOV AL, [SI]   ; Load the first BCD digit into AL
  SUB AL, [DI]   ; Subtract the second BCD digit from AL
  DAA            ; Decimal adjust after subtraction

  STC            ; Set the carry flag to account for borrow

  ADC AL, AH     ; Add the borrow flag (AH) to AL

  AAM            ; Adjust AL for BCD

  MOV [DI], AL   ; Store the result back in memory

  INC SI         ; Move to the next digit in the first number
  INC DI         ; Move to the next digit in the second number
  LOOP SubtractLoop

INT 20h   ; Terminate the program

RET       ; Return to DOS (only needed for COM files)
