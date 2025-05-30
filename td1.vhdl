library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ThreeBusMultiplier is
    Port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        valid_in   : in  std_logic;
        A_in       : in  std_logic_vector(7 downto 0);
        B_in       : in  std_logic_vector(7 downto 0);
        C_in       : in  std_logic_vector(7 downto 0);
        result     : out std_logic_vector(15 downto 0);
        valid_out  : out std_logic
    );
end ThreeBusMultiplier;

architecture Behavioral of ThreeBusMultiplier is

    type state_type is (IDLE, STORE_B, STORE_C, CALC1, CALC2, CALC3);
    signal state : state_type := IDLE;

    signal A_reg, B_reg, C_reg : std_logic_vector(7 downto 0);
    signal result_reg          : std_logic_vector(15 downto 0);
    signal valid_out_reg       : std_logic;

begin

    process(clk, reset)
    begin
        if reset = '1' then
            state          <= IDLE;
            A_reg          <= (others => '0');
            B_reg          <= (others => '0');
            C_reg          <= (others => '0');
            result_reg     <= (others => '0');
            valid_out_reg  <= '0';
        elsif rising_edge(clk) then
            valid_out_reg <= '0'; -- default

            case state is
                when IDLE =>
                    if valid_in = '1' then
                        A_reg <= A_in;
                        state <= STORE_B;
                    end if;

                when STORE_B =>
                    B_reg <= B_in;
                    state <= STORE_C;

                when STORE_C =>
                    C_reg <= C_in;
                    state <= CALC1;

                when CALC1 =>
                    result_reg <= std_logic_vector(unsigned(A_reg) * unsigned(B_reg));
                    valid_out_reg <= '1';
                    state <= CALC2;

                when CALC2 =>
                    result_reg <= std_logic_vector(unsigned(A_reg) * unsigned(C_reg));
                    state <= CALC3;

                when CALC3 =>
                    result_reg <= std_logic_vector(unsigned(B_reg) * unsigned(C_reg));
                    state <= IDLE;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

    result     <= result_reg;
    valid_out  <= valid_out_reg;

end Behavioral;
/* Mon test bench */ 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ThreeBusMultiplier is
end tb_ThreeBusMultiplier;

architecture Behavioral of tb_ThreeBusMultiplier is

    signal clk        : std_logic := '0';
    signal reset      : std_logic := '1';
    signal valid_in   : std_logic := '0';
    signal A_in       : std_logic_vector(7 downto 0) := (others => '0');
    signal B_in       : std_logic_vector(7 downto 0) := (others => '0');
    signal C_in       : std_logic_vector(7 downto 0) := (others => '0');
    signal result     : std_logic_vector(15 downto 0);
    signal valid_out  : std_logic;

    constant clk_period : time := 10 ns;

    component ThreeBusMultiplier
        Port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            valid_in   : in  std_logic;
            A_in       : in  std_logic_vector(7 downto 0);
            B_in       : in  std_logic_vector(7 downto 0);
            C_in       : in  std_logic_vector(7 downto 0);
            result     : out std_logic_vector(15 downto 0);
            valid_out  : out std_logic
        );
    end component;

begin

    uut: ThreeBusMultiplier
        port map (
            clk        => clk,
            reset      => reset,
            valid_in   => valid_in,
            A_in       => A_in,
            B_in       => B_in,
            C_in       => C_in,
            result     => result,
            valid_out  => valid_out
        );

    -- Clock generation
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus
    stim_proc: process
    begin
        -- Initial reset
        wait for 20 ns;
        reset <= '0';

        -- Send A = 5, then B = 6, then C = 7
        wait for clk_period;
        A_in <= x"05";
        valid_in <= '1';

        wait for clk_period;
        valid_in <= '0';
        B_in <= x"06";

        wait for clk_period;
        C_in <= x"07";

        -- Wait for 5 more cycles to capture output
        wait for 50 ns;

        -- Send second set: A = 10, B = 3, C = 2
        A_in <= x"0A";
        valid_in <= '1';

        wait for clk_period;
        valid_in <= '0';
        B_in <= x"03";

        wait for clk_period;
        C_in <= x"02";

        wait for 50 ns;

        wait;
    end process;

end Behavioral;
