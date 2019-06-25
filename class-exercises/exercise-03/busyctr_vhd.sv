////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	busyctr_vhd.sv
//
// Project:	A set of Yosys Formal Verification exercises
//
// Background:	
//
// #1, To Prove:
//	1. Assume that once raised, i_start_signal will remain high until it
//		is both high and the counter is no longer busy.
//		Following (i_start_signal)&&(!o_busy), i_start_signal is no
//		longer constrained--until it is raised again.
//	2. o_busy will *always* be true any time the counter is non-zero.
//	3. If the counter is non-zero, it should always be counting down
//
// #2, To Prove:
//	1. First, adjust o_busy to be a clocked signal/register
//	2. Prove that it will only ever be true when the counter is non-zero
//
//	This particular file is a System Verilog wrapper around busyctr.vhd,
//	so as to be able to use the System Verilog assertions to verify
//	counter.vhd
//
// To Prove:	That the counter's value stays between 0 and MAX_VALUE-1.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2017-2018, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of  the GNU General Public License as published
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
module	busyctr_vhd(i_clk, i_reset, i_start_signal, counter, o_busy);
	parameter	[15:0]	MAX_AMOUNT = 22;
	input	wire		i_clk, i_reset, i_start_signal;
	input	wire	[15:0]	counter;
	input	wire		o_busy;

`ifdef	FORMAL
 	// Your formal properties would go here
`endif
endmodule

bind busyctr busyctr_vhd copy (.*);
