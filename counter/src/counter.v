
`timescale 1ns / 1ps



//////////////////////////////////////////////////////////////////////////////////

module counter( clk, count, reset );


//registers and wires		


// IO pins
input wire clk;

input wire reset;

output reg [7:0] count;

//-----

always @ (posedge clk or posedge reset)
begin
  if (reset)
     count  <= 0;
  else
	 	count <= count+1;
end


endmodule

