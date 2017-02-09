; PEPE gerado por 'lcc' (IST: prs 2005)
; 'rl' serve como frame-pointer e 'r0' como acumulador
; os registos 'r1' a 'r10' sao preservados nas chamadas
PLACE 0
CALL main
SWE 240 ; exit(code in r0)
; global printf
; TEXT
printf: ; ncalls=5
PUSH r9
PUSH r10
PUSH rl
MOV rl, sp
; P_fmt EQU 8
SUB sp, 2
MOV r10, -2
ADD r10, rl
MOV r9, 8
ADD r9, rl
MOV [r10],r9
JMP L3
L2:
MOV r10, 8
ADD r10, rl
MOV r10,[r10]
MOVB r10, [r10]
MOV r9,37
CMP r10,r9
JNE L5
MOV r10, 8
ADD r10, rl
MOV r9, 8
ADD r9, rl
MOV r9,[r9]
ADD r9,1
MOV [r10],r9
MOV r10, 8
ADD r10, rl
MOV r10,[r10]
MOVB r10, [r10]
MOV r9,100
CMP r10,r9
JNE L7
MOV r10, -2
ADD r10, rl
MOV r9, -2
ADD r9, rl
MOV r9,[r9]
ADD r9,2
MOV [r10],r9
MOV r10, -2
ADD r10, rl
MOV r10,[r10]
MOV r10,[r10]
PUSH r10
CALL printi
ADD sp,2
JMP L6
L7:
MOV r10, 8
ADD r10, rl
MOV r10,[r10]
MOVB r10, [r10]
MOV r9,115
CMP r10,r9
JNE L9
MOV r10, -2
ADD r10, rl
MOV r9, -2
ADD r9, rl
MOV r9,[r9]
ADD r9,2
MOV [r10],r9
MOV r10, -2
ADD r10, rl
MOV r10,[r10]
MOV r10,[r10]
PUSH r10
CALL prints
ADD sp,2
JMP L6
L9:
MOV r10, 8
ADD r10, rl
MOV r10,[r10]
MOVB r10, [r10]
MOV r9,99
CMP r10,r9
JNE L11
MOV r10, -2
ADD r10, rl
MOV r9, -2
ADD r9, rl
MOV r9,[r9]
ADD r9,2
MOV [r10],r9
MOV r10, -2
ADD r10, rl
MOV r10,[r10]
MOV r10,[r10]
PUSH r10
CALL printch
ADD sp,2
JMP L6
L11:
MOV r10, 8
ADD r10, rl
MOV r10,[r10]
MOVB r10, [r10]
PUSH r10
CALL printch
ADD sp,2
JMP L6
L5:
MOV r10, 8
ADD r10, rl
MOV r10,[r10]
MOVB r10, [r10]
PUSH r10
CALL printch
ADD sp,2
L6:
MOV r10, 8
ADD r10, rl
MOV r9, 8
ADD r9, rl
MOV r9,[r9]
ADD r9,1
MOV [r10],r9
L3:
MOV r10, 8
ADD r10, rl
MOV r10,[r10]
MOVB r10, [r10]
CMP r10,0
JNE L2
MOV r0,0
L1:
MOV sp, rl
POP rl
POP r9
POP r10
RET
; global main
main: ; ncalls=1
PUSH r10
PUSH rl
MOV rl, sp
MOV r10,10
PUSH r10
MOV r10,123
PUSH r10
MOV r10,L15
PUSH r10
MOV r10,L14
PUSH r10
CALL printf
ADD sp,14
MOV r0,0
L13:
MOV sp, rl
POP rl
POP r10
RET
; extern printch
; extern prints
; extern printi
; RODATA
L15:
STRING "bkabka", 0
L14:
STRING "%s %d %c", 0
