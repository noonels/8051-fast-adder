;      Author: Matthew Healy   <mhealy@mst.edu>
;              Jaxson Johnston <jnjt37@mst.edu>
;              Lukas Grbesa    <lgqq3@mst.edu>
;       Group: NULL
;        Date: 29 November 2017
;     License: MIT License
; Description: This program simulates the functionality of a
;              carry lookahead fast adder using an 8051 microcontroller.
;              Since this is a software simulation, it does not perform as
;              quickly as an implementation in logic gates, but it serves
;              as a proof-of-concept.

        MOV 40H, #00H   ; Input A
        MOV 41H, #00H
        MOV 42H, #00H
        MOV 43H, #00H
        MOV 44H, #00H
        MOV 45H, #00H
        MOV 46H, #00H
        MOV 47H, #00H

        MOV 48H, #00H  ; Input B
        MOV 49H, #00H
        MOV 4AH, #00H
        MOV 4BH, #00H
        MOV 4CH, #00H
        MOV 4DH, #00H
        MOV 4EH, #00H
        MOV 4FH, #00H

        MOV R2,  #8H   ; Length of longest operand in bytes

        MOV R0, #40H
        MOV R1, #48H
        MOV A, R2
        MOV R5, A      ; length of operands stored in R2

SETUP:  MOV SCON, #10000010B
        MOV TMOD, #00010000B
        MOV TL1, #00H  ; start timer at 0
        MOV TLH, #00H  ; start timer at 0

INPUTA: MOV SBUF, @R0  ; output byte of A
        INC R0         ; move to next byte
        DJNZ R5, INPUTA
        MOV R0, #40H   ; reset to beginning of A

        MOV A, R2      ; reset counter
        MOV R5, A
INPUTB: MOV SBUF, @R1  ; output byte of B
        INC R1
        DJNZ R5, INPUTB
        MOV R1, #48H   ; reset to beginning of B

        SETB TR1       ; start timer
        MOV A, R2      ; init counter
        MOV R5, A
LOAD:   MOV R4, @R0    ; temp hold for byte of R6 data
        MOV A, @R0
        XRL A, @R1     ; propagate
        MOV @R0, A

        MOV A, @R1
        ANL A, R4      ; generate
        MOV @R1, A
        INC R0         ; move to next bit of P
        INC R1         ; move to next bit of G
        DJNZ R5, LOAD

        MOV A, R2      ; reset R5
        MOV R5, A
        CLR C          ; C will be used as Ci in boolean equation
        MOV R0, #040H
        MOV R1, #048H


CARRY:  MOV A, @R0
        MOV R3, A
        MOV A, @R1
        MOV R4, #8H    ; set counter for 8 rotations
BYTE:   ANL C, A.0     ; intermediate = Ci AND P(i+1)
        ORL R3.0, C
        MOV C, R3.0    ; save Ci into C as well as R3.0
        RL A           ; rotate P byte
        MOV @R1        ; store P byte in mem
        MOV A, R3      ; move G/C to A for rotation
        RL A           ; rotate G/C byte
        MOV R3, A      ; replace byte in R3
        MOV A, @R1     ; reload P from mem
        DJNZ R4, BYTE  ; repeat for whole byte
        MOV A, R3
        MOV @R0, A     ; replace C/G in memory

        INC R0
        INC R1
        DJNZ R5, CARRY

SUM:    MOV A, @R0
        XRL A, @R1
        MOV @R0, A     ; compute final sum
        INC R0         ; move to next bit of P
        INC R1         ; move to next bit of Carry string
        DJNZ R5, SUM
        CLR TR1        ; stop timer

TIME:   MOV SBUF, TH1  ; output high byte of time
        MOV SBUF, TL1  ; output low byte of time

        MOV R0, #48H   ; reset R0 to beginning of result string
OUT:    MOV SBUF, @R0  ; output byte of result
        INC R0
        DJNZ R5, OUT
        RET            ; result string pointed to by R6
