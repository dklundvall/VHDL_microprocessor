library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use work.CPU_package.all;

entity RW_MEMORY is
	port(	adr				: IN 		address_bus;
			data				: INOUT	data_bus;
			clk				: IN 		std_logic;
			ce					: IN		std_logic;
			rw					: IN 		std_logic;
		   rwm_13			: OUT	std_logic_vector(3 DOWNTO 0):=(OTHERS =>'0');
			rwm_14			: OUT	std_logic_vector(3 DOWNTO 0):=(OTHERS =>'0')	
	);
end entity;

architecture Behaviour of RW_MEMORY is

--array ska vara ADR lång och data_bus bred.
	TYPE ram_reg IS ARRAY (0 TO 15) OF data_bus;
	SIGNAL ram : ram_reg:=(OTHERS=> (OTHERS=>'0'));
	
	BEGIN
	rwm_13	<=	std_logic_vector(ram(14));
	rwm_14	<=	std_logic_vector(ram(15));
	data	<=	std_logic_vector(ram(to_integer(unsigned(adr)))) WHEN ce = '0' and rw = '1' ELSE
				(OTHERS => 'Z') WHEN ce = '1' or (ce ='0' and rw = '0') ELSE
				(OTHERS => 'Z');
				
	PROCESS(clk)
	BEGIN
		IF (rising_edge(clk)) THEN
		
			IF (ce = '0') THEN
				IF (rw = '0') THEN
					--WRITE MODE
					ram(to_integer(unsigned(adr)))<= data;	
				END IF;
			END IF;
		END IF;
		
	END PROCESS;

END ARCHITECTURE;