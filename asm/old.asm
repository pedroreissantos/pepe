; PEPE gerado por 'lcc' (IST: prs 2005)
; 'rl' serve como frame-pointer e 'r0' como acumulador
; os registos 'r1' a 'r10' sao preservados nas chamadas
PLACE 0
JMP main
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
POP r9
POP r10
RET
; global main
main: ; ncalls=3
PUSH r10
PUSH rl
MOV rl, sp
SUB sp, 2
CALL readi
MOV [rl + -2],r0
MOV r10, [rl + -2]
PUSH r10
CALL fib
ADD sp,2
MOV r10,r0
PUSH r10
CALL printi
ADD sp,2
MOV r0,0
L4:
MOV sp, rl
POP rl
POP r10
RET
; extern printi
; extern readi
