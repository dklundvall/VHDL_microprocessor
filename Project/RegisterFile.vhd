LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.CPU_package.all;

ENTITY RegisterFile IS
	PORT(	clk				:	IN 	std_logic;
			data_in			:	IN 	data_word;
			data_out_1		:	OUT	data_word;
			data_out_0		:	OUT	data_word;
			sel_in			:	IN	std_logic_vector(1 DOWNTO 0);
			sel_out_1		:	IN	std_logic_vector(1 DOWNTO 0);
			sel_out_0		:	IN	std_logic_vector(1 DOWNTO 0);
			rw_reg			:	IN	std_logic);
END ENTITY;

ARCHITECTURE RTL OF RegisterFile IS	

	TYPE register_table IS ARRAY (0 TO 3) OF data_word;
	SIGNAL register_list : register_table:=(OTHERS =>(OTHERS => '0'));
	
BEGIN
	
	data_out_0 <= register_list(to_integer(unsigned(sel_out_0)));
	data_out_1 <= register_list(to_integer(unsigned(sel_out_1)));

	PROCESS(clk, rw_reg)
		BEGIN	
		
		IF rising_edge(clk) and rw_reg = '0' THEN
			register_list(to_integer(unsigned(sel_in))) <= data_in;		
		END IF;	
	
	END PROCESS;	
END ARCHITECTURE;
