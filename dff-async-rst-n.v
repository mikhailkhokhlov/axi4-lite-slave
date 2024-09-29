module dff_async_rst_n #(parameter WIDTH = 32,
                         parameter RESET = {WIDTH{1'b0}})

                        (input                      i_clock   ,
                         input                      i_areset_n,
                         input                      en,
                         input      [(WIDTH - 1):0] d,
                         output reg [(WIDTH - 1):0] q);

  always @(posedge i_clock or negedge i_areset_n)
    if (!i_areset_n)
      q <= RESET;
    else if (en)
      q <= d;

endmodule
