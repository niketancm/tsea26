OBJS = memory.o sim.o support.o io.o

CCOPTS= -g -Wall  -O2
CC=gcc
LD=gcc

all: sim


sim: sim.h $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o sim


.c.o:
	$(CC) $(CCOPTS) -c $?

clean:
	rm -f sim *~ *.o sad.hex results.hex profile.txt


test: sim
	srasm sad.asm
	./sim sad.hex



prof_report:
	sed -n '/code/,/rom0/p' < sad.hex |grep ' '|awk '{print $$3 ":" $$2 " "}'> prof_tmp.txt
	paste prof_tmp.txt profile.txt | grep :
