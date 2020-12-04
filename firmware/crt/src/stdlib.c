#include <stdlib.h>

int buf1[12];
int buf2[12];

int strcmp(const int* s1, const int* s2) {
  int i;

  for (i = 0; s1[i] != '\0' && s2[i] != '\0' && s1[i] == s2[i]; i++) ;

  if (s1[i] > s2[i]) return 1;
  else if (s1[i] == s2[i]) return 0;
  else return -1;
}

int atoi(const int* nptr) {
  int x = 0;
  while (*nptr == ' ') { nptr ++; }
  while (*nptr >= '0' && *nptr <= '9') {
    x = x * 10 + *nptr - '0';
    nptr ++;
  }
  return x;
}

/*
int* itoa(int num) {
  int len1 = 0, len2 = 0;
  if (num < 0) {
    buf1[len1 ++] = '-';
    num = - num;
  }

  if (num == 0) {
    buf1[len1 ++] = '0';
  }

  while (num > 0) {
    buf2[len2 ++] = num % 10;
    num = num / 10; 
  }

  while (len2) {
    len2 --;
    buf1[len1 ++] = buf2[len2];
  }

  buf1[len1] = '\0';
  return buf1;
}
*/