; PEPE gerado por 'lcc' (IST: prs 2005)
; 'rl' serve como frame-pointer e 'r0' como acumulador
; os registos 'r1' a 'r10' sao preservados nas chamadas
PLACE 0
CALL main
SWE 240 ; exit(code in r0)
; global fib
; TEXT
fib: ; ncalls=2
PUSH r9
PUSH r10
PUSH rl
MOV rl, sp
; P_i EQU 8
MOV r10, [rl + 8]
CMP r10,1
JGT L2
MOV r0, [rl + 8]
JMP L1
L2:
MOV r10, [rl + 8]
SUB r10,1
PUSH r10
CALL fib
ADD sp,2
MOV r10,r0
MOV r9, [rl + 8]
SUB r9,2
PUSH r9
CALL fib
ADD sp,2
MOV r9,r0
MOV r0,r10
ADD r0,r9
L1:
MOV sp, rl
POP rl
POP r10
POP r9
RET
; global main
main: ; ncalls=4
PUSH r10
PUSH rl
MOV rl, sp
; P_argc EQU 6
; P_argv EQU 8
MOV r10, 8
ADD r10, rl
MOV r10,[r10]
MOV r10,[r10 + 2]
PUSH r10
CALL atoi
ADD sp,2
MOV r10,r0
PUSH r10
CALL fib
ADD sp,2
MOV r10,r0
PUSH r10
CALL printi
ADD sp,2
CALL printLN
MOV r0,0
L4:
MOV sp, rl
POP rl
POP r10
RET
; extern printLN
; extern atoi
; extern printi
