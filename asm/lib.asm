; entry point
start:
CALL main
SWE 240

; extern exit
exit:
MOV r0, [sp + 2]
SWE 240 ; exit
RET

; extern printi
printi:
MOV r0, [sp + 2]
SWE 244 ; printINT
RET

; extern printch
printch:
MOV r0, [sp + 2]
SWE 245 ; printBYTE
RET

; extern prints
prints:
MOV r0, [sp + 2]
SWE 246 ; printINT
RET

; extern printLN
printLN:
SWE 247
RET

; extern printHEX
printHEX:
SWE 248
RET

; extern readi
readi:
SWE 241
RET

; extern readch
readch:
SWE 242
RET

; extern reads
reads:
MOV r0, [sp + 2]
SWE 243 ; printINT
RET

