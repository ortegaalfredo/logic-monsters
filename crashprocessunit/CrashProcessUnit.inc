//Basic definitions
`define operand_width 16 ///< Operand width 

`define code_width 18 // Xilinx block ram
`define code_depth 10 // 1024 instructions
`define code_size (1<<`code_depth) ///< Instruction memory size

`define reset_vector 0 ///< Reset vector

// Operation codes
`define OP_NOP   00

`define OP_MOV_RR 01
`define OP_MOV_RI 02

`define OP_MOV_RS 05
`define OP_MOV_SR 06

`define OP_ADD_RR 07
`define OP_ADD_RI 08

`define OP_SUB_RR 11
`define OP_SUB_RI 12

`define OP_AND_RR 15

`define OP_OR_RR  17

`define OP_CMP_RR 27

`define OP_JMP_R 31

`define OP_JE_I  36
`define OP_JNE_I 37
