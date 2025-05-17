module SPI_slave(d_in_slave , MOSI , s_clk , ss_n , clk , rst , load , busy
                ,d_out_slave, MISO , done_slave , ready);
parameter reg_width = 32;

input ss_n , s_clk , clk , rst;
input MOSI , load , busy;
input [reg_width - 1:0] d_in_slave;

output reg done_slave ;//, ready;
output reg MISO ;
output reg [reg_width - 1:0] d_out_slave;
output ready;

reg [reg_width - 1:0] shift_reg;
reg [$clog2(reg_width):0] bit_cnt;

    always @(posedge clk , posedge rst)
        begin
            if(rst)
                begin
                    bit_cnt <= 0;   done_slave <= 0;
                    MISO  <= 0;     d_out_slave <= 0;
                    shift_reg <= 0;
                    
                end
            else if(!ss_n && (load))                        //load state
                shift_reg <= d_in_slave;
            
            else if(!ss_n && (bit_cnt != reg_width) && busy)    //transfer state
                begin
                    if(s_clk)
                            MISO <= shift_reg[reg_width-1];
                    else
                        begin
                            shift_reg <= {shift_reg[reg_width-2 : 0] , MOSI};
                            bit_cnt <= bit_cnt + 1;
                        end 
                end
            else if(!ss_n && (bit_cnt == reg_width) && busy)  //done state
                begin
                    d_out_slave <= shift_reg;
                    done_slave <= 1;
                    //bit_cnt <= bit_cnt + 1;
                end
            else
                begin
                    //d_out_slave <= 0;
                    done_slave <= 0;
                    bit_cnt <= 0;
                end
        end

assign ready = (!ss_n) ? 1 : 0;

endmodule