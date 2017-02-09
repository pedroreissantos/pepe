; PEPE gerado por 'lcc' (IST: prs 2005)
; 'rl' serve como frame-pointer e 'r0' como acumulador
; os registos 'r1' a 'r10' sao preservados nas chamadas
PLACE 0
CALL main
SWE 240 ; exit(code in r0)
; global main
; TEXT
main: ; ncalls=1
PUSH r8
PUSH r9
PUSH r10
PUSH rl
MOV rl, sp
SUB sp, 2
MOV r10, -2
ADD r10, rl
MOV r9,L2
MOV [r10],r9
JMP L4
L3:
MOV r10, -2
ADD r10, rl
MOV r10,[r10]
MOV r9, -2
ADD r9, rl
MOV r8,r10
ADD r8,1
MOV [r9],r8
MOVB r10, [r10]
PUSH r10
CALL printch
ADD sp,2
L4:
MOV r10, -2
ADD r10, rl
MOV r10,[r10]
MOVB r10, [r10]
CMP r10,0
JNE L3
MOV r0,0
L1:
MOV sp, rl
POP rl
POP r8
POP r9
POP r10
RET
; extern printch
; RODATA
L2:
STRING "Era uma vez os tr", 234, "s porquinhos e um lobo Mau!", 10, 0
