; PEPE gerado por 'lcc' (IST: prs 2005, 2009)
; 'rl' serve como frame-pointer e 'r0' como acumulador
; os registos 'r1' a 'r10' sao preservados nas chamadas
; global main
; TEXT
main: ; ncalls=10
PUSH r9
PUSH r10
PUSH rl
MOV rl, sp
; P_argc EQU 8
; P_argv EQU 10
SUB sp, 2
MOV r10,L2
PUSH r10
CALL prints
ADD sp,2
MOV r10, [rl + 8]
PUSH r10
CALL printi
ADD sp,2
CALL printLN
MOV r10,L3
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
MOV r10,1
MOV [rl + -2],r10
JMP L7
L4:
MOV r10, [rl + -2]
PUSH r10
CALL printi
ADD sp,2
MOV r10,L8
PUSH r10
CALL prints
ADD sp,2
MOV r10, [rl + -2]
SHLA r10,1
MOV r9, 10
ADD r9, rl
MOV r9,[r9]
MOV r10,[r10 + r9]
PUSH r10
CALL prints
ADD sp,2
CALL printLN
L5:
MOV r10, [rl + -2]
ADD r10,1
MOV [rl + -2],r10
L7:
MOV r10, [rl + -2]
MOV r9, [rl + 8]
CMP r10,r9
JLT L4
MOV r0, [rl + 8]
L1:
MOV sp, rl
POP rl
POP r10
POP r9
RET
; extern printLN
; extern printi
; extern prints
; RODATA
L8:
STRING " -> ", 0
L3:
STRING "prog = ", 0
L2:
STRING "argc = ", 0
