//
// testbench
//
//  >cver  thisfile
//  >gtkwave dumpfile.vcd
//


`include "counter_for_isolator_blip_detection.v"


`timescale 1 ns / 100 ps

module TEST_counter_for_isolator_blip_detection();

// IO pins
    reg clk;

    reg reset;

    output wire [7:0] count;


//---------------------------------------------------------

	counter_for_isolator_blip_detection DUT (
			.clk(clk),
			.count(count),
			.reset(reset)
			);



    //----------------------------------------------------------
    // create a 33Mhz clock
    always
    #15.33333 clk = ~clk; // 


    //-----------------------------------------------------------
    // initial blocks are sequential and start at time 0
    initial
        begin
            $display($time, " << Starting the Simulation >>");
		clk = 1'b1;
        reset = 1'b1;

	#200
        reset =1'b0;
	#600

	#60


	#10000

	#592
        reset =1'b1;

	#60



            #129000;
            $display($time, " << Simulation Complete >>");
//            $stop;
            $finish;
            // stop the simulation
    end

//--------------------------------------------------------------
// This initial block runs concurrently with the other
// blocks in the design and starts at time 0
    initial begin
        // $monitor will print whenever a signal changes
        // in the design
//        $monitor($time, " Clk=%b, nCS=%b, Dout=%b, ", Clk, nCS, Dout);
    end
//--------------------------------------------------------------
    initial
        begin
            $dumpfile("dumpfile.vcd");
            $dumpvars;
    //        $dumpon;
    end

//------

//----------------------
endmodule //



