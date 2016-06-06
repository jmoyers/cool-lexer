flex:
	flex -d cool.flex
	clang++ -Wall -I. -Iinclude -stdlib=libc++ -c lextest.cc \
		-Wno-c++11-compat-deprecated-writable-strings
	clang++ -Wall -I. -Iinclude -stdlib=libc++ -c utilities.cc \
		-Wno-c++11-compat-deprecated-writable-strings
	clang++ -Wall -I. -Iinclude -stdlib=libc++ -c stringtab.cc \
		-Wno-c++11-compat-deprecated-writable-strings
	clang++ -Wall -I. -Iinclude -stdlib=libc++ -c handle_flags.cc \
		-Wno-c++11-compat-deprecated-writable-strings
	clang++ -Wall -I. -Iinclude -stdlib=libc++ -c lex.yy.c \
		-Wno-c++11-compat-deprecated-writable-strings
	clang++ -Wall -Iinclude -stdlib=libc++ -ll -o flex_lexer \
		lextest.o \
		utilities.o \
		stringtab.o \
		handle_flags.o \
		lex.yy.o
#	clang++ -Wall -I. -Iinclude -stdlib=libc++ -lfl \
#		-Wno-c++11-compat-deprecated-writable-strings \
#		lex.yy.cc \
#		lextest.cc \
#		utilities.cc \
#		stringtab.cc \
#		handle_flags.cc

test:
	./flex_lexer test.cl
