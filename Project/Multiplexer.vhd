LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.CPU_package.all;

ENTITY Multiplexer IS
	PORT(	Sel			: IN	std_logic_vector(1 DOWNTO 0);
			Data_in_2	: IN	data_word;
			Data_in_1	: IN 	data_bus;
		   Data_in_0	: IN	data_word;
			Data_out		: OUT	data_word);	
END ENTITY;

ARCHITECTURE RTL OF Multiplexer IS

	BEGIN
	PROCESS(Sel, Data_in_0, Data_in_1, Data_in_2)
	BEGIN
		CASE Sel IS
			WHEN "00" =>	Data_out	<= Data_in_0;
			WHEN "01" =>	Data_out	<= Data_in_1;
			WHEN "10" =>	Data_out	<= Data_in_2;
			WHEN OTHERS =>	Data_out	<= (OTHERS => 'Z');
		END CASE;
		
	END PROCESS;

END ARCHITECTURE;