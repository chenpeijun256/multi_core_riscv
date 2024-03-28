#include <stdint.h>

int add(int a, int b) {
    a = a + 2;
    return a + b;
}

int main()
{
    int a = 3;
    int b = 5;
    int c = add(a, b);
    return 0;
}
