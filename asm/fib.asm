; PEPE gerado por 'lcc' (IST: prs 2005)
; 'rl' serve como frame-pointer e 'r0' como acumulador
; os registos 'r1' a 'r10' sao preservados nas chamadas
PLACE 0
CALL main
SWE 240 ; exit(code in r0)
; global main
; TEXT
main: ; ncalls=5
PUSH r9
PUSH r10
PUSH rl
MOV rl, sp
MOV r0, 10
SUB sp, r0
MOV r10,45
MOV [rl + -8],r10
MOV r10,0
MOV [rl + -2],r10
MOV r10,1
MOV [rl + -6],r10
MOV r10, -4
ADD r10, rl
MOV r9, -2
ADD r9, rl
MOV [r10],r9
MOV r10,L2
PUSH r10
CALL prints
ADD sp,2
CALL readi
MOV [rl + -8],r0
JMP L4
L3:
MOV r10,L6
PUSH r10
CALL prints
ADD sp,2
MOV r10, [rl + -2]
MOV r9, [rl + -6]
ADD r10,r9
MOV r9, -4
ADD r9, rl
MOV r9,[r9]
MOV [r9],r10
PUSH r10
CALL printi
ADD sp,2
MOV r10, -4
ADD r10, rl
MOV r10,[r10]
MOV r9, -2
ADD r9, rl
CMP r10,r9
JNE L8
MOV r10, -10
ADD r10, rl
MOV r9, -6
ADD r9, rl
MOV [r10],r9
JMP L9
L8:
MOV r10, -10
ADD r10, rl
MOV r9, -2
ADD r9, rl
MOV [r10],r9
L9:
MOV r10, -4
ADD r10, rl
MOV r9, -10
ADD r9, rl
MOV r9,[r9]
MOV [r10],r9
L4:
MOV r10, [rl + -8]
MOV r9,r10
SUB r9,1
MOV [rl + -8],r9
CMP r10,0
JGT L3
MOV r10,L10
PUSH r10
CALL prints
ADD sp,2
MOV r0,0
L1:
MOV sp, rl
POP rl
POP r9
POP r10
RET
; extern printi
; extern readi
; extern prints
; RODATA
L10:
STRING "", 10, 0
L6:
STRING " ", 0
L2:
STRING "Numero a calcular: ", 0
; STRING "N", 250, "mero a calcular: ", 0
