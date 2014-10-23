 /*
 * This file contains a simulator for a very simplified version of
 * the Senior DSP processor. Only the instructions necessary for
 * lab 4 are included and some simplifications have been made.
 *
 * TODO: Doesn't check/update access time for address registers and
 *       some other registers
 *       Could use a few more comments...
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "sim.h"

/* ----------------------------------------------------------------------
 * Global variables for various registers
 * ---------------------------------------------------------------------- */

static uint16_t rf[32];      /* Register file */
static int rf_busy[32];      /* Keep track of when the register file will be updated */
static uint16_t ar[4];       /* Address registers */

static uint16_t loopcnt;     /* Loop related registers */
static uint16_t loopend;     
static uint16_t loopstart;

static uint16_t stackptr;    /* Stack pointer */

static uint16_t pc;          /* Program counter */
static int      delayslot;   /* True if we are in a delay slot */
static int      skip_cycles; /* Number of cycles to skip when jumping */
static int      dojump;      /* True if we should jump immediately */
static uint16_t jump_pc;     /* Jump address */

static int repeat_sad;               /* If we are in the special repeat_sad instruction or not */
static uint16_t sad_best_yet;        /* Used for the best SAD match yet (sr30) */
static uint16_t sad_accumulator;     /* Used for accelerated instruction (sr31) */
static int repeat_sad_stop_counter;  /* When this counter reaches 0, the repeat_sad loop can stop */

// Ignoring V flag for now
static int flag_n;           
static int flag_z;
static int flag_c;

/* Global cycle counter */
static unsigned long long cycle;

static int stop;
/* ----------------------------------------------------------------------
 * Utility functions
 * ---------------------------------------------------------------------- */

void sim_stop(void)
{
	stop = 1;
}

void sim_print_regs(void)
{
	int i;
	printf("PC: %04x\n",pc);
	printf("stackptr: %04x\n",stackptr);
	printf("Flags: N %d,  Z: %d, C: %d\n",flag_n,flag_z,flag_c);
	printf("Register file:");
	for(i=0; i < 32; i++){
		if((i % 8) == 0){ /* Print a newline for every 8 registers */
			printf("\n");
		}
		printf("%04x ",rf[i]);
	}
	printf("\nAddress registers:\n");
	printf("%04x %04x %04x %04x\n",ar[0],ar[1],ar[2],ar[3]);
}

static void advance_cycles(int num)
{
	int i;

	while(num > 0){
		/* Go through the rf_busy array and decrease all counters 
		 * The programmer may not access a register with a non-zero
		 * counter value */
		for (i = 0; i < 32; i++) {
			if(rf_busy[i] > 0) {
				rf_busy[i]--;
			}

		}

		/* This register is used in the repeat_sad loop */
		if(repeat_sad_stop_counter > 0){
			repeat_sad_stop_counter--;
		}
		
		num--;
		cycle++;
	}
}

/* Use this function to stop the repeat_sad instruction in num cycles */
static void repeat_sad_stop(int num)
{
	if(repeat_sad_stop_counter == 0) {
		/* We have already signalled a stop */
		return;
	}else if(repeat_sad_stop_counter < 0) {
		/* + 1 since advance_cycles() is decreasing this value before it will ever be used */
		repeat_sad_stop_counter = num + 1;
	}else if(num < repeat_sad_stop_counter) {
		repeat_sad_stop_counter = num + 1;
	}
}

/* Check if a register is accessed before the value has been written
 * 
 * This is used to simulate the effects a pipeline will have. The idea
 * is that the user is not allowed to write assembly code which will
 * access a register before the result is available. */

static void check_access(unsigned int regnum)
{
	if (regnum > 31) {
		sim_internal_fail();
	}

	if (rf_busy[regnum] > 0) {
		sim_warning("Trying to access register %d which is not ready yet",regnum);
	}
}

static void check_sr_access(unsigned int regnum)
{
	if (regnum > 31) {
		sim_internal_fail();
	}

}

/* Signextend <val>. val has <bits> significant bits */
static int sx(unsigned int val, int bits)
{
	int mask;
	if(val & (1 << (bits - 1))){
		mask = ~((1 << (bits - 1)) - 1);
		val = val | mask;
	}
	return val;
}

/* Update the flags based on a 32 bit result 
 * (V flag is not implemented yet) */

static void update_flags(uint32_t result)
{
	flag_n = 0;
	if(result & 0x8000) {
		flag_n = 1;
	}

	flag_z = 1;
	if(result & 0xffff) {
		flag_z = 0;
	}

	flag_c = 0;
	if(result & 0x10000) {
		flag_c = 1;
	}
}



/* ----------------------------------------------------------------------
 * Utility functions for register access
 * ---------------------------------------------------------------------- */

static int get_rega(uint32_t insn)
{
	return 	(insn & 0x0001f000) >> 12;
}

static int get_regb(uint32_t insn)
{
	return (insn & 0x00000f80) >> 7;
}

static int get_dreg(uint32_t insn)
{
	return (insn & 0x003e0000) >> 17; // Extract destination register
	
}

/* Return the value in register file register <regnum>
 * Also checking that we are allowed to access this register at this clock cycle */
static uint16_t get_reg(int regnum)
{
	check_access(regnum);
	return rf[regnum];
}

static uint16_t get_opa(uint32_t insn)
{
	int reg;
	reg = get_rega(insn);
	return get_reg(reg);
}

static uint16_t get_opb(uint32_t insn)
{
	if (insn & 0x00400000) {
		return  sx(insn & 0xfff,12);
	} else {
		int reg;
		reg = get_regb(insn);
		return get_reg(reg);
	}
}

static uint16_t get_opd(uint32_t insn)
{
	int reg;
	reg = get_dreg(insn);
	check_access(reg);

	return rf[reg];
}

static void set_reg(unsigned int regnum, uint16_t regval, int delay)
{
	if(regnum > 31){
		sim_internal_fail();
	}

	rf[regnum] = regval;
	rf_busy[regnum] = delay + 1; /* + 1 since advance_pc() is decreasing this value before it will ever be used */
}


static void sr_write(unsigned int reg,unsigned int val)
{
	switch(reg){
	case 0: ar[0] = val; break;
	case 1: ar[1] = val; break;
	case 2: ar[2] = val; break;
	case 3: ar[3] = val; break;
	case 30: 
		sad_best_yet = val;
		break;
	case 31:
		sad_accumulator = val;
		break;
	default:
		sim_warning("Unknown special register %d",reg);
		break;
	}
}

static uint16_t sr_read(unsigned int reg)
{
	check_sr_access(reg);
	switch(reg) {
	case 0: return ar[0];
	case 1: return ar[1];
	case 2: return ar[2];
	case 3: return ar[3];
	case 30: return sad_best_yet;
	case 31: return sad_accumulator;
	default: sim_warning("Trying to read unimplemented special register %d",reg);
		return 0;
	}
}


/* ----------------------------------------------------------------------
 * The following section contains code for all implemented instructions
 * ---------------------------------------------------------------------- */


/* Load instruction */
static void insn_load(uint32_t insn)
{
	uint16_t addr;
	uint16_t value;

	int addr_reg = (insn & 0x00006000) >> 13;
	

	switch(insn & 0x38000000) {
	case 0x00000000: addr = get_opb(insn); break; // Indirect
	case 0x08000000: addr = ar[addr_reg] + get_opb(insn); break; // Indexed
	case 0x10000000: addr = ar[addr_reg]++; break; // Post-increment
	case 0x18000000: addr = --ar[addr_reg]; break; // Pre-decrement
	case 0x20000000: addr = ar[addr_reg] + sx(insn & 0x1fff,13); break; // offset
	case 0x40000000: addr = insn & 0x0000ffff; break; // Absolute addressing
	default:
		sim_warning("Unknown addressing mode for load");
		return;
	}

	/* What memory should we access? */
	if (insn & 0x00010000) {
		value = mem1_read(addr);
	} else {
		value = mem0_read(addr);
	}

	/* Set destination register */
	set_reg(get_dreg(insn), value, 1);
}

/* Move Load Store group */
static void insn_moveloadstore(uint32_t insn)
{
	switch (insn & 0x07c00000) {
	case 0x00400000: // move srd, ra  (move to special purpose register)
		sr_write(get_dreg(insn), get_opa(insn));
		break;

	case 0x02000000: // set rd,#imm16
		set_reg(get_dreg(insn), insn & 0xffff, 1);
		break;

	case 0x02400000: // set srd, #imm16
		sr_write(get_dreg(insn), insn & 0xffff);
		break;

	case 0x04c00000: // out
		io_out(insn & 0xffff, get_opd(insn));
		break;

	case 0x04000000: // load
		insn_load(insn);
		break;

	default:
		sim_warning("Unimplemented move/load/store");
		break;
	}
}

/* Logic operation group */
static void insn_logic_op(uint32_t insn)
{
	uint32_t opa, opb;
	uint32_t result;

	opa = get_opa(insn);
	opb = get_opb(insn);

	switch (insn & 0x07800000) {
	case 0x00000000: result = opa & opb; break; // andn
	case 0x01000000: result = opa | opb; break; // orn
	case 0x02000000: result = opa ^ opb; break; // xorn
	default: sim_warning("Unimplemented logic instruction"); return;
	}

	if(insn & 0x00800000) {
		update_flags(result);
	}

	set_reg(get_dreg(insn),result,0);
}

/* Create absolute value of the two's complement number val */
static uint16_t abs16(uint16_t val)
{
	if(val == 0x8000){
		return 0x7fff;
	}
	if(val & 0x8000) {
		val = ~val;
		return val + 1;
	}
	return val;
}

/* Arithmetic operation group */
static void insn_arithmetic_op(uint32_t insn)
{
	// Doing the calculation in 32 bits simplifies the flag generation a lot
	uint32_t opa, opb;
	uint32_t result;

	opa = get_opa(insn);
	opb = get_opb(insn);
	
	switch (insn & 0x07800000) {
	case 0x00000000:  // addn
		result = opa + opb;
		break;
	case 0x01800000: // add
		result = opa + opb;
		update_flags(result);
		break;
	case 0x02000000: // subn
		result = opb - opa;
		break;
	case 0x03800000: // subn
		result = opb - opa;
		update_flags(result);
		break;
	case 0x05800000: // abs
		result = abs16(opa);
		update_flags(result);
		break;
	default:
		sim_warning("Unimplemented arithmetic instrution");
		break;
	}

	set_reg(get_dreg(insn),result,0);

}

/* Iterative operation group */
static void insn_iterative_op(uint32_t insn)
{
	repeat_sad = 0;

	switch (insn & 0x07c00000) {
	case 0x00800000: // repeat_sad
		repeat_sad = 1;
		repeat_sad_stop_counter = -1;
	case 0x00400000: // repeat
		loopstart = pc + 1;
		loopend   = pc + 1 + (insn & 0x7f);
		loopcnt   = (insn & 0x003ffc00) >> 10;
		break;
	default:
		sim_warning("Unimplemented iterative instruction");
	}
}

/* First 2 bits are 01. This is used by many different instruction groups.
 * This function decides what kind of group insn belongs to */

static void insn_type01(uint32_t insn)
{
	switch (insn & 0xf8000000) {
	case 0x40000000:  insn_arithmetic_op(insn); break;
	case 0x50000000:  insn_logic_op(insn);      break;
	case 0x68000000:  insn_iterative_op(insn);  break;
	default:
		sim_warning("Unimplemented type01");
	}
	
}

/* Check if the condition specified in <insn> is true. Return 1 if
 * true, 0 otherwise */
 
static int check_condition(uint32_t insn)
{
	switch(insn & 0x1f) {
	case 0: return 1; // Always true
	case 2: return flag_z; // EQ
	case 3: return !flag_z; // Not EQ
	case 4: return flag_c && !flag_z; // Unsigned greater than
	case 5: return flag_c; // Unsigned greater than or equal
	case 6: return !flag_c && flag_z; // Unsigned less than or equal
	case 7: return !flag_c; // Unsigned Less Than
	default: sim_warning("Unimplemented condition");
		return 0;
	}
		
}

/* Program Flow Control instruction group
 * The jump itself is handled by advance_pc(), this function
 * will only set the control flags for advance_pc()
 */
static void insn_pfc(uint32_t insn)
{
	int delayslots = (insn & 0x18000000) >> 27;
	uint16_t jumpaddr;

	if(insn == 0x81000000) {
		return; // NOP
		// This is handled in this function to avoid reading
		// registers which are not used otherwise
	}

	/* Check for absolute addressing or register indirect addressing */

	if (insn & 0x00400000) {
		jumpaddr = (insn & 0x003fffc0) >> 6;
	} else {
		jumpaddr = get_opa(insn);
	}

	switch (insn & 0x07c00000) {

	case 0x00000000: // jump (register indirect)
	case 0x00400000: // jump (absolute)

		if(!check_condition(insn)) {		// Check condition for conditional jump
			return;
		}
		jump_pc = jumpaddr; // It was a real jump
		break;

	case 0x00800000: // call (register indirect)
	case 0x00c00000: // call (absolute)
		mem1_store(stackptr++,pc+1 + delayslots);
		jump_pc = jumpaddr;
		break;

	case 0x01800000: // ret
		jump_pc = mem1_read(--stackptr);
		break;

	default:
		sim_warning("Unimplemented PFC instruction");
	}


	// This is used to setup the jump parameters for advance_pc()
	if(delayslots) {
		delayslot = delayslots + 1;
		skip_cycles = 3 - delayslots;
	}else{
		skip_cycles = 3;
		dojump = 1;
	}

	pm_profile(pc,skip_cycles); // Add cost to jump instruction
}

/* Accelerated instruction group */
static void insn_accelerated(uint32_t insn)
{

	int16_t mem1,mem0;
	int16_t result = 0,temp;
	uint16_t R_a = get_opa(insn);

	uint16_t mem_reg_0 = sr_read(0);
	uint16_t mem_reg_1 = sr_read(1);

	mem1 = mem1_read((R_a+mem_reg_1));
	mem0 = mem0_read((R_a+mem_reg_0));

	temp = mem0 - mem1;
	result = abs16(temp);

	temp = sr_read(31)+result;
	sr_write(31,temp);

	/* This is for the repeat_sad instruciton */
	if(sr_read(31) >= sr_read(30))
	  {
	    repeat_sad_stop(4);
	  }

/* Store the result in the register.  */
	set_reg(get_dreg(insn),temp,2);
}

/* Advances the program counter one step, taking care to honor delay
 * slots and loop instructions */
static void advance_pc(void)
{
	pc++; // Increment PC normally

	if ( dojump ) {          // Handle jumps without delay slot
		pc = jump_pc;
		dojump = 0;

		advance_cycles(skip_cycles);
	} else if ( delayslot ) { // Handle delay slot
		delayslot--;
		if ( !delayslot ) {
			advance_cycles(skip_cycles);
			pc = jump_pc;
		}
	}

	if(loopcnt) {            // Handle loop counter
		if(loopend == pc){
			// This handles the repeat_sad instruction's
			// early loop termination
			if (repeat_sad) {
				if(repeat_sad_stop_counter == 0){
					return;
				}
			}
			pc = loopstart;
			loopcnt--;
		}
	}

}

/* Fetch, decode and execute one instruction */
static void run_insn(void)
{
	uint32_t insn;

	/* Update access times for registers */
	advance_cycles(1);

	/* Fetch instruction */
	advance_pc();

	/*	printf("Cycle: %llu, pc = 0x%04x\n",cycle,pc); */
	insn = pm_read(pc);
	pm_profile(pc,1); // Update profiling


	/* Check top bits for the type of instruction */
	switch(insn & 0xc0000000) { 
	case 0x00000000:
		insn_moveloadstore(insn); // This is a move, load or store instruction
		break;
	case 0x40000000:
		insn_type01(insn); // There are many different kind of instructions with this prefix
		break;
	case 0x80000000:
		insn_pfc(insn); // Program Flow Control instruction
		break;
	case 0xc0000000:
		insn_accelerated(insn);
		break;
	}
}


/* Run a given amount of cycles or until someone signals us to stop
 * If num_cycles is negative, run forever */
static void sim_run(int num_cycles)
{
	while(num_cycles != 0){
		run_insn();

		if(num_cycles > 0) {
		  num_cycles--;
		}

		if(stop){
			stop = 0;
			return;
		}


	}
}


/* Initialize everything */
static void sim_init(void)
{
	pc = 0;
	delayslot = 0;
	stackptr = 0x7f00; // Stack begins high in memory 1

	// Start CPU by jumping to address 0
	dojump = 1;
	jump_pc = 0;

	flag_c = 0;
	flag_z = 0;
	flag_n = 0;

}

/* Load the images into memory */
static void load_images(void)
{
	int c;
	FILE *fp;
	int i;
	fp = fopen("image1.raw","rb");
	if (!fp) {
		sim_failure("Could not open image1.raw");
	}

	for (i = 0; i < 176*144; i++) {
		c = fgetc(fp);
		if (c < 0) {
			break;
		}
		mem0_store(i,c);
	}
	fclose(fp);

	fp = fopen("image2.raw","rb");
	if (!fp) {
		sim_failure("Could not open image2.raw");
	}

	for (i = 0; i < 176*144; i++) {
		c = fgetc(fp);
		if (c < 0) {
			break;
		}
		mem1_store(i,c);
	}
	fclose(fp);
}

int main(int argc, char **argv)
{
	if(argc != 2){
		sim_failure("Usage: %s <hex-file>", argv[0]);
	}

	sim_init();
	load_hex(argv[1]);
	load_images();

	sim_run(-1);
	printf("Stopped after a total of %llu cycles\n",cycle);
	dump_profile();

	return 0;
}
