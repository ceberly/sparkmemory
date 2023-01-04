# sparkmemory
Some example memory allocators in Ada / SPARK.

The only allocator here right now is built to Ginger Bill's blog post https://www.gingerbill.org/article/2019/02/08/memory-allocation-strategies-002/ 

You should read the whole series.

To build:
1) get Alire https://alire.ada.dev
2) in the root of the project: `alr build --release` (release is necessary (I think) to avoid having to link against any of the Ada language libs).
3) build example/Makefile to see a C code example...
