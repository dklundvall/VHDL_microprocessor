LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.CPU_package.all;

ENTITY DataBuffer IS
	PORT(	out_en		: IN	std_logic;
			data_in		: IN	data_word;
			data_out		: OUT	data_bus);
END ENTITY;

ARCHITECTURE RTL OF DataBuffer IS

	BEGIN
	PROCESS(out_en, data_in)
	BEGIN
	
	IF out_en = '1' THEN
		data_out <= data_in;
	ELSE
		data_out <= (OTHERS => 'Z');
	END IF;
	
	END PROCESS;
END ARCHITECTURE;