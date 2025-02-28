`define NAN  3
`define ZERO 2
`define INF  1
`define NORM 0

module bf16_add #(
    parameter EXP_WIDTH = 8,
    parameter SIG_WIDTH = 7, 
    parameter FLAG_WIDTH = 4
) (
    input [EXP_WIDTH+SIG_WIDTH:0] i_data_a,
    input [EXP_WIDTH+SIG_WIDTH:0] i_data_b,

    output reg [EXP_WIDTH+SIG_WIDTH:0] o_data,
    output reg [FLAG_WIDTH-1:0] o_flag
);

wire [FLAG_WIDTH-1:0] flag_a, flag_b;
wire signed [EXP_WIDTH-1:0] exp_a, exp_b;
wire [SIG_WIDTH-1:0] sig_a, sig_b;
wire sign_a, sign_b;

bf16_class m_class_a (
    i_data_a,
    flag_a,
    sig_a,
    exp_a,
    sign_a
);

bf16_class m_class_b (
    i_data_b,
    flag_b,
    sig_b,
    exp_b,
    sign_b
);

reg [SIG_WIDTH-1:0] sig_augend, sig_addend, sig_norm;
reg signed [EXP_WIDTH:0] exp_augend, exp_addend, exp_norm;
reg sign_augend, sign_addend;
reg signed [EXP_WIDTH+1:0] shift_count;

reg [SIG_WIDTH:0] sig_sum;
reg sub;

//signed adder submodule
reg signed [SIG_WIDTH+2:0] adder_op_a;
reg signed [SIG_WIDTH+2:0] adder_op_b;
reg signed [SIG_WIDTH+2:0] adder_out;
//assign adder_out = adder_op_a + adder_op_b;

always @(*) begin
    
    o_flag = 4'b0000;
    sub = sign_a^sign_b;
    //augend -> larger number (no shifting needed)
    //addend -> smaller number (needs to be shifted)

    //handle edge cases -> zeros, inf and nan

    //handle nan
    if(flag_a[`NAN] | flag_b[`NAN]) begin
        o_data = flag_b[`NAN] ? i_data_b : i_data_a;
        o_flag[`NAN] = 1'b1;
    end
    //handle both zero
    else if(flag_a[`ZERO] & flag_b[`ZERO]) begin
        o_data = {sign_a&sign_b, 15'b0000000_00000000};
        o_flag[`ZERO] = 1'b1; 
    end
    //handle one zero
    else if(flag_a[`ZERO] | flag_b[`ZERO]) begin
        o_data = flag_b[`ZERO] ? i_data_a : i_data_b;
        o_flag[`ZERO] = 1'b1; 
    end
    //handle inf
    else if(flag_a[`INF] | flag_b[`INF]) begin
        if(flag_a[`INF] & flag_b[`INF] && sign_a^sign_b) begin
            o_data = {sign_a^sign_b, 15'b11111111_1000000};
            o_flag[`NAN] = 1'b1;
        end
        else begin
            o_data = flag_a[`INF] ? i_data_a : i_data_b;
            o_flag[`INF] = 1'b1;
        end
    end
    //handle normal 
    else begin
        //compare inputs and extract augend and addend
        if(i_data_a[14:0] < i_data_b[14:0]) begin
            sig_augend = sig_b;
            sig_addend = sig_a;
            exp_augend = exp_b;
            exp_addend = exp_a;
            sign_augend = sign_b;
            sign_addend = sign_a;
            shift_count = exp_b - exp_a;
        end
        else begin
            sig_augend = sig_a;
            sig_addend = sig_b;
            exp_augend = exp_a;
            exp_addend = exp_b;
            sign_augend = sign_a;
            sign_addend = sign_b;
            shift_count = exp_a - exp_b;
        end
        //send to adder
        adder_op_a = {1'b1, sig_augend, 1'b0};
        adder_op_b = ({1'b1, sig_addend, 1'b0} >> shift_count);
        adder_out = adder_op_a + adder_op_b;
        
        if(!sub) begin //both same sign    
            if(adder_out[SIG_WIDTH+2]) begin
                exp_norm = exp_augend+'d128;
                o_data = {sign_augend, exp_norm[EXP_WIDTH-1:0], adder_out[SIG_WIDTH+1:2]};
            end
            else begin
                exp_norm = exp_augend+'d127;
                o_data = {sign_augend, exp_norm[EXP_WIDTH-1:0], adder_out[SIG_WIDTH:1]};
            end
            if(exp_norm[EXP_WIDTH-1:0] == 8'b11111111) begin
                o_data[SIG_WIDTH-1:0] = 7'b0000000;
                o_flag[`INF] = 1'b1;
            end
            else 
                o_flag[`NORM] = 1'b1;        
        end
        //handle opp sign
        //no case for inf overflow, result could be zero...
        else begin         
            //adder_op_b = -adder_op_b;
            adder_out = adder_op_a - adder_op_b;
            sig_norm = 'd0;
            //output at adder_out -> 9 bits
            //check for 1 starting from 8th bit
            if(adder_out[8]) begin
                sig_norm[6:0] = adder_out[7:1];
                exp_norm = exp_augend + 'd127;
            end
            else if(adder_out[7]) begin
                sig_norm[6:0] = adder_out[6:0];
                exp_norm = exp_augend + 'd126;
            end
            else if(adder_out[6]) begin
                sig_norm[6:1] = adder_out[5:0];
                exp_norm = exp_augend + 'd125;
            end
            else if(adder_out[5]) begin
                sig_norm[6:2] = adder_out[4:0];
                exp_norm = exp_augend + 'd124;
            end
            else if(adder_out[4]) begin
                sig_norm[6:3] = adder_out[3:0];
                exp_norm = exp_augend + 'd123;
            end
            else if(adder_out[3]) begin
                sig_norm[6:4] = adder_out[2:0];
                exp_norm = exp_augend + 'd122;
            end
            else if(adder_out[2]) begin
                sig_norm[6:5] = adder_out[1:0];
                exp_norm = exp_augend + 'd121;
            end
            else if(adder_out[1]) begin
                sig_norm[6] = adder_out[0];
                exp_norm = exp_augend + 'd120;
            end
            else if(adder_out[0]) begin
                sig_norm = 'd0;
                exp_norm = exp_augend + 'd119;
            end
            else begin
                sig_norm = 'd0;
                exp_norm = 'd0;
                sign_augend = 0;
            end
            
            o_data = {sign_augend, exp_norm[EXP_WIDTH-1:0], sig_norm[SIG_WIDTH-1:0]};
            if(exp_norm[EXP_WIDTH-1:0] == 8'b00000000) begin
                o_data[SIG_WIDTH-1:0] = 7'b0000000;
                o_flag[`ZERO] = 1'b1;
            end
            else 
                o_flag[`NORM] = 1'b1;
        end
    end
end

endmodule