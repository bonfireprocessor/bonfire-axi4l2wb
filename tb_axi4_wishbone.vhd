--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   20:51:54 02/01/2018
-- Design Name:
-- Module Name:   /home/thomas/fusesoc_projects/bonfire/bonfire-axi4l2wb/tb_axi4_wishbone.vhd
-- Project Name:  bonfire-axi4l2wb_0
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: bonfire_axi4l2wb
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

LIBRARY std;
USE std.textio.all;
use work.txt_util.all;

ENTITY tb_axi4_wishbone IS
END tb_axi4_wishbone;

ARCHITECTURE behavior OF tb_axi4_wishbone IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT bonfire_axi4l2wb
    GENERIC (
        ADRWIDTH  : integer := 15; -- Width of the AXI Address Bus, the Wishbone Adr- Bus coresponds with it, but without the lowest adress bits
        FAST_READ_TERM : boolean := TRUE -- TRUE: Allows AXI read termination in same cycle as
        );
    PORT(
         S_AXI_ACLK : IN  std_logic;
         S_AXI_ARESETN : IN  std_logic;
         S_AXI_AWADDR : IN  std_logic_vector(14 downto 0);
         S_AXI_AWVALID : IN  std_logic;
         S_AXI_AWREADY : OUT  std_logic;
         S_AXI_WDATA : IN  std_logic_vector(31 downto 0);
         S_AXI_WSTRB : IN  std_logic_vector(3 downto 0);
         S_AXI_WVALID : IN  std_logic;
         S_AXI_WREADY : OUT  std_logic;
         S_AXI_ARADDR : IN  std_logic_vector(14 downto 0);
         S_AXI_ARVALID : IN  std_logic;
         S_AXI_ARREADY : OUT  std_logic;
         S_AXI_RDATA : OUT  std_logic_vector(31 downto 0);
         S_AXI_RRESP : OUT  std_logic_vector(1 downto 0);
         S_AXI_RVALID : OUT  std_logic;
         S_AXI_RREADY : IN  std_logic;
         S_AXI_BRESP : OUT  std_logic_vector(1 downto 0);
         S_AXI_BVALID : OUT  std_logic;
         S_AXI_BREADY : IN  std_logic;
         wb_clk_o : OUT  std_logic;
         wb_rst_o : OUT  std_logic;
         wb_addr_o : OUT  std_logic_vector(14 downto 2);
         wb_dat_o : OUT  std_logic_vector(31 downto 0);
         wb_we_o : OUT  std_logic;
         wb_sel_o : OUT  std_logic_vector(3 downto 0);
         wb_stb_o : OUT  std_logic;
         wb_cyc_o : OUT  std_logic;
         wb_dat_i : IN  std_logic_vector(31 downto 0);
         wb_ack_i : IN  std_logic
        );
    END COMPONENT;


   --Inputs
   signal S_AXI_ACLK : std_logic := '0';
   signal S_AXI_ARESETN : std_logic := '1';
   signal S_AXI_AWADDR : std_logic_vector(14 downto 0) := (others => '0');
   signal S_AXI_AWVALID : std_logic := '0';
   signal S_AXI_WDATA : std_logic_vector(31 downto 0) := (others => '0');
   signal S_AXI_WSTRB : std_logic_vector(3 downto 0) := (others => '0');
   signal S_AXI_WVALID : std_logic := '0';
   signal S_AXI_ARADDR : std_logic_vector(14 downto 0) := (others => '0');
   signal S_AXI_ARVALID : std_logic := '0';
   signal S_AXI_RREADY : std_logic := '0';
   signal S_AXI_BREADY : std_logic := '0';
   signal wb_dat_i : std_logic_vector(31 downto 0) := (others => '0');
   signal wb_ack_i : std_logic := '0';

    --Outputs
   signal S_AXI_AWREADY : std_logic;
   signal S_AXI_WREADY : std_logic;
   signal S_AXI_ARREADY : std_logic;
   signal S_AXI_RDATA : std_logic_vector(31 downto 0);
   signal S_AXI_RRESP : std_logic_vector(1 downto 0);
   signal S_AXI_RVALID : std_logic;
   signal S_AXI_BRESP : std_logic_vector(1 downto 0);
   signal S_AXI_BVALID : std_logic;
   signal wb_clk_o : std_logic;
   signal wb_rst_o : std_logic;
   signal wb_addr_o : std_logic_vector(14 downto 2);
   signal wb_dat_o : std_logic_vector(31 downto 0);
   signal wb_we_o : std_logic;
   signal wb_sel_o : std_logic_vector(3 downto 0);
   signal wb_stb_o : std_logic;
   signal wb_cyc_o : std_logic;

   -- Clock period definitions
   constant S_AXI_ACLK_period : time := 10 ns;

   subtype t_address is std_logic_vector(31 downto 0);
   subtype t_data is std_logic_vector(S_AXI_WDATA'high downto S_AXI_WDATA'low);

   signal stop : boolean:=FALSE;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: bonfire_axi4l2wb
   GENERIC MAP (
      FAST_READ_TERM => TRUE
   )
   PORT MAP (
          S_AXI_ACLK => S_AXI_ACLK,
          S_AXI_ARESETN => S_AXI_ARESETN,
          S_AXI_AWADDR => S_AXI_AWADDR,
          S_AXI_AWVALID => S_AXI_AWVALID,
          S_AXI_AWREADY => S_AXI_AWREADY,
          S_AXI_WDATA => S_AXI_WDATA,
          S_AXI_WSTRB => S_AXI_WSTRB,
          S_AXI_WVALID => S_AXI_WVALID,
          S_AXI_WREADY => S_AXI_WREADY,
          S_AXI_ARADDR => S_AXI_ARADDR,
          S_AXI_ARVALID => S_AXI_ARVALID,
          S_AXI_ARREADY => S_AXI_ARREADY,
          S_AXI_RDATA => S_AXI_RDATA,
          S_AXI_RRESP => S_AXI_RRESP,
          S_AXI_RVALID => S_AXI_RVALID,
          S_AXI_RREADY => S_AXI_RREADY,
          S_AXI_BRESP => S_AXI_BRESP,
          S_AXI_BVALID => S_AXI_BVALID,
          S_AXI_BREADY => S_AXI_BREADY,
          wb_clk_o => wb_clk_o,
          wb_rst_o => wb_rst_o,
          wb_addr_o => wb_addr_o,
          wb_dat_o => wb_dat_o,
          wb_we_o => wb_we_o,
          wb_sel_o => wb_sel_o,
          wb_stb_o => wb_stb_o,
          wb_cyc_o => wb_cyc_o,
          wb_dat_i => wb_dat_i,
          wb_ack_i => wb_ack_i
        );

   -- Clock process definitions
   S_AXI_ACLK_process :process
   begin
        while not stop loop
          S_AXI_ACLK <= '0';
          wait for S_AXI_ACLK_period/2;
          S_AXI_ACLK <= '1';
          wait for S_AXI_ACLK_period/2;
       end loop;
       wait;
   end process;

   -- Wishbone dummy cycle termination
   wb_ack_i <= wb_cyc_o and wb_stb_o;

   wb_dat_i <= X"AA55AA11" when wb_cyc_o='1' and wb_we_o='0'
               else (others=>'U');


   process
   begin

     wait until rising_edge(S_AXI_ACLK);
     if wb_ack_i='1' and wb_cyc_o='1' then
       if wb_we_o='1' then
         print(OUTPUT,"WB Write to Adresss: " & str(wb_addr_o) & " Data: " & hstr(wb_dat_o) );
       else
         print(OUTPUT,"WB read from Adresss: " & str(wb_addr_o) & " Data: " & hstr(wb_dat_i) );
       end if;
     end if;

   end process;


   -- Stimulus process
   stim_proc: process
   variable wrdy,awrdy,bvalid : boolean;
   variable rvalid,arrdy : boolean;
   variable t: t_data;
   variable adr : natural;
   variable count : natural;

   procedure start_write(adr: t_address;data : t_data) is
   begin

      S_AXI_AWADDR <= adr(S_AXI_AWADDR'range);
      S_AXI_AWVALID <= '1';
      S_AXI_WDATA  <= data;
      S_AXI_WSTRB <= (others => '1');
      S_AXI_WVALID <= '1';
      S_AXI_BREADY <= '1';
   end procedure;


   procedure start_read(adr: t_address; r_ready: std_logic) is
   begin
     S_AXI_ARADDR <= adr(S_AXI_ARADDR'range);
     S_AXI_ARVALID <= '1';
     S_AXI_RREADY <= r_ready;

   end procedure;

   begin
      -- hold reset state for 100 ns.


      wait for S_AXI_ACLK_period*1;

      -- Write cycle test
      wait until rising_edge(S_AXI_ACLK);
      start_write((others =>'0'), X"55AAFF55");

      wait until rising_edge(S_AXI_ACLK);
      wrdy := false; awrdy := false; bvalid:=false;
      while not wrdy or not awrdy or not bvalid loop
        if S_AXI_AWREADY='1' then
           S_AXI_AWVALID <= '0';
           print(OUTPUT,"AW Phase OK");
           awrdy := true;
        end if;
        if S_AXI_WREADY='1' then
           S_AXI_WVALID <= '0';
           wrdy := true;
          print(OUTPUT,"Write Phase OK");
        end if;
        if S_AXI_BVALID='1' then
          print(OUTPUT,"WRITE RESPONSE OK");
          bvalid:=true;
        end if;
        wait until rising_edge(S_AXI_ACLK);
      end loop;


      -- Read Test with RREADY=1 upfront

      start_read((others=>'0'),'1');
      wait until rising_edge(S_AXI_ACLK);
      rvalid:=false; arrdy:=false;
      while not rvalid or not arrdy loop
        if S_AXI_ARREADY='1' then
          S_AXI_ARVALID<='0';
          arrdy := true;
          print(OUTPUT,"AR Phase OK");
        end if;
        if S_AXI_RVALID='1' then
          print(OUTPUT,"Read data: " & hstr(S_AXI_RDATA));
          rvalid:=true;
          S_AXI_RREADY <= '0';
        end if;
        wait until rising_edge(S_AXI_ACLK);
      end loop;


     -- Read Test with RREADY=0 upfront
      print(OUTPUT,"Read with RREADY=0 upfront");
      start_read((others=>'0'),'0');
      wait until rising_edge(S_AXI_ACLK);
      rvalid:=false; arrdy:=false;
      while not rvalid or not arrdy loop
        if S_AXI_ARREADY='1' then
          S_AXI_ARVALID<='0';
          arrdy := true;
          print(OUTPUT,"AR Phase OK");
        end if;
        if S_AXI_RVALID='1' then
          print(OUTPUT,"Read data: " & hstr(S_AXI_RDATA));
          rvalid:=true;
          S_AXI_RREADY <= '1';
        end if;
        wait until rising_edge(S_AXI_ACLK);
      end loop;
     S_AXI_RREADY <= '0';
     wait until rising_edge(S_AXI_ACLK);

     -- Test Read and write together
     print(OUTPUT,"Overlapping R/W");
     start_write((others =>'0'), X"55AAFF55");
     start_read((others=>'0'),'1');
     wait until rising_edge(S_AXI_ACLK);
     rvalid:=false; arrdy:=false;
     wrdy := false; awrdy := false; bvalid:=false;
     while not wrdy or not awrdy or not rvalid or not arrdy  or not bvalid loop
        if S_AXI_AWREADY='1' then
           S_AXI_AWVALID <= '0';
           awrdy := true;
           print(OUTPUT,"AW Phase OK");
        end if;
        if S_AXI_WREADY='1' then
           S_AXI_WVALID <= '0';
           print(OUTPUT,"Write Phase OK");
           wrdy := true;
        end if;
        if S_AXI_ARREADY='1' then
          S_AXI_ARVALID<='0';
          arrdy := true;
          print(OUTPUT,"AR Phase OK");
        end if;
        if S_AXI_RVALID='1' then
          print(OUTPUT,"Read data: " & hstr(S_AXI_RDATA));
          rvalid:=true;
          S_AXI_RREADY <= '0';
        end if;
        if S_AXI_BVALID='1' then
          print(OUTPUT,"WRITE RESPONSE OK");
          bvalid:=true;
        end if;
        wait until rising_edge(S_AXI_ACLK);
      end loop;

      -- Write without waiting for BREADY

      print(OUTPUT,"Multiple Write Test");
      for i in 0 to 5 loop
        t:=std_logic_vector(to_unsigned(i,t'length) sll 2 );
        start_write(t,t);
        wait until rising_edge(S_AXI_ACLK);
        wrdy := false; awrdy := false;
        while not wrdy or not awrdy loop
          if S_AXI_AWREADY='1' then
             S_AXI_AWVALID <= '0';
             print(OUTPUT,"AW Phase OK");
             awrdy := true;
          end if;
          if S_AXI_WREADY='1' then
            S_AXI_WVALID <= '0';
            wrdy := true;
            print(OUTPUT,"Write Phase OK");
          end if;

          wait until rising_edge(S_AXI_ACLK);
        end loop;
      end loop;

      --Overlapping read
      -- Inject Read Cycles
      print(OUTPUT,"Overlapping read test");
      adr := 0;
      count := 0;
      while adr <=3  or count <=3 loop
         t:=std_logic_vector(to_unsigned(adr,t'length) sll 2 );
         start_read(t,'1');
         wait until rising_edge(S_AXI_ACLK);

         if adr>3 then
           S_AXI_ARVALID<='0';
          -- Increment Address whenever ARREADY becomes TRUE
         elsif S_AXI_ARREADY='1' then
           adr := adr + 1;
           print(OUTPUT,"Read Adress Phase: " & str(adr));
         end if;

         if S_AXI_RVALID='1' then -- Data read...
           count := count  + 1;
           print(OUTPUT,"Read OK: " & str(count));
         end if;
      end loop;

      wait until wb_cyc_o='0'; -- Let the last Wishbone cycle terminate
      report "Finished";
      stop <= TRUE;
      wait;
   end process;

END;
