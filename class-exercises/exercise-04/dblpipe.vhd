--------------------------------------------------------------------------------
--
-- Filename: 	dblpipe.v
--
-- Project:	A set of Yosys Formal Verification exercises
--
-- Background:	This file contains a pair of LFSR modules.  They "should" be
--		identical.
--
-- To prove:
--
--	1. That nothing changes as long as CE is low
--
--	2. That the outputs of the two LFSR's are identical, and hence the
--		output, o_data, will be forever zero.
--
--
-- Creator:	Dan Gisselquist, Ph.D.
--		Gisselquist Technology, LLC
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Copyright (C) 2017-2018, Gisselquist Technology, LLC
--
-- This program is free software (firmware): you can redistribute it and/or
-- modify it under the terms of the GNU General Public License as published
-- by the Free Software Foundation, either version 3 of the License, or (at
-- your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for more details.
--
-- You should have received a copy of the GNU General Public License along
-- with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
-- target there if the PDF file isn't present.)  If not, see
-- <http://www.gnu.org/licenses/> for a copy.
--
-- License:	GPL, v3, as defined and found on www.gnu.org,
--		http://www.gnu.org/licenses/gpl.html
--
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dblpipe is

	port (i_clk, i_ce, i_data : in std_logic;
		o_data : out std_logic := '0');

end entity dblpipe;

architecture behavior of dblpipe is
	component lfsr_fib
	  port(i_clk, i_reset, i_ce, i_in : in std_logic;
		o_bit : out std_logic);
	end component;

	signal	a_data, b_data : std_logic;
begin
----
----

one: lfsr_fib port map (
	i_clk => i_clk,
	i_reset => '0',
	i_ce => i_ce,
	i_in => i_data,
	o_bit => a_data);

two: lfsr_fib port map (
	i_clk => i_clk,
	i_reset => '0',
	i_ce => i_ce,
	i_in => i_data,
	o_bit => b_data);

process(a_data, b_data)
begin
	o_data <= a_data xor b_data;
end process;

----
----
end behavior;
