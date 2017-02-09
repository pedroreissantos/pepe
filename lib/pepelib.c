#include <stdio.h>
void exit(const int code); /* use the system call */
int readi(void) {
  char buf[80]; 
  fgets(buf, 80, stdin);
  return atoi(buf);
}
char readch(void) { char ch; scanf("%c%*[^\n]\n", &ch);  return ch; } 
int reads(char *ptr) { return scanf("%[^\n]\n", ptr); }
int printi(int i) { return printf("%d", i); }
int printch(char ch) { return printf("%c", ch); } 
int prints(char *str) { return printf("%s", str); } 
int printLN(void) { return printf("\n"); } 
int printi(int i) { return printf("%hx", (short)i); }
