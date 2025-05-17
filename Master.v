module SPI_Master(d_in , MISO , clk , rst , start , in_addr
                 , d_out , MOSI , s_clk , cs_n , done , busy , load);
            //FSM states
localparam IDLE = 2'b00;
localparam LOAD = 2'b01;
localparam TRANSFER = 2'b10;
localparam DONE = 2'b11;

            //no bits in reg to be transferred
parameter reg_width = 32;


input rst , clk;
input start , MISO;
input [reg_width-1:0] d_in;
input [1:0] in_addr;        //offset

output reg s_clk ;
output reg MOSI , done , busy;
output reg [reg_width-1:0] d_out;
output reg load;
output reg [3:0] cs_n;


//internal signals
reg [1:0] cs , ns;
reg [reg_width-1:0] shift_reg;
reg [$clog2(reg_width):0] bit_cnt;           //counting number of bits transferred
reg ss_n;

            //current state logic
    always@(posedge clk , posedge rst)
        begin
            if(rst)
                cs <= IDLE;
            else
                cs <= ns;
        end

            //next state logic
    always @(*)
        begin
            case(cs)
                IDLE: ns = (start) ? LOAD : cs;
                LOAD: ns = TRANSFER;
                TRANSFER: ns = ((bit_cnt == (reg_width)) && s_clk) ? DONE : cs;     //we can remove s_clk here
                DONE: ns = IDLE;
            endcase
        end 

            //output logic
    always @(posedge clk , posedge rst)
        begin
            if(rst)
                begin
                    ss_n <= 1;      s_clk <= 0;
                    done <= 0;      busy  <= 0;
                    d_out<= 0;      MOSI  <= 0;
                    load <= 0;      bit_cnt <= 0;
                    shift_reg <=0;
                end

            else
                begin
                    case(cs)
                        IDLE:
                            begin
                                ss_n <= 0;      //start of communication     
                                done <= 0;      busy  <= 0;
                                MOSI <= 0;      //d_out <= 0;
                                bit_cnt <= 0;   //load <= 1;
                                if(ns == LOAD)
                                    load <= 1;
                                else
                                    load <= 0;
                            end

                        LOAD:
                            begin
                                shift_reg <= d_in;
                                busy <= 1;
                                load <= 0;
                                s_clk <= 1;
                            end

                        TRANSFER:
                            begin
                                s_clk <= ~s_clk;
                                load <= 0;

                                    if(s_clk)
                                            MOSI <= shift_reg[reg_width - 1];
                                    else
                                        begin
                                            shift_reg <= {shift_reg[reg_width-2 : 0] , MISO};
                                            bit_cnt <= bit_cnt + 1;
                                        end
                            end

                        DONE:
                            begin
                                d_out <= shift_reg;
                                //ss_n  <= 1;
                                done  <= 1;
                                busy  <= 0;     load <= 0;
                            end
                    endcase
                end
        end

            //slave selection logic
    always @(*) begin
        cs_n[3:0] = 4'b1111;
            case(in_addr[1:0])
                2'b11: cs_n[3] = ss_n;
                2'b10: cs_n[2] = ss_n;
                2'b01: cs_n[1] = ss_n;
                default : cs_n[0] = ss_n;                  
            endcase
    end
endmodule