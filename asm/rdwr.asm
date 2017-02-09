MOV r0, GRET
SWE 246 ; writeSTRING

SWE 241 ; readINT
MOV r1, VAL
MOV [r1], r0

MOV r0, OUT
SWE 246 ; writeSTRING

MOV r0, VAL
MOV r0, [r0]
SWE 244 ; writeINT

SWE 247 ; writeNL
MOV r0, 2
SWE 240 ; exit(2)

VAL WORD 10
GRET STRING "Introduza um número: ", 0
OUT  STRING "Introduziu ", 0
