`define NAN  3
`define ZERO 2
`define INF  1
`define NORM 0
`define BIAS 127
`define EMAX 127
`define EMIN -126


module bf16_mul # (
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

reg sign;
reg [2*SIG_WIDTH+1:0] sig_raw;
reg [SIG_WIDTH-1:0] sig;
reg signed [EXP_WIDTH+1:0] exp_raw, exp, exp_out;

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

always @(*) begin
    o_flag = 4'b0000;
    sign = i_data_a[15]^i_data_b[15];
    //handle NaN
    if(flag_a[`NAN] | flag_b[`NAN]) begin
        o_data = {16'b0_11111111_1000000};
        o_flag[`NAN] = 1'b1;
    end
    //handle zero 
    else if(flag_a[`ZERO] | flag_b[`ZERO]) begin
        if(flag_a[`INF] | flag_b[`INF]) begin
            o_data = {16'b1_11111111_1000000};
            o_flag[`NAN] = 1'b1;
        end
        else begin
            o_data = {sign, 15'b00000000_0000000};
            o_flag[`ZERO] = 1'b1;
        end
    end  
    //handle infinity
    else if(flag_a[`INF] | flag_b[`INF]) begin
        o_data = {sign, 15'b11111111_0000000};
        o_flag[`INF] = 1'b1;
    end
    //handle normal
    else begin
        exp_raw = exp_a + exp_b; //actual exp value in signed int
        sig_raw = {1'b1, sig_a} * {1'b1, sig_b}; //actual sig of result
        
        if(sig_raw[15] == 1'b1) begin
            sig = sig_raw[14:8];
            exp = exp_raw + 'd1;
        end
        else begin
            sig = sig_raw[13:7];
            exp = exp_raw;
        end
        //result too small so output zero
        if(exp < `EMIN) begin
            o_data = {sign, 15'b00000000_0000000};
            o_flag[`ZERO] = 1'b1;
        end
        //result too large so output inf
        else if(exp > `EMAX) begin
            o_data = {sign, 15'b11111111_0000000};
            o_flag[`INF] = 1'b1;
        end
        //result is a normal number
        else begin
            exp_out = exp + `BIAS;
            o_data = {sign, exp_out[7:0], sig[6:0]};
            o_flag[`NORM] = 1'b1;
        end
    end
end

endmodule


//bf16_class module 
