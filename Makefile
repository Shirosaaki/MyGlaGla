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
