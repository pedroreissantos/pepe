; PEPE gerado por 'lcc' (IST: prs 2005, 2009)
; 'rl' serve como frame-pointer e 'r0' como acumulador
; os registos 'r1' a 'r10' sao preservados nas chamadas
include atoi.asm
include lib.asm
; global main
; TEXT
main: ; ncalls=3
PUSH r9
PUSH r10
PUSH rl
MOV rl, sp
; P_argc EQU 8
; P_argv EQU 10
SUB sp, 4
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOV r10,[r10 + 2]
PUSH r10
CALL atoi
ADD sp,2
MOV [rl + -4],r0
JMP L3
L2:
MOV r10,0
MOV [rl + -2],r10
L5:
MOV r10, [rl + -2]
MOV r9,2
MOD r10,r9
CMP r10,0
JNE L9
MOV r10, [rl + 8]
ADD r10,1
MOV [rl + 8],r10
JMP L10
L9:
MOV r10, [rl + 8]
SUB r10,1
MOV [rl + 8],r10
L10:
L6:
MOV r10, [rl + -2]
ADD r10,1
MOV [rl + -2],r10
MOV r10, [rl + -2]
MOV r9,30000
CMP r10,r9
JLT L5
MOV r10, [rl + -4]
PUSH r10
CALL printi
ADD sp,2
CALL printLN
L3:
MOV r10, [rl + -4]
MOV r9,r10
SUB r9,1
MOV [rl + -4],r9
CMP r10,0
JNE L2
MOV r0,0
L1:
MOV sp, rl
POP rl
POP r10
POP r9
RET
; extern printLN
; extern printi
; extern atoi
