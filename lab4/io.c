#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "sim.h"

/* Handle out instructions */
void io_out(uint16_t port, uint16_t val)
{
	static FILE *hexfile;

	switch(port) {
	case 0x11:
		if(!hexfile){
			hexfile = fopen("results.hex","w");
			if(!hexfile) {
				sim_failure("Could not open results.hex");
			}
		}
		fprintf(hexfile,"%04x\n",val);
		break;
		
	case 0x13:
		printf("Stopping simulation due to write to port 0x13\n");
		sim_stop();
		break;
	default:
		sim_warning("Writing to unknown I/O port");
		break;
	}
}
