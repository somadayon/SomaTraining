NAME = CG
TRANS_NAME = trans
ADDVN_NAME = add_vn

all: build_trans run_trans run_addvn build_cg run_cg clean

build_trans:
	cc $(TRANS_NAME).c -o $(TRANS_NAME) -lGL -lGLU -lglut -lm

run_trans:
	./$(TRANS_NAME)

run_addvn:
	ruby $(ADDVN_NAME).rb

build_cg:
	cc $(NAME).c -o $(NAME) -lGL -lGLU -lglut -lm

run_cg:
	./$(NAME)

clean:
	rm -f $(NAME) $(TRANS_NAME) $(ADDVN_NAME)
