##Clock signal
create_clock -add -name FCLK_CLK0 -period 5.00 -waveform {0 4} [get_ports { FCLK_CLK0 }];
