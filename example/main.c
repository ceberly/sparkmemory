#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

// XXX: this could be extern and hidden but it is making
// the Ada <-> C loop *so* much easier to have it defined.
// Revisit.
struct Arena {
  void *buf;
  size_t *buf_length;
  uintptr_t curr_offset;
};

extern void arena_init(struct Arena *, void *, size_t size);
extern void *arena_alloc(struct Arena *, size_t size, size_t align);

int main(void) {
  void *store = malloc(1024);

  struct Arena a;
  arena_init(&a, store, 1024);

  arena_alloc(&a, 100, 2);

  free(store);

  return EXIT_SUCCESS;
}
