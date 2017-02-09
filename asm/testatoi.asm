; PEPE gerado por 'lcc' (IST: prs 2005)
; 'rl' serve como frame-pointer e 'r0' como acumulador
; os registos 'r1' a 'r10' sao preservados nas chamadas
; USE: pepe asm/testatoi.asm  -q -- 32
include atoi.asm
include lib.asm
; global main
; TEXT
main: ; ncalls=3
PUSH r10
PUSH rl
MOV rl, sp
; P_argc EQU 6
; P_argv EQU 8
MOV r10, 8
ADD r10, rl
MOV r10,[r10]
MOV r10, [r10 + 2] ; MOVB
PUSH r10
CALL atoi
ADD sp,2
MOV r10,r0
PUSH r10
CALL printi
ADD sp,2
MOV r10,L2
PUSH r10
CALL prints
ADD sp,2
MOV r0,0
L1:
MOV sp, rl
POP rl
POP r10
RET
; extern prints
; extern atoi
; extern printi
; RODATA
L2:
STRING "", 10, 0
