add r1, r2
add r1, -8
add r1, 7
addc r1, r2
sub r3, r4
sub r3, -8
sub r3, 7
subb r3, r4
cmp r2, r4
cmp r4, -8
cmp r4, 7
mul r3, r1
div r1, r3
mod r3, r2
neg r3
and r2, r3
or r2, r3
not r3
xor r3, r4
test r4, r1
bit r2, 3
set r2, 1
clr r2, 1
cpl r2, 3
shr r2, 3
shl r2, 2
shra r2, 3
shla r2, 2
ror r2, 8
rol r2, 1
rorc r2, 5
rolc r2, 4
mov r1, [r2 + -16]
mov r1, [r2]
mov r1, [r2 + 15]
mov r1, [r2 + r4]
mov [r2 + -16], r3
mov [r2], r3
mov [r2 + 15], r3
mov [r2 + r4], r3
movb r5, [r2]
movb [r2], r1
mov r5, 30000
mov r4, a1
mov a1, r3
mov r3, USP
mov USP, r3
swap r1, r4
swap r3, [r2]
swap [r2], r4
push r2
pop r2
pushc
popc
jz start
jnz start
jn start
jnn start
jp start
jnp start
jc start
jnc start
jv start
jnv start
ja start
jae start
jb start
jbe start
jeq start
jne start
jlt start
jle start
jgt start
jge start
jmp start
jmp r2
nop
swe 241
call start
call r2
callf start
callf r2
ret
retf
rfe
jlt start
