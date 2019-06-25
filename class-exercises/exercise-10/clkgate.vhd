--------------------------------------------------------------------------------
--
-- Filename: 	clkgate.v
--
-- Project:	A set of Yosys Formal Verification exercises
--
-- Background:	This file contains an implementation of a clock gate.  The
--		clock should only tick if the enable line is high.
--
-- Assume:
--	1. A single incoming clock
--
--	2. An enable line that is not synchronous to it
--
-- To prove:
--
--	1. Glitches in the enable line will not create glitches in the clock
--
--	2. The latch can be successfully replaced with a flip flop
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

entity	clkgate is

  port(i_clk, i_areset_n, i_en : in std_logic;
	o_clk : out std_logic := '0');

end entity clkgate;

architecture behavior of clkgate is
  signal latch : std_logic := '0';
begin
-----
-----

process(all)
begin
  if (i_areset_n = '0') then
    latch <= '0';
  elsif (i_clk = '0') then
    latch <= i_en;
  end if;
end process;

o_clk <= '1' when (latch = '1') and (i_clk = '1') else '0';

-----
-----
end behavior;
