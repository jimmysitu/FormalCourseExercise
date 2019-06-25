////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	iserdes_vhd.sv
//
// Project:	A set of Yosys Formal Verification exercises
//
// Purpose:	The formal wrapper around an example VHDL input SERDES operator
//
// Assume:
//	1. Two clocks, where one clock (i_fast_clk) is exactly WIDTH
//		times faster than (i_slow_clk), and where
//
//	2. i_slow_clk and i_fast_clk share a positive edge transition
//
// To prove:
//
//	1. That the output returned on the positive edge of the slow clock,
//		is the input that was received
//
//	2. That the slow clock outputs are stable, over the slow clock
//
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2018, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	GPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/gpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
module iserdes_vhd(i_slow_clk, i_fast_clk, i_areset_n, i_pin, o_word,
		r_word);
	//
	parameter			WIDTH=10;
	parameter	[(WIDTH-1):0]	RESET_VALUE = 0;
	//
	input	wire			i_slow_clk, i_fast_clk,
					i_areset_n;
	//
	input	wire			i_pin;
	input	wire	[(WIDTH-1):0]	o_word;
	input	wire	[(WIDTH-1):0]	r_word;

`ifdef	FORMAL
	//
	// Your properties will go here
	//
`endif
endmodule

bind iserdes iserdes_vhd #(.WIDTH(WIDTH), .RESET_VALUE(RESET_VALUE)) copy (.*);
