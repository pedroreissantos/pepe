; PEPE gerado por 'lcc' (IST: prs 2005)
; 'rl' serve como frame-pointer e 'r0' como acumulador
; os registos 'r1' a 'r10' sao preservados nas chamadas
PLACE 0
CALL main
SWE 240 ; exit
; global f
; TEXT
main: ; ncalls=1
PUSH r10
PUSH rl
MOV rl, sp
SUB sp, 2
MOV r10,30000
MOV [rl -2],r10
L2:
MOV r10, [rl -2]
CMP r10, 6
JGE L3
PUSH r10
CALL print
ADD sp,2
L3:
MOV r10, [rl -2]
SUB r10,1
MOV [rl + -2],r10
CMP r10,0
JGE L2
L1:
MOV sp, rl
POP rl
POP r10
RET
; extern print
print:
PUSH r0 ; save
MOV r0, [sp + 4]
SWE 244 ; printINT
SWE 247 ; printNL
POP r0 ; restore
RET
