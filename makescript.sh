

antlr -gt practica.g
dlg -ci parser.dlg scan.c
g++ -o practica practica.c scan.c err.c -I/usr/include/pccts/ -Wno-write-strings -std=c++11
