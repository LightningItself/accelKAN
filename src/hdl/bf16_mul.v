`define NAN  3
`define ZERO 2
`define INF  1
`define NORM 0
`define BIAS 254


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

reg [2*SIG_WIDTH-1:0] sig_raw, sig;
reg [2*EXP_WIDTH-1:0] exp_raw, exp;


reg sign;

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
        o_data = {sign, 15'b11111111_1000000};
        o_flag[`NAN] = 1'b1;
    end
    //handle zero 
    else if(flag_a[`ZERO] | flag_b[`ZERO]) begin
        if(flag_a[`INF] | flag_b[`INF]) begin
            o_data = {sign, 15'b11111111_1000000};
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
        
        //shift these to bf16_class module
        exp_raw = exp_a + exp_b;
        
        if(sig_raw[21] == 1'b1) begin
            sig = sig_raw[21:11];
            exp = exp_raw + 1;
        end
        else begin
            sig = sig_raw[20:10];
            exp = exp_raw;
        end
        
        //if too small, return zero
        o_data = {sign, exp[7:0], sig[6:0]};
        o_flag[`NORM] = 1'b1;
        //else return the normal result

    end

end



endmodule




//bf16_class module 
