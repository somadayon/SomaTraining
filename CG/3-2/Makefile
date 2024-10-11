NAME = CG
TRANS_NAME = trans

all: build_trans run_trans build_cg run_cg

build_trans:
	cc $(TRANS_NAME).c -o $(TRANS_NAME) -lGL -lGLU -lglut

run_trans:
	./$(TRANS_NAME)

build_cg:
	cc $(NAME).c -o $(NAME) -lGL -lGLU -lglut

run_cg:
	./$(NAME)

clean:
	rm -f $(NAME) $(TRANS_NAME)
