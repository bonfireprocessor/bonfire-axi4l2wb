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


signal read_taken : std_logic:='0';
signal write_taken : std_logic:='0';

signal wb_address : std_logic_vector(wb_addr_o'range);
signal axi_wr_adr : std_logic_vector(wb_addr_o'range);
signal axi_rd_adr : std_logic_vector(wb_addr_o'range);

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


    S_AXI_AWREADY <= not write_taken;
    S_AXI_ARREADY <= not read_taken;

    achannels: process(S_AXI_ACLK)
    begin
       if rising_edge(S_AXI_ACLK) then
         if S_AXI_ARESETN='0' then
            write_taken <= '0';
            read_taken <= '0';
         elsif stb='1' then
           if wb_ack_i='1' then
             if we='1' then
               write_taken<='0';
             else
               read_taken<='0';
             end if;  
           end if;
         else
           if  S_AXI_AWVALID='1' and write_taken='0' then
             write_taken <= '1';
             axi_wr_adr <= S_AXI_AWADDR(wb_address'high downto wb_address'low);
           end if;

           if S_AXI_ARVALID='1' and read_taken='0' then
             read_taken <= '1';
             axi_rd_adr <= S_AXI_ARADDR(wb_address'high downto wb_address'low);
           end if;
         end if;
       end if;

    end process;


  S_AXI_WREADY <= '1' when write_taken='1' and state=s_idle
                  else '0';

  wb_address <= axi_wr_adr when stb='1' and we='1' else
                axi_rd_adr when stb='1' and we='0' else (others=>'X');

  -- AXI State machine
  process(S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
       if S_AXI_ARESETN='0' then
         state <= s_idle;
         we <= '0';
         stb <= '0';
         sel <= (others=>'0');
        
         S_AXI_BVALID <= '0';
         S_AXI_RVALID <= '0';
       else
         case state is
           when s_idle =>
             S_AXI_BVALID <= '0';
             S_AXI_RVALID <= '0';
             -- process AXI address phase
             if read_taken='1' then
               stb <= '1';
               we <= '0';
               sel <= (others=> '1');
               state <= s_read;

             elsif write_taken='1' then
               if S_AXI_WVALID='1' then
                 sel <= S_AXI_WSTRB;
                 wb_dat_o <= S_AXI_WDATA;
                 stb <= '1';
                 we <= '1';
                 state <= s_write_response;
               else
                 -- when no valid write channel yet, wait for it
                 state <= s_write;
               end if;
             end if;

           when s_write => -- process "delayed" write channel
             if S_AXI_WVALID='1' then
               sel <= S_AXI_WSTRB;
               wb_dat_o <= S_AXI_WDATA;
               stb <= '1';
               we <= '1';
               state <= s_write_response;
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
