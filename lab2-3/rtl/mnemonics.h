/* Instruction Encoding */
/* ==================== */

/* move-load-store		      tt=00 */
/* ----------------------------------- */
/* 33222222 22221111 11111100 00000000 */
/* 10987654 32109876 54321098 76543210 */
/* tt...000 00ddddda aaaa.... ........ move r[d],sr[a]; */
/* tt...000 01ddddda aaaa.... ........ move sr[d],r[a]; */
/* tt...000 11ddddd. ..AA.sss .rsccccc move cdt r[d],acr[A]; 	rd<=scaling(sat(rnd(acra))) */
/*                                                       		r<=rnd s<=sat <= factor 16 for yacrx */
/* tt...001 10..HDDa aaaa.... ...ccccc move acr[D].H,ra;	H<=H/L */
/* tt...010 00ddddd. iiiiiiii iiiiiiii set r[d],#imm16; */
/* tt...010 01ddddd. iiiiiiii iiiiiiii set sr[d],#imm16; */

/* ttmmm100 00dddddq aaaaaaaa aaaaaaaa ld[q] r[d],dm[q](mmm); 	a<= absolute address */
/* ttmmm101 00aaaaab bbbbnnnr rbb..... dblld r[a],dm0(mmm),r[b],dm1(nnn); m<=addressing mode dm0, n<=adrressing mode dm1 */
/* ttmmm101 01aaaaab bbbbnnnr rbb..... dblst dm0(mmm),r[a],dm1(nnn),r[b]; m<=addressing mode dm0, n<=adrressing mode dm1 */
/* ttmmm100 01aaaaaq aaaaaaaa aaaaaaaa st[q] dm[q](mmm),r[b]; 	q<=dm 0/1; m<=addressing mode */
/*   000100 01aaaaaq ....bbbb b.......                INDR */
/*   001100 01aaaaaq .RR.bbbb b....... RR<=ar[R]			INDX */
/*   010100 01aaaaaq sRR..... ........ RR<=ar[R]			INC */
/*   011100 01aaaaaq sRR..... ........ RR<=ar[R]			DEC */
/*   100100 01aaaaaq sRRLLLLL LLLLLLLL RR<=ar[R]			OFS, L<= OFFSET */
/*   101100 01aaaaaq .RR..... ........ RR<=ar[R]			MINC */
/*   110100 01aaaaaq aaaaaaaa aaaaaaaa 		            ABS */
/*   111100 01aaaaaq .RR..... ........ RR<=ar[R]			BRV */

/* ttmmm011 00dddddq iiiiiiii iiiiiiii st[q] dm[q](mmm),#imm16; 	d<=indirect addressing - reg, mmm<=??? */

/* tt...100 10ddddd. pppppppp pppppppp in r[d],IO(PAM); */
/* tt...100 11aaaaa. pppppppp pppppppp out IO(PAM),r[a]; */
/* ttmmm111 00dddddq ssssbbbb b..iiiii ldrn r[d],dm[q](...),n; 	rd<=dm[q] n times stall PL  */
/* ttmmm111 01aaaaaq ssssbbbb b..iiiii strn dm[q](...),r[a],n; 	rd<=dm[q] n times stall PL s<=step */

`define MOVE_1           10'b00???_000_00
`define MOVE_2           10'b00???_000_01
`define MOVE_3           10'b00???_000_11
`define MOVE_4           10'b00???_001_10
`define SET_1            10'b00???_010_00
`define SET_2            10'b00???_010_01
`define LD               10'b00???_100_00
`define DBLLD		         10'b00???_101_00
`define DBLST	           10'b00???_101_01
`define ST               10'b00???_100_01
`define IN               10'b00???_100_10
`define OUT              10'b00???_100_11


/*  Arithmetic operations */

/* 16b arith		ttttt=01000 */
/* ----------------------------------- */
/* 33222222 22221111 11111100 00000000 */
/* 10987654 32109876 54321098 76543210 */
/* ttttt000 00ddddda aaaabbbb b..ccccc addn cdt r[d],r[a],r[b]; */
/* ttttt000 01ddddda aaaaiiii iiiiiiii addn r[d],r[a],#imm12s;	r[d],#imm12s,r[a] */
/* ttttt000 10ddddda aaaabbbb b..ccccc addc cdt r[d],r[a],r[b]; */
/* ttttt000 11ddddda aaaaiiii iiiiiiii addc r[d],r[a],#imm12s;	r[d],#imm12s,r[a] */
/* ttttt001 00ddddda aaaabbbb b..ccccc adds cdt r[d],r[a],r[b]; */
/* ttttt001 01ddddda aaaaiiii iiiiiiii adds r[d],r[a],#imm12s;	r[d].#imm12s,r[a] */
/* ttttt001 10ddddda aaaabbbb b..ccccc add cdt r[d],r[a],r[b]; */
/* ttttt001 11ddddda aaaaiiii iiiiiiii add r[d],r[a],#imm12s;	r[d],#imm12s,r[a] */
/* ttttt010 00ddddda aaaabbbb b..ccccc subn cdt r[d],r[b],r[a];	r[d]<=r[b]-r[a] */
/* ttttt010 01ddddda aaaaiiii iiiiiiii subn r[d],#imm12s,r[a];	r[d]<=#imm12s-r[a] */
/* ttttt010 10ddddda aaaabbbb b..ccccc subc cdt r[d],r[b],r[a];	r[d]<=r[b]-r[a] */
/* ttttt010 11ddddda aaaaiiii iiiiiiii subc r[d],#imm12s,r[a];	r[d]<=#imm12s-r[a] */
/* ttttt011 00ddddda aaaabbbb b..ccccc subs cdt r[d],r[b],r[a];	r[d]<=r[b]-r[a] */
/* ttttt011 01ddddda aaaaiiii iiiiiiii subs r[d],#imm12s,r[a];	r[d]<=#imm12s-r[a] */
/* ttttt011 10ddddda aaaabbbb b..ccccc sub cdt r[d],r[b],r[a];	r[d]<=r[b]-r[a] */
/* ttttt011 11ddddda aaaaiiii iiiiiiii sub r[d],#imm12s,r[a];	r[d]<=#imm12s-r[a] */
/* ttttt100 00.....a aaaabbbb b..ccccc cmp cdt r[a],r[b]; */
/* ttttt100 01.iiiia aaaaiiii iiiiiiii cmp r[a],#imm16s; */
/* ttttt100 10ddddda aaaabbbb b..ccccc max cdt r[d],r[a],r[b]; */
/* ttttt100 11ddddda aaaaiiii iiiiiiii max r[d],r[a],#imm12s; */
/* ttttt101 00ddddda aaaabbbb b..ccccc min cdt r[d],r[a],r[b]; */
/* ttttt101 01ddddda aaaaiiii iiiiiiii min r[d],r[a],#imm12s; */
/* ttttt101 10ddddda aaaa.... ..sccccc abs cdt r[d],r[a] ;s<=sat/notsat */

`define ARITH_16B   10'b01000_???_??

`define ADDN_1      10'b01000_000_00
`define ADDN_2      10'b01000_000_01
`define ADDC_1      10'b01000_000_10
`define ADDC_2      10'b01000_000_11
`define ADDS_1      10'b01000_001_00
`define ADDS_2      10'b01000_001_01
`define ADD_1       10'b01000_001_10
`define ADD_2       10'b01000_001_11
`define SUBN_1      10'b01000_010_00
`define SUBN_2      10'b01000_010_01
`define SUBC_1      10'b01000_010_10
`define SUBC_2      10'b01000_010_11
`define SUBS_1      10'b01000_011_00
`define SUBS_2      10'b01000_011_01
`define SUB_1       10'b01000_011_10
`define SUB_2       10'b01000_011_11
`define CMP_1       10'b01000_100_00
`define CMP_2       10'b01000_100_01
`define MAX_1       10'b01000_100_10
`define MAX_2       10'b01000_100_11
`define MIN_1       10'b01000_101_00
`define MIN_2       10'b01000_101_01
`define ABS         10'b01000_101_10

/* 16b logic		ttttt=01010 */
/* ----------------------------------- */
/* 33222222 22221111 11111100 00000000 */
/* 10987654 32109876 54321098 76543210 */
/* ttttt000 00ddddda aaaabbbb b..ccccc andn cdt r[d],r[a],r[b]; */
/* ttttt000 01ddddda aaaaiiii iiiiiiii andn r[d],r[a],#imm12s; */
/* ttttt000 10ddddda aaaabbbb b..ccccc and cdt r[d],r[a],r[b]; */
/* ttttt000 11ddddda aaaaiiii iiiiiiii and r[d],r[a],#imm12s; */
/* ttttt001 00ddddda aaaabbbb b..ccccc orn cdt r[d],r[a],r[b]; */
/* ttttt001 01ddddda aaaaiiii iiiiiiii orn r[d],r[a],#imm12s; */
/* ttttt001 10ddddda aaaabbbb b..ccccc or cdt r[d],r[a],r[b]; */
/* ttttt001 11ddddda aaaaiiii iiiiiiii or r[d],r[a],#imm12s; */
/* ttttt010 00ddddda aaaabbbb b..ccccc xorn cdt r[d],r[a],r[b]; */
/* ttttt010 01ddddda aaaaiiii iiiiiiii xorn r[d],r[a],#imm12s; */
/* ttttt010 10ddddda aaaabbbb b..ccccc xor cdt r[d],r[a],r[b]; */
/* ttttt010 11ddddda aaaaiiii iiiiiiii xor r[d],r[a],#imm12s; */
/* ttttt100 01.iiii. ....iiii iiiiiiii andf flags #imm16; <= reset flags */
/* ttttt100 11.iiii. ....iiii iiiiiiii orf flags #imm16; <= set flags */
/* ttttt101 01.iiii. ....iiii iiiiiiii xorf flags #imm16; <= toggle flags */
/* ttttt100 00ddddda aaaa.... ...ccccc led cdt rd,ra; <= leading 0 */
/* ttttt100 10ddddda aaaa.... ...ccccc led cdt rd,ra; <= leading 1 */
/* ttttt101 00ddddda aaaax... ...ccccc led cdt rd,ra; <= leading x x<=to count leading x */
/* ttttt101 00ddddda aaaa.... ...ccccc led cdt rd,ra; <= leading x */

`define LOGIC_16B          10'b01010_???_??
`define LOGIC_16B_ANDORXOR 10'b01010_0??_??
`define LOGIC_16B_ANDS     10'b01010_000_0?
`define LOGIC_16B_ORS      10'b01010_001_??
`define LOGIC_16B_XORS     10'b01010_010_??
`define LOGIC_16B_LEDS     10'b01010_10?_??

`define ANDN_1             10'b01010_000_00
`define ANDN_2             10'b01010_000_01
`define AND_1              10'b01010_000_10
`define AND_2              10'b01010_000_11
`define ORN_1              10'b01010_001_00
`define ORN_2              10'b01010_001_01
`define OR_1               10'b01010_001_10
`define OR_2               10'b01010_001_11
`define XORN_1             10'b01010_010_00
`define XORN_2             10'b01010_010_01
`define XOR_1              10'b01010_010_10
`define XOR_2              10'b01010_010_11
`define ANDF               10'b01010_100_01
`define ORF                10'b01010_100_11
`define XORF               10'b01010_101_01
`define LED_1              10'b01010_100_00
`define LED_2              10'b01010_100_10
`define LED_3              10'b01010_101_00


/* 16b shift		ttttt=01001 */
/* ----------------------------------- */
/* 33222222 22221111 11111100 00000000 */
/* 10987654 32109876 54321098 76543210 */
/* ttttt000 00ddddda aaaabbbb b..ccccc asr cdt rd,ra,rb; */
/* ttttt000 01ddddda aaaaiiii i..ccccc asr cdt rd,ra,#imm5;  */
/* ttttt000 10ddddda aaaabbbb b..ccccc asl cdt rd,ra,rb; */
/* ttttt000 11ddddda aaaaiiii i..ccccc asl cdt rd,ra,#imm5;  */
/* ttttt001 00ddddda aaaabbbb b..ccccc lsr cdt rd,ra,rb; */
/* ttttt001 01ddddda aaaaiiii i..ccccc lsr cdt rd,ra,#imm5;  */
/* ttttt001 10ddddda aaaabbbb b..ccccc lsl cdt rd,ra,rb; */
/* ttttt001 11ddddda aaaaiiii i..ccccc lsl cdt rd,ra,#imm5;  */
/* ttttt010 00ddddda aaaabbbb b..ccccc ror cdt rd,ra,rb; */
/* ttttt010 01ddddda aaaaiiii i..ccccc ror cdt rd,ra,#imm5;  */
/* ttttt010 10ddddda aaaabbbb b..ccccc rol cdt rd,ra,rb; */
/* ttttt010 11ddddda aaaaiiii i..ccccc rol cdt rd,ra,#imm5;  */
/* ttttt011 00ddddda aaaabbbb b..ccccc rcr cdt rd,ra,rb; */
/* ttttt011 01ddddda aaaaiiii i..ccccc rcr cdt rd,ra,#imm5;  */
/* ttttt011 10ddddda aaaabbbb b..ccccc rcl cdt rd,ra,rb; */
/* ttttt011 11ddddda aaaaiiii i..ccccc rcl cdt rd,ra,#imm5;  */

`define SHIFT_16B    10'b01001_???_??
`define SHIFT_16B_AS 10'b01001_000_??
`define SHIFT_16B_LS 10'b01001_001_??
`define SHIFT_16B_RO 10'b01001_010_??
`define SHIFT_16B_RC 10'b01001_011_??


`define ASR_1        10'b01001_000_00
`define ASR_2        10'b01001_000_01
`define ASL_1        10'b01001_000_10
`define ASL_2        10'b01001_000_11
`define LSR_1        10'b01001_001_00
`define LSR_2        10'b01001_001_01
`define LSL_1        10'b01001_001_10
`define LSL_2        10'b01001_001_11
`define ROR_1        10'b01001_010_00
`define ROR_2        10'b01001_010_01
`define ROL_1        10'b01001_010_10
`define ROL_2        10'b01001_010_11
`define RCR_1        10'b01001_011_00
`define RCR_2        10'b01001_011_01
`define RCL_1        10'b01001_011_10
`define RCL_2        10'b01001_011_11

/* 32b single 		ttttt=01011 */
/* ----------------------------------- */
/* 33222222 22221111 11111100 00000000 */
/* 10987654 32109876 54321098 76543210 */
/* ttttt000 00...DD. ..AABB.. ...ccccc addl cdt acrd,acra,acrb; acra<=AA acrb<=BB */
/* ttttt000 01...DD. ..AAbbbb b..ccccc addl cdt acrd,acra,rb:0; */
/* ttttt000 10...DD. ..AAbbbb b..ccccc addl cdt acrd,acra,sign:rb; */
/* ttttt000 11...DDa aaaabbbb bAAccccc addl cdt acrd,acra,ra:rb; */
/* ttttt001 00...DD. ..AABB.. ...ccccc subl cdt acrd,acra,acrb;  */
/* ttttt001 01...DD. ..AAbbbb b..ccccc subl cdt acrd,acra,rb:0; */
/* ttttt001 10...DD. ..AAbbbb b..ccccc subl cdt acrd,acra,sign:rb; */
/* ttttt001 11...DDa aaaabbbb bAAccccc subl cdt acrd,acra,ra:rb; */
/* ttttt010 00...... ..AABB.. ...ccccc cmpl cdt acra,acrb;  */
/* ttttt010 01...... ..AAbbbb b..ccccc cmpl cdt acra,rb:0; */
/* ttttt010 10...... ..AAbbbb b..ccccc cmpl cdt acra,sign:rb; */
/* ttttt010 11.....a aaaabbbb bAAccccc cmpl cdt acra,ra:rb; */
/* ttttt011 00...DD. ..AA.... ..sccccc absl cdt acrd,acra;  --s<=sat/notsat; h<= H/L */
/* ttttt011 01...DDa aaaa.... .hsccccc absl cdt acrd,H/Lra;  */
/* ttttt100 00...DD. ..AA.... ..sccccc negl cdt acrd,acra;   */
/* ttttt100 01...DDa aaaa.... .hsccccc negl cdt acrd,H/Lra;  */
/* ttttt101 00...DDa aaaabbbb b..ccccc movel cdt acrd,ra:rb; */
/* ttttt101 01...DDa aaaa.... .h.ccccc movel cdt acrd,H/Lra;  */
/* ttttt101 10...DD. ........ ...ccccc clr cdt acrd; */
/* ttttt110 00sssDD. ....BB.. .rsccccc postop cdt acrd,acrb; --scaling,r-round s-sat */
/* ttttt110 01ddddd. ..AAaaaa arsccccc addl cdt sat rnd rd,acrA,ra:0 */
/* ttttt110 10ddddd. ..AAaaaa arsccccc addl cdt sat rnd rd,acrA,1:ra */
/* ttttt111 01dddddq ffBBaaaa arsbbbbb sublst[q] sat rnd rd,ra:0,acrB,arf,rb */
/* ttttt110 10dddddq ffBBaaaa arsbbbbb sublst[q] sat rnd rd,1:ra,acrB,arf,rb */

`define SINGLE_32B    10'b01011_???_??
`define SINGLE_MOVEL  10'b01011_101_0?
`define ADDL_1        10'b01011_000_00
`define ADDL_2        10'b01011_000_01
`define ADDL_3        10'b01011_000_10
`define ADDL_4        10'b01011_000_11
`define SUBL_1        10'b01011_001_00
`define SUBL_2        10'b01011_001_01
`define SUBL_3        10'b01011_001_10
`define SUBL_4        10'b01011_001_11
`define CMPL_1        10'b01011_010_00
`define CMPL_2        10'b01011_010_01
`define CMPL_3        10'b01011_010_10
`define CMPL_4        10'b01011_010_11
`define ABSL_1        10'b01011_011_00
`define ABSL_2        10'b01011_011_01
`define NEGL_1        10'b01011_100_00
`define NEGL_2        10'b01011_100_01
`define MOVEL_1       10'b01011_101_00
`define MOVEL_2       10'b01011_101_01
`define CLR           10'b01011_101_10
`define POSTOP        10'b01011_110_00 
`define ADDL_5        10'b01011_110_01
`define ADDL_6        10'b01011_110_10
`define SUBLST_1      10'b01011_111_01
`define SUBLST_2      10'b01011_111_10

/* 32b double  	 	ttttt=01100 */
/* ----------------------------------- */
/* 33222222 22221111 11111100 00000000 */
/* 10987654 32109876 54321098 76543210 */
/* ttttt000 00sssDDa aaaabbbb buu..... mul  acrd,ra,rb; u<=un/signed */
/* ttttt000 01sssDDa aaaabbbb buu..... mac  acrd,ra,rb; <=mac accumulate */
/* ttttt000 10sssDDa aaaabbbb buu..... mdm  acrd,ra,rb; <=mac diminish */
/* tttttRR0 11mmmDDa aaaabbbb bdddddq. mulld[q] acrD,ra,rb,rd,dm[q](mmm), RR<=ar*/
/* tttttRR1 00mmmDDa aaaabbbb bdddddq. macld[q] acrD,ra,rb,rd,dm[q](mmm), RR<=ar*/
/* tttttbb1 01fffDDa aaaabbbb bdddddff muldblld acrD,ra,rb,rd,rf, bb<=bit reverse*/

`define DOUBLE_32B  10'b01100_???_??
`define MUL         10'b01100_000_00
`define MAC         10'b01100_000_01
`define MDM         10'b01100_000_10
`define MULLD       10'b01100_??0_11
`define MACLD       10'b01100_??1_00
`define MULDBLLD    10'b01100_??1_01

/* Iterative		ttttt=01101 */
/* ----------------------------------- */
/* 33222222 22221111 11111100 00000000 */
/* 10987654 32109876 54321098 76543210 */
/* ttttt000 00sssDDm mmAAmmmB Buu.q... conv scaling dm0(AM),dm1(AM); q<=add/sub; u<=un/signed; AA<=addr0; BB<=addr1 */
/* ttttt000 01kkkkkk kkkkkk.. .iiiiiii rep iter12,ins7; <= repeat m,n */

`define ITERATIVE   10'b01101_???_??

`define CONV        10'b01101_000_00
`define REP         10'b01101_000_01

/* Program flow control */

/* PFC			      tt=10 */
/* ----------------------------------- */
/* 33222222 22221111 11111100 00000000 */
/* 10987654 32109876 54321098 76543210 */
/* tt.jj000 00.....a aaaa.... ...ccccc jmp cdt ra; j<=delay 0/1/2/3 */
/* tt.jj000 01iiiiii iiiiiiii ii.ccccc jmp cdt #imm16; */
/* tt.jj000 10.....a aaaa.... ........ call ra; */
/* tt.jj000 11iiiiii iiiiiiii ii...... call #imm16; */
/* tt...001 00...... ........ ........ NOP; */
/* tt.jj001 10...... ........ ........ ret; j<=delay 0/1/2/3 */
/* tt.jj010 00...... ........ ........ reti; j<=delay 0/1/2/3 */
/* tt...010 10...... ........ ........ sleep; */
/* tt...010 11iiiiii iiiiiiii ii...... sleep #imm16; */

`define PFC          10'b10???_???_??
`define PFC_JUMPS    10'b1?do instruction.???_000_0?
`define PFC_CALLS    10'b10???_000_1?
`define PFC_SLEEPS   10'b10???_010_??
`define JUMP_1       10'b10???_000_00
`define JUMP_2       10'b10???_000_01
`define CALL_1       10'b10???_000_10
`define CALL_2       10'b10???_000_11
`define NOP          10'b10???_001_00
`define RET          10'b10???_001_10
`define RETI         10'b10???_010_00
`define SLEEP_1      10'b10???_010_10
`define SLEEP_2      10'b10???_010_11


/* Accelerations */

`define ACCELERATED_INSTRUCTION 10`b11???_???_??

/* Pipeline depth */

`define CONV_DEPTH_INSTRUCTIONS  `CONV
/* -----\/----- EXCLUDED -----\/-----
`define E1_DEPTH_INSTRUCTIONS `IN, `ARITH_16B, `LOGIC_16B, `SHIFT_16B, `SET_1, `SET_2, `NOP, `OUT, `MOVE_1, `MOVE_2, `LD, `ST, `PFC, `REP, `SINGLE_32B, `DOUBLE_32B
`define E2_DEPTH_INSTRUCTIONS `MOVE_3, `MOVE_4
 -----/\----- EXCLUDED -----/\----- */
`define E1_DEPTH_INSTRUCTIONS `IN, `ARITH_16B, `LOGIC_16B, `SHIFT_16B, `SET_1, `SET_2, `NOP, `OUT, `MOVE_1, `MOVE_2, `LD, `ST, `PFC, `REP, `DBLST, `DBLLD
`define E2_DEPTH_INSTRUCTIONS `MOVE_3, `MOVE_4, `SINGLE_32B, `DOUBLE_32B
//EOF




