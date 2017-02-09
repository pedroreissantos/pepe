PLACE 0
CALL main
SWE 240 ; exit
main:
        MOV R1, a
	MOV R1, [R1]
	MOV R2, b
	MOV R2, [R2]
; SHRA R1, R2
_L1:
	CMP R2, 0
	JEQ _L2
        SHRA R1, 1
	SUB R2, 1
	JMP _L1
_L2:
;
        MOV R0, R1
        RET
a WORD 144
b WORD 6
