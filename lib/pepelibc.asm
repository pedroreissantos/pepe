; PEPE gerado por 'lcc' (IST: prs 2005, 2009)
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
MOV r10,1
MOV [rl + -2],r10
MOV r10,0
MOV [rl + -4],r10
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOVBS r10, r10
MOV r9,45
CMP r10,r9
JNE L_5
MOV r10, 10
ADD r10, rl
MOV r9, 10
ADD r9, rl
MOV r9,[r9]
ADD r9,1
MOV [r10],r9
MOV r10,-1
MOV [rl + -2],r10
JMP L_5
L_4:
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOVBS r10, r10
MOV r9,48
CMP r10,r9
JLT L_9
MOV r9,57
CMP r10,r9
JLE L_7
L_9:
MOV r0,0
JMP L_1
L_7:
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOV r9, 10
ADD r9, rl
MOV r8,r10
ADD r8,1
MOV [r9],r8
MOV r9,10
MOV r8, [rl + -4]
MUL r9,r8
MOVBS r10, r10
ADD r9,r10
MOV r10,48
SUB r9,r10
MOV [rl + -4],r9
L_5:
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOVBS r10, r10
CMP r10,0
JNE L_4
MOV r10, [rl + -4]
MOV r9, [rl + -2]
MOV r0,r10
MUL r0,r9
L_1:
MOV sp, rl
POP rl
POP r10
POP r9
POP r8
RET
; global strlen
strlen: ; ncalls=0
PUSH r8
PUSH r9
PUSH r10
PUSH rl
MOV rl, sp
; P_str EQU 10
SUB sp, 2
MOV r10, -2
ADD r10, rl
MOV r9, 10
ADD r9, rl
MOV r9,[r9]
MOV [r10],r9
L_11:
L_12:
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOV r9, 10
ADD r9, rl
MOV r8,r10
ADD r8,1
MOV [r9],r8
MOVBS r10, r10
CMP r10,0
JNE L_11
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOV r9, -2
ADD r9, rl
MOV r9,[r9]
SUB r10,r9
MOVBS r10,r10
MOV r0,r10
L_10:
MOV sp, rl
POP rl
POP r10
POP r9
POP r8
RET
; global strcmp
strcmp: ; ncalls=0
PUSH r7
PUSH r8
PUSH r9
PUSH r10
PUSH rl
MOV rl, sp
; P_s1 EQU 12
; P_s2 EQU 14
SUB sp, 2
L_15:
L_16:
MOV r10, 12
ADD r10, rl
MOV r10,[r10]
MOV r9, 12
ADD r9, rl
MOV r8,r10
ADD r8,1
MOV [r9],r8
MOV r9, 14
ADD r9, rl
MOV r9,[r9]
MOV r8, 14
ADD r8, rl
MOV r7,r9
ADD r7,1
MOV [r8],r7
MOVBS r10, r10
MOVBS r9, r9
CMP r10,r9
JNE L_19
MOV r10,1
MOV [rl + -2],r10
JMP L_20
L_19:
MOV r10,0
MOV [rl + -2],r10
L_20:
MOV r10, [rl + -2]
CMP r10,0
JNE L_15
MOV r10, 14
ADD r10, rl
MOV r10,[r10]
MOVBS r10, r10
MOV r9, 12
ADD r9, rl
MOV r9,[r9]
MOVBS r9, r9
MOV r0,r10
SUB r0,r9
L_14:
MOV sp, rl
POP rl
POP r10
POP r9
POP r8
POP r7
RET
; global strcpy
strcpy: ; ncalls=0
PUSH r7
PUSH r8
PUSH r9
PUSH r10
PUSH rl
MOV rl, sp
; P_s1 EQU 12
; P_s2 EQU 14
SUB sp, 2
MOV r10, -2
ADD r10, rl
MOV r9, 12
ADD r9, rl
MOV r9,[r9]
MOV [r10],r9
L_22:
L_23:
MOV r10, 12
ADD r10, rl
MOV r10,[r10]
MOV r9, 12
ADD r9, rl
MOV r8,r10
ADD r8,1
MOV [r9],r8
MOV r9, 14
ADD r9, rl
MOV r9,[r9]
MOV r8, 14
ADD r8, rl
MOV r7,r9
ADD r7,1
MOV [r8],r7
MOV r9,[r9]
MOVB [r10],r9
MOVBS r10,r9
CMP r10,0
JNE L_22
MOV r10, -2
ADD r10, rl
MOV r0,[r10]
L_21:
MOV sp, rl
POP rl
POP r10
POP r9
POP r8
POP r7
RET
; global strcat
strcat: ; ncalls=1
PUSH r8
PUSH r9
PUSH r10
PUSH rl
MOV rl, sp
; P_s1 EQU 10
; P_s2 EQU 12
SUB sp, 2
MOV r10, -2
ADD r10, rl
MOV r9, 10
ADD r9, rl
MOV r9,[r9]
MOV [r10],r9
L_26:
L_27:
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOV r9, 10
ADD r9, rl
MOV r8,r10
ADD r8,1
MOV [r9],r8
MOVBS r10, r10
CMP r10,0
JNE L_26
MOV r10, 12
ADD r10, rl
MOV r10,[r10]
PUSH r10
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
ADD r10,-1
PUSH r10
CALL strcpy
ADD sp,4
MOV r10, -2
ADD r10, rl
MOV r0,[r10]
L_25:
MOV sp, rl
POP rl
POP r10
POP r9
POP r8
RET
; global printf
printf: ; ncalls=6
PUSH r9
PUSH r10
PUSH rl
MOV rl, sp
; P_fmt EQU 8
; P_i EQU 10
SUB sp, 6
MOV r10,0
MOV [rl + -2],r10
MOV r10, -4
ADD r10, rl
MOV r9, 8
ADD r9, rl
MOV [r10],r9
JMP L_33
L_30:
MOV r10, 8
ADD r10, rl
MOV r10,[r10]
MOVBS r10, r10
MOV r9,37
CMP r10,r9
JEQ L_34
MOV r10, 8
ADD r10, rl
MOV r10,[r10]
MOVBS r10, r10
PUSH r10
CALL printch
ADD sp,2
MOV r9, [rl + -2]
ADD r9,r0
MOV [rl + -2],r9
JMP L_35
L_34:
MOV r10, 8
ADD r10, rl
MOV r10,[r10]
MOVBS r10, r10
MOV [rl + -6],r10
MOV r10, [rl + -6]
MOV r9,99
CMP r10,r9
JEQ L_40
MOV r9,100
CMP r10,r9
JEQ L_39
CMP r10,r9
JGT L_45
L_44:
MOV r10, [rl + -6]
MOV r9,37
CMP r10,r9
JEQ L_42
JMP L_36
L_45:
MOV r10, [rl + -6]
MOV r9,115
CMP r10,r9
JEQ L_41
JMP L_36
L_39:
MOV r10, -4
ADD r10, rl
MOV r10,[r10]
ADD r10,2
MOV r9, -4
ADD r9, rl
MOV [r9],r10
MOV r10,[r10]
PUSH r10
CALL printi
ADD sp,2
MOV r9, [rl + -2]
ADD r9,r0
MOV [rl + -2],r9
MOV r10, 8
ADD r10, rl
MOV r9, 8
ADD r9, rl
MOV r9,[r9]
ADD r9,1
MOV [r10],r9
JMP L_37
L_40:
MOV r10, -4
ADD r10, rl
MOV r10,[r10]
ADD r10,2
MOV r9, -4
ADD r9, rl
MOV [r9],r10
MOV r10,[r10]
MOVBS r10,r10
PUSH r10
CALL printch
ADD sp,2
MOV r9, [rl + -2]
ADD r9,r0
MOV [rl + -2],r9
MOV r10, 8
ADD r10, rl
MOV r9, 8
ADD r9, rl
MOV r9,[r9]
ADD r9,1
MOV [r10],r9
JMP L_37
L_41:
MOV r10, -4
ADD r10, rl
MOV r10,[r10]
ADD r10,2
MOV r9, -4
ADD r9, rl
MOV [r9],r10
MOV r10,[r10]
PUSH r10
CALL prints
ADD sp,2
MOV r9, [rl + -2]
ADD r9,r0
MOV [rl + -2],r9
MOV r10, 8
ADD r10, rl
MOV r9, 8
ADD r9, rl
MOV r9,[r9]
ADD r9,1
MOV [r10],r9
JMP L_37
L_42:
MOV r10,37
PUSH r10
CALL printch
ADD sp,2
MOV r9, [rl + -2]
ADD r9,r0
MOV [rl + -2],r9
MOV r10, 8
ADD r10, rl
MOV r9, 8
ADD r9, rl
MOV r9,[r9]
ADD r9,1
MOV [r10],r9
JMP L_37
L_36:
MOV r10, 8
ADD r10, rl
MOV r10,[r10]
MOVBS r10, r10
PUSH r10
MOV r10,L_43
PUSH r10
CALL printf
ADD sp,4
L_37:
L_35:
L_31:
MOV r10, 8
ADD r10, rl
MOV r9, 8
ADD r9, rl
MOV r9,[r9]
ADD r9,1
MOV [r10],r9
L_33:
MOV r10, 8
ADD r10, rl
MOV r10,[r10]
MOVBS r10, r10
CMP r10,0
JNE L_30
MOV r0, [rl + -2]
L_29:
MOV sp, rl
POP rl
POP r10
POP r9
RET
; global scanf
scanf: ; ncalls=4
PUSH r8
PUSH r9
PUSH r10
PUSH rl
MOV rl, sp
; P_fmt EQU 10
SUB sp, 6
MOV r10,0
MOV [rl + -2],r10
MOV r10, -4
ADD r10, rl
MOV r9, 10
ADD r9, rl
MOV [r10],r9
JMP L_50
L_47:
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOVBS r10, r10
MOV r9,37
CMP r10,r9
JNE L_51
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOVBS r10, r10 + 1
MOV [rl + -6],r10
MOV r10, [rl + -6]
MOV r9,99
CMP r10,r9
JEQ L_57
MOV r8,100
CMP r10,r8
JEQ L_56
CMP r10,r9
JLT L_53
L_59:
MOV r10, [rl + -6]
MOV r9,115
CMP r10,r9
JEQ L_58
JMP L_53
L_56:
MOV r10, -4
ADD r10, rl
MOV r10,[r10]
ADD r10,2
MOV r9, -4
ADD r9, rl
MOV [r9],r10
CALL readi
MOV r8,[r10]
ADD r8,r0
MOV [r10],r8
MOV r10, 10
ADD r10, rl
MOV r9, 10
ADD r9, rl
MOV r9,[r9]
ADD r9,1
MOV [r10],r9
MOV r10, [rl + -2]
ADD r10,1
MOV [rl + -2],r10
JMP L_54
L_57:
MOV r10, -4
ADD r10, rl
MOV r10,[r10]
ADD r10,2
MOV r9, -4
ADD r9, rl
MOV [r9],r10
CALL readch
MOV r8,[r10]
MOV r9,r0
MOVBS r9,r9
ADD r8,r9
MOV [r10],r8
MOV r10, 10
ADD r10, rl
MOV r9, 10
ADD r9, rl
MOV r9,[r9]
ADD r9,1
MOV [r10],r9
MOV r10, [rl + -2]
ADD r10,1
MOV [rl + -2],r10
JMP L_54
L_58:
MOV r10, -4
ADD r10, rl
MOV r10,[r10]
ADD r10,2
MOV r9, -4
ADD r9, rl
MOV [r9],r10
MOV r10,[r10]
PUSH r10
CALL reads
ADD sp,2
MOV r10, 10
ADD r10, rl
MOV r9, 10
ADD r9, rl
MOV r9,[r9]
ADD r9,1
MOV [r10],r9
MOV r10, [rl + -2]
ADD r10,1
MOV [rl + -2],r10
JMP L_54
L_53:
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOVBS r10, r10
PUSH r10
MOV r10,L_43
PUSH r10
CALL printf
ADD sp,4
L_54:
L_51:
L_48:
MOV r10, 10
ADD r10, rl
MOV r9, 10
ADD r9, rl
MOV r9,[r9]
ADD r9,1
MOV [r10],r9
L_50:
MOV r10, 10
ADD r10, rl
MOV r10,[r10]
MOVBS r10, r10
CMP r10,0
JNE L_47
MOV r0, [rl + -2]
L_46:
MOV sp, rl
POP rl
POP r10
POP r9
POP r8
RET
; extern readch
; extern reads
; extern readi
; extern prints
; extern printch
; extern printi
; RODATA
L_43:
STRING "", 39, "%%%c", 39, " not supported.", 10, 0
