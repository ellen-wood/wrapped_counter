`default_nettype none
`ifdef FORMAL
    `define MPRJ_IO_PADS 38    
`endif

//`define USE_WB  0
//`define USE_LA  0
`define USE_IO  1
//`define USE_MEM 0
//`define USE_IRQ 0

module wrapped_counter (
`ifdef USE_POWER_PINS
    inout vccd1,
    inout vssd1,
`endif
    // interface as user_proj_example.v
    input wire wb_clk_i,
`ifdef USE_WB
    input wire wb_rst_i,
    input wire wbs_stb_i,
    input wire wbs_cyc_i,
    input wire wbs_we_i,
    input wire [3:0] wbs_sel_i,
    input wire [31:0] wbs_dat_i,
    input wire [31:0] wbs_adr_i,
    output wire wbs_ack_o,
    output wire [31:0] wbs_dat_o,
`endif

    // Logic Analyzer Signals
    // only provide first 32 bits to reduce wiring congestion
`ifdef USE_LA
    input  wire [31:0] la1_data_in,
    output wire [31:0] la1_data_out,
    input  wire [31:0] la1_oenb,
`endif

    // IOs
`ifdef USE_IO
    input  wire [`MPRJ_IO_PADS-1:0] io_in,
    output wire [`MPRJ_IO_PADS-1:0] io_out,
    output wire [`MPRJ_IO_PADS-1:0] io_oeb,
`endif
    


    // IRQ
`ifdef USE_IRQ
    output wire [2:0] irq,
`endif

`ifdef USE_CLK2
    // extra user clock
    input wire user_clock2,
`endif
    
    
    //active input, ( only connect tristated outputs if this is high) 
    input wire active,

    //JW misc bits to output onto chip pins ( only connect if   active (see above ) is high
    input wire [7:0] chip_pin_output_bit,

    input wire clk_blip //For the crosstalk event counts
);
   
    wire [`MPRJ_IO_PADS-1:0] buf_io_out;
 
    //JW counter and other bits go out to  buf_io_out  and tristated to chip pins
    wire[7:0] buf_io_out_LOWER_8_BITS;
    //Wire up the sources 
    assign buf_io_out[7:0] = 8'b0;
    assign buf_io_out[15:8] = buf_io_out_LOWER_8_BITS[7:0] ;
    assign buf_io_out[23:16] = chip_pin_output_bit[7:0] ;
    assign buf_io_out[37:24] = 14'b0;

    // all outputs must be tristated before being passed onto the project
    //wire buf_wbs_ack_o;
    //wire [31:0] buf_wbs_dat_o;
    //wire [31:0] buf_la1_data_out;
    wire [`MPRJ_IO_PADS-1:0] buf_io_out;
    wire [`MPRJ_IO_PADS-1:0] buf_io_oeb;
    //wire [2:0] buf_irq;

    `ifdef FORMAL
    // formal can't deal with z, so set all outputs to 0 if not active
    `ifdef USE_WB
    assign wbs_ack_o    = active ? buf_wbs_ack_o    : 1'b0;
    assign wbs_dat_o    = active ? buf_wbs_dat_o    : 32'b0;
    `endif
    `ifdef USE_LA
    assign la1_data_out = active ? buf_la1_data_out  : 32'b0;
    `endif
    `ifdef USE_IO
    assign io_out       = active ? buf_io_out       : {`MPRJ_IO_PADS{1'b0}};
    assign io_oeb       = active ? buf_io_oeb       : {`MPRJ_IO_PADS{1'b0}};
    `endif
    `ifdef USE_IRQ
    assign irq          = active ? buf_irq          : 3'b0;
    `endif
    `include "properties.v"
    `else
    // tristate buffers
    
    `ifdef USE_WB
    assign wbs_ack_o    = active ? buf_wbs_ack_o    : 1'bz;
    assign wbs_dat_o    = active ? buf_wbs_dat_o    : 32'bz;
    `endif
    `ifdef USE_LA
    assign la1_data_out  = active ? buf_la1_data_out  : 32'bz;
    `endif
    `ifdef USE_IO
    assign io_out       = active ? buf_io_out       : {`MPRJ_IO_PADS{1'bz}};
    assign io_oeb       = active ? buf_io_oeb       : {`MPRJ_IO_PADS{1'bz}};
    `endif
    `ifdef USE_IRQ
    assign irq          = active ? buf_irq          : 3'bz;
    `endif
    `endif

    // permanently set oeb so that outputs are always enabled: 0 is output, 1 is high-impedance
    assign buf_io_oeb = {`MPRJ_IO_PADS{1'b0}};


        counter counter (
            .clk(clk_blip),
            .count(buf_io_out_LOWER_8_BITS),
            .reset(io_in[8])
            );


endmodule 
`default_nettype wire
