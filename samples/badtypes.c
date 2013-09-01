#include <stdio.h>

struct words {
  int age;
  int br;
};

int main() {
  struct words w = {.age=4};
  printf("%s", w + "hello world!" + 44 + '!');
}

voidc() {
  return a;
}