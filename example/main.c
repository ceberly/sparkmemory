#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// XXX: this could be extern and hidden but it is making
// the Ada <-> C loop *so* much easier to have it defined.
// Revisit.
struct Arena {
  void *buf;
  size_t *buf_length;
  uintptr_t curr_offset;
};

extern void arena_free_all(struct Arena *);
extern void arena_init(struct Arena *, void *, size_t size);
extern void *arena_alloc(struct Arena *, size_t size, size_t align);

int main(void) {
  // https://www.gingerbill.org/code/memory-allocation-strategies/part002.c
  int i;

  unsigned char backing_buffer[256];
  struct Arena a = {0};

  arena_init(&a, backing_buffer, 256);

  for (i = 0; i < 10; i++) {
    int *x;
    float *f;
    char *str;

    // Reset all arena offsets for each loop
    arena_free_all(&a);

    x = (int *)arena_alloc(&a, sizeof(int), sizeof(int));
    f = (float *)arena_alloc(&a, sizeof(float), sizeof(float));
    str = arena_alloc(&a, 10, 2);

    *x = 123;
    *f = 987;
    memmove(str, "Hellope", 7);

    printf("%p: %d\n", x, *x);
    printf("%p: %f\n", f, *f);
    printf("%p: %s\n", str, str);

//    str = arena_resize(&a, str, 10, 16);
//    memmove(str + 7, " world!", 7);
//    printf("%p: %s\n", str, str);
  }

  arena_free_all(&a);
}
