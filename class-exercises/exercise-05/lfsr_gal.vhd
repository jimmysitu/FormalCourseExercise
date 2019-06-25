--------------------------------------------------------------------------------
--
-- Filename: 	lfsr_gal.v
--
-- Project:	DSP Filtering Example Project
--
-- Purpose:	
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

entity	lfsr_gal is

	generic (LN : natural := 8;
		TAPS : std_logic_vector(LN-1 downto 0) := x"2d";
		INITIAL_FILL : std_logic_vector(LN-1 downto 0) := x"80");

	port (i_clk, i_reset, i_ce, i_in : in std_logic;
		o_bit : out std_logic := '0');

end entity lfsr_gal;

architecture behavior of lfsr_gal is
	signal	sreg : std_logic_vector(LN-1 downto 0) := INITIAL_FILL;
begin
----
----


process(i_clk)
begin
	if (rising_edge(i_clk)) then
		if (i_reset = '1') then
			sreg <= INITIAL_FILL;
		elsif (i_ce = '1') then
			if (sreg(0)) then
				sreg <= ( i_in & sreg(LN-1 downto 1) ) xor TAPS;
			else
				sreg <= ( i_in & sreg(LN-1 downto 1) );
			end if;
		end if;
	end if;
end process;

process(sreg)
begin
	o_bit <= sreg(0);
end process;

----
----
end behavior;
