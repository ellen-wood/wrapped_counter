// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/wrapper_squared/wrapper_squared.sch
module wrapper_squared
(
  output wire [37:0] io_out,
  output wire [37:0] io_oeb,
  inout wire vccd1,
  inout wire vcca1,
  inout wire vssa1,
  inout wire vssd1,
  inout wire [10:0] analog_io,
  input wire wb_clk_i,
  input wire [37:0] io_in
);
wire [7:0] chip_pin_output_bit ;
wire TXRX_A_NEG ;
wire active ;
wire vdd ;
wire TXRX_A_POS ;
wire vss_iso ;
wire blip_RX ;
wire clk_blip ;
wire del_ramp ;
wire net1 ;
wire net2 ;
wire net3 ;
wire net4 ;
wire vdd_inject1 ;
wire vdd_inject2 ;
wire TXRX_B_NEG ;
wire TXRX_B_POS ;
wire vdd_iso ;

wrapped_counter
x1 ( 
 .vccd1( vccd1 ),
 .wb_clk_i( wb_clk_i ),
 .io_out( io_out[37:0] ),
 .io_in( io_in[37:0] ),
 .io_oeb( io_oeb[37:0] ),
 .active( active ),
 .chip_pin_output_bit( chip_pin_output_bit ),
 .vssd1( vssd1 ),
 .clk_blip( clk_blip )
);


analog_mux
x3 ( 
 .A( analog_io[2] ),
 .X( analog_io[4] ),
 .B( analog_io[3] ),
 .vdd( vccd1 ),
 .vdda( vcca1 ),
 .vss( vssd1 ),
 .vssa( vssa1 ),
 .SEL( io_in[8] )
);


pwm_v1
x6 ( 
 .vdd( vccd1 ),
 .vss( vssd1 ),
 .adc_in( analog_io[1] ),
 .out( chip_pin_output_bit[0] ),
 .diode( analog_io[10] ),
 .cascref( net1 ),
 .SAMPLE( io_in[9] )
);


pwm_v2
x7 ( 
 .vdd( vccd1 ),
 .vss( vssd1 ),
 .adc_in( analog_io[0] ),
 .out( chip_pin_output_bit[1] ),
 .diode( analog_io[10] ),
 .cascref( net1 ),
 .SAMPLE( io_in[9] )
);

tran  R5 ( vccd1 ,  TXRX_B_NEG );
tran  R11 ( TXRX_B_POS ,  vssd1 );
tran  R14 ( TXRX_A_NEG ,  vccd1 );
tran  R4 ( vssd1 ,  TXRX_A_POS );

crosstalk_glitch_transmitter
x5 ( 
 .vdd( vccd1 ),
 .TXRX_A_NEG( TXRX_A_NEG ),
 .in( io_in[12] ),
 .TXRX_A_POS( TXRX_A_POS ),
 .vss( vssd1 )
);


crosstalk_glitch_detector
x8 ( 
 .vdd( vccd1 ),
 .blip_RX( blip_RX ),
 .TXRX_B_POS( TXRX_B_POS ),
 .TXRX_B_NEG( TXRX_B_NEG ),
 .vss( vssd1 )
);


nand_P3u_N2u_compact
x9 ( 
 .vdd( vccd1 ),
 .b( active ),
 .a( io_in[10] ),
 .out( net2 ),
 .vss( vssd1 )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 250 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M1 ( 
 .D( vdd_inject1 ),
 .G( net2 ),
 .S( vccd1 ),
 .B( vccd1 )
);


nand_P3u_N2u_compact
x11 ( 
 .vdd( vccd1 ),
 .b( active ),
 .a( io_in[11] ),
 .out( net3 ),
 .vss( vssd1 )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 250 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M2 ( 
 .D( vdd_inject2 ),
 .G( net3 ),
 .S( vccd1 ),
 .B( vccd1 )
);


schmitt_ratio_1_to_1
x12 ( 
 .in( del_ramp ),
 .out( net4 ),
 .vdd( vdd_iso ),
 .vss( vss_iso )
);


inv_P24u_N10u
x13 ( 
 .a( net4 ),
 .out( clk_blip ),
 .vdd( vdd_iso ),
 .vss( vss_iso )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M3 ( 
 .D( del_ramp ),
 .G( blip_RX ),
 .S( vss_iso ),
 .B( vss_iso )
);


pfet_01v8
#(
.L ( 1 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M4 ( 
 .D( del_ramp ),
 .G( vss_iso ),
 .S( vdd_iso ),
 .B( vdd_iso )
);


pfet_01v8
#(
.L ( 2 ) ,
.W ( 3 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M5 ( 
 .D( del_ramp ),
 .G( vdd_iso ),
 .S( del_ramp ),
 .B( del_ramp )
);


res_generic_m2
#(
.W ( 1 ) ,
.L ( 1 ) ,
.model ( res_generic_m2 ) ,
.mult ( 1 )
)
R1 ( 
 .M( net1 ),
 .P( vssd1 )
);


pfet_01v8
#(
.L ( 1 ) ,
.W ( 2 ) ,
.nf ( 1 ) ,
.mult ( 5 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M6 ( 
 .D( analog_io[10] ),
 .G( analog_io[10] ),
 .S( vdd ),
 .B( vdd )
);


vdd_vss_interconnect_parasitics_test_ACTIVE
x2 ( 
 .vdd_inject( vdd_inject1 ),
 .vss( vssd1 ),
 .vdd_sense( analog_io[7] ),
 .vss_sense( analog_io[6] ),
 .enable( vccd1 )
);


vdd_vss_interconnect_parasitics_test_PASSIVE
x10 ( 
 .vdd_inject( vdd_inject2 ),
 .vss( vssd1 ),
 .vdd_sense( analog_io[9] ),
 .vss_sense( analog_io[8] )
);


vref_switched_capactior_divider_bandgap
x4 ( 
 .vdd( vccd1 ),
 .vdd_an( vccd1 ),
 .vref( analog_io[5] ),
 .vss_an( vssd1 ),
 .vss( vssd1 )
);



*COUPLING CAPAICTANCE
.param ccoupling=0.25e-12
*ATTENUATING CAPACITANCE
.param cattenuation=0.25e-12

.param RZ=60
.param M_POHMS=90
.param C_PARASITIC_LINKAGE=20e-12

*COMMON MODE INJECTION
*MAKE THIS 1e6 TO TURN OFF,  1e-3 TO TURN ON
.param R_COMMON_MODE_NOISE_LINK=1e-3

endmodule

// expanding   symbol:  wrapped_counter.sym # of pins=9
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/wrapper_squared/wrapped_counter.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/wrapper_squared/wrapped_counter.sch
module wrapped_counter
(
  inout wire vccd1,
  input wire wb_clk_i,
  output wire [37:0] io_out,
  input wire [37:0] io_in,
  output wire [37:0] io_oeb,
  input wire active,
  input wire [7:0] chip_pin_output_bit,
  inout wire vssd1,
  input wire clk_blip
);
endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/analog_mux/analog_mux.sym # of pins=8
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/analog_mux/analog_mux.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/analog_mux/analog_mux.sch
module analog_mux
(
  inout wire A,
  inout wire X,
  inout wire B,
  inout wire vdd,
  inout wire vdda,
  inout wire vss,
  inout wire vssa,
  input wire SEL
);
wire ENABLE_HV_buf ;
wire n_ENABLE_H_buf ;
wire ENABLE_HV ;
wire n_ENABLE_HV_buf ;
wire ENABLE_H_buf ;
wire n_ENABLE_HV ;


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M10 ( 
 .D( n_ENABLE_H_buf ),
 .G( SEL ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M11 ( 
 .D( n_ENABLE_H_buf ),
 .G( SEL ),
 .S( vss ),
 .B( vss )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M1 ( 
 .D( ENABLE_H_buf ),
 .G( n_ENABLE_H_buf ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M2 ( 
 .D( ENABLE_H_buf ),
 .G( n_ENABLE_H_buf ),
 .S( vss ),
 .B( vss )
);


pfet_g5v0d10v5
#(
.L ( 0.5 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_g5v0d10v5 ) ,
.spiceprefix ( X )
)
M4 ( 
 .D( n_ENABLE_HV ),
 .G( ENABLE_HV ),
 .S( vdda ),
 .B( vdda )
);


nfet_g5v0d10v5
#(
.L ( 0.5 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_g5v0d10v5 ) ,
.spiceprefix ( X )
)
M5 ( 
 .D( n_ENABLE_HV ),
 .G( ENABLE_H_buf ),
 .S( vssa ),
 .B( vss )
);


pfet_g5v0d10v5
#(
.L ( 0.5 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_g5v0d10v5 ) ,
.spiceprefix ( X )
)
M6 ( 
 .D( ENABLE_HV ),
 .G( n_ENABLE_HV ),
 .S( vdda ),
 .B( vdda )
);


nfet_g5v0d10v5
#(
.L ( 0.5 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_g5v0d10v5 ) ,
.spiceprefix ( X )
)
M7 ( 
 .D( ENABLE_HV ),
 .G( n_ENABLE_H_buf ),
 .S( vssa ),
 .B( vss )
);


pfet_g5v0d10v5
#(
.L ( 0.5 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_g5v0d10v5 ) ,
.spiceprefix ( X )
)
M8 ( 
 .D( n_ENABLE_HV_buf ),
 .G( ENABLE_HV ),
 .S( vdda ),
 .B( vdda )
);


nfet_g5v0d10v5
#(
.L ( 0.5 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_g5v0d10v5 ) ,
.spiceprefix ( X )
)
M9 ( 
 .D( n_ENABLE_HV_buf ),
 .G( ENABLE_HV ),
 .S( vssa ),
 .B( vss )
);


pfet_g5v0d10v5
#(
.L ( 0.5 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_g5v0d10v5 ) ,
.spiceprefix ( X )
)
M12 ( 
 .D( ENABLE_HV_buf ),
 .G( n_ENABLE_HV ),
 .S( vdda ),
 .B( vdda )
);


nfet_g5v0d10v5
#(
.L ( 0.5 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_g5v0d10v5 ) ,
.spiceprefix ( X )
)
M13 ( 
 .D( ENABLE_HV_buf ),
 .G( n_ENABLE_HV ),
 .S( vssa ),
 .B( vss )
);


pfet_g5v0d10v5
#(
.L ( 0.5 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 200 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_g5v0d10v5 ) ,
.spiceprefix ( X )
)
M3 ( 
 .D( X ),
 .G( n_ENABLE_HV_buf ),
 .S( B ),
 .B( vdda )
);


nfet_g5v0d10v5
#(
.L ( 0.5 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 100 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_g5v0d10v5 ) ,
.spiceprefix ( X )
)
M14 ( 
 .D( X ),
 .G( ENABLE_HV_buf ),
 .S( B ),
 .B( vss )
);


pfet_g5v0d10v5
#(
.L ( 0.5 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 200 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_g5v0d10v5 ) ,
.spiceprefix ( X )
)
M15 ( 
 .D( X ),
 .G( ENABLE_HV_buf ),
 .S( A ),
 .B( vdda )
);


nfet_g5v0d10v5
#(
.L ( 0.5 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 100 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_g5v0d10v5 ) ,
.spiceprefix ( X )
)
M16 ( 
 .D( X ),
 .G( n_ENABLE_HV_buf ),
 .S( A ),
 .B( vss )
);

endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/adc_simple_single_slope/pwm_v1.sym # of pins=7
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/adc_simple_single_slope/pwm_v1.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/adc_simple_single_slope/pwm_v1.sch
module pwm_v1
(
  inout wire vdd,
  inout wire vss,
  input wire adc_in,
  output wire out,
  input wire diode,
  input wire cascref,
  input wire SAMPLE
);
wire n_out ;
wire slope ;
wire net1 ;
wire net2 ;
wire net3 ;
wire net4 ;
wire net5 ;
wire n_SAMPLE ;


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M1 ( 
 .D( n_out ),
 .G( slope ),
 .S( net1 ),
 .B( vss )
);


pfet_01v8
#(
.L ( 1 ) ,
.W ( 2 ) ,
.nf ( 1 ) ,
.mult ( 5 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M2 ( 
 .D( net2 ),
 .G( diode ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 2 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M3 ( 
 .D( slope ),
 .G( SAMPLE ),
 .S( net3 ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 2 ) ,
.nf ( 1 ) ,
.mult ( 5 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M4 ( 
 .D( net3 ),
 .G( cascref ),
 .S( net2 ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 1 ) ,
.W ( 2 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M7 ( 
 .D( net4 ),
 .G( diode ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 2 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M8 ( 
 .D( n_out ),
 .G( cascref ),
 .S( net4 ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M9 ( 
 .D( n_out ),
 .G( n_SAMPLE ),
 .S( vdd ),
 .B( vdd )
);


inv_P8u_N3u
x1 ( 
 .a( SAMPLE ),
 .out( n_SAMPLE ),
 .vdd( vdd ),
 .vss( vss )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M10 ( 
 .D( out ),
 .G( n_out ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 1 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M11 ( 
 .D( out ),
 .G( n_out ),
 .S( vss ),
 .B( vss )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 100 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M12 ( 
 .D( net1 ),
 .G( net1 ),
 .S( vss ),
 .B( vss )
);


nfet_01v8_lvt
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 4 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8_lvt ) ,
.spiceprefix ( X )
)
M13 ( 
 .D( slope ),
 .G( SAMPLE ),
 .S( adc_in ),
 .B( vss )
);


cap_0p2pF_series_0p4pF_active_ACCUMULATION
x2 ( 
 .vdd( vdd ),
 .n_SAMPLE( n_SAMPLE ),
 .cap_left( slope ),
 .cap_right( vss ),
 .psubs( net5 )
);

endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/adc_simple_single_slope/pwm_v2.sym # of pins=7
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/adc_simple_single_slope/pwm_v2.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/adc_simple_single_slope/pwm_v2.sch
module pwm_v2
(
  inout wire vdd,
  inout wire vss,
  input wire adc_in,
  output wire out,
  input wire diode,
  input wire cascref,
  input wire SAMPLE
);
wire n_out ;
wire slope ;
wire net1 ;
wire net2 ;
wire net3 ;
wire net4 ;
wire net5 ;
wire n_SAMPLE ;


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M1 ( 
 .D( n_out ),
 .G( slope ),
 .S( net1 ),
 .B( vss )
);


pfet_01v8
#(
.L ( 1 ) ,
.W ( 2 ) ,
.nf ( 1 ) ,
.mult ( 5 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M2 ( 
 .D( net2 ),
 .G( diode ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 2 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M3 ( 
 .D( slope ),
 .G( SAMPLE ),
 .S( net3 ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 2 ) ,
.nf ( 1 ) ,
.mult ( 5 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M4 ( 
 .D( net3 ),
 .G( cascref ),
 .S( net2 ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 1 ) ,
.W ( 2 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M7 ( 
 .D( net4 ),
 .G( diode ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 2 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M8 ( 
 .D( n_out ),
 .G( cascref ),
 .S( net4 ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M9 ( 
 .D( n_out ),
 .G( n_SAMPLE ),
 .S( vdd ),
 .B( vdd )
);


inv_P8u_N3u
x1 ( 
 .a( SAMPLE ),
 .out( n_SAMPLE ),
 .vdd( vdd ),
 .vss( vss )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M10 ( 
 .D( out ),
 .G( n_out ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 1 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M11 ( 
 .D( out ),
 .G( n_out ),
 .S( vss ),
 .B( vss )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 100 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M12 ( 
 .D( net1 ),
 .G( net1 ),
 .S( vss ),
 .B( vss )
);


nfet_01v8_lvt
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 4 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8_lvt ) ,
.spiceprefix ( X )
)
M13 ( 
 .D( slope ),
 .G( SAMPLE ),
 .S( adc_in ),
 .B( vss )
);


cap_0p2pF_series_0p4pF_active_ENHANCEMENT
x2 ( 
 .vdd( vdd ),
 .n_SAMPLE( n_SAMPLE ),
 .cap_left( slope ),
 .cap_right( vss ),
 .psubs( net5 )
);

endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/isomesh_1pin_ISOLATED_2022/crosstalk_glitch_transmitter.sym # of pins=5
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/isomesh_1pin_ISOLATED_2022/crosstalk_glitch_transmitter.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/isomesh_1pin_ISOLATED_2022/crosstalk_glitch_transmitter.sch
module crosstalk_glitch_transmitter
(
  inout wire vdd,
  inout wire TXRX_A_NEG,
  input wire in,
  inout wire TXRX_A_POS,
  inout wire vss
);
wire ngp ;
wire out ;
wire pgp ;


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1000 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M34 ( 
 .D( TXRX_A_POS ),
 .G( pgp ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 50 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M1 ( 
 .D( pgp ),
 .G( out ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8_lvt
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 300 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8_lvt ) ,
.spiceprefix ( X )
)
M5 ( 
 .D( TXRX_A_NEG ),
 .G( ngp ),
 .S( vss ),
 .B( vss )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 50 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M2 ( 
 .D( ngp ),
 .G( pgp ),
 .S( vss ),
 .B( vss )
);

tran  R3 ( out ,  ngp );

nfet_01v8_lvt
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 400 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8_lvt ) ,
.spiceprefix ( X )
)
M7 ( 
 .D( pgp ),
 .G( out ),
 .S( vss ),
 .B( vss )
);


buffer_amplifier_chain_self_resetting_oneshot_fast_positive_edge
x2 ( 
 .vdd_fly( vdd ),
 .in( in ),
 .out( out ),
 .vss_fly( vss )
);

endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/isomesh_1pin_ISOLATED_2022/crosstalk_glitch_detector.sym # of pins=5
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/isomesh_1pin_ISOLATED_2022/crosstalk_glitch_detector.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/isomesh_1pin_ISOLATED_2022/crosstalk_glitch_detector.sch
module crosstalk_glitch_detector
(
  inout wire vdd,
  output wire blip_RX,
  inout wire TXRX_B_POS,
  inout wire TXRX_B_NEG,
  inout wire vss
);
wire bias1 ;
wire TXRX_B_POS_via_R ;
wire vdd_rc ;
wire tap2 ;
wire tap3 ;
wire tap4 ;
wire det_final ;
wire net1 ;
wire gate ;
wire n_det_final ;
wire n_det ;
wire det_final_pre ;


nfet_01v8_lvt
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8_lvt ) ,
.spiceprefix ( X )
)
M4 ( 
 .D( n_det ),
 .G( gate ),
 .S( TXRX_B_POS_via_R ),
 .B( TXRX_B_POS_via_R )
);

tran  R6 ( gate ,  bias1 );

pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M6 ( 
 .D( det_final_pre ),
 .G( n_det ),
 .S( vdd ),
 .B( vdd )
);

tran  R12 ( det_final_pre ,  vss );

pfet_01v8
#(
.L ( 1 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M8 ( 
 .D( net1 ),
 .G( vss ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M9 ( 
 .D( det_final ),
 .G( net1 ),
 .S( vss ),
 .B( vss )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M10 ( 
 .D( det_final ),
 .G( net1 ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8_lvt
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 0.5 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8_lvt ) ,
.spiceprefix ( X )
)
M11 ( 
 .D( net1 ),
 .G( det_final_pre ),
 .S( vss ),
 .B( vss )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M3 ( 
 .D( n_det_final ),
 .G( det_final ),
 .S( vss ),
 .B( vss )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M12 ( 
 .D( n_det_final ),
 .G( det_final ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 3 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M13 ( 
 .D( n_det ),
 .G( vss ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8_lvt
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8_lvt ) ,
.spiceprefix ( X )
)
M14 ( 
 .D( bias1 ),
 .G( bias1 ),
 .S( TXRX_B_POS_via_R ),
 .B( TXRX_B_POS_via_R )
);


nfet_01v8_lvt
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8_lvt ) ,
.spiceprefix ( X )
)
M15 ( 
 .D( tap2 ),
 .G( tap2 ),
 .S( bias1 ),
 .B( TXRX_B_POS_via_R )
);


nfet_01v8_lvt
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8_lvt ) ,
.spiceprefix ( X )
)
M16 ( 
 .D( tap3 ),
 .G( tap3 ),
 .S( tap2 ),
 .B( TXRX_B_POS_via_R )
);


nfet_01v8_lvt
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8_lvt ) ,
.spiceprefix ( X )
)
M17 ( 
 .D( tap4 ),
 .G( tap4 ),
 .S( tap3 ),
 .B( TXRX_B_POS_via_R )
);


nfet_01v8_lvt
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8_lvt ) ,
.spiceprefix ( X )
)
M18 ( 
 .D( vdd_rc ),
 .G( vdd_rc ),
 .S( tap4 ),
 .B( TXRX_B_POS_via_R )
);

tran  R9 ( vdd ,  vdd_rc );
tran  R13 ( TXRX_B_POS_via_R ,  TXRX_B_POS );

nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M19 ( 
 .D( blip_RX ),
 .G( n_det_final ),
 .S( vss ),
 .B( vss )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 8 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M20 ( 
 .D( blip_RX ),
 .G( n_det_final ),
 .S( vdd ),
 .B( vdd )
);

endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/gates_simple/nand_P3u_N2u_compact.sym # of pins=5
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/gates_simple/nand_P3u_N2u_compact.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/gates_simple/nand_P3u_N2u_compact.sch
module nand_P3u_N2u_compact
(
  inout wire vdd,
  input wire b,
  input wire a,
  output wire out,
  inout wire vss
);
wire net1 ;


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M4 ( 
 .D( out ),
 .G( b ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M3 ( 
 .D( out ),
 .G( a ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M2 ( 
 .D( out ),
 .G( b ),
 .S( net1 ),
 .B( vss )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M1 ( 
 .D( net1 ),
 .G( a ),
 .S( vss ),
 .B( vss )
);

endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/gates_complex_and_flops/schmitt_ratio_1_to_1.sym # of pins=4
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/gates_complex_and_flops/schmitt_ratio_1_to_1.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/gates_complex_and_flops/schmitt_ratio_1_to_1.sch
module schmitt_ratio_1_to_1
(
  input wire in,
  output wire out,
  inout wire vdd,
  inout wire vss
);
wire ppass ;
wire npass ;
wire schmitt_out ;


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mptop ( 
 .D( ppass ),
 .G( in ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mnmid ( 
 .D( schmitt_out ),
 .G( in ),
 .S( npass ),
 .B( vss )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mpmid ( 
 .D( schmitt_out ),
 .G( in ),
 .S( ppass ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mnbot ( 
 .D( npass ),
 .G( in ),
 .S( vss ),
 .B( vss )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mpfb ( 
 .D( ppass ),
 .G( schmitt_out ),
 .S( vss ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mnfb ( 
 .D( npass ),
 .G( schmitt_out ),
 .S( vdd ),
 .B( vss )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mpinv ( 
 .D( out ),
 .G( schmitt_out ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mninv ( 
 .D( out ),
 .G( schmitt_out ),
 .S( vss ),
 .B( vss )
);

endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/gates_simple/inv_P24u_N10u.sym # of pins=4
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/gates_simple/inv_P24u_N10u.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/gates_simple/inv_P24u_N10u.sch
module inv_P24u_N10u
(
  input wire a,
  output wire out,
  inout wire vdd,
  inout wire vss
);

pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 24 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M2 ( 
 .D( out ),
 .G( a ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M1 ( 
 .D( out ),
 .G( a ),
 .S( vss ),
 .B( vss )
);

endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vdd_vss_interconnect_parasitics_test/vdd_vss_interconnect_parasitics_test_ACTIVE.sym # of pins=5
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vdd_vss_interconnect_parasitics_test/vdd_vss_interconnect_parasitics_test_ACTIVE.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vdd_vss_interconnect_parasitics_test/vdd_vss_interconnect_parasitics_test_ACTIVE.sch
module vdd_vss_interconnect_parasitics_test_ACTIVE
(
  inout wire vdd_inject,
  inout wire vss,
  inout wire vdd_sense,
  inout wire vss_sense,
  input wire enable
);

nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 5 ) ,
.nf ( 1 ) ,
.mult ( 2080 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M1 ( 
 .D( vdd_inject ),
 .G( enable ),
 .S( vss ),
 .B( vss )
);


res_generic_m3
#(
.W ( 12.7 ) ,
.L ( 12 ) ,
.model ( res_generic_m3 ) ,
.mult ( 1 )
)
R1 ( 
 .M( vdd_sense ),
 .P( vdd_inject )
);


res_generic_m3
#(
.W ( 12.7 ) ,
.L ( 12 ) ,
.model ( res_generic_m3 ) ,
.mult ( 1 )
)
R2 ( 
 .M( vss ),
 .P( vss_sense )
);

endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vdd_vss_interconnect_parasitics_test/vdd_vss_interconnect_parasitics_test_PASSIVE.sym # of pins=4
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vdd_vss_interconnect_parasitics_test/vdd_vss_interconnect_parasitics_test_PASSIVE.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vdd_vss_interconnect_parasitics_test/vdd_vss_interconnect_parasitics_test_PASSIVE.sch
module vdd_vss_interconnect_parasitics_test_PASSIVE
(
  inout wire vdd_inject,
  inout wire vss,
  inout wire vdd_sense,
  inout wire vss_sense
);

res_generic_m3
#(
.W ( 12.7 ) ,
.L ( 12 ) ,
.model ( res_generic_m3 ) ,
.mult ( 1 )
)
R1 ( 
 .M( vdd_sense ),
 .P( vdd_inject )
);


res_generic_m3
#(
.W ( 12.7 ) ,
.L ( 12 ) ,
.model ( res_generic_m3 ) ,
.mult ( 1 )
)
R2 ( 
 .M( vdd_inject ),
 .P( vss_sense )
);


res_generic_m4
#(
.W ( 150 ) ,
.L ( 4.43 ) ,
.model ( res_generic_m4 ) ,
.mult ( 1 )
)
R4 ( 
 .M( vss ),
 .P( vdd_inject )
);

endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vref_switched_capactior_divider_bandgap/vref_switched_capactior_divider_bandgap.sym # of pins=5
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vref_switched_capactior_divider_bandgap/vref_switched_capactior_divider_bandgap.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vref_switched_capactior_divider_bandgap/vref_switched_capactior_divider_bandgap.sch
module vref_switched_capactior_divider_bandgap
(
  inout wire vdd,
  inout wire vdd_an,
  output wire vref,
  inout wire vss_an,
  inout wire vss
);
wire q0_early ;
wire ring4_NC ;
wire nq2_late ;
wire nq0 ;
wire nq1 ;
wire nq2 ;
wire nq0_to_nq1 ;
wire q2_late ;
wire ring6_NC ;
wire q0 ;
wire q1 ;
wire q2 ;
wire ve ;
wire ring0 ;
wire ring2 ;
wire ring3 ;
wire ring5 ;
wire ring7 ;
wire ring8 ;
wire switched_cappos ;
wire net1 ;
wire net2 ;
wire net3 ;
wire net4 ;
wire net5 ;
wire net6 ;
wire net7 ;
wire net8 ;
wire ring1_NC ;
wire nq0_early ;
wire vdd_filt ;
wire q0_to_q1 ;
wire samp0 ;
wire samp1 ;


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_1x ( 
 .D( ve ),
 .G( nq0_early ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 6 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_samp_cappos ( 
 .D( switched_cappos ),
 .G( nq0_to_nq1 ),
 .S( vdd_filt ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 3.33 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 292 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_samp0_cap ( 
 .D( samp0 ),
 .G( switched_cappos ),
 .S( samp0 ),
 .B( samp0 )
);


pfet_01v8
#(
.L ( 3.33 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 81 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_samp1_cap ( 
 .D( samp1 ),
 .G( switched_cappos ),
 .S( samp1 ),
 .B( samp1 )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_samp_cappos_COMP ( 
 .D( switched_cappos ),
 .G( q0_to_q1 ),
 .S( switched_cappos ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mn_sampler0 ( 
 .D( ve ),
 .G( q0 ),
 .S( samp0 ),
 .B( vss )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_sampler0 ( 
 .D( ve ),
 .G( nq0 ),
 .S( samp0 ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mn_sampler1 ( 
 .D( ve ),
 .G( q1 ),
 .S( samp1 ),
 .B( vss )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_sampler1 ( 
 .D( ve ),
 .G( nq1 ),
 .S( samp1 ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 3.33 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 48 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_divider_cap ( 
 .D( vss_an ),
 .G( switched_cappos ),
 .S( vss_an ),
 .B( vss_an )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mnsampvref ( 
 .D( samp1 ),
 .G( q2_late ),
 .S( vref ),
 .B( vss )
);


pfet_01v8
#(
.L ( 3.33 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 93 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_cvref_cap ( 
 .D( vss_an ),
 .G( vref ),
 .S( vss_an ),
 .B( vss_an )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mnsampvref_COMP ( 
 .D( vref ),
 .G( nq2_late ),
 .S( vref ),
 .B( vss )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mnsamp0gnd ( 
 .D( samp0 ),
 .G( q2 ),
 .S( vss_an ),
 .B( vss )
);


pfet_01v8
#(
.L ( 2.08 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_vdd_filt_bias1 ( 
 .D( vdd_filt ),
 .G( vss ),
 .S( vdd_an ),
 .B( vdd_an )
);


pfet_01v8
#(
.L ( 3.33 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 120 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_vdd_filt_cap ( 
 .D( vdd_filt ),
 .G( vss_an ),
 .S( vdd_filt ),
 .B( vdd_filt )
);


launcher
h4 ( 
);


launcher
h5 ( 
);


launcher
h6 ( 
);


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_2 ( 
 .D( ve ),
 .G( nq1 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_3 ( 
 .D( ve ),
 .G( nq1 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_4 ( 
 .D( ve ),
 .G( nq1 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_5 ( 
 .D( ve ),
 .G( nq1 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_6 ( 
 .D( ve ),
 .G( nq1 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_7 ( 
 .D( ve ),
 .G( nq1 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_8 ( 
 .D( ve ),
 .G( nq1 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_9 ( 
 .D( ve ),
 .G( nq1 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_10 ( 
 .D( ve ),
 .G( nq1 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_11 ( 
 .D( ve ),
 .G( nq1 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_12 ( 
 .D( ve ),
 .G( nq1 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_13 ( 
 .D( ve ),
 .G( nq1 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_14 ( 
 .D( ve ),
 .G( nq1 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_15 ( 
 .D( ve ),
 .G( nq1 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.83 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mp_bjt_i_16 ( 
 .D( ve ),
 .G( nq1 ),
 .S( vdd ),
 .B( vdd )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q2 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q1 ( 
 .collector( vss ),
 .base( net1 ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q3 ( 
 .collector( vss ),
 .base( net2 ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q4 ( 
 .collector( vss ),
 .base( net3 ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q5 ( 
 .collector( vss ),
 .base( net4 ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q6 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q7 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q8 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q9 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q10 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q11 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q12 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q13 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q14 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q15 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q16 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q17 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q18 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q19 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q20 ( 
 .collector( net5 ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q21 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q22 ( 
 .collector( vss ),
 .base( net6 ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q23 ( 
 .collector( vss ),
 .base( net7 ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q24 ( 
 .collector( vss ),
 .base( net8 ),
 .emitter( ve )
);


pnp_05v5
#(
.model ( pnp_05v5_W0p68L0p68 ) ,
.spiceprefix ( X )
)
Q25 ( 
 .collector( vss ),
 .base( vss_an ),
 .emitter( ve )
);


ringosc9_stage
x14 ( 
 .ring0( ring0 ),
 .ring4( ring4_NC ),
 .ring2( ring2 ),
 .ring3( ring3 ),
 .ring1( ring1_NC ),
 .ring5( ring5 ),
 .ring6( ring6_NC ),
 .ring7( ring7 ),
 .ring8( ring8 ),
 .vdd( vdd ),
 .vss( vss )
);


inv_bg
x4 ( 
 .a( q0_to_q1 ),
 .q( nq0_to_nq1 ),
 .vdd( vdd ),
 .vss( vss )
);


inv_bg
x5 ( 
 .a( q2_late ),
 .q( nq2_late ),
 .vdd( vdd ),
 .vss( vss )
);


inv_bg
x6 ( 
 .a( q2 ),
 .q( nq2 ),
 .vdd( vdd ),
 .vss( vss )
);


inv_bg
x7 ( 
 .a( q1 ),
 .q( nq1 ),
 .vdd( vdd ),
 .vss( vss )
);


inv_bg
x8 ( 
 .a( q0 ),
 .q( nq0 ),
 .vdd( vdd ),
 .vss( vss )
);


inv_bg
x9 ( 
 .a( q0_early ),
 .q( nq0_early ),
 .vdd( vdd ),
 .vss( vss )
);


nor_bg
x10 ( 
 .vdd( vdd ),
 .b( ring8 ),
 .a( ring5 ),
 .q( q2_late ),
 .vss( vss )
);


nor_bg
x11 ( 
 .vdd( vdd ),
 .b( ring8 ),
 .a( ring3 ),
 .q( q2 ),
 .vss( vss )
);


nor_bg
x12 ( 
 .vdd( vdd ),
 .b( ring7 ),
 .a( ring0 ),
 .q( q0 ),
 .vss( vss )
);


nor_bg
x13 ( 
 .vdd( vdd ),
 .b( ring2 ),
 .a( ring8 ),
 .q( q1 ),
 .vss( vss )
);


inv_bg
x15 ( 
 .a( ring7 ),
 .q( q0_early ),
 .vdd( vdd ),
 .vss( vss )
);


nand_bg
x1 ( 
 .vdd( vdd ),
 .b( ring2 ),
 .a( ring0 ),
 .q( q0_to_q1 ),
 .vss( vss )
);

endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/gates_simple/inv_P8u_N3u.sym # of pins=4
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/gates_simple/inv_P8u_N3u.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/gates_simple/inv_P8u_N3u.sch
module inv_P8u_N3u
(
  input wire a,
  output wire out,
  inout wire vdd,
  inout wire vss
);

pfet_01v8
#(
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 8 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M2 ( 
 .D( out ),
 .G( a ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M1 ( 
 .D( out ),
 .G( a ),
 .S( vss ),
 .B( vss )
);

endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/capacitors/cap_0p2pF_series_0p4pF_active_ACCUMULATION.sym # of pins=5
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/capacitors/cap_0p2pF_series_0p4pF_active_ACCUMULATION.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/capacitors/cap_0p2pF_series_0p4pF_active_ACCUMULATION.sch
module cap_0p2pF_series_0p4pF_active_ACCUMULATION
(
  inout wire vdd,
  input wire n_SAMPLE,
  inout wire cap_left,
  inout wire cap_right,
  inout wire psubs
);
wire psubs_NC1 ;
wire psubs_NC2 ;
wire capcom ;


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mptiny ( 
 .D( vdd ),
 .G( n_SAMPLE ),
 .S( capcom ),
 .B( capcom )
);


cap_0p4pF_pmos_ACCUMULATION
x1 ( 
 .neg( cap_left ),
 .pos( capcom ),
 .psubs( psubs_NC1 )
);


cap_0p4pF_pmos_ACCUMULATION
x2 ( 
 .neg( cap_right ),
 .pos( capcom ),
 .psubs( psubs_NC2 )
);

endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/capacitors/cap_0p2pF_series_0p4pF_active_ENHANCEMENT.sym # of pins=5
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/capacitors/cap_0p2pF_series_0p4pF_active_ENHANCEMENT.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/capacitors/cap_0p2pF_series_0p4pF_active_ENHANCEMENT.sch
module cap_0p2pF_series_0p4pF_active_ENHANCEMENT
(
  inout wire vdd,
  input wire n_SAMPLE,
  inout wire cap_left,
  inout wire cap_right,
  inout wire psubs
);
wire psubs_NC1 ;
wire psubs_NC2 ;
wire capcom ;


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mptiny ( 
 .D( vdd ),
 .G( n_SAMPLE ),
 .S( capcom ),
 .B( capcom )
);


cap_0p4pF_pmos_ENHANCEMENT
x1 ( 
 .neg( cap_left ),
 .pos( capcom ),
 .psubs( psubs_NC1 )
);


cap_0p4pF_pmos_ENHANCEMENT
x2 ( 
 .neg( cap_right ),
 .pos( capcom ),
 .psubs( psubs_NC2 )
);

endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/isomesh_1pin_ISOLATED_2022/buffer_amplifier_chain_self_resetting_oneshot_fast_positive_edge.sym # of pins=4
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/isomesh_1pin_ISOLATED_2022/buffer_amplifier_chain_self_resetting_oneshot_fast_positive_edge.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/isomesh_1pin_ISOLATED_2022/buffer_amplifier_chain_self_resetting_oneshot_fast_positive_edge.sch
module buffer_amplifier_chain_self_resetting_oneshot_fast_positive_edge
(
  inout wire vdd_fly,
  input wire in,
  output wire out,
  inout wire vss_fly
);
wire Rstage10 ;
wire stage10 ;
wire stage11 ;
wire stage12 ;
wire stage13 ;
wire stage14 ;
wire net1 ;
wire net2 ;
wire net3 ;
wire net4 ;
wire stage0 ;
wire stage1 ;
wire stage2 ;
wire stage3 ;
wire stage4 ;
wire stage5 ;
wire stage6 ;
wire stage7 ;
wire stage8 ;
wire stage9 ;
wire enable_negoutput ;


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 400 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M9 ( 
 .D( stage9 ),
 .G( stage8 ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 800 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M10 ( 
 .D( out ),
 .G( stage9 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M21 ( 
 .D( stage9 ),
 .G( stage8 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 5 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M13 ( 
 .D( out ),
 .G( stage9 ),
 .S( vss_fly ),
 .B( vss_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 5 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M15 ( 
 .D( stage8 ),
 .G( stage7 ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 400 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M16 ( 
 .D( stage8 ),
 .G( stage7 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M17 ( 
 .D( stage7 ),
 .G( stage6 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 200 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M18 ( 
 .D( stage7 ),
 .G( stage6 ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 200 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M19 ( 
 .D( stage6 ),
 .G( stage5 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 5 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M20 ( 
 .D( stage6 ),
 .G( stage5 ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 5 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M22 ( 
 .D( stage5 ),
 .G( stage4 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 100 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M23 ( 
 .D( stage5 ),
 .G( stage4 ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 100 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M24 ( 
 .D( stage4 ),
 .G( stage3 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M25 ( 
 .D( stage4 ),
 .G( stage3 ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M6 ( 
 .D( stage3 ),
 .G( stage2 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 40 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M7 ( 
 .D( stage3 ),
 .G( stage2 ),
 .S( vss_fly ),
 .B( vss_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 30 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M14 ( 
 .D( stage2 ),
 .G( stage6 ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 40 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M26 ( 
 .D( stage2 ),
 .G( stage1 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M27 ( 
 .D( stage2 ),
 .G( stage1 ),
 .S( vss_fly ),
 .B( vss_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 15 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M28 ( 
 .D( stage0 ),
 .G( stage4 ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M29 ( 
 .D( stage1 ),
 .G( stage0 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 15 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M30 ( 
 .D( stage1 ),
 .G( stage0 ),
 .S( vss_fly ),
 .B( vss_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 40 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M31 ( 
 .D( stage4 ),
 .G( stage8 ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 30 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M32 ( 
 .D( stage1 ),
 .G( stage5 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 60 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M33 ( 
 .D( stage6 ),
 .G( Rstage10 ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 50 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M34 ( 
 .D( stage3 ),
 .G( stage7 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 80 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M1 ( 
 .D( stage8 ),
 .G( stage12 ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 80 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M2 ( 
 .D( stage5 ),
 .G( stage9 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 120 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M3 ( 
 .D( stage7 ),
 .G( stage11 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 200 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M4 ( 
 .D( stage9 ),
 .G( stage13 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M8 ( 
 .D( stage0 ),
 .G( net2 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M11 ( 
 .D( stage0 ),
 .G( net2 ),
 .S( vss_fly ),
 .B( vss_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 120 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M12 ( 
 .D( out ),
 .G( stage14 ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 8 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M5 ( 
 .D( net2 ),
 .G( net3 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M35 ( 
 .D( net2 ),
 .G( net3 ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 6 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M36 ( 
 .D( net3 ),
 .G( net4 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M37 ( 
 .D( net3 ),
 .G( net4 ),
 .S( vss_fly ),
 .B( vss_fly )
);


nand_P3u_N2u_compact_DEEPNWELL
x1 ( 
 .vdd( vdd_fly ),
 .b( in ),
 .a( enable_negoutput ),
 .out( net4 ),
 .vss( vss_fly )
);


nand_P3u_N2u_compact_DEEPNWELL
x4 ( 
 .vdd( vdd_fly ),
 .b( in ),
 .a( net1 ),
 .out( enable_negoutput ),
 .vss( vss_fly )
);


nand_P3u_N2u_compact_DEEPNWELL
x5 ( 
 .vdd( vdd_fly ),
 .b( enable_negoutput ),
 .a( net2 ),
 .out( net1 ),
 .vss( vss_fly )
);


res_generic_m1
#(
.L ( 1 ) ,
.model ( res_generic_m1 ) ,
.mult ( 1 )
)
R13 ( 
 .M( stage10 ),
 .P( out )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 30 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M38 ( 
 .D( stage11 ),
 .G( out ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 10 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M39 ( 
 .D( stage11 ),
 .G( out ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 40 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M40 ( 
 .D( stage12 ),
 .G( stage11 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 15 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M41 ( 
 .D( stage12 ),
 .G( stage11 ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 60 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M42 ( 
 .D( stage13 ),
 .G( stage12 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 20 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M43 ( 
 .D( stage13 ),
 .G( stage12 ),
 .S( vss_fly ),
 .B( vss_fly )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 81 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M44 ( 
 .D( stage14 ),
 .G( stage13 ),
 .S( vdd_fly ),
 .B( vdd_fly )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 40 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M45 ( 
 .D( stage14 ),
 .G( stage13 ),
 .S( vss_fly ),
 .B( vss_fly )
);

tran  R1 ( Rstage10 ,  stage10 );
endmodule

// expanding   symbol:  ../vref_switched_capactior_divider_bandgap/ringosc9_stage.sym # of pins=11
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vref_switched_capactior_divider_bandgap/ringosc9_stage.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vref_switched_capactior_divider_bandgap/ringosc9_stage.sch
module ringosc9_stage
(
  output wire ring0,
  output wire ring4,
  output wire ring2,
  output wire ring3,
  output wire ring1,
  output wire ring5,
  output wire ring6,
  output wire ring7,
  output wire ring8,
  inout wire vdd,
  inout wire vss
);

pfet_01v8
#(
.L ( 8.33 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mpring0 ( 
 .D( ring0 ),
 .G( ring8 ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 8.33 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mnring0 ( 
 .D( ring0 ),
 .G( ring8 ),
 .S( vss ),
 .B( vss )
);


pfet_01v8
#(
.L ( 4.17 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mpring1 ( 
 .D( ring1 ),
 .G( ring0 ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 4.17 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mnring1 ( 
 .D( ring1 ),
 .G( ring0 ),
 .S( vss ),
 .B( vss )
);


pfet_01v8
#(
.L ( 4.17 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mpring2 ( 
 .D( ring2 ),
 .G( ring1 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 8.33 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mpring3 ( 
 .D( ring3 ),
 .G( ring2 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 8.33 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mpring4 ( 
 .D( ring4 ),
 .G( ring3 ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 4.17 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mnring2 ( 
 .D( ring2 ),
 .G( ring1 ),
 .S( vss ),
 .B( vss )
);


nfet_01v8
#(
.L ( 8.33 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mnring3 ( 
 .D( ring3 ),
 .G( ring2 ),
 .S( vss ),
 .B( vss )
);


nfet_01v8
#(
.L ( 8.33 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mnring4 ( 
 .D( ring4 ),
 .G( ring3 ),
 .S( vss ),
 .B( vss )
);


pfet_01v8
#(
.L ( 8.33 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mpring5 ( 
 .D( ring5 ),
 .G( ring4 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 8.33 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mpring6 ( 
 .D( ring6 ),
 .G( ring5 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 8.33 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mpring7 ( 
 .D( ring7 ),
 .G( ring6 ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 8.33 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mpring8 ( 
 .D( ring8 ),
 .G( ring7 ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 8.33 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mnring5 ( 
 .D( ring5 ),
 .G( ring4 ),
 .S( vss ),
 .B( vss )
);


nfet_01v8
#(
.L ( 8.33 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mnring6 ( 
 .D( ring6 ),
 .G( ring5 ),
 .S( vss ),
 .B( vss )
);


nfet_01v8
#(
.L ( 8.33 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mnring7 ( 
 .D( ring7 ),
 .G( ring6 ),
 .S( vss ),
 .B( vss )
);


nfet_01v8
#(
.L ( 8.33 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
mnring8 ( 
 .D( ring8 ),
 .G( ring7 ),
 .S( vss ),
 .B( vss )
);

endmodule

// expanding   symbol:  inv_bg.sym # of pins=4
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vref_switched_capactior_divider_bandgap/inv_bg.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vref_switched_capactior_divider_bandgap/inv_bg.sch
module inv_bg
(
  input wire a,
  output wire q,
  inout wire vdd,
  inout wire vss
);

pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M2 ( 
 .D( q ),
 .G( a ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M1 ( 
 .D( q ),
 .G( a ),
 .S( vss ),
 .B( vss )
);

endmodule

// expanding   symbol:  nor_bg.sym # of pins=5
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vref_switched_capactior_divider_bandgap/nor_bg.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vref_switched_capactior_divider_bandgap/nor_bg.sch
module nor_bg
(
  inout wire vdd,
  input wire b,
  input wire a,
  output wire q,
  inout wire vss
);
wire net1 ;


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M4 ( 
 .D( net1 ),
 .G( a ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M3 ( 
 .D( q ),
 .G( b ),
 .S( net1 ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M2 ( 
 .D( q ),
 .G( a ),
 .S( vss ),
 .B( vss )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M1 ( 
 .D( q ),
 .G( b ),
 .S( vss ),
 .B( vss )
);

endmodule

// expanding   symbol:  nand_bg.sym # of pins=5
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vref_switched_capactior_divider_bandgap/nand_bg.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/vref_switched_capactior_divider_bandgap/nand_bg.sch
module nand_bg
(
  inout wire vdd,
  input wire b,
  input wire a,
  output wire q,
  inout wire vss
);
wire net1 ;


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M4 ( 
 .D( q ),
 .G( b ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M3 ( 
 .D( q ),
 .G( a ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M2 ( 
 .D( q ),
 .G( b ),
 .S( net1 ),
 .B( vss )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 0.5 ) ,
.nf ( 1 ) ,
.mult ( 1 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M1 ( 
 .D( net1 ),
 .G( a ),
 .S( vss ),
 .B( vss )
);

endmodule

// expanding   symbol:  ../capacitors/cap_0p4pF_pmos_ACCUMULATION.sym # of pins=3
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/capacitors/cap_0p4pF_pmos_ACCUMULATION.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/capacitors/cap_0p4pF_pmos_ACCUMULATION.sch
module cap_0p4pF_pmos_ACCUMULATION
(
  inout wire neg,
  inout wire pos,
  inout wire psubs
);

pfet_01v8
#(
.L ( 2.08 ) ,
.W ( 4.6 ) ,
.nf ( 1 ) ,
.mult ( 5 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mpcap1 ( 
 .D( neg ),
 .G( pos ),
 .S( neg ),
 .B( neg )
);

endmodule

// expanding   symbol:  cap_0p4pF_pmos_ENHANCEMENT.sym # of pins=3
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/capacitors/cap_0p4pF_pmos_ENHANCEMENT.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/capacitors/cap_0p4pF_pmos_ENHANCEMENT.sch
module cap_0p4pF_pmos_ENHANCEMENT
(
  inout wire neg,
  inout wire pos,
  inout wire psubs
);

pfet_01v8
#(
.L ( 2.08 ) ,
.W ( 4.6 ) ,
.nf ( 1 ) ,
.mult ( 5 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
mpcap1 ( 
 .D( pos ),
 .G( neg ),
 .S( pos ),
 .B( pos )
);

endmodule

// expanding   symbol:  /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/gates_simple/nand_P3u_N2u_compact_DEEPNWELL.sym # of pins=5
// sym_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/gates_simple/nand_P3u_N2u_compact_DEEPNWELL.sym
// sch_path: /root/isolator_transformer/driver_ic_v3_skywater_0u13_RISC-V/spice_experimental_2022/gates_simple/nand_P3u_N2u_compact_DEEPNWELL.sch
module nand_P3u_N2u_compact_DEEPNWELL
(
  inout wire vdd,
  input wire b,
  input wire a,
  output wire out,
  inout wire vss
);
wire net1 ;


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M4 ( 
 .D( out ),
 .G( b ),
 .S( vdd ),
 .B( vdd )
);


pfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 3 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( pfet_01v8 ) ,
.spiceprefix ( X )
)
M3 ( 
 .D( out ),
 .G( a ),
 .S( vdd ),
 .B( vdd )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M2 ( 
 .D( out ),
 .G( b ),
 .S( net1 ),
 .B( vss )
);


nfet_01v8
#(
.L ( 0.15 ) ,
.W ( 1 ) ,
.nf ( 1 ) ,
.mult ( 2 ) ,
.ad ( "'int((nf+1)/2) ) ,
.pd ( "'2*int((nf+1)/2) ) ,
.as ( "'int((nf+2)/2) ) ,
.ps ( "'2*int((nf+2)/2) ) ,
.nrd ( "'0.29 ) ,
.nrs ( "'0.29 ) ,
.sa ( 0 ) ,
.sb ( 0 ) ,
.sd ( 0 ) ,
.model ( nfet_01v8 ) ,
.spiceprefix ( X )
)
M1 ( 
 .D( net1 ),
 .G( a ),
 .S( vss ),
 .B( vss )
);

endmodule
