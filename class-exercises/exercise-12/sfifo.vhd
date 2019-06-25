--------------------------------------------------------------------------------
--
-- Filename: 	sfifo.vhd
--
-- Project:	A set of Yosys Formal Verification exercises
--
-- Purpose:	A synchronous data FIFO.
--
-- To Prove:
--	1. That the counter's value stays between 0 and MAX_VALUE-1.
--	2. That given two subsequent inputs, they may be read out later in the
--		same order
--
-- Creator:	Dan Gisselquist, Ph.D.
--		Gisselquist Technology, LLC
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Copyright (C) 2015-2018, Gisselquist Technology, LLC
--
-- This program is free software (firmware): you can redistribute it and/or
-- modify it under the terms of  the GNU General Public License as published
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
use ieee.std_logic_unsigned.all;

entity sfifo is

	generic(DW : natural := 8;	-- Byte/data width
		LGFLEN : natural := 4); -- Log of the buffer size

	port(i_clk, i_reset : in std_logic;
		-- The incoming (write) interface
		i_wr   : in std_logic;
		i_data : in std_logic_vector(DW-1 downto 0);
		o_full : out std_logic := '0';
		--
		-- The outgoing (read) interface
		i_rd    : in  std_logic;
		o_data  : out std_logic_vector(DW-1 downto 0);
		o_empty : out std_logic := '1';
		o_err   : out std_logic := '0');

end entity sfifo;

architecture behavior of sfifo is
	constant FLEN : natural := 2 ** LGFLEN;

	subtype data_type is std_logic_vector(DW-1 downto 0);
	subtype ptr_type  is unsigned(LGFLEN downto 0);
	type	mem_type  is array (FLEN-1 downto 0) of data_type;
	signal	mem : mem_type;

	signal	wraddr  : ptr_type := to_unsigned(0, LGFLEN+1);
	signal	r_next  : ptr_type := to_unsigned(1, LGFLEN+1);
	signal	rdaddr  : ptr_type := to_unsigned(0, LGFLEN+1);

	signal	w_first_plus_one : ptr_type;
	signal 	r_unfl : std_logic := '0';
	signal	r_ovfl : std_logic := '0';
-----
----- Formal interface wires
-----
----- Since we can't read a memory from within our bound property file,
----- we'll need to do that memory read here and then import it into our
----- property file.  This logic will quietly be removed by the synthesizer
----- if used in a synthesys context.
-----
	signal	f_const_addr      : ptr_type;
	signal	f_const_next_addr : ptr_type;
	signal	f_data_first      : data_type;
	signal	f_data_next       : data_type;

----- To know where to read from, we'll need an arbitrary constant address
----- Not the "anyconst" property used here for that purpose
-----
	attribute anyconst : bit;
	attribute anyconst of f_const_addr : signal  is '1';
begin
----- 
----- 
w_first_plus_one <= wraddr  + 1;
-- Overflow is an error, as is underflow.
o_err <= (r_unfl) or (r_ovfl);


-- Logic defining the full output.  Ideally, we might've said
--
-- o_full == '1' when (wraddr(LGFLEN-1 downto 0) == rdaddr(LGFLEN-1 downto 0))
--		and (wraddr[LGFLEN] != rdaddr[LGFLEN]) else '0';
--
-- The following logic does the same thing, only using clocked logic,
-- so the logic needs to be set one clock earlier.

process(i_clk)
begin
  if (rising_edge(i_clk)) then
	if (i_reset = '1') then
		o_full <= '0';
	elsif (i_rd) then
		if ((o_full = '1') and (i_wr = '1')) then
			o_full <= '1';
		else
			o_full <= '0';
		end if;
	elsif (i_wr) then
		if (o_full) then
			o_full <= '1';
		elsif ((w_first_plus_one(LGFLEN-1 downto 0)
						= rdaddr(LGFLEN-1 downto 0))
			    and (w_first_plus_one(LGFLEN) /= rdaddr(LGFLEN)))
			then
			o_full <= '1';
		else
			o_full <= '0';
		end if;
	elsif ((wraddr (LGFLEN-1 downto 0) = rdaddr(LGFLEN-1 downto 0))
			and (wraddr (LGFLEN) /= rdaddr(LGFLEN))) then
		o_full <= '1';
	end if;
  end if;
end process;

-- Writes to the FIFO
process(i_clk)
begin
  if (rising_edge(i_clk)) then

	if (i_reset = '1') then
		r_ovfl  <= '0';
		wraddr  <= to_unsigned(0,LGFLEN+1);
	elsif (i_wr = '1') then

		if ((i_rd = '1') or (o_full = '0')) then
			wraddr  <= wraddr  + 1;
		else
			-- Set the error flag on any overflow
			r_ovfl <= '1';
		end if;
	end if;

  end if;
end process;

-- Write our data into the FIFO
process(i_clk)
begin
  if (rising_edge(i_clk)) then
	if ((i_wr = '1') and (not (o_full = '1'))) then
		mem(to_integer(unsigned(wraddr (LGFLEN-1 downto 0)))) <= i_data;
	end if;
  end if;
end process;

-- Handle the "are we empty" output flag, o_empty
process(i_clk)
begin
  if (rising_edge(i_clk)) then
	if (i_reset = '1') then
		o_empty <= '1';
	elsif (i_wr = '1') then
		o_empty <= '0';
	elsif (i_rd = '1') then
		o_empty <= '1' when ((o_empty = '1') or (r_next = wraddr ))
				else '0';
	else
		o_empty <= '1' when (rdaddr = wraddr) else '0';
	end if;
  end if;
end process;

-- Detect underflow, and manage the last and next pointers
process(i_clk)
begin
  if (rising_edge(i_clk)) then
	if (i_reset = '1') then
		rdaddr <= to_unsigned(0,LGFLEN+1);
		r_next <= to_unsigned(1,LGFLEN+1);
		r_unfl <= '0';
	elsif (i_rd = '1') then
		if (o_empty = '0') then
			rdaddr <= r_next;
			r_next <= rdaddr + to_unsigned(2,LGFLEN+1);
		else
			-- Set the error flag on any attempt to read
			-- from an empty fifo
			r_unfl <= '1';
		end if;
	end if;
  end if;
end process;

o_data <= mem(to_integer(unsigned(rdaddr(LGFLEN-1 downto 0))));

-----------------------
-----
----- Formal interface logic
-----
----- Nothing in this file reads these wires, so they will be lost on
----- synthesis.  However, they are placed here so that we can do this
----- read for the property file.
-----------------------

f_const_next_addr <= f_const_addr + to_unsigned(1,LGFLEN+1);
f_data_first <= mem(to_integer(unsigned(f_const_addr(LGFLEN-1 downto 0))));
f_data_next  <= mem(to_integer(unsigned(f_const_next_addr(LGFLEN-1 downto 0))));

-----------------------
-----------------------
-----
-----
end behavior;
