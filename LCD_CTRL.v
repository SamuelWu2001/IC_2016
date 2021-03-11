module LCD_CTRL(clk, reset, cmd, cmd_valid, IROM_Q, IROM_rd, IROM_A, IRAM_valid, IRAM_D, IRAM_A, busy, done);
input clk;
input reset;
input [3:0] cmd;
input cmd_valid;
input [7:0] IROM_Q;
output IROM_rd;
output [5:0] IROM_A;
output IRAM_valid;
output [7:0] IRAM_D;
output [5:0] IRAM_A;
output busy;
output done;

reg [3:0]current;
//reg [3:0]next;
//reg [3:0]cmd;
reg [1:0]count;
reg [7:0]map[63:0];
reg [1:0]rm[7:0];
reg [7:0]mma;
reg [5:0]temp;
integer i;

reg [5:0]index;
reg bbb;
reg IROM_rd;
reg [5:0] IROM_A;
reg IRAM_valid;
reg [7:0] IRAM_D;
reg [5:0] IRAM_A;
reg busy;
reg done;
reg [1:0]r_count;
always @(negedge clk) begin
    if(reset)begin
        IROM_A = 6'd0;
        busy <= 1;
        current <= 4'hc;
        count <= 0;
        IROM_rd <= 1;
        done <= 0;
        IRAM_valid <=0;
        index <= 0;
        bbb <= 0;
    end
    else if(busy==1)begin
        case(current)
            4'hc:begin //correct
                map[index] = IROM_Q;
                
                IROM_A <= IROM_A+1;
                if (index==0) begin
                    if(bbb==1)begin
                        index = index + 1;
                        bbb<=0;
                    end
                    else begin
                        bbb <= 1; 
                    end
                end
                else begin
                    index <= index + 1; 
                end
                
                //ccc = ccc+1;
                if(index==6'd63)begin
                    IROM_A <= 6'd36; 
                    busy <= 0;
                    //IRAM_A <= 6'd0;
                    IROM_rd <= 0;
                    index<=0;
                end
            end
            4'hd:begin
                count <= count+1;
                IRAM_D <= map[IRAM_A];
                if(count==1)begin
                    IRAM_A <= IRAM_A+6'd7;
                end
                else if(count==3)begin
                    busy <= 0;
                    count <= 0;
                    IRAM_valid <=0;
                    done <= 1;
                end
                else begin
                    IRAM_A <= IRAM_A+6'd1;
                end
            end
            4'he:begin
                count <= count+1;
                IRAM_D <= mma;
                map[IRAM_A] <= mma;
                if(count==1)begin
                    IRAM_A <= IRAM_A+6'd7;
                end
                else if(count==3)begin
                    busy <= 0;
                    count <= 0;
                    //IRAM_valid <=0;
                    done <= 1;
                end
                else begin
                    IRAM_A <= IRAM_A+6'd1;
                end
            end
            4'hf:begin
                count <= count+1;
                IRAM_D <= rm[count];
                map[IRAM_A] <= rm[count];
                if(count==1)begin
                    IRAM_A <= IRAM_A+6'd7;
                end
                else if(count==3)begin
                    busy <= 0;
                    count <= 0;
                    //IRAM_valid <=0;
                    done <= 1;
                end
                else begin
                    IRAM_A <= IRAM_A+6'd1;
                end
            end
            4'd0:begin //correct
                //IRAM_valid <=1;
                IRAM_D <= map[index];
                IRAM_A <= index;
                index <= index + 1;
                if(IRAM_A==6'd63)begin
                    busy <= 0;
                    IRAM_A <= 6'd27;
                    IRAM_valid <=0;
                    done <= 1;
                end
            end
            4'd1:begin
                //IRAM_valid <=1;
                if(IROM_A[5:3]==3'd1)begin
                    IROM_A[5:3] <= 3'd1;
                end 
                else begin
                    IROM_A[5:3] <= IROM_A[5:3]-3'd1;
                end
                IRAM_A <= IROM_A-6'd9;
                current <= 4'hd;
            end
            4'd2:begin
                //IRAM_valid <=1;
                if(IROM_A[5:3]==3'd7)begin
                    IROM_A[5:3] <= 3'd7;
                end 
                else begin
                    IROM_A[5:3] <= IROM_A[5:3]+3'd1;
                end
                IRAM_A <= IROM_A-6'd9;
                current <= 4'hd;
            end
            4'd3:begin
                if(IROM_A[2:0]==3'd1)begin
                    IROM_A[2:0] <= 3'd1;
                end 
                else begin
                    IROM_A[2:0] <= IROM_A[2:0]-3'd1;
                end
                IRAM_A <= IROM_A-6'd9;
                current <= 4'hd;
            end
            4'd4:begin
                if(IROM_A[2:0]==3'd7)begin
                    IROM_A[2:0] <= 3'd7;
                end 
                else begin
                    IROM_A[2:0] <= IROM_A[2:0]+3'd1;
                end
                IRAM_A <= IROM_A-6'd9;
                current <= 4'hd;
            end
            4'd5:begin
                temp <= IRAM_A;
                for (i = 0;i < 4 ; i = i+1 ) begin
                    if(i==1)begin
                        temp <= temp + 6'd7;
                    end
                    else begin
                        temp <= temp + 6'd1;
                    end
                    if(mma<map[temp])begin
                        mma <= map[temp];
                    end
                end
                //IRAM_A <= IROM_A-6'd9;
                current <= 4'he;
            end
            4'd6:begin
                temp <= IRAM_A;
                for (i = 0;i < 4 ; i = i+1 ) begin
                    if(i==1)begin
                        temp <= temp + 6'd7;
                    end
                    else begin
                        temp <= temp + 6'd1;
                    end
                    if(mma>map[temp])begin
                        mma <= map[temp];
                    end
                end
                //IRAM_A <= IROM_A-6'd9;
                current <= 4'he;
            end
            4'd7:begin
                mma <= ({2'b0,map[IRAM_A]}+{2'b0,map[IRAM_A+1]}+{2'b0,map[IRAM_A+8]}+{2'b0,map[IRAM_A+9]})>>2;
                //IRAM_A <= IROM_A-6'd9;
                current <= 4'he;
            end
            4'd8:begin
                rm[0] <= map[IRAM_A+1];
                rm[1] <= map[IRAM_A+9];
                rm[2] <= map[IRAM_A+0];
                rm[3] <= map[IRAM_A+8];
                //IRAM_A <= IROM_A-6'd9;
                current <= 4'hf;
            end
            4'd8:begin
                rm[0] <= map[IRAM_A+8];
                rm[1] <= map[IRAM_A+0];
                rm[2] <= map[IRAM_A+9];
                rm[3] <= map[IRAM_A+1];
                //IRAM_A <= IROM_A-6'd9;
                current <= 4'hf;
            end
            4'ha:begin
                rm[0] <= map[IRAM_A+8];
                rm[1] <= map[IRAM_A+9];
                rm[2] <= map[IRAM_A+0];
                rm[3] <= map[IRAM_A+1];
                //IRAM_A <= IROM_A-6'd9;
                current <= 4'hf;
            end
            4'hb:begin
                rm[0] <= map[IRAM_A+1];
                rm[1] <= map[IRAM_A+0];
                rm[2] <= map[IRAM_A+9];
                rm[3] <= map[IRAM_A+8];
                //IRAM_A <= IROM_A-6'd9;
                current <= 4'hf;
            end
        endcase
    end
    else begin
        if(busy==0&&cmd_valid==1)begin
            current <= cmd;
            busy <= 1;
            done <= 0;
            IRAM_valid <= 1;
            IRAM_A <= 0;
        end
        
    end
end
endmodule



