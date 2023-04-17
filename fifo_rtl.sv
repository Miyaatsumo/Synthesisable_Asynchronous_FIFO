//`timescale 1ns/1ps
module fifo_rtl #(parameter WIDTH= 8,ADDR= 5,DEPTH=16)
    (
        input  logic [WIDTH-1:0]data_in,
        input  logic w_in,
        input  logic r_in,
        input  logic w_clk,
        input  logic r_clk,
        input  logic w_rst,
        input  logic r_rst,
        output logic w_full,
        output logic r_empty,
        output logic [WIDTH-1:0]data_out
);
    logic [ADDR-1:0]w_ptr,r_ptr,bin,bin1,gray1,gray,bin_next1,bin_next,wq2_ptr,rq2_ptr;
    logic [ADDR-2:0]w_addr,r_addr;
    logic [ADDR-1:0]temp,temp1;// used for intermediate signal of write and read synchronizer
    logic [WIDTH-1:0]mem[DEPTH-1:0];
    logic full,empty;

    generate
        begin

    //Write Pointer
    assign w_addr   = bin[ADDR-2:0];
    assign bin_next = (w_in & !w_full)?(bin+'b1):bin;
    assign gray     = (bin_next>>'b1) ^ bin_next;

    always_ff@(posedge w_clk)
    begin
        if(!w_rst)
        begin
            w_ptr    <= 'b0;
            bin      <= 'b0;
            w_full   <= 'b0;
            wq2_ptr  <= 'b0;
            temp     <= 'b0;
            mem      <= '{default:'b0};

        end
        else
        begin
            bin             <= bin_next;
            w_ptr           <= gray;
            w_full          <= full;
            {wq2_ptr,temp}  <= {temp,r_ptr};
           // mem[w_addr]    <= (w_in==1)?data_in:'bx;
            if(w_in && !w_full)
                mem[w_addr] <= data_in;
        end
    end
        end
    endgenerate

    //full conidition
    assign full             = {~wq2_ptr[ADDR-1:ADDR-2],wq2_ptr[ADDR-3:0]}==gray;

     generate
         begin


    //Read Pointer
    assign r_addr          = bin1[ADDR-2:0];
    assign bin_next1       = (r_in & !r_empty)?(bin1+'b1):bin1;
    assign gray1           = (bin_next1>>1)^bin_next1;
    
    always_ff@(posedge r_clk)
    begin
        if(!r_rst)
        begin
            r_ptr         <= 'b0;
            bin1          <= 'b0;
            r_empty       <= 'b0;
            rq2_ptr       <= 'b0;
            temp1         <= 'b0;
        end
        else
        begin
            bin1            <= bin_next1;
            r_ptr           <= gray1;
            {rq2_ptr,temp1} <= {temp1,w_ptr};
            r_empty         <= empty;
            if(r_in && !r_empty)
            begin
                data_out    <= mem[r_addr];
                //mem[r_addr] <= 'b0;
            end
        //    data_out        <= (r_in && !r_empty)?mem[r_addr]:'bx;
        end
    end
         end
     endgenerate
     
    //Empty condition
    assign empty             = (rq2_ptr==gray1);
        
endmodule    
