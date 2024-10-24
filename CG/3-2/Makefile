NAME = CG
TRANS_NAME = trans

all: run_trans build_cg run_cg clean

run_trans:
	ruby $(TRANS_NAME).rb

build_cg:
	cc $(NAME).c -o $(NAME) -lGL -lGLU -lglut -lm

run_cg:
	./$(NAME)

clean:
	rm -f $(NAME)
