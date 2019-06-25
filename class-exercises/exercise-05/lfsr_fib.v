////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	lfsr_fib.v
//
// Project:	A set of Yosys Formal Verification exercises
//
// Background:	This file implements a Linear Feedback Shift Register (LFSR).
//		If properly implemented, it will take 2^N-1 samples before the
//	output sequence repeats.  Over the course of these 2^N-1 samples, there
//	should be exactly 2^(N-1) one's and 2^(N-1)-1 zeros.
//
//	To read more, see: http://zipcpu.com/dsp/2017/10/27/lfsr.html
//
// To Prove:	
//	1. If (i_in) is forever zero,
//		sreg will never be completely zero
//	2. If (sreg) is ever zero
//		sreg will remain zero until the clock after i_in is true
//
// Some more advanced proofs include:
//	1. if (i_in) is forever zero,
//		prove this sequence repeats every 127 bits
//	2. if (i_in) is forever zero,
//		prove this sequence will produce exactly 64 ones and 63 zeros.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2017, Gisselquist Technology, LLC
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
module	lfsr_fib(i_clk, i_reset, i_ce, i_in, o_bit);
	parameter		LN=8;	// LFSR Register length/polynomial deg
	parameter [(LN-1):0]	TAPS = 8'h2d,
				INITIAL_FILL = { { (LN-1){1'b0}}, 1'b1 };
	//
	input	wire			i_clk, i_reset, i_ce, i_in;
	output	wire			o_bit;

	reg	[(LN-1):0]	sreg;

	initial	sreg = INITIAL_FILL;
	always @(posedge i_clk)
		if (i_reset)
		begin
			sreg <= INITIAL_FILL;
		end else if (i_ce)
		begin
			sreg[(LN-2):0] <= sreg[(LN-1):1];
			sreg[(LN-1)] <= (^(sreg & TAPS)) ^ i_in;
		end

	assign	o_bit = sreg[0];

endmodule
