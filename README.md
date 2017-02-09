PEPE


  This is an emulator for the PEPE processor with debugging capabilities.
  The emulator reads a list of PEPE assembler files and executes them.

  To run use: pepe program.asm pepelib.asm -- arguments
  for example: pepe fibonacci.asm pepelib.asm -- 12

  In interactive mode use:
    include filename.asm
    eof
   or type pepe instructions followed by EOF:
    MOV r1, 12
    MOV r2, 45
    ADD r1, r2
    EOF
   Then use the debugger.

(C)Pedro Reis dos Santos, 2012 (IST, ULisboa)