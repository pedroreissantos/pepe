MOV r0, STR
SWE 246 ; writeSTRING

MOV r0, 1
SWE 240 ; exit(1)

STR STRING "Ol� pessoal!", 10, 0
