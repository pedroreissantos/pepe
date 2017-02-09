; PEPE gerado por 'lcc' (IST: prs 2005)
; 'rl' serve como frame-pointer e 'r0' como acumulador
; os registos 'r1' a 'r10' sao preservados nas chamadas
PLACE 0
CALL main
SWE 240
; global main
; TEXT
main: ; ncalls=1
PUSH r10
PUSH rl
MOV rl, sp
MOV r10, L2
PUSH r10
CALL prints
ADD sp,2
MOV r0,0
L1:
MOV sp, rl
POP rl
POP r10
RET
; extern printf
; RODATA
L2: STRING "Sejam todos bem vindos!", 10, 0
