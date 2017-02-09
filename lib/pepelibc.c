int printi(const int i);
int printch(const char ch);
int prints(const char *);
int readi(void);
int reads(char *buf);
char readch(void);

int atoi(char *val)
{
  register int i = 1, x = 0;

  if (*val == '-') { val++; i = -1; }

  while (*val != 0)
    if (*val < '0' || *val > '9')
      return 0;
    else
      x = x * 10 + *val++ - '0';
  
  return x * i;
}

int strlen(char *str)
{
	char *dst = str;
	while (*str++ != 0) ;
	return str - dst;
}

int strcmp(const char *s1, const char *s2)
{
	while ((*s1++ == *s2++) != 0) ;
	return *s2 - *s1;
}

char *strcpy(char *s1, const char *s2)
{
	char *dst = s1;
	while ((*s1++ = *s2++) != 0) ;
	return dst;
}

char *strcat(char *s1, const char *s2)
{
	char *dst = s1;
	while (*s1++ != 0) ;
	strcpy(s1 - 1, s2);
	return dst;
}

int printf(const char *fmt, int i)
{
	int *args, nch = 0;

	for (args = (int*)&fmt; *fmt != 0; fmt++)
		if (*fmt != '%')
			nch += printch(*fmt);
		else
			switch (*fmt) {
				case 'd':
					nch += printi(*++args);
					fmt++;
					break;
				case 'c':
					nch += printch(*++args);
					fmt++;
					break;
				case 's':
					nch += prints((char*)*++args);
					fmt++;
					break;
				case '%':
					nch += printch('%');
					fmt++;
					break;
				default:
					printf("'%%%c' not supported.\n", *fmt);
					break;
			}
	return nch;
}

int scanf(const char *fmt)
{
	int *args, nch = 0;

	for (args = (int*)&fmt; *fmt != 0; fmt++)
		if (*fmt == '%')
			switch (fmt[1]) {
				case 'd':
					*++args += readi();
					fmt++;
					nch++;
					break;
				case 'c':
					*++args += readch();
					fmt++;
					nch++;
					break;
				case 's':
					reads((char*)*++args);
					fmt++;
					nch++;
					break;
				default:
					printf("'%%%c' not supported.\n", *fmt);
					break;
			}
	return nch;
}
