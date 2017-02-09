; PEPE gerado por 'lcc' (IST: prs 2005, 2009)
; 'rl' serve como frame-pointer e 'r0' como acumulador
; os registos 'r1' a 'r10' sao preservados nas chamadas
; global main
; TEXT
main: ; ncalls=5
PUSH r9
PUSH r10
PUSH rl
MOV rl, sp
; P_argc EQU 8
; P_argv EQU 10
MOV r10,L2
PUSH r10
CALL prints
ADD sp,2
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOV r10,[r10]
PUSH r10
CALL prints
ADD sp,2
CALL printLN
JMP L4
L3:
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOV r10,[r10]
PUSH r10
CALL prints
ADD sp,2
CALL printLN
L4:
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
ADD r10,2
MOV r9, 10
ADD r9, rl
MOV [r9],r10
MOV r10,[r10]
MOV r9,0
CMP r10,r9
JNE L3
MOV r0, [rl + 8]
L1:
MOV sp, rl
POP rl
POP r10
POP r9
RET
; extern printLN
; extern prints
; RODATA
L2:
STRING "prog = ", 0
