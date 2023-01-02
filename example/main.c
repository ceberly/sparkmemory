#include <stdio.h>
#include <stdlib.h>

typedef struct Arena *Arena;

extern void arena_init(Arena, void *, size_t size);
extern void arena_alloc(Arena, void *, size_t size, size_t align);

int main(void) {
  void *store = malloc(1024);

  Arena a = NULL;

  arena_init(a, store, 1024);

  int p = 32;
  arena_alloc(a, &p, sizeof(int), sizeof(int));

  p = 32;

  fprintf(stderr, "%d\n", p);

  return EXIT_SUCCESS;
}
