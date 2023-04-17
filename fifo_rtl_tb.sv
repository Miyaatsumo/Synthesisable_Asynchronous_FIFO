//`timescale 1ns/1ps
module fifo_rtl_tb;
    parameter WIDTH='d8;
    logic [WIDTH-1:0]data_in;
    logic w_in;
    logic r_in;
    logic w_clk;
    logic r_clk;
    logic w_rst;
    logic r_rst;
    logic w_full;
    logic r_empty;
    logic [WIDTH-1:0]data_out;

    fifo_rtl DUT(data_in,w_in,r_in,w_clk,r_clk,w_rst,r_rst,w_full,r_empty,data_out);

    //Write Clock
    initial
    begin:Fast_Clock
        w_clk=0;
        forever #5 w_clk=~w_clk;
    end

    //Read Clock
    initial
    begin:Slow_Clock
        r_clk=0;
        forever #10 r_clk=~r_clk;
    end

    //Data Generation
    initial
    begin
        w_rst=0; r_rst=0;
        #15 w_rst=1;r_rst=1;w_in=1;r_in=0;
        repeat(16)
        begin
            data_in=$random;
            #10;
        end
        r_in='b1;
        w_in='b0;

        #600;
        w_in='b1;
        data_in=$random;
        #100 $finish;
    end
endmodule

