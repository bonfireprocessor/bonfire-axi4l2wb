----------------------------------------------------------------------------------
-- Module Name:    bonfire_axi4l2wb - Behavioral

-- The Bonfire Processor Project, (c) 2016,2017 Thomas Hornschuh

-- Simple AXI4 Lite Slave to Wishbone  master bridge

-- License: See LICENSE or LICENSE.txt File in git project root.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;

entity bonfire_axi4l2wb is

generic (
    ADRWIDTH  : integer := 15;
    DATAWIDTH : integer := 32);

  port (
    ---------------------------------------------------------------------------
    -- AXI Interface
    ---------------------------------------------------------------------------
    -- Clock and Reset
    S_AXI_ACLK    : in  std_logic;
    S_AXI_ARESETN : in  std_logic;
    -- Write Address Channel
    S_AXI_AWADDR  : in  std_logic_vector(ADRWIDTH-1 downto 0);
    S_AXI_AWVALID : in  std_logic;
    S_AXI_AWREADY : out std_logic;
    -- Write Data Channel
    S_AXI_WDATA   : in  std_logic_vector(31 downto 0);
    S_AXI_WSTRB   : in  std_logic_vector(3 downto 0);
    S_AXI_WVALID  : in  std_logic;
    S_AXI_WREADY  : out std_logic;
    -- Read Address Channel
    S_AXI_ARADDR  : in  std_logic_vector(ADRWIDTH-1 downto 0);
    S_AXI_ARVALID : in  std_logic;
    S_AXI_ARREADY : out std_logic;
    -- Read Data Channel
    S_AXI_RDATA   : out std_logic_vector(31 downto 0);
    S_AXI_RRESP   : out std_logic_vector(1 downto 0);
    S_AXI_RVALID  : out std_logic;
    S_AXI_RREADY  : in  std_logic;
    -- Write Response Channel
    S_AXI_BRESP   : out std_logic_vector(1 downto 0);
    S_AXI_BVALID  : out std_logic;
    S_AXI_BREADY  : in  std_logic;

    -- Wishbone interface
    wb_clk_o      : out std_logic;
    wb_rst_o      : out std_logic;

    wb_addr_o     : out std_logic_vector(ADRWIDTH-1 downto 2);
    wb_dat_o      : out std_logic_vector(31 downto 0);
    wb_we_o       : out std_logic;
    wb_sel_o      : out std_logic_vector(3 downto 0);
    wb_stb_o      : out std_logic;
    wb_cyc_o      : out std_logic;

    wb_dat_i      : in  std_logic_vector(31 downto 0);
    wb_ack_i      : in  std_logic
    );

end bonfire_axi4l2wb;


architecture Behavioral of bonfire_axi4l2wb is

signal axi_wready : std_logic := '0';
signal read_taken, write_taken : std_logic;

signal wb_address : std_logic_vector(wb_addr_o'range);
signal we : std_logic := '0';
signal stb : std_logic := '0';
signal sel : std_logic_vector(3 downto 0) := (others=>'0');

type t_state is (s_idle,s_read,s_write,s_write_response,s_write_finish,s_read_finish);
signal state : t_state := s_idle;

begin

   wb_clk_o <= S_AXI_ACLK;
   wb_rst_o <= not S_AXI_ARESETN;
   wb_addr_o <= wb_address;
   wb_stb_o <= stb;
   wb_cyc_o <= stb;
   wb_sel_o <= sel;
   wb_we_o <= we;

   S_AXI_BRESP <= "00";
   S_AXI_RRESP <= "00";
  



   -- Implement "Valid with Ready handshake" as in Figure 3.3 of the AXI SPEC
   -- The "*taken" signals will be active for one clock only, because
   -- the master should deassert *VALID after *READY becomes true
   chan_arbiter:  process (S_AXI_AWVALID,S_AXI_ARVALID,state) begin

    read_taken <= '0';
    write_taken <= '0';
    if state=s_idle then
      if S_AXI_AWVALID='1' then  -- Assume write has prio over read
         write_taken <= '1';
      elsif S_AXI_ARVALID='1' then
         read_taken <= '1';
      end if;
    end if;
  end process;

  S_AXI_AWREADY <= write_taken;
  S_AXI_ARREADY <= read_taken;
  S_AXI_WREADY <= axi_wready or write_taken;

  -- AXI State machine
  process(S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
       if S_AXI_ARESETN='0' then
         state <= s_idle;
         we <= '0';
         stb <= '0';
         sel <= (others=>'0');
         axi_wready <= '0';
         S_AXI_BVALID <= '0';
         S_AXI_RVALID <= '0';
       else
         case state is
           when s_idle =>
             S_AXI_BVALID <= '0';
             S_AXI_RVALID <= '0';
             -- process AXI address phase
             if read_taken='1' then
               wb_address <= S_AXI_ARADDR(wb_address'high downto wb_address'low);
               stb <= '1';
               we <= '0';
               sel <= (others=> '1');
               state <= s_read;

             elsif write_taken='1' then
               wb_address <= S_AXI_AWADDR(wb_address'high downto wb_address'low);
               if S_AXI_WVALID='1' then
                 sel <= S_AXI_WSTRB;
                 wb_dat_o <= S_AXI_WDATA;
                 stb <= '1';
                 we <= '1';
                 state <= s_write_response;
                 axi_wready <='0';
               else 
                 -- when no valid write channel yet, wait for it                
                 state <= s_write;
                 axi_wready <= '1';
               end if;
             end if;

           when s_write => -- process "delayed" write channel
             if S_AXI_WVALID='1' then
               sel <= S_AXI_WSTRB;
               wb_dat_o <= S_AXI_WDATA;
               stb <= '1';
               we <= '1';
               state <= s_write_response;
               axi_wready <='0';
             end if;
           when s_write_response =>
             if wb_ack_i = '1' then
               S_AXI_BVALID <= '1';
               if S_AXI_BREADY='1' then
                 state <= s_idle;
               else
                 state <= s_write_finish;
               end if;
               stb <= '0';
               we <= '0';
            end if;
           when  s_write_finish =>
             if S_AXI_BREADY='1' then
               S_AXI_BVALID <= '0';
               state <= s_idle;
             end if;

           when s_read =>
             if wb_ack_i='1' then
               S_AXI_RDATA <= wb_dat_i;
               stb <= '0';
               S_AXI_RVALID <= '1';
               if S_AXI_RREADY='1' then
                 state <= s_idle;
               else
                 state <= s_read_finish;
               end if;
             end if;
           when s_read_finish =>
             if S_AXI_RREADY='1' then
               state <= s_idle;
               S_AXI_RVALID <= '0';
             end if;
         end case;
       end if;
    end if;

  end process;


end Behavioral;
