# ==============================================
#                 Makefile
#  makefile
#  Author: shirosaaki
#  Date: 2025-11-18
# =============================================

NAME	=	glados

all: 
	stack build
	stack install
	cp -rf $(shell stack path --local-bin)/$(NAME)-exe ./$(NAME)

clean:
	stack clean
	rm -rf app/Main

fclean: clean
	rm -rf $(NAME)

re: fclean all

run_test:
	stack test
