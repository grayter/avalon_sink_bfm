library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library types;
use types.bus_data_types_pkg.all;

library bfm;

-- This bfm simply acknowledges the data that it receives, such that data flow
-- is maintained. It has a configuration interface that allows testbenches to
-- adjust how willing it is to ack data. It is expected that testbenches that
-- wish to verify the data contained in a transaction do so through some form
-- of higher level scoreboarding mechanism rather than embedding the check here.

package avalon_sink_bfm_pkg is
  component avalon_sink_bfm
    port (
      -- Clocking
      clk        : in  std_ulogic;
      reset      : in  std_ulogic;
      -- Configuration
      pause_pct  : in  natural range 0 to 99;
      -- Inputs
      packet     : in  types.bus_data_types_pkg.AVALON_DATA_STREAM_PACKET_t;
      packet_ack : out types.bus_data_types_pkg.ACK_t
      );
  end component;
end avalon_sink_bfm_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library types;
use types.bus_data_types_pkg.all;  -- needed for records, might want to move

library osvvm;
context osvvm.OsvvmContext;

library bfm;

entity avalon_sink_bfm is
  port (
    -- Clocking
    clk        : in  std_ulogic;
    reset      : in  std_ulogic;
    -- Configuration
    pause_pct  : in  natural range 0 to 99;
    -- Inputs
    packet     : in  types.bus_data_types_pkg.AVALON_DATA_STREAM_PACKET_t;
    packet_ack : out types.bus_data_types_pkg.ACK_t
    );
end avalon_sink_bfm;

architecture bfm of avalon_sink_bfm is
  signal ready : std_ulogic;
begin

  -- Handle acks based on our ready signal
  packet_ack.ack <= '1' when packet.valid and ready else '0';

  -- Generate ready signal
  process(clk, reset) is
    variable RV         : RandomPType;
    variable gen_chance : integer;
  begin
    if rising_edge(clk) then
      gen_chance := RV.RandInt(0, 100);
      if gen_chance >= pause_pct then
        ready <= '1';
      else
        ready <= '0';
      end if;
    end if;

    if reset then
      gen_chance := 0;
      ready <= '0';
      RV.InitSeed(RV'instance_name);      
    end if;
  end process;

end architecture;
