int main(int argc, char *argv[]){
  int i, j = atoi(argv[1]); 
  while (j--) {
   for (i = 0; i < 30000; i++)
      if (i %2 == 0) argc++; else argc--;
    printi(j);
    printLN();
  }
  return 0;
}
