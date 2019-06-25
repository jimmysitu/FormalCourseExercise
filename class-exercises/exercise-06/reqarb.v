////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	reqarb.v
//
// Project:	A set of Yosys Formal Verification exercises
//
// Background:	This is a request arbiter.  It accepts requests from channels
//		A and B, and outputs one request at a time.  Any time there is
//	a valid request, the *_req line will be high and the requested data
//	will be placed onto *_data.  Each channel source has a series of
//	requests, possibly bursty requests, they would like to send to the
//	output.  However, only one request can go through at a time.  Hence,
//	the need for an arbiter to decide whose request goes through.
//
// To Prove:
//	1. No data will be lost
//	2. Only one source will ever have access to the channel at any given
//		time
//	3. All requests will go through
//
// You will need to make some assumptions in order to formally verify that this
// core meets the above conditions.  What assumptions you choose to make will
// be up to you--as long as they maintain the spirit of the description outlined
// above.
//
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
module	reqarb(i_clk, i_reset,
		i_a_req, i_a_data, o_a_busy,
		i_b_req, i_b_data, o_b_busy,
		o_req, o_data, i_busy);
	//
	input	wire	i_clk, i_reset;
	//
	// A's channel to make requests to send data.
	//	If i_a_req is true, A wishes to send i_a_data
	//	If o_a_busy is true, A must wait
	//
	input	wire	i_a_req, i_a_data;
	output	wire	o_a_busy;
	//
	// Slave channel B
	input	wire	i_b_req, i_b_data;
	output	wire	o_b_busy;
	//
	// Outoing master channel
	output	wire	o_req, o_data;
	input	wire	i_busy;

	reg	a_is_the_owner;
	initial	a_is_the_owner = 1'b0;
	always @(posedge i_clk)
		if (i_reset)
			a_is_the_owner <= 1'b0;
		else if ((i_a_req)&&(!i_b_req))
			a_is_the_owner <= 1'b1;
		else if ((i_b_req)&&(!i_a_req))
			a_is_the_owner <= 1'b0;

	assign	o_a_busy = (!a_is_the_owner)||(i_busy);

	assign	o_b_busy = ( a_is_the_owner)||(i_busy);

	assign	o_req  = (a_is_the_owner) ? i_a_req  : i_b_req;
	assign	o_data = (a_is_the_owner) ? i_a_data : i_b_data;

`ifdef	FORMAL
`endif
endmodule
