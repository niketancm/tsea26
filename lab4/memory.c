#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <ctype.h>

#include "sim.h"

/* ----------------------------------------------------------------------
 * Memory arrays
 * ---------------------------------------------------------------------- */

static uint32_t pm[65536];
static uint64_t pm_prof[65536]; // Stores profiling information

static uint16_t mem0[65536];
static uint16_t mem1[65536];

static uint8_t pm_usage[65536];
static uint8_t mem0_usage[65536];
static uint8_t mem1_usage[65536];

/* ----------------------------------------------------------------------
 * Utility functions for reading and writing to/from memory 
 * ---------------------------------------------------------------------- */

static void pm_store(unsigned int addr,unsigned int val)
{
	if(addr >= 65536) {
		sim_failure("Writing to PM above 65536");
	}
	pm_usage[addr] = 1;
	pm[addr] = val;
}

void mem0_store(unsigned int addr,unsigned int val)
{
	if(addr >= 65536) {
		sim_failure("Writing to mem0 above 65536");
	}
	mem0_usage[addr] = 1;
	mem0[addr] = val;
}

void mem1_store(unsigned int addr,unsigned int val)
{
	if(addr >= 65536) {
		sim_failure("Writing to mem1 above 65536");
	}
	mem1_usage[addr] = 1;
	mem1[addr] = val;
}


/* Functions for reading out memory */
uint32_t pm_read(unsigned int addr)
{
	if(addr >= 65536) {
		sim_failure("Trying to read above 65536 in pm");
	}
	
	if(!pm_usage[addr]) {
		sim_warning("Trying to read uninitialized address %d in PM",addr);
	}

	return pm[addr];
}

// Used to profile the usage of various parts of the program memory
void pm_profile(unsigned int addr,int times)
{
	if(addr >= 65536){
		sim_failure("PM address above 65536");
	}
	pm_prof[addr]+=times;
}



uint32_t mem0_read(unsigned int addr)
{
	if(addr >= 65536) {
		sim_failure("Trying to read above 65536 in mem0");
	}
	
	if(!mem0_usage[addr]) {
		sim_warning("Trying to read uninitialized address %d in MEM0",addr);
	}

	return mem0[addr] & 0xffff;
}

uint32_t mem1_read(unsigned int addr)
{
	if(addr >= 65536) {
		sim_failure("Trying to read above 65536 in mem1");
	}
	
	if(!mem1_usage[addr]) {
		sim_warning("Trying to read uninitialized address %d in MEM1",addr);
	}

	return mem1[addr] & 0xffff;
}


/* Load a hex file from the senior assembler into the simulators memory  */
int load_hex(char *filename)
{
	FILE *fp;
	
	char line[256];
	unsigned addr;
	void (*store_hex)(unsigned int  , unsigned int);
	int line_no;

	
	fp = fopen(filename,"r");
	if(!fp){
		sim_failure("Could not load '%s': %s", filename, strerror(errno));
	}


	addr = 0;
	line_no = 0;

	store_hex = 0;

	while((fgets(line, sizeof(line), fp))) {
		line_no++;
		if (line[0] == ';') {
			// Ignore a comment
		} else if(!strncmp(line, "code", 4)) {
			addr = 0;
			store_hex = pm_store;
		} else if(!strncmp(line, "rom0", 4)) {
			addr = 0;
			store_hex = mem0_store;
		} else if(!strncmp(line, "rom1", 4)) {
			addr = 0;
			store_hex = mem1_store;
		} else if(!strncmp(line, "org ", 4)) {
			addr = strtoul(line+4, 0, 0);
		} else if(store_hex) {
			char *endptr;
			unsigned hex = strtoul(line, &endptr, 16);
			(*store_hex)(addr, hex);

			addr++;

		} else {
			sim_failure("Error reading hex file");
		}
	}

	fclose(fp);
	return 0;
}



void dump_profile(void)
{
	FILE *fp;
	unsigned int i;
	fp = fopen("profile.txt","w");
	if(!fp){
		sim_warning("Could not open profile.txt: %s",strerror(errno));
		return;
	}

	for(i=0; i < 65536; i++){
		fprintf(fp,"%lld\n", pm_prof[i]);
	}

	fclose(fp);
}
