// Crash process unit
// Icarus Verilog is a Verilog simulation and synthesis tool.
// This is a small state-machine that when parsed by iverilog, it causes a stack-based
// buffer overflow. This particular file demonstrates code execution on win32.
// (c) A. Ortega 2020



`include "CrashProcessUnit.inc"

module crashpu(clk,reset,address,instruction);

input clk; //Clock
input reset; //Reset
output [`code_depth-1:0] address; // Address bus
input [`code_width-1:0] instruction; //Instruction bus

// Address latch
reg [`code_depth-1:0] address_latch;
assign address = address_latch;

// Registers
reg [`operand_width-1:0] r[0:1];

// Program counter
reg [`operand_width-1:0] pc;
`define program_counter pc

// flags
reg [1:0] ZFLAG; //zero flag

integer i;
// Main loop
always @ (posedge clk or posedge reset)
	begin
	address_latch= `program_counter;
	//@ (negedge clk)
	// reset
	if (reset) 
		begin
		`program_counter =  `reset_vector; // load reset vector
		address_latch= `program_counter;
		for (i=0; i<2;i = i+1) // clear registers and special registers
			begin
			r[i] = 0;
			end
		$display("Reset");
		end
	else begin
	`program_counter=`program_counter+1;
	if (`program_counter==10)
		`program_counter=0;

	// fetch instruction
	$display("Instruction fetched: %08x:%08x",address_latch,instruction);
	case (instruction[5:0]) // 64 opcodes max
		`OP_NOP: begin
			 end
		`OP_MOV_RR:	begin
				$display("OP_MOV_RR R%02x<=R%02x",instruction[11:9],instruction[8:6]);
				r[instruction[11:9]]=r[instruction[8:6]];
			 	end
		`OP_MOV_RI:	begin
				$display("OP_MOV_RI R%02x<=%04x",instruction[8:6],instruction[17:9]);
				r[instruction[8:6]]=instruction[17:9];
			 	end
		`OP_ADD_RR:	begin
				$display("OP_ADD_RR R%02x+=R%02x",instruction[11:9],instruction[8:6]);
				r[instruction[11:9]]=r[instruction[11:9]] + r[instruction[8:6]];
				end
		`OP_ADD_RI:	begin
				$display("OP_ADD_RI R%02x+=%04x",instruction[8:6],instruction[17:9]);
				r[instruction[8:6]]=r[instruction[8:6]] + instruction[17:9];
				end
		`OP_SUB_RR:	begin
				$display("OP_SUB_RR R%02x-=R%02x",instruction[11:9],instruction[8:6]);
				r[instruction[11:9]]=r[instruction[11:9]] - r[instruction[8:6]];
				end
		`OP_SUB_RI:	begin
				$display("OP_SUB_RI R%02x-=%04x",instruction[8:6],instruction[17:9]);
	//			[instruction[8:6]]=r[instruction[8:6]] - instruction[17:9];
				end
		`OP_AND_RR:	begin
				$display("OP_AND_RR R%02x&=R%02x",instruction[11:9],instruction[8:6]);
				r[instruction[11:9]]=r[instruction[11:9]] & r[instruction[8:6]];
				end
		`OP_OR_RR:	begin
				$display("OP_OR_RR R%02x|=R%02x",instruction[11:9],instruction[8:6]);
				r[instruction[11:9]]=r[instruction[11:9]] | r[instruction[8:6]];
				end
		`OP_CMP_RR:	begin
				$display("OP_CMP_RR R%02x,R%02x",instruction[11:9],instruction[8:6]);
				if (r[instruction[11:9]]==r[instruction[8:6]]) ZFLAG=1;
				end
		`OP_JE_I:	begin
				$display("OP_JE_I (%1d) %04x",instruction[17:17],instruction[16:6]);
				if (ZFLAG==1)
				if (instruction[17:17]==1) // Sign!
					`program_counter=`program_counter-instruction[16:6];
				else 	`program_counter=`program_counter+instruction[16:6];

				end
		`OP_JNE_I:	begin
				$display("OP_JNE_I (%1d) %04x",instruction[17:17],instruction[16:6]);
				if (ZFLAG==0)
				if (instruction[17:17]==1) // Sign!
					`program_counter=`program_counter-instruction[16:6];
				else 	`program_counter=`program_counter+instruction[16:6];
				end
		`OP_JMP_R:	begin
				$display("OP_JMP_R R%01x",instruction[8:6]);
				`program_counter=r[instruction[8:6]];
				end
		default: begin 
			 $display("Invalid OP! %04X",instruction[5:0]);
			 // ILLEGAL OPCODE!
			 // Reset
		 	`program_counter=0;
			 end
	endcase


	case (instruction[5:0]) // flags settings
	`OP_ADD_RR,`OP_ADD_RI,`OP_SUB_RR,`OP_SUB_RI,
	`OP_AND_RR,`OP_OR_RR:
			begin
			if (r[instruction[8:6]]==0) ZFLAG=1'b1; else ZFLAG=1'b0; //zero
			end
		default: begin
			 end
	endcase
	end
	$display("Regs: pc:%02x r0:%02x r1:%02x",`program_counter,r[0],r[1]);
	$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAccBBKDzvTYIIIIIIIIIIIIIIII7QZjAXP0A0AkAAQ2AB2BB0BBABXP8ABuJIBHKOjRWvXK58p8MtXQcioyJGpjZUQNpVvQiP3TlKBPTplKRV4LLKBV5Lnkpn6hLKdvNkcm7LNkslwmT8wqHklKpKr8qGlKak10c1xoNksLlOylWqHooitruGavXQKzNN0uZX1OqvwKUG9pYubU8RnkBsQ4vaizvoMgdT0JNkpKglWqM9LKB4nquQyz3npV9ozrtyM7puWrMYZfVQJrsdowtTDdBrpjTO3VnOM8LXkOKOkO0P0WRnCuPDwQupwPwPUpwPepuptMWzA("A");
	end

endmodule
