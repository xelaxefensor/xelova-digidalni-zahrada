#include <stdio.h>
int main() {
int x;

scanf("%d", &x);

printf("%8x\n", *((int*)&x));
return 0;
}