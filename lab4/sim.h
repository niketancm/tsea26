#ifndef _SIM_H
#define _SIM_H

void sim_print_regs(void);

/* Memory functions */
int load_hex(char *filename);
void mem0_store(unsigned int addr,unsigned int val);
void mem1_store(unsigned int addr,unsigned int val);
unsigned int pm_read(unsigned int addr);
unsigned int mem0_read(unsigned int addr);
unsigned int mem1_read(unsigned int addr);

void pm_profile(unsigned int addr,int times);
void dump_profile(void);


void sim_warning(const char *str,...);
void sim_failure(const char *str,...);

void io_out(uint16_t port, uint16_t val);

void sim_internal_fail(void);


void sim_stop(void);

#endif
