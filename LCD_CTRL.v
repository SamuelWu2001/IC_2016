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
reg [2:0]count;
reg [7:0]map[63:0];
reg [7:0]rm[3:0];
reg [7:0]mma;
reg [5:0]temp;
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
reg [7:0]NONE_IRAM_D;
reg [5:0]NONE_IRAM_A;
reg [5:0]NONE_IROM_A;
reg [5:0]temp_IROM_A;
integer i;
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
        if (current == 4'hc) begin
            map[index] = IROM_Q;
            IROM_A <= IROM_A + 1;
            if (index==0) begin
                if(bbb==1)begin
                    index = index + 1;
                    bbb <= 0;
                end
                else begin
                    bbb <= 1; 
                end
            end
            else begin
                index <= index + 1; 
            end
            if(index == 6'd63)begin
                IROM_A <= NONE_IROM_A;
                temp_IROM_A <= 6'd36;
                busy <= 0;
                index<=0;
            end
        end
        case(cmd)
            /*
            4'hc:begin //correct
                map[index] = IROM_Q;
                IROM_A <= IROM_A + 1;
                if (index==0) begin
                    if(bbb==1)begin
                        index = index + 1;
                        bbb <= 0;
                    end
                    else begin
                        bbb <= 1; 
                    end
                end
                else begin
                    index <= index + 1; 
                end

                if(index==6'd63)begin
                    IROM_A <= 6'd36; 
                    busy <= 0;
                    IROM_rd <= 0;
                    index<=0;
                end
            end
            4'hd:begin
                count <= count+1;
                case (count)
                   4'd0: begin IRAM_A　<= IROM_A -8;IRAM_D <= map[IROM_A-8]; end
                    4'd1: begin IRAM_A　<= IROM_A -1;IRAM_D <= map[IROM_A-1]; end
                    4'd2: begin IRAM_A　<= IROM_A; IRAM_D <= map[IROM_A]; end
                endcase
                if(count==0)begin
                   IRAM_A <= IRAM_A+6'd7;
               end
                else if(count==2)begin
                    busy <= 0;
                    count <= 0;
                    IRAM_valid <=0;
                    done <= 1;
                    IRAM_A <= IROM_A - 9;
                end
                else begin
            
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
            */
            4'd0:begin //correct
                IRAM_valid <=1;
                IRAM_D <= map[index];
                IRAM_A <= index;
                index <= index + 1;
                if(IRAM_A==6'd63)begin
                    busy <= 0;
                    IRAM_valid <=0;
                    done <= 1;
                end
            end
            4'd1:begin //SHift Up
                count <= count+1;
                case (count)
                    3'd0: begin
                        if(temp_IROM_A[5:3]==3'd1)begin
                           temp_IROM_A[5:3] <= 3'd1;
                        end 
                        else begin
                           temp_IROM_A[5:3] <=temp_IROM_A[5:3] - 3'd1;
                        end  
                    end
                    3'd1: begin IRAM_valid <= 1; IRAM_A <=temp_IROM_A - 9;IRAM_D <= map[temp_IROM_A-9]; end
                    3'd2: begin IRAM_A <=temp_IROM_A - 8;IRAM_D <= map[temp_IROM_A-8]; end
                    3'd3: begin IRAM_A <=temp_IROM_A - 1; IRAM_D <= map[temp_IROM_A-1]; end
                    3'd4: begin IRAM_A <=temp_IROM_A; IRAM_D <= map[temp_IROM_A];end
                    3'd5: begin
                        IRAM_A <= NONE_IRAM_A;
                        IRAM_D <= NONE_IRAM_D;
                        busy <= 0;
                        count <= 0;
                        IRAM_valid <= 0;
                         
                    end
                endcase
            end
            4'd2:begin //Shift Down
                count <= count+1;
                case (count)
                    3'd0: begin
                        if(temp_IROM_A[5:3]==3'd7)begin
                           temp_IROM_A[5:3] <= 3'd7;
                        end 
                        else begin
                           temp_IROM_A[5:3] <=temp_IROM_A[5:3] + 3'd1;
                        end
                    end
                    3'd1: begin IRAM_valid <= 1;  IRAM_A <=temp_IROM_A - 9;IRAM_D <= map[temp_IROM_A-9]; end
                    3'd2: begin IRAM_A <=temp_IROM_A - 8;IRAM_D <= map[temp_IROM_A-8]; end
                    3'd3: begin IRAM_A <=temp_IROM_A - 1; IRAM_D <= map[temp_IROM_A-1]; end
                    3'd4: begin IRAM_A <=temp_IROM_A; IRAM_D <= map[temp_IROM_A]; end
                    3'd5: begin
                        IRAM_A <= NONE_IRAM_A;
                        IRAM_D <= NONE_IRAM_D;
                        busy <= 0;
                        count <= 0;
                        IRAM_valid <= 0;
                         
                    end
                endcase
            end
            4'd3:begin //Shift Left
                count <= count+1;
                case (count)
                    3'd0: begin
                        if(temp_IROM_A[2:0]==3'd1)begin
                           temp_IROM_A[2:0] <= 3'd1;
                        end 
                        else begin
                           temp_IROM_A[2:0] <=temp_IROM_A[2:0]-3'd1;
                        end                    
                    end
                    3'd1: begin IRAM_valid <= 1; IRAM_A <=temp_IROM_A - 9;IRAM_D <= map[temp_IROM_A-9]; end
                    3'd2: begin IRAM_A <=temp_IROM_A - 8;IRAM_D <= map[temp_IROM_A-8]; end
                    3'd3: begin IRAM_A <=temp_IROM_A - 1; IRAM_D <= map[temp_IROM_A-1]; end
                    3'd4: begin IRAM_A <=temp_IROM_A; IRAM_D <= map[temp_IROM_A]; end
                    3'd5: begin
                        IRAM_A <= NONE_IRAM_A;
                        IRAM_D <= NONE_IRAM_D;
                        busy <= 0;
                        count <= 0;
                        IRAM_valid <= 0;
                         
                    end
                endcase
            end
            4'd4:begin //Shift Right
                count <= count+1;
                case (count)
                    3'd0: begin
                        if(temp_IROM_A[2:0]==3'd7)begin
                           temp_IROM_A[2:0] <= 3'd7;
                        end 
                        else begin
                           temp_IROM_A[2:0] <=temp_IROM_A[2:0]+3'd1;
                        end                    
                    end
                    3'd1: begin IRAM_valid <= 1; IRAM_A <=temp_IROM_A - 9;IRAM_D <= map[temp_IROM_A-9]; end
                    3'd2: begin IRAM_A <=temp_IROM_A - 8;IRAM_D <= map[temp_IROM_A-8]; end
                    3'd3: begin IRAM_A <=temp_IROM_A - 1; IRAM_D <= map[temp_IROM_A-1]; end
                    3'd4: begin IRAM_A <=temp_IROM_A; IRAM_D <= map[temp_IROM_A]; end
                    3'd5: begin
                        IRAM_A <= NONE_IRAM_A;
                        IRAM_D <= NONE_IRAM_D;
                        busy <= 0;
                        count <= 0;
                        IRAM_valid <= 0;
                         
                    end
                endcase
            end
            4'd5:begin //Max
                count <= count+1;
                case (count)
                    3'd0: begin
                        for (i = 0;i < 4 ; i = i+1 ) begin
                            if(i == 0)begin
                                mma = map [temp_IROM_A - 9];
                            end
                            else if (i == 1)begin
                                if (mma < map[temp_IROM_A - 8])begin
                                    mma = map[temp_IROM_A - 8];
                                end
                            end
                            else if (i == 2)begin
                                if (mma < map[temp_IROM_A - 1])begin
                                    mma = map[temp_IROM_A - 1];
                                end
                            end
                            else begin 
                                if (mma < map[temp_IROM_A])begin
                                    mma = map[temp_IROM_A];
                                end
                            end
                        end
                    end
                    3'd1: begin IRAM_valid <= 1; IRAM_A <=temp_IROM_A - 9; map[temp_IROM_A-9] <= mma; IRAM_D <= mma; end
                    3'd2: begin IRAM_A <=temp_IROM_A - 8; map[temp_IROM_A-8] <= mma; IRAM_D <= mma; end
                    3'd3: begin IRAM_A <=temp_IROM_A - 1; map[temp_IROM_A-1] <= mma; IRAM_D <= mma; end
                    3'd4: begin IRAM_A <=temp_IROM_A; IRAM_D <= mma; map[temp_IROM_A] <= mma;end
                    3'd5: begin
                        IRAM_A <= NONE_IRAM_A;
                        IRAM_D <= NONE_IRAM_D;
                        busy <= 0;
                        count <= 0;
                        IRAM_valid <= 0;
                    end
                endcase
            end
            4'd6:begin //Min
                count <= count+1;
                case (count)
                    3'd0: begin
                        for (i = 0;i < 4 ; i = i + 1) begin
                            if(i == 0)begin
                                mma = map [temp_IROM_A - 9];
                            end
                            else if (i == 1)begin
                                if (mma > map[temp_IROM_A - 8])begin
                                    mma = map[temp_IROM_A - 8];
                                end
                            end
                            else if (i == 2)begin
                                if (mma > map[temp_IROM_A - 1])begin
                                    mma = map[temp_IROM_A - 1];
                                end
                            end
                            else begin 
                                if (mma > map[temp_IROM_A])begin
                                    mma = map[temp_IROM_A];
                                end
                            end
                        end
                    end
                    3'd1: begin IRAM_valid <= 1; IRAM_A <=temp_IROM_A - 9; map[temp_IROM_A-9] <= mma; IRAM_D <= mma; end
                    3'd2: begin IRAM_A <=temp_IROM_A - 8; map[temp_IROM_A-8] <= mma; IRAM_D <= mma; end
                    3'd3: begin IRAM_A <=temp_IROM_A - 1; map[temp_IROM_A-1] <= mma; IRAM_D <= mma; end
                    3'd4: begin IRAM_A <=temp_IROM_A; IRAM_D <= mma; map[temp_IROM_A] <= mma;end
                    3'd5: begin
                        IRAM_A <= NONE_IRAM_A;
                        IRAM_D <= NONE_IRAM_D;
                        busy <= 0;
                        count <= 0;
                        IRAM_valid <= 0;
                         
                    end
                endcase
            end
            4'd7:begin //Average
                count <= count + 1;
                case (count)
                    3'd0: begin
                        mma <= ({2'b0,map[temp_IROM_A - 9]}+{2'b0,map[temp_IROM_A -8]}+{2'b0,map[temp_IROM_A -1]}+{2'b0,map[temp_IROM_A]})>>2;
                    end
                    3'd1: begin IRAM_valid <= 1; IRAM_A <=temp_IROM_A - 9; map[temp_IROM_A-9] <= mma; IRAM_D <= mma; end
                    3'd2: begin IRAM_A <=temp_IROM_A - 8; map[temp_IROM_A-8] <= mma; IRAM_D <= mma; end
                    3'd3: begin IRAM_A <=temp_IROM_A - 1; map[temp_IROM_A-1] <= mma; IRAM_D <= mma; end
                    3'd4: begin IRAM_A <=temp_IROM_A; IRAM_D <= mma; map[temp_IROM_A] <= mma;end
                    3'd5: begin
                        IRAM_A <= NONE_IRAM_A;
                        IRAM_D <= NONE_IRAM_D;
                        busy <= 0;
                        count <= 0;
                        IRAM_valid <= 0;
                         
                    end
                    endcase
                //IRAM_A <=temp_IROM_A-6'd9;
            end
            4'd8:begin //Counterclockwise Rotation
                count <= count + 1;
                case (count)
                    3'd0: begin
                        rm[0] <= map[temp_IROM_A-8];
                        rm[1] <= map[temp_IROM_A];
                        rm[2] <= map[temp_IROM_A-9];
                        rm[3] <= map[temp_IROM_A-1];
                        end
                    3'd1: begin IRAM_valid <= 1;IRAM_A <=temp_IROM_A - 9; map[temp_IROM_A-9] <= rm[0]; IRAM_D <= rm[0]; end
                    3'd2: begin IRAM_A <=temp_IROM_A - 8; map[temp_IROM_A-8] <= rm[1]; IRAM_D <= rm[1]; end
                    3'd3: begin IRAM_A <=temp_IROM_A - 1; map[temp_IROM_A-1] <= rm[2]; IRAM_D <= rm[2]; end
                    3'd4: begin IRAM_A <=temp_IROM_A; map[temp_IROM_A] <= rm[3]; IRAM_D <= rm[3];end
                    3'd5: begin
                        IRAM_A <= NONE_IRAM_A;
                        IRAM_D <= NONE_IRAM_D;
                        busy <= 0;
                        count <= 0;
                        IRAM_valid <= 0;
                         
                    end
                endcase
            end
            4'd9:begin //Shift Clockwise Rotation
                count <= count + 1;
                case (count)
                    3'd0: begin
                        rm[0] <= map[temp_IROM_A-1];
                        rm[1] <= map[temp_IROM_A-9];
                        rm[2] <= map[temp_IROM_A];
                        rm[3] <= map[temp_IROM_A-8];
                    end
                    3'd1: begin IRAM_valid <= 1; IRAM_A <=temp_IROM_A - 9; map[temp_IROM_A-9] <= rm[0]; IRAM_D <= rm[0]; end
                    3'd2: begin IRAM_A <=temp_IROM_A - 8; map[temp_IROM_A-8] <= rm[1]; IRAM_D <= rm[1]; end
                    3'd3: begin IRAM_A <=temp_IROM_A - 1; map[temp_IROM_A-1] <= rm[2]; IRAM_D <= rm[2]; end
                    3'd4: begin IRAM_A <=temp_IROM_A; map[temp_IROM_A] <= rm[3]; IRAM_D <= rm[3];end
                    3'd5: begin
                        IRAM_A <= NONE_IRAM_A;
                        IRAM_D <= NONE_IRAM_D;
                        busy <= 0;
                        count <= 0;
                        IRAM_valid <= 0;
                         
                    end
                endcase
            end
            4'ha:begin //Mirror X
                count <= count + 1;
                case (count)
                    3'd0: begin
                        rm[0] <= map[temp_IROM_A-1];
                        rm[1] <= map[temp_IROM_A];
                        rm[2] <= map[temp_IROM_A-9];
                        rm[3] <= map[temp_IROM_A-8];
                    end
                    3'd1: begin IRAM_valid <= 1; IRAM_A <=temp_IROM_A - 9; map[temp_IROM_A-9] <= rm[0]; IRAM_D <= rm[0]; end
                    3'd2: begin IRAM_A <=temp_IROM_A - 8; map[temp_IROM_A-8] <= rm[1]; IRAM_D <= rm[1]; end
                    3'd3: begin IRAM_A <=temp_IROM_A - 1; map[temp_IROM_A-1] <= rm[2]; IRAM_D <= rm[2]; end
                    3'd4: begin IRAM_A <=temp_IROM_A; map[temp_IROM_A] <= rm[3]; IRAM_D <= rm[3];end
                    3'd5: begin
                        IRAM_A <= NONE_IRAM_A;
                        IRAM_D <= NONE_IRAM_D;
                        busy <= 0;
                        count <= 0;
                        IRAM_valid <= 0;
                         
                    end
                endcase
            end
            4'hb:begin //Mirror Y
                count <= count + 1;
                case (count)
                    3'd0: begin
                        rm[0] <= map[temp_IROM_A-8];
                        rm[1] <= map[temp_IROM_A-9];
                        rm[2] <= map[temp_IROM_A];
                        rm[3] <= map[temp_IROM_A-1];
                    end
                    3'd1: begin IRAM_valid <= 1; IRAM_A <=temp_IROM_A - 9; map[temp_IROM_A-9] <= rm[0]; IRAM_D <= rm[0]; end
                    3'd2: begin IRAM_A <=temp_IROM_A - 8; map[temp_IROM_A-8] <= rm[1]; IRAM_D <= rm[1]; end
                    3'd3: begin IRAM_A <=temp_IROM_A - 1; map[temp_IROM_A-1] <= rm[2]; IRAM_D <= rm[2]; end
                    3'd4: begin IRAM_A <=temp_IROM_A; map[temp_IROM_A] <= rm[3]; IRAM_D <= rm[3];end
                    3'd5: begin
                        IRAM_A <= NONE_IRAM_A;
                        IRAM_D <= NONE_IRAM_D;
                        busy <= 0;
                        count <= 0;
                        IRAM_valid <= 0;
                         
                    end
                endcase
            end
        endcase
    end
    else begin
        if(busy == 0)begin
            IROM_rd <= 0;
            current <= cmd;
            busy <= 1;
            done <= 0;
        end
    end
end
endmodule