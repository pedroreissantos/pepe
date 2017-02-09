; PEPE gerado por 'lcc' (IST: prs 2005)
; 'rl' serve como frame-pointer e 'r0' como acumulador
; os registos 'r1' a 'r10' sao preservados nas chamadas
; global atoi
; TEXT
atoi: ; ncalls=0
PUSH r8
PUSH r9
PUSH r10
PUSH rl
MOV rl, sp
; P_val EQU 10
SUB sp, 4

; i = 1
MOV r10,1
MOV [rl + -2],r10
; x = 0
MOV r10,0
MOV [rl + -4],r10

; if (*val != '-') goto L_5
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOVB r10, [r10]
MOV r9,45
CMP r10,r9
JNE L_5

; val++
MOV r10, 10
ADD r10, rl
MOV r9, 10
ADD r9, rl
MOV r9,[r9]
ADD r9,1
MOV [r10],r9
; i = -1
MOV r10,-1
MOV [rl + -2],r10
JMP L_5

L_4:
; if (*val < '0') goto L_9
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOVB r10, [r10]
MOV r9,48
CMP r10,r9
JLT L_9

; if (*val <= '9') goto L_7
MOV r9,57
CMP r10,r9
JLE L_7

L_9:
; return 0
MOV r0,0
JMP L_1

L_7:
; val++
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOV r9, 10
ADD r9, rl
MOV r8,r10
ADD r8,1
MOV [r9],r8

;  x = x * 10 + *val++ - '0';
MOV r9,10
MOV r8, [rl + -4]
MUL r9,r8
MOVB r10, [r10]
ADD r9,r10
MOV r10,48
SUB r9,r10
MOV [rl + -4],r9

L_5:
; if (*val != 0) goto L_4
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOVB r10, [r10]
CMP r10,0
JNE L_4

; return x * i
MOV r10, [rl + -4]
MOV r9, [rl + -2]
MOV r0,r10
MUL r0,r9

L_1:
MOV sp, rl
POP rl
POP r8
POP r9
POP r10
RET
