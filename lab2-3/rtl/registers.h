// -*- verilog -*-
/*   Definition of the op-codes for Senior    */
/* Bobo Svangård <bobosv@gmail.com>         */
/*                                          */
/* Document history:                        */
/*       2007-07-02:   First edition / Bobo */

/* CDT Test flag conditions */
									  
`define UT          5'b00000  //unconditionally true			  
`define Unused      5'b00001  //eller??					       
`define EQ          5'b00010  //ALU equal                                 
`define NE          5'b00011  //ALU not equal			   	  
`define UGT         5'b00100  //ALU unsigned greater than	   	  
`define UGE_CS      5'b00101  //ALU unsigned greater than or equal	  
`define ULE         5'b00110  //ALU unsigned less than or equal		  
`define ULT_CC      5'b00111  //ALU unsigned less than			   
`define SGT         5'b01000  //ALU signed greater than			       
`define SGE         5'b01001  //ALU signed greater than or equal
`define SLE         5'b01010  //ALU signed less than or equal
`define SLT         5'b01011  //ALU signed less than
`define MI          5'b01100  //ALU negative
`define PL          5'b01101  //ALU positive
`define VS          5'b01110  //ALU has overflowed
`define VC          5'b01111  //ALU has not overflowed
`define MEQ         5'b10000  //MAC or MUL equal
`define MNE         5'b10001  //MAC or MUL not equal
`define MGT         5'b10010  //MAC or MUL greater than
`define MGE_MPL     5'b10011  //MAC or MUL positive or zero
`define MLE         5'b10100  //MAC or MUL less than or equal
`define MLT_MMI     5'b10101  //MAC or MUL negative or less than
`define MVS         5'b10110  //MAC was saturated
`define MVC         5'b10111  //MAC was not saturated


/* Adressing modes */

`define A_INDR        3'b000  /* Reg indirect         */
`define A_INDX        3'b001  /* Indexed              */
`define A_INC         3'b010  /* Post add             */
`define A_DEC         3'b011  /* Pre subtract         */
`define A_OFS         3'b100  /* Offset               */
`define A_MINC        3'b101  /* Post add, mod addr   */
`define A_ABS         3'b110  /* Absolute             */
`define A_BRV         3'b111  /* Bit reversal         */


/* Special register */
`define AR0         5'b00000  //AG Adress register 0
`define AR1         5'b00001  //AG Adress register 1
`define AR2         5'b00010  //AG Adress register 2
`define AR3         5'b00011  //AG Adress register 3
`define BOT0        5'b00100  //AG Bottom for AR0
`define TOP0        5'b00101  //AG Top for AR0
`define STEP0       5'b00110  //AG Step for AR0
`define BOT1        5'b00111  //AG Bottom for AR1
`define TOP1        5'b01000  //AG Top for AR1
`define STEP1       5'b01001  //AG Step for AR1
`define FL0         5'b01010  //CP Flags, processor status register
`define FL1         5'b01011  //CP Flags, core control register
`define LOOPN       5'b01100  //CP Number of iterations in loop
`define LOOPB       5'b01101  //CP Loop start adress
`define LOOPE       5'b01110  //CP Loop en address
`define INTMASK     5'b01111  //CP Reserved
`define GUARDS01    5'b10000  //MAC Reserved 
`define GUARDS23    5'b10001  //MAC Resserved




/* Definitions for fl0 */
`define AZ 0
`define AN 1
`define AC 2
`define AV 3
`define MZ 4
`define MN 5
`define MS 6
`define MV 7


/* Definitions for scaling */

`define scale_none      3'b000
`define scale_mul2      3'b001
`define scale_mul4      3'b010
`define scale_div2      3'b011
`define scale_div4      3'b100
`define scale_div8      3'b101
`define scale_div16     3'b110
`define scale_mul65536  3'b110

