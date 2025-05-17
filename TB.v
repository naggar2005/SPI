module TB();

parameter reg_width = 32;

reg rst , clk , start;
reg [reg_width - 1 : 0] d_in_Master , d_in_Slave_0 ,  d_in_Slave_1 ,  d_in_Slave_2 ,  d_in_Slave_3;
reg [4:0] in_addr;

wire [reg_width - 1 : 0] d_out_Master , d_out_Slave;
wire done_master , done_slave , ready , busy;

    TopModule #(reg_width) DUT(d_in_Master , d_in_Slave_0 ,  d_in_Slave_1 ,  d_in_Slave_2 ,  d_in_Slave_3 , start , clk , rst , in_addr
                             ,d_out_Master , d_out_Slave , done_master , done_slave , busy , ready);

                    //clock generation
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

            //monitoring 
    initial begin
        $monitor("clk = %b , reset = %b , data_in_master = %h , data_out_slave = %h , data_in_slave = %h , data_out_master = %h"
                , clk , rst , d_in_Master , d_out_Slave , d_in_Slave_2 , d_out_Master);         //we will activate slave_2
    end 

            //test cases generation
    initial begin
        rst = 1;
        d_in_Master = 'ha800_0545;
        d_in_Slave_0 =  'ha800_0969;
        d_in_Slave_1 =  'ha800_0676;
        d_in_Slave_2 =  'ha800_0787;
        d_in_Slave_3 =  'ha800_0191;
        start = 1;
                    //test start signal;
            @(negedge clk);
        rst = 0;
        start = 0;
        in_addr = 5'b100_10;        //d_out_master = 'ha800_0787
            @(negedge clk);
        start = 1;
            @(negedge clk); 
        start = 0;
        repeat(75)
            @(negedge clk);
            //*************************************************//
        start = 0;
        d_in_Master = 'ha800_0454;  //d_out_slave = 'ha800_0454
        in_addr = 5'b100_11;       //d_out_master = 'ha800_0191
            @(negedge clk);
        start = 1;
            @(negedge clk);
        start = 0;
        repeat(75)
            @(negedge clk);

        $display ("finished!!!  data_out_master = %h , data_out_slave = %h",
                 d_out_Master , d_out_Slave);
                 $stop;
    end        

endmodule