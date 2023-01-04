default:
	clang -O2 -g -Wall -Wextra -Werror -fsanitize=address,undefined -std=c11 \
		main.c ../lib/libSparkmemory.a

format:
	clang-format -i main.c
