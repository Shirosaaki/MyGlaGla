# ==============================================
#                 Makefile
#  makefile
#  Author: shirosaaki
#  Date: 2025-11-18
# =============================================

NAME	=	glados

all: 
	stack build --copy-bins --local-bin-path .
	stack install

clean:
	stack clean
	rm -rf app/Main

fclean: clean
	rm -rf $(NAME)

re: fclean all

run_test:
	stack test

test_coverage:
	stack test --coverage
# VM targets
generate_test_bytecode:
	stack runghc tools/generate_test_bytecode.hs

test_vm: generate_test_bytecode
	@echo "Testing VM with bytecode files..."
	@echo "==================================="
	@echo -n "test_add.o (2 + 3): "
	@stack exec glados-exe test_add.o
	@echo -n "test_mul.o (4 * 5): "
	@stack exec glados-exe test_mul.o
	@echo -n "test_lt.o (3 < 5): "
	@stack exec glados-exe test_lt.o
	@echo -n "test_complex.o ((2 + 3) * 4): "
	@stack exec glados-exe test_complex.o

disasm:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make disasm FILE=yourfile.o"; \
	else \
		stack exec glados-exe -- -d $(FILE); \
	fi

clean_bytecode:
	rm -f test_*.o

.PHONY: generate_test_bytecode test_vm disasm clean_bytecode