/* basic functions of libc (printf and scanf have very limited options) */
int printf(const char *, ...);
int atoi(const char *);
int strcmp(const char *, const char *);
char *strcpy(char *, const char *);
char *strcat(char *, const char *);
int scanf(const char *, ...);

/* lib.asm (base functions provided by lib.asm)
 *         [a 'start' function that calls a 'main' function and then
 *          calls 'exit' is also provided.] */

/* exit: terminate the program with the given 'code' */
void exit(const int code);

/* printi:
 * print a decimanl integer and returns the number of characters written */
int printi(const int i);

/* printch: print a character and returns the number of characters written */
int printch(const char ch);

/* prints: print a string and returns the number of characters written */
int prints(const char *);

/* printLN: print a new-line and returns the number of characters written */
int printLN(void);

/* printHEX: * print an unsigned hexadecimanl integer
 * and returns the number of characters written */
int printHEX(const int i);

/* readi: reads and returns a decimal integer */
int readi(void);

/* reads: reads to 'buf' and returns the number of read chars
 *        (assumes that 'buf' is large enough to hold the data) */
int reads(char *buf);

/* readch: reads and returns a character */
char readch(void);
