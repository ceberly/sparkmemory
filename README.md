# sparkmemory
Some example memory allocators in Ada / SPARK.

The only allocator here right now is built to Ginger Bill's blog post https://www.gingerbill.org/article/2019/02/08/memory-allocation-strategies-002/ 

You should read the whole series.

~~All except one proof (unfortunately the main one) work at SPARK level 0. The main proof only works at level 2 right now so could use some revisiting.~~ All proofs work at --level=0 now, thanks to @yannickmoy. 

The idea behind the main proof is that the allocator never hands out a pointer to a region that is already accounted for (https://github.com/ceberly/sparkmemory/blob/main/src/sparkmemory.adb#L54)

You can reach me on twitter (@chriseberly) or mastodon (@chris@discuss.systems). Feedback and general Ada/SPARK expertise is more than welcome!

To build:
1) get Alire https://alire.ada.dev
2) in the root of the project: `alr build --release` (release is necessary (I think) to avoid having to link against any of the Ada language libs).
3) build example/Makefile to see a C code example. It should look something like this: <img width="607" alt="image" src="https://user-images.githubusercontent.com/99014/210695969-263ff67a-399d-4aee-b8ca-086d5a6959be.png">

