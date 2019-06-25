--------------------------------------------------------------------------------
--
-- Filename: 	iserdes.v
--
-- Project:	A set of Yosys Formal Verification exercises
--
-- Purpose:	An example input SERDES operator
--
-- Assume:
--	1. Two clocks, where one clock (i_fast_clk) is exactly WIDTH
--		times faster than (i_slow_clk), and where
--
--	2. i_slow_clock and i_fast_clock share a positive edge transition
--
-- To prove:
--
--	1. That the output returned on the positive edge of the slow clock,
--		is the input that was received
--
--	2. That the slow clock outputs are stable, over the slow clock
--
--
-- Creator:	Dan Gisselquist, Ph.D.
--		Gisselquist Technology, LLC
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Copyright (C) 2018, Gisselquist Technology, LLC
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

entity iserdes is

	generic (WIDTH : natural := 10;
		RESET_VALUE : std_logic_vector(WIDTH -1 downto 0)
				:= std_logic_vector(to_unsigned(0,WIDTH)));

	port	(i_slow_clk, i_fast_clk, i_areset_n : in std_logic;
		i_pin : in std_logic;
		o_word : out std_logic_vector(WIDTH-1 downto 0) := RESET_VALUE);

end entity iserdes;

architecture behavior of iserdes is
	signal r_word : std_logic_vector(WIDTH-1 downto 0) := RESET_VALUE;
begin
-- 	//
-- 	// The basic input SERDESE operator
-- 	//

process(i_fast_clk, i_areset_n)
begin
  if (i_areset_n = '0') then
	r_word <= RESET_VALUE;
  elsif (rising_edge(i_fast_clk)) then
	r_word <= r_word(WIDTH-2 downto 0) & i_pin;
  end if;
end process;


process(i_slow_clk, i_areset_n)
begin
  if (i_areset_n = '0') then
	o_word <= RESET_VALUE;
  elsif (rising_edge(i_slow_clk)) then
	o_word <= r_word(WIDTH-2 downto 0) & i_pin;
  end if;
end process;

----
----
end behavior;
