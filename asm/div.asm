; PEPE gerado por 'lcc' (IST: prs 2005, 2009)
; 'rl' serve como frame-pointer e 'r0' como acumulador
; os registos 'r1' a 'r10' sao preservados nas chamadas
include lib.asm
; global main
; TEXT
main: ; ncalls=8
PUSH r8
PUSH r9
PUSH r10
PUSH rl
MOV rl, sp
SUB sp, 6
MOV r10,2
MOV [rl + -2],r10
MOV r10,1
MOV [rl + -6],r10
MOV r10,L2
PUSH r10
CALL prints
ADD sp,2
CALL readi
MOV [rl + -4],r0
JMP L4
L3:
MOV r10, [rl + -4]
MOV r9, [rl + -2]
MOD r10,r9
CMP r10,0
JNE L6
MOV r10, [rl + -4]
PUSH r10
CALL printi
ADD sp,2
MOV r10,L8
PUSH r10
CALL prints
ADD sp,2
MOV r10, [rl + -2]
PUSH r10
CALL printi
ADD sp,2
MOV r10,L9
PUSH r10
CALL prints
ADD sp,2
MOV r10,0
MOV [rl + -6],r10
L6:
MOV r10, [rl + -2]
ADD r10,1
MOV [rl + -2],r10
L4:
MOV r10, [rl + -2]
MOV r9, [rl + -4]
MOV r8,2
DIV r9,r8
CMP r10,r9
JLE L3
MOV r10, [rl + -6]
CMP r10,1
JNE L10
MOV r10, [rl + -4]
PUSH r10
CALL printi
ADD sp,2
MOV r10,L12
PUSH r10
CALL prints
ADD sp,2
L10:
MOV r0,0
L1:
MOV sp, rl
POP rl
POP r10
POP r9
POP r8
RET
; extern printi
; extern readi
; extern prints
; RODATA
L12:
STRING " ", -23, " primo.", 10, 0
L9:
STRING ".", 10, 0
L8:
STRING " ", -23, " divis", -19, "vel por ", 0
L2:
STRING "C", -31, "lculo dos divisores.", 10, "Indique um n", -6, "mero: ", 0
