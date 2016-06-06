This is a flex lexer implementaiton for the cool language.

Only file of interest here is cool.flex, or perhaps the makefile if you're interested in building on OSX.

Note the key here was the Stanford course doesn't use the c++ version of flex output, they need the -lfl (or on osx -ll) option to disable some default function that allows you to pass multiple input files in.
