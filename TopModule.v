module TopModule(d_in_Master , d_in_Slave_0 , d_in_Slave_1 , d_in_Slave_2 , d_in_Slave_3 , start , clk , rst , in_addr
                , d_out_Master , d_out_Slave , done_master , done_slave , busy , ready);
parameter reg_width = 32;

input rst , clk;
input start;
input [reg_width - 1 : 0] d_in_Master , d_in_Slave_0 , d_in_Slave_1 , d_in_Slave_2 , d_in_Slave_3;
input [4:0] in_addr;    //in_addr [4:2] : base_address = 100 (SPI SELECTOR) , in_addr[1:0] : offset (slave selector)

            //outputs of master
output   done_master;
output  busy ;
output  [reg_width - 1 : 0] d_out_Master;

            //outputs of slave must be reg
output reg [reg_width - 1 : 0] d_out_Slave;
output reg ready , done_slave;

            //internal signals
reg MISO;
wire MOSI;
wire s_clk , load;
wire clk_in;
wire [3:0] cs_n;


                //each slave has a uniqe outputs to prevent multi_driven signals
wire [reg_width - 1 : 0] d_out_Slave_0 , d_out_Slave_1 , d_out_Slave_2 , d_out_Slave_3;
wire MISO_0 , MISO_1 , MISO_2 , MISO_3;
wire done_slave_0 , done_slave_1 , done_slave_2 , done_slave_3;
wire ready_0 , ready_1 , ready_2 , ready_3;




    SPI_Master #(reg_width) Master (d_in_Master , MISO , clk_in , rst , start , in_addr[1:0]   //offset
                                , d_out_Master , MOSI , s_clk , cs_n , done_master , busy , load);

    SPI_slave #(reg_width) Slave_0 (d_in_Slave_0 , MOSI , s_clk , cs_n[0] , clk_in , rst , load , busy
                                , d_out_Slave_0, MISO_0 , done_slave_0 , ready_0);
                                
    SPI_slave #(reg_width) Slave_1 (d_in_Slave_1 , MOSI , s_clk , cs_n[1] , clk_in , rst , load , busy
                                , d_out_Slave_1, MISO_1 , done_slave_1 , ready_1);

    SPI_slave #(reg_width) Slave_2 (d_in_Slave_2 , MOSI , s_clk , cs_n[2] , clk_in , rst , load , busy
                                , d_out_Slave_2, MISO_2 , done_slave_2 , ready_2);

    SPI_slave #(reg_width) Slave_3 (d_in_Slave_3 , MOSI , s_clk , cs_n[3] , clk_in , rst , load , busy
                                , d_out_Slave_3, MISO_3 , done_slave_3 , ready_3);



    assign clk_in = (in_addr[4:2] == 3'b100) ? clk : 0;          //SPI SELECTOR
    

    always @(*)
        begin
            case(in_addr[1:0])
                3'b11:
                        begin
                            d_out_Slave = d_out_Slave_3;
                            MISO = MISO_3;
                            done_slave = done_slave_3;
                            ready = ready_3;
                        end
                3'b10:
                        begin
                            d_out_Slave = d_out_Slave_2;
                            MISO = MISO_2;
                            done_slave = done_slave_2;
                            ready = ready_2; 
                        end
                3'b01:
                        begin
                            d_out_Slave = d_out_Slave_1;
                            MISO = MISO_1;
                            done_slave = done_slave_1;
                            ready = ready_1; 
                        end
                default:
                        begin
                            d_out_Slave = d_out_Slave_0;
                            MISO = MISO_0;
                            done_slave = done_slave_0;
                            ready = ready_0; 
                        end
            endcase
        end


    


endmodule