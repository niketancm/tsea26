#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdarg.h>

#include "sim.h"

void sim_internal_fail(void)
{
	fprintf(stderr,"Internal error in simulator, aborting\n");

	/* This function should not be called, but if it is called,
	 * the abort function will leave the user a core dump so that
	 * the developer can figure out what happened */
	abort();
}

void sim_failure(const char *str,...)
{
	va_list argp;
	printf("Simulator error: ");
	va_start(argp,str);
	vprintf(str,argp);
	va_end(argp);
	printf("\n");
	exit(255);
}

void sim_warning(const char *str, ...)
{
	va_list argp;
	printf("Simulator warning: ");
	va_start(argp,str);
	vprintf(str,argp);
	va_end(argp);
	printf("\n");

	sim_print_regs();

	sim_stop();
}
