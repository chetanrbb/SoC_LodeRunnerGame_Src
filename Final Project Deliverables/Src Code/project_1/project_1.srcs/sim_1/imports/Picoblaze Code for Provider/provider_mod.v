//
///////////////////////////////////////////////////////////////////////////////////////////
// Copyright © 2010-2014, Xilinx, Inc.
// This file contains confidential and proprietary information of Xilinx, Inc. and is
// protected under U.S. and international copyright and other intellectual property laws.
///////////////////////////////////////////////////////////////////////////////////////////
//
// Disclaimer:
// This disclaimer is not a license and does not grant any rights to the materials
// distributed herewith. Except as otherwise provided in a valid license issued to
// you by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE
// MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY
// DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
// INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT,
// OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable
// (whether in contract or tort, including negligence, or under any other theory
// of liability) for any loss or damage of any kind or nature related to, arising
// under or in connection with these materials, including for any direct, or any
// indirect, special, incidental, or consequential loss or damage (including loss
// of data, profits, goodwill, or any type of loss or damage suffered as a result
// of any action brought by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-safe, or for use in any
// application requiring fail-safe performance, such as life-support or safety
// devices or systems, Class III medical devices, nuclear facilities, applications
// related to the deployment of airbags, or any other applications that could lead
// to death, personal injury, or severe property or environmental damage
// (individually and collectively, "Critical Applications"). Customer assumes the
// sole risk and liability of any use of Xilinx products in Critical Applications,
// subject only to applicable laws and regulations governing limitations on product
// liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
///////////////////////////////////////////////////////////////////////////////////////////
//
//
// Definition of a program memory for KCPSM6 including generic parameters for the 
// convenient selection of device family, program memory size and the ability to include 
// the JTAG Loader hardware for rapid software development.
//
// This file is primarily for use during code development and it is recommended that the 
// appropriate simplified program memory definition be used in a final production design. 
//
//
//    Generic                  Values             Comments
//    Parameter                Supported
//  
//    C_FAMILY                 "7S"               7-Series device 
//                                                  (Artix-7, Kintex-7, Virtex-7 or Zynq)
//                             "US"               UltraScale device
//                                                  (Kintex UltraScale and Virtex UltraScale)
//
//    C_RAM_SIZE_KWORDS        1, 2 or 4          Size of program memory in K-instructions
//
//    C_JTAG_LOADER_ENABLE     0 or 1             Set to '1' to include JTAG Loader
//
// Notes
//
// If your design contains MULTIPLE KCPSM6 instances then only one should have the 
// JTAG Loader enabled at a time (i.e. make sure that C_JTAG_LOADER_ENABLE is only set to 
// '1' on one instance of the program memory). Advanced users may be interested to know 
// that it is possible to connect JTAG Loader to multiple memories and then to use the 
// JTAG Loader utility to specify which memory contents are to be modified. However, 
// this scheme does require some effort to set up and the additional connectivity of the 
// multiple BRAMs can impact the placement, routing and performance of the complete 
// design. Please contact the author at Xilinx for more detailed information. 
//
// Regardless of the size of program memory specified by C_RAM_SIZE_KWORDS, the complete 
// 12-bit address bus is connected to KCPSM6. This enables the generic to be modified 
// without requiring changes to the fundamental hardware definition. However, when the 
// program memory is 1K then only the lower 10-bits of the address are actually used and 
// the valid address range is 000 to 3FF hex. Likewise, for a 2K program only the lower 
// 11-bits of the address are actually used and the valid address range is 000 to 7FF hex.
//
// Programs are stored in Block Memory (BRAM) and the number of BRAM used depends on the 
// size of the program and the device family. 
//
// In a Spartan-6 device a BRAM is capable of holding 1K instructions. Hence a 2K program 
// will require 2 BRAMs to be used and a 4K program will require 4 BRAMs to be used. It 
// should be noted that a 4K program is not such a natural fit in a Spartan-6 device and 
// the implementation also requires a small amount of logic resulting in slightly lower 
// performance. A Spartan-6 BRAM can also be split into two 9k-bit memories suggesting 
// that a program containing up to 512 instructions could be implemented. However, there 
// is a silicon errata which makes this unsuitable and therefore it is not supported by 
// this file.
//
// In a Virtex-6 or any 7-Series device a BRAM is capable of holding 2K instructions so 
// obviously a 2K program requires only a single BRAM. Each BRAM can also be divided into 
// 2 smaller memories supporting programs of 1K in half of a 36k-bit BRAM (generally 
// reported as being an 18k-bit BRAM). For a program of 4K instructions, 2 BRAMs are used.
//
//
// Program defined by 'E:\System_on_Chip\Projects\Final\Picoblaze Code for Provider\provider_mod.psm'.
//
// Generated by KCPSM6 Assembler: 30 May 2016 - 22:00:27. 
//
// Assembler used ROM_form template: ROM_form_JTAGLoader_Vivado_2June14.v
//
//
`timescale 1ps/1ps
module provider_mod (address, instruction, enable, rdl, clk);
//
parameter integer C_JTAG_LOADER_ENABLE = 1;                        
parameter         C_FAMILY = "7S";                        
parameter integer C_RAM_SIZE_KWORDS = 2;                        
//
input         clk;        
input  [11:0] address;        
input         enable;        
output [17:0] instruction;        
output        rdl;
//
//
wire [15:0] address_a;
wire [35:0] data_in_a;
wire [35:0] data_out_a;
wire [35:0] data_out_a_l;
wire [35:0] data_out_a_h;
wire [15:0] address_b;
wire [35:0] data_in_b;
wire [35:0] data_in_b_l;
wire [35:0] data_out_b;
wire [35:0] data_out_b_l;
wire [35:0] data_in_b_h;
wire [35:0] data_out_b_h;
wire        enable_b;
wire        clk_b;
wire [7:0]  we_b;
//
wire [11:0] jtag_addr;
wire        jtag_we;
wire        jtag_clk;
wire [17:0] jtag_din;
wire [17:0] jtag_dout;
wire [17:0] jtag_dout_1;
wire [0:0]  jtag_en;
//
wire [0:0]  picoblaze_reset;
wire [0:0]  rdl_bus;
//
parameter integer BRAM_ADDRESS_WIDTH = addr_width_calc(C_RAM_SIZE_KWORDS);
//
//
function integer addr_width_calc;
  input integer size_in_k;
    if (size_in_k == 1) begin addr_width_calc = 10; end
      else if (size_in_k == 2) begin addr_width_calc = 11; end
      else if (size_in_k == 4) begin addr_width_calc = 12; end
      else begin
        if (C_RAM_SIZE_KWORDS != 1 && C_RAM_SIZE_KWORDS != 2 && C_RAM_SIZE_KWORDS != 4) begin
          //#0;
          $display("Invalid BlockRAM size. Please set to 1, 2 or 4 K words..\n");
          $finish;
        end
    end
endfunction
//
//
generate
  if (C_RAM_SIZE_KWORDS == 1) begin : ram_1k_generate 
    //
    if (C_FAMILY == "7S") begin: akv7 
      //
      assign address_a[13:0] = {address[9:0], 4'b1111};
      assign instruction = data_out_a[17:0];
      assign data_in_a[17:0] = {16'b0000000000000000, address[11:10]};
      assign jtag_dout = data_out_b[17:0];
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b[17:0] = data_out_b[17:0];
        assign address_b[13:0] = 14'b11111111111111;
        assign we_b[3:0] = 4'b0000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b[17:0] = jtag_din[17:0];
        assign address_b[13:0] = {jtag_addr[9:0], 4'b1111};
        assign we_b[3:0] = {jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB18E1 #(.READ_WIDTH_A              (18),
                 .WRITE_WIDTH_A             (18),
                 .DOA_REG                   (0),
                 .INIT_A                    (18'b000000000000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (18'b000000000000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (18),
                 .WRITE_WIDTH_B             (18),
                 .DOB_REG                   (0),
                 .INIT_B                    (18'b000000000000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (18'b000000000000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .SIM_DEVICE                ("7SERIES"),
                 .IS_CLKARDCLK_INVERTED     (0),
                 .IS_CLKBWRCLK_INVERTED     (0),
                 .IS_ENARDEN_INVERTED       (0),
                 .IS_ENBWREN_INVERTED       (0),
                 .IS_RSTRAMARSTRAM_INVERTED (0),
                 .IS_RSTRAMB_INVERTED       (0),
                 .IS_RSTREGARSTREG_INVERTED (0),
                 .IS_RSTREGB_INVERTED       (0),
                 .INIT_00                   (256'hF02C10016014D101B12DB02C041304130413F02DF02C10002004200420042004),
                 .INIT_01                   (256'hF010F00CF00810006007D000D02BF02C9001B02CF12D11012007D02B2014D016),
                 .INIT_02                   (256'hF00FF00D1090F00B1090F0091020F004F003F002F001F016F012F00EF00AF014),
                 .INIT_03                   (256'h1002D026D026004400B000A400980085011B010A00F900E82031D000B0008001),
                 .INIT_04                   (256'hD005B00DD004B00CD002B00AD003B00BD000B008D001B0092031F0008000B000),
                 .INIT_05                   (256'hD00DB015D00CB014D00BB013D00AB012D009B011D008B010D007B00FD006B00E),
                 .INIT_06                   (256'hD01AB01DD019B01CD017B01BD015B01AD013B019D011B018D00FB017D00EB016),
                 .INIT_07                   (256'hD022B025D021B024D020B023D01FB022D01EB021D01DB020D01CB01FD01BB01E),
                 .INIT_08                   (256'hD60200BCF52400C9F52000E0B41CB30BB20AB109B0085000D024B027D023B026),
                 .INIT_09                   (256'h00C9F52100E0B41DB30FB20EB10DB00C5000F618D02C100F2096D02C10006094),
                 .INIT_0A                   (256'h5000F61A00BCF52600C9F52200E0B41EB313B212B111B0105000F61900BCF525),
                 .INIT_0B                   (256'h500000C260C0D4035000F61B00BCF52700C9F52300E0B41FB317B216B115B014),
                 .INIT_0C                   (256'h500060DED50200E01201E0CC1320160160DFD50200E01001E0C51120500000D0),
                 .INIT_0D                   (256'h5000160020DF60DED50200E01201E0DA1320160260DFD50200E09001E0D39101),
                 .INIT_0E                   (256'hB001B732B61CB52EB40BB30AB909B8085000950415001500D32AD229D128D027),
                 .INIT_0F                   (256'hB733B61DB52FB40FB30EB20DB10C5000F732F61CF52EF40BF30AF909F808012C),
                 .INIT_10                   (256'hB61EB530B413B312B211B1105000F733F61DF52FF40FF30EF20DF10C012CB002),
                 .INIT_11                   (256'hB531B417B316B215B1145000F734F61EF530F413F312F211F110012CB003B734),
                 .INIT_12                   (256'hD02C10026132D0015000F735F61FF531F417F316F215F114012CB004B735B61F),
                 .INIT_13                   (256'h6144D0042145015CD02C1004613ED00321450151D02C10036138D00221450146),
                 .INIT_14                   (256'h1600655001766150D505150115001700214AD7005000014521450167D02C1005),
                 .INIT_15                   (256'h150017022160D702500016016550017E615BD5051501150017012155D7015000),
                 .INIT_16                   (256'h655001726171D505150115001703216BD703500016026550017A6166D5051501),
                 .INIT_17                   (256'hE181940150009101E17D920150001301E179140150001801E175190150001603),
                 .INIT_18                   (256'h0000000000000000000000000000000000000000000000000000000050009301),
                 .INIT_19                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_20                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'hD001B036F0049003F0039002F0029001D02CF0019000F00010016318D001B000),
                 .INIT_31                   (256'h00000000000000000000000000009001D02CF03610002300D02CF03610016315),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h2300000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'h888888888888888888888888888888A42AAAAAD2A222AAAAA8DA48AD9C0AA8AA),
                 .INITP_01                  (256'h0002AAAA000080AA8B674D9DB674D9DAADAAA800AAA800AAA800A8A32AA00288),
                 .INITP_02                  (256'hD9D9D9D82D4360B50D82D4360B50DAA8DA8DA8DA8DAAAA80002AAAA0000AAAA8),
                 .INITP_03                  (256'h0000000000000000000000000000000000000000000000000000000000000009),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000002A2A30888A270),
                 .INITP_07                  (256'h8000000000000000000000000000000000000000000000000000000000000000))
     kcpsm6_rom( .ADDRARDADDR               (address_a[13:0]),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a[15:0]),
                 .DOPADOP                   (data_out_a[17:16]), 
                 .DIADI                     (data_in_a[15:0]),
                 .DIPADIP                   (data_in_a[17:16]), 
                 .WEA                       (2'b00),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b[13:0]),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b[15:0]),
                 .DOPBDOP                   (data_out_b[17:16]), 
                 .DIBDI                     (data_in_b[15:0]),
                 .DIPBDIP                   (data_in_b[17:16]), 
                 .WEBWE                     (we_b[3:0]),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0));
    end // akv7;  
    // 
    //
    if (C_FAMILY == "US") begin: us 
      //
      assign address_a[13:0] = {address[9:0], 4'b1111};
      assign instruction = data_out_a[17:0];
      assign data_in_a[17:0] = {16'b0000000000000000, address[11:10]};
      assign jtag_dout = data_out_b[17:0];
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b[17:0] = data_out_b[17:0];
        assign address_b[13:0] = 14'b11111111111111;
        assign we_b[3:0] = 4'b0000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b[17:0] = jtag_din[17:0];
        assign address_b[13:0] = {jtag_addr[9:0], 4'b1111};
        assign we_b[3:0] = {jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB18E2 #(.READ_WIDTH_A              (18),
                 .WRITE_WIDTH_A             (18),
                 .DOA_REG                   (0),
                 .INIT_A                    (18'b000000000000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (18'b000000000000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (18),
                 .WRITE_WIDTH_B             (18),
                 .DOB_REG                   (0),
                 .INIT_B                    (18'b000000000000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (18'b000000000000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .IS_CLKARDCLK_INVERTED     (0),
                 .IS_CLKBWRCLK_INVERTED     (0),
                 .IS_ENARDEN_INVERTED       (0),
                 .IS_ENBWREN_INVERTED       (0),
                 .IS_RSTRAMARSTRAM_INVERTED (0),
                 .IS_RSTRAMB_INVERTED       (0),
                 .IS_RSTREGARSTREG_INVERTED (0),
                 .IS_RSTREGB_INVERTED       (0),
                 .CASCADE_ORDER_A           ("NONE"),
                 .CASCADE_ORDER_B           ("NONE"),
                 .CLOCK_DOMAINS             ("INDEPENDENT"),
                 .ENADDRENA                 ("FALSE"),
                 .ENADDRENB                 ("FALSE"),
                 .RDADDRCHANGEA             ("FALSE"),
                 .RDADDRCHANGEB             ("FALSE"),
                 .SLEEP_ASYNC               ("FALSE"),
                 .INIT_00                   (256'hF02C10016014D101B12DB02C041304130413F02DF02C10002004200420042004),
                 .INIT_01                   (256'hF010F00CF00810006007D000D02BF02C9001B02CF12D11012007D02B2014D016),
                 .INIT_02                   (256'hF00FF00D1090F00B1090F0091020F004F003F002F001F016F012F00EF00AF014),
                 .INIT_03                   (256'h1002D026D026004400B000A400980085011B010A00F900E82031D000B0008001),
                 .INIT_04                   (256'hD005B00DD004B00CD002B00AD003B00BD000B008D001B0092031F0008000B000),
                 .INIT_05                   (256'hD00DB015D00CB014D00BB013D00AB012D009B011D008B010D007B00FD006B00E),
                 .INIT_06                   (256'hD01AB01DD019B01CD017B01BD015B01AD013B019D011B018D00FB017D00EB016),
                 .INIT_07                   (256'hD022B025D021B024D020B023D01FB022D01EB021D01DB020D01CB01FD01BB01E),
                 .INIT_08                   (256'hD60200BCF52400C9F52000E0B41CB30BB20AB109B0085000D024B027D023B026),
                 .INIT_09                   (256'h00C9F52100E0B41DB30FB20EB10DB00C5000F618D02C100F2096D02C10006094),
                 .INIT_0A                   (256'h5000F61A00BCF52600C9F52200E0B41EB313B212B111B0105000F61900BCF525),
                 .INIT_0B                   (256'h500000C260C0D4035000F61B00BCF52700C9F52300E0B41FB317B216B115B014),
                 .INIT_0C                   (256'h500060DED50200E01201E0CC1320160160DFD50200E01001E0C51120500000D0),
                 .INIT_0D                   (256'h5000160020DF60DED50200E01201E0DA1320160260DFD50200E09001E0D39101),
                 .INIT_0E                   (256'hB001B732B61CB52EB40BB30AB909B8085000950415001500D32AD229D128D027),
                 .INIT_0F                   (256'hB733B61DB52FB40FB30EB20DB10C5000F732F61CF52EF40BF30AF909F808012C),
                 .INIT_10                   (256'hB61EB530B413B312B211B1105000F733F61DF52FF40FF30EF20DF10C012CB002),
                 .INIT_11                   (256'hB531B417B316B215B1145000F734F61EF530F413F312F211F110012CB003B734),
                 .INIT_12                   (256'hD02C10026132D0015000F735F61FF531F417F316F215F114012CB004B735B61F),
                 .INIT_13                   (256'h6144D0042145015CD02C1004613ED00321450151D02C10036138D00221450146),
                 .INIT_14                   (256'h1600655001766150D505150115001700214AD7005000014521450167D02C1005),
                 .INIT_15                   (256'h150017022160D702500016016550017E615BD5051501150017012155D7015000),
                 .INIT_16                   (256'h655001726171D505150115001703216BD703500016026550017A6166D5051501),
                 .INIT_17                   (256'hE181940150009101E17D920150001301E179140150001801E175190150001603),
                 .INIT_18                   (256'h0000000000000000000000000000000000000000000000000000000050009301),
                 .INIT_19                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_20                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'hD001B036F0049003F0039002F0029001D02CF0019000F00010016318D001B000),
                 .INIT_31                   (256'h00000000000000000000000000009001D02CF03610002300D02CF03610016315),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h2300000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'h888888888888888888888888888888A42AAAAAD2A222AAAAA8DA48AD9C0AA8AA),
                 .INITP_01                  (256'h0002AAAA000080AA8B674D9DB674D9DAADAAA800AAA800AAA800A8A32AA00288),
                 .INITP_02                  (256'hD9D9D9D82D4360B50D82D4360B50DAA8DA8DA8DA8DAAAA80002AAAA0000AAAA8),
                 .INITP_03                  (256'h0000000000000000000000000000000000000000000000000000000000000009),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000002A2A30888A270),
                 .INITP_07                  (256'h8000000000000000000000000000000000000000000000000000000000000000))
     kcpsm6_rom( .ADDRARDADDR               (address_a[13:0]),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOUTADOUT                 (data_out_a[15:0]),
                 .DOUTPADOUTP               (data_out_a[17:16]), 
                 .DINADIN                   (data_in_a[15:0]),
                 .DINPADINP                 (data_in_a[17:16]), 
                 .WEA                       (2'b00),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b[13:0]),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOUTBDOUT                 (data_out_b[15:0]),
                 .DOUTPBDOUTP               (data_out_b[17:16]), 
                 .DINBDIN                   (data_in_b[15:0]),
                 .DINPBDINP                 (data_in_b[17:16]), 
                 .WEBWE                     (we_b[3:0]),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .ADDRENA                   (1'b1),
                 .ADDRENB                   (1'b1),
                 .CASDIMUXA                 (1'b0),
                 .CASDIMUXB                 (1'b0),
                 .CASDINA                   (16'b0000000000000000), 
                 .CASDINB                   (16'b0000000000000000),
                 .CASDINPA                  (2'b00),
                 .CASDINPB                  (2'b00),
                 .CASDOMUXA                 (1'b0),
                 .CASDOMUXB                 (1'b0),
                 .CASDOMUXEN_A              (1'b1),
                 .CASDOMUXEN_B              (1'b1),
                 .CASOREGIMUXA              (1'b0),
                 .CASOREGIMUXB              (1'b0),
                 .CASOREGIMUXEN_A           (1'b0),
                 .CASOREGIMUXEN_B           (1'b0),
                 .SLEEP                     (1'b0));
    end // us;  
    // 
  end // ram_1k_generate;
endgenerate
//  
generate
  if (C_RAM_SIZE_KWORDS == 2) begin : ram_2k_generate 
    //
    if (C_FAMILY == "7S") begin: akv7 
      //
      assign address_a = {1'b1, address[10:0], 4'b1111};
      assign instruction = {data_out_a[33:32], data_out_a[15:0]};
      assign data_in_a = {35'b00000000000000000000000000000000000, address[11]};
      assign jtag_dout = {data_out_b[33:32], data_out_b[15:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b = {2'b00, data_out_b[33:32], 16'b0000000000000000, data_out_b[15:0]};
        assign address_b = 16'b1111111111111111;
        assign we_b = 8'b00000000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b = {2'b00, jtag_din[17:16], 16'b0000000000000000, jtag_din[15:0]};
        assign address_b = {1'b1, jtag_addr[10:0], 4'b1111};
        assign we_b = {jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB36E1 #(.READ_WIDTH_A              (18),
                 .WRITE_WIDTH_A             (18),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (18),
                 .WRITE_WIDTH_B             (18),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .RAM_EXTENSION_A           ("NONE"),
                 .RAM_EXTENSION_B           ("NONE"),
                 .SIM_DEVICE                ("7SERIES"),
                 .IS_CLKARDCLK_INVERTED     (0),
                 .IS_CLKBWRCLK_INVERTED     (0),
                 .IS_ENARDEN_INVERTED       (0),
                 .IS_ENBWREN_INVERTED       (0),
                 .IS_RSTRAMARSTRAM_INVERTED (0),
                 .IS_RSTRAMB_INVERTED       (0),
                 .IS_RSTREGARSTREG_INVERTED (0),
                 .IS_RSTREGB_INVERTED       (0),
                 .INIT_00                   (256'hF02C10016014D101B12DB02C041304130413F02DF02C10002004200420042004),
                 .INIT_01                   (256'hF010F00CF00810006007D000D02BF02C9001B02CF12D11012007D02B2014D016),
                 .INIT_02                   (256'hF00FF00D1090F00B1090F0091020F004F003F002F001F016F012F00EF00AF014),
                 .INIT_03                   (256'h1002D026D026004400B000A400980085011B010A00F900E82031D000B0008001),
                 .INIT_04                   (256'hD005B00DD004B00CD002B00AD003B00BD000B008D001B0092031F0008000B000),
                 .INIT_05                   (256'hD00DB015D00CB014D00BB013D00AB012D009B011D008B010D007B00FD006B00E),
                 .INIT_06                   (256'hD01AB01DD019B01CD017B01BD015B01AD013B019D011B018D00FB017D00EB016),
                 .INIT_07                   (256'hD022B025D021B024D020B023D01FB022D01EB021D01DB020D01CB01FD01BB01E),
                 .INIT_08                   (256'hD60200BCF52400C9F52000E0B41CB30BB20AB109B0085000D024B027D023B026),
                 .INIT_09                   (256'h00C9F52100E0B41DB30FB20EB10DB00C5000F618D02C100F2096D02C10006094),
                 .INIT_0A                   (256'h5000F61A00BCF52600C9F52200E0B41EB313B212B111B0105000F61900BCF525),
                 .INIT_0B                   (256'h500000C260C0D4035000F61B00BCF52700C9F52300E0B41FB317B216B115B014),
                 .INIT_0C                   (256'h500060DED50200E01201E0CC1320160160DFD50200E01001E0C51120500000D0),
                 .INIT_0D                   (256'h5000160020DF60DED50200E01201E0DA1320160260DFD50200E09001E0D39101),
                 .INIT_0E                   (256'hB001B732B61CB52EB40BB30AB909B8085000950415001500D32AD229D128D027),
                 .INIT_0F                   (256'hB733B61DB52FB40FB30EB20DB10C5000F732F61CF52EF40BF30AF909F808012C),
                 .INIT_10                   (256'hB61EB530B413B312B211B1105000F733F61DF52FF40FF30EF20DF10C012CB002),
                 .INIT_11                   (256'hB531B417B316B215B1145000F734F61EF530F413F312F211F110012CB003B734),
                 .INIT_12                   (256'hD02C10026132D0015000F735F61FF531F417F316F215F114012CB004B735B61F),
                 .INIT_13                   (256'h6144D0042145015CD02C1004613ED00321450151D02C10036138D00221450146),
                 .INIT_14                   (256'h1600655001766150D505150115001700214AD7005000014521450167D02C1005),
                 .INIT_15                   (256'h150017022160D702500016016550017E615BD5051501150017012155D7015000),
                 .INIT_16                   (256'h655001726171D505150115001703216BD703500016026550017A6166D5051501),
                 .INIT_17                   (256'hE181940150009101E17D920150001301E179140150001801E175190150001603),
                 .INIT_18                   (256'h0000000000000000000000000000000000000000000000000000000050009301),
                 .INIT_19                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_20                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'hD001B036F0049003F0039002F0029001D02CF0019000F00010016318D001B000),
                 .INIT_31                   (256'h00000000000000000000000000009001D02CF03610002300D02CF03610016315),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h2300000000000000000000000000000000000000000000000000000000000000),
                 .INIT_40                   (256'h040913325000640A920104041219500064059101040011285000640190011018),
                 .INIT_41                   (256'h00000000000000000000000000000000500064149301040913645000640F9301),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'h888888888888888888888888888888A42AAAAAD2A222AAAAA8DA48AD9C0AA8AA),
                 .INITP_01                  (256'h0002AAAA000080AA8B674D9DB674D9DAADAAA800AAA800AAA800A8A32AA00288),
                 .INITP_02                  (256'hD9D9D9D82D4360B50D82D4360B50DAA8DA8DA8DA8DAAAA80002AAAA0000AAAA8),
                 .INITP_03                  (256'h0000000000000000000000000000000000000000000000000000000000000009),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000002A2A30888A270),
                 .INITP_07                  (256'h8000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000B62D8B62D8B4),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
     kcpsm6_rom( .ADDRARDADDR               (address_a),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a[31:0]),
                 .DOPADOP                   (data_out_a[35:32]), 
                 .DIADI                     (data_in_a[31:0]),
                 .DIPADIP                   (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b[31:0]),
                 .DOPBDOP                   (data_out_b[35:32]), 
                 .DIBDI                     (data_in_b[31:0]),
                 .DIPBDIP                   (data_in_b[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .CASCADEINA                (1'b0),
                 .CASCADEINB                (1'b0),
                 .INJECTDBITERR             (1'b0),       
                 .INJECTSBITERR             (1'b0));   
    end // akv7;  
    // 
    //
    if (C_FAMILY == "US") begin: us 
      //
      assign address_a[14:0] = {address[10:0], 4'b1111};
      assign instruction = {data_out_a[33:32], data_out_a[15:0]};
      assign data_in_a = {35'b00000000000000000000000000000000000, address[11]};
      assign jtag_dout = {data_out_b[33:32], data_out_b[15:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b = {2'b00, data_out_b[33:32], 16'b0000000000000000, data_out_b[15:0]};
        assign address_b[14:0] = 15'b111111111111111;
        assign we_b = 8'b00000000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b = {2'b00, jtag_din[17:16], 16'b0000000000000000, jtag_din[15:0]};
        assign address_b[14:0] = {jtag_addr[10:0], 4'b1111};
        assign we_b = {jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB36E2 #(.READ_WIDTH_A              (18),
                 .WRITE_WIDTH_A             (18),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (18),
                 .WRITE_WIDTH_B             (18),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .CASCADE_ORDER_A           ("NONE"),
                 .CASCADE_ORDER_B           ("NONE"),
                 .CLOCK_DOMAINS             ("INDEPENDENT"),
                 .ENADDRENA                 ("FALSE"),
                 .ENADDRENB                 ("FALSE"),
                 .EN_ECC_PIPE               ("FALSE"),
                 .RDADDRCHANGEA             ("FALSE"),
                 .RDADDRCHANGEB             ("FALSE"),
                 .SLEEP_ASYNC               ("FALSE"),
                 .IS_CLKARDCLK_INVERTED     (0),
                 .IS_CLKBWRCLK_INVERTED     (0),
                 .IS_ENARDEN_INVERTED       (0),
                 .IS_ENBWREN_INVERTED       (0),
                 .IS_RSTRAMARSTRAM_INVERTED (0),
                 .IS_RSTRAMB_INVERTED       (0),
                 .IS_RSTREGARSTREG_INVERTED (0),
                 .IS_RSTREGB_INVERTED       (0),
                 .INIT_00                   (256'hF02C10016014D101B12DB02C041304130413F02DF02C10002004200420042004),
                 .INIT_01                   (256'hF010F00CF00810006007D000D02BF02C9001B02CF12D11012007D02B2014D016),
                 .INIT_02                   (256'hF00FF00D1090F00B1090F0091020F004F003F002F001F016F012F00EF00AF014),
                 .INIT_03                   (256'h1002D026D026004400B000A400980085011B010A00F900E82031D000B0008001),
                 .INIT_04                   (256'hD005B00DD004B00CD002B00AD003B00BD000B008D001B0092031F0008000B000),
                 .INIT_05                   (256'hD00DB015D00CB014D00BB013D00AB012D009B011D008B010D007B00FD006B00E),
                 .INIT_06                   (256'hD01AB01DD019B01CD017B01BD015B01AD013B019D011B018D00FB017D00EB016),
                 .INIT_07                   (256'hD022B025D021B024D020B023D01FB022D01EB021D01DB020D01CB01FD01BB01E),
                 .INIT_08                   (256'hD60200BCF52400C9F52000E0B41CB30BB20AB109B0085000D024B027D023B026),
                 .INIT_09                   (256'h00C9F52100E0B41DB30FB20EB10DB00C5000F618D02C100F2096D02C10006094),
                 .INIT_0A                   (256'h5000F61A00BCF52600C9F52200E0B41EB313B212B111B0105000F61900BCF525),
                 .INIT_0B                   (256'h500000C260C0D4035000F61B00BCF52700C9F52300E0B41FB317B216B115B014),
                 .INIT_0C                   (256'h500060DED50200E01201E0CC1320160160DFD50200E01001E0C51120500000D0),
                 .INIT_0D                   (256'h5000160020DF60DED50200E01201E0DA1320160260DFD50200E09001E0D39101),
                 .INIT_0E                   (256'hB001B732B61CB52EB40BB30AB909B8085000950415001500D32AD229D128D027),
                 .INIT_0F                   (256'hB733B61DB52FB40FB30EB20DB10C5000F732F61CF52EF40BF30AF909F808012C),
                 .INIT_10                   (256'hB61EB530B413B312B211B1105000F733F61DF52FF40FF30EF20DF10C012CB002),
                 .INIT_11                   (256'hB531B417B316B215B1145000F734F61EF530F413F312F211F110012CB003B734),
                 .INIT_12                   (256'hD02C10026132D0015000F735F61FF531F417F316F215F114012CB004B735B61F),
                 .INIT_13                   (256'h6144D0042145015CD02C1004613ED00321450151D02C10036138D00221450146),
                 .INIT_14                   (256'h1600655001766150D505150115001700214AD7005000014521450167D02C1005),
                 .INIT_15                   (256'h150017022160D702500016016550017E615BD5051501150017012155D7015000),
                 .INIT_16                   (256'h655001726171D505150115001703216BD703500016026550017A6166D5051501),
                 .INIT_17                   (256'hE181940150009101E17D920150001301E179140150001801E175190150001603),
                 .INIT_18                   (256'h0000000000000000000000000000000000000000000000000000000050009301),
                 .INIT_19                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_20                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'hD001B036F0049003F0039002F0029001D02CF0019000F00010016318D001B000),
                 .INIT_31                   (256'h00000000000000000000000000009001D02CF03610002300D02CF03610016315),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h2300000000000000000000000000000000000000000000000000000000000000),
                 .INIT_40                   (256'h040913325000640A920104041219500064059101040011285000640190011018),
                 .INIT_41                   (256'h00000000000000000000000000000000500064149301040913645000640F9301),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'h888888888888888888888888888888A42AAAAAD2A222AAAAA8DA48AD9C0AA8AA),
                 .INITP_01                  (256'h0002AAAA000080AA8B674D9DB674D9DAADAAA800AAA800AAA800A8A32AA00288),
                 .INITP_02                  (256'hD9D9D9D82D4360B50D82D4360B50DAA8DA8DA8DA8DAAAA80002AAAA0000AAAA8),
                 .INITP_03                  (256'h0000000000000000000000000000000000000000000000000000000000000009),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000002A2A30888A270),
                 .INITP_07                  (256'h8000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000B62D8B62D8B4),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
     kcpsm6_rom( .ADDRARDADDR               (address_a[14:0]),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOUTADOUT                 (data_out_a[31:0]),
                 .DOUTPADOUTP               (data_out_a[35:32]), 
                 .DINADIN                   (data_in_a[31:0]),
                 .DINPADINP                 (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b[14:0]),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOUTBDOUT                 (data_out_b[31:0]),
                 .DOUTPBDOUTP               (data_out_b[35:32]), 
                 .DINBDIN                   (data_in_b[31:0]),
                 .DINPBDINP                 (data_in_b[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .INJECTDBITERR             (1'b0),       
                 .INJECTSBITERR             (1'b0),   
                 .ADDRENA                   (1'b1),
                 .ADDRENB                   (1'b1),
                 .CASDIMUXA                 (1'b0),
                 .CASDIMUXB                 (1'b0),
                 .CASDINA                   (32'b00000000000000000000000000000000), 
                 .CASDINB                   (32'b00000000000000000000000000000000),
                 .CASDINPA                  (4'b0000),
                 .CASDINPB                  (4'b0000),
                 .CASDOMUXA                 (1'b0),
                 .CASDOMUXB                 (1'b0),
                 .CASDOMUXEN_A              (1'b1),
                 .CASDOMUXEN_B              (1'b1),
                 .CASINDBITERR              (1'b0),
                 .CASINSBITERR              (1'b0),
                 .CASOREGIMUXA              (1'b0),
                 .CASOREGIMUXB              (1'b0),
                 .CASOREGIMUXEN_A           (1'b0),
                 .CASOREGIMUXEN_B           (1'b0),
                 .ECCPIPECE                 (1'b0),
                 .SLEEP                     (1'b0));
    end // us;  
    // 
  end // ram_2k_generate;
endgenerate              
//
generate
  if (C_RAM_SIZE_KWORDS == 4) begin : ram_4k_generate 
    //
    if (C_FAMILY == "7S") begin: akv7 
      //
      assign address_a = {1'b1, address[11:0], 3'b111};
      assign instruction = {data_out_a_h[32], data_out_a_h[7:0], data_out_a_l[32], data_out_a_l[7:0]};
      assign data_in_a = 36'b00000000000000000000000000000000000;
      assign jtag_dout = {data_out_b_h[32], data_out_b_h[7:0], data_out_b_l[32], data_out_b_l[7:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b_l = {3'b000, data_out_b_l[32], 24'b000000000000000000000000, data_out_b_l[7:0]};
        assign data_in_b_h = {3'b000, data_out_b_h[32], 24'b000000000000000000000000, data_out_b_h[7:0]};
        assign address_b = 16'b1111111111111111;
        assign we_b = 8'b00000000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b_h = {3'b000, jtag_din[17], 24'b000000000000000000000000, jtag_din[16:9]};
        assign data_in_b_l = {3'b000, jtag_din[8],  24'b000000000000000000000000, jtag_din[7:0]};
        assign address_b = {1'b1, jtag_addr[11:0], 3'b111};
        assign we_b = {jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB36E1 #(.READ_WIDTH_A              (9),
                 .WRITE_WIDTH_A             (9),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (9),
                 .WRITE_WIDTH_B             (9),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .RAM_EXTENSION_A           ("NONE"),
                 .RAM_EXTENSION_B           ("NONE"),
                 .SIM_DEVICE                ("7SERIES"),
                 .IS_CLKARDCLK_INVERTED     (0),
                 .IS_CLKBWRCLK_INVERTED     (0),
                 .IS_ENARDEN_INVERTED       (0),
                 .IS_ENBWREN_INVERTED       (0),
                 .IS_RSTRAMARSTRAM_INVERTED (0),
                 .IS_RSTRAMB_INVERTED       (0),
                 .IS_RSTREGARSTREG_INVERTED (0),
                 .IS_RSTREGB_INVERTED       (0),
                 .INIT_00                   (256'h100C080007002B2C012C2D01072B14162C0114012D2C1313132D2C0004040404),
                 .INIT_01                   (256'h02262644B0A498851B0AF9E8310000010F0D900B9009200403020116120E0A14),
                 .INIT_02                   (256'h0D150C140B130A1209110810070F060E050D040C020A030B0008010931000000),
                 .INIT_03                   (256'h2225212420231F221E211D201C1F1B1E1A1D191C171B151A131911180F170E16),
                 .INIT_04                   (256'hC921E01D0F0E0D0C00182C0F962C009402BC24C920E01C0B0A09080024272326),
                 .INIT_05                   (256'h00C2C003001BBC27C923E01F17161514001ABC26C922E01E131211100019BC25),
                 .INIT_06                   (256'h0000DFDE02E001DA2002DF02E001D30100DE02E001CC2001DF02E001C52000D0),
                 .INIT_07                   (256'h331D2F0F0E0D0C00321C2E0B0A09082C01321C2E0B0A0908000400002A292827),
                 .INIT_08                   (256'h311716151400341E30131211102C03341E301312111000331D2F0F0E0D0C2C02),
                 .INIT_09                   (256'h4404455C2C043E0345512C03380245462C02320100351F31171615142C04351F),
                 .INIT_0A                   (256'h000260020001507E5B0501000155010000507650050100004A00004545672C05),
                 .INIT_0B                   (256'h810100017D0100017901000175010003507271050100036B030002507A660501),
                 .INIT_0C                   (256'h0000000000000000000000000000000000000000000000000000000000000001),
                 .INIT_0D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_0E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_0F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_10                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_11                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_12                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_13                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_14                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_15                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_16                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_17                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_18                   (256'h00000000000000012C3600002C36011501360403030202012C01000001180100),
                 .INIT_19                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_20                   (256'h00000000000000000014010964000F010932000A010419000501002800010118),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_31                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'hAAAD567A08912244014A14A14A002940000000000000000000C0000000301800),
                 .INITP_01                  (256'h00000000000000000000000000000001998CFF9FF3FE7FDCB2CB255AAAAD5556),
                 .INITP_02                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_03                  (256'h8000000000000000000000000000000000000000000000000000000000110004),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000294050),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_07                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
   kcpsm6_rom_l( .ADDRARDADDR               (address_a),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a_l[31:0]),
                 .DOPADOP                   (data_out_a_l[35:32]), 
                 .DIADI                     (data_in_a[31:0]),
                 .DIPADIP                   (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b_l[31:0]),
                 .DOPBDOP                   (data_out_b_l[35:32]), 
                 .DIBDI                     (data_in_b_l[31:0]),
                 .DIPBDIP                   (data_in_b_l[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .CASCADEINA                (1'b0),
                 .CASCADEINB                (1'b0),
                 .INJECTDBITERR             (1'b0),      
                 .INJECTSBITERR             (1'b0));   
      //
      RAMB36E1 #(.READ_WIDTH_A              (9),
                 .WRITE_WIDTH_A             (9),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (9),
                 .WRITE_WIDTH_B             (9),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .RAM_EXTENSION_A           ("NONE"),
                 .RAM_EXTENSION_B           ("NONE"),
                 .SIM_DEVICE                ("7SERIES"),
                 .IS_CLKARDCLK_INVERTED     (0),
                 .IS_CLKBWRCLK_INVERTED     (0),
                 .IS_ENARDEN_INVERTED       (0),
                 .IS_ENBWREN_INVERTED       (0),
                 .IS_RSTRAMARSTRAM_INVERTED (0),
                 .IS_RSTRAMB_INVERTED       (0),
                 .IS_RSTREGARSTREG_INVERTED (0),
                 .IS_RSTREGB_INVERTED       (0),
                 .INIT_00                   (256'h78787808B0E86878C8587808106890E87888B068585802020278780810101010),
                 .INIT_01                   (256'h08686800000000000000000090E8584078780878087808787878787878787878),
                 .INIT_02                   (256'h685868586858685868586858685868586858685868586858685868581078C058),
                 .INIT_03                   (256'h6858685868586858685868586858685868586858685868586858685868586858),
                 .INIT_04                   (256'h007A005A59595858287B6808106808B06B007A007A005A595958582868586858),
                 .INIT_05                   (256'h2800B0EA287B007A007A005A59595858287B007A007A005A59595858287B007A),
                 .INIT_06                   (256'h280B10B0EA0089F0890BB0EA00C8F0C828B0EA0089F0890BB0EA0088F0882800),
                 .INIT_07                   (256'h5B5B5A5A595958287B7B7A7A797C7C00585B5B5A5A595C5C284A0A0A69696868),
                 .INIT_08                   (256'h5A5A595958287B7B7A7A79797800585B5B5A5A595958287B7B7A7A7979780058),
                 .INIT_09                   (256'hB0E810006808B0E810006808B0E810006808B0E8287B7B7A7A79797800585B5B),
                 .INIT_0A                   (256'h0A0B90EB280B3200B0EA8A0A0B90EB280B3200B0EA8A0A0B90EB280010006808),
                 .INIT_0B                   (256'hF0CA28C8F0C92889F08A288CF08C280B3200B0EA8A0A0B90EB280B3200B0EA8A),
                 .INIT_0C                   (256'h00000000000000000000000000000000000000000000000000000000000028C9),
                 .INIT_0D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_0E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_0F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_10                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_11                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_12                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_13                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_14                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_15                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_16                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_17                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_18                   (256'h000000000000004868780811687808B168587848784878486878487888B16858),
                 .INIT_19                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1F                   (256'h1100000000000000000000000000000000000000000000000000000000000000),
                 .INIT_20                   (256'h000000000000000028B2C9020928B2C9020928B2C9020928B2C8020828B2C808),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_31                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'h01FF008FB52AD4ABEFE0FE0FE0ED7C1AAAAAAAAAAAAAAAAC7FF9D5FFEB2EA3EF),
                 .INITP_01                  (256'h00000000000000000000000000000002AAAA614C298530BEBAEBAFF807FC03FE),
                 .INITP_02                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_03                  (256'h8000000000000000000000000000000000000000000000000000000001DD2AD4),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000D6B5AC),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_07                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
   kcpsm6_rom_h( .ADDRARDADDR               (address_a),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a_h[31:0]),
                 .DOPADOP                   (data_out_a_h[35:32]), 
                 .DIADI                     (data_in_a[31:0]),
                 .DIPADIP                   (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b_h[31:0]),
                 .DOPBDOP                   (data_out_b_h[35:32]), 
                 .DIBDI                     (data_in_b_h[31:0]),
                 .DIPBDIP                   (data_in_b_h[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .CASCADEINA                (1'b0),
                 .CASCADEINB                (1'b0),
                 .INJECTDBITERR             (1'b0),      
                 .INJECTSBITERR             (1'b0));  
    end // akv7;  
    //
    //
    if (C_FAMILY == "US") begin: us 
      //
      assign address_a[14:0] = {address[11:0], 3'b111};
      assign instruction = {data_out_a_h[32], data_out_a_h[7:0], data_out_a_l[32], data_out_a_l[7:0]};
      assign data_in_a = 36'b00000000000000000000000000000000000;
      assign jtag_dout = {data_out_b_h[32], data_out_b_h[7:0], data_out_b_l[32], data_out_b_l[7:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b_l = {3'b000, data_out_b_l[32], 24'b000000000000000000000000, data_out_b_l[7:0]};
        assign data_in_b_h = {3'b000, data_out_b_h[32], 24'b000000000000000000000000, data_out_b_h[7:0]};
        assign address_b[14:0] = 15'b111111111111111;
        assign we_b = 8'b00000000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b_h = {3'b000, jtag_din[17], 24'b000000000000000000000000, jtag_din[16:9]};
        assign data_in_b_l = {3'b000, jtag_din[8],  24'b000000000000000000000000, jtag_din[7:0]};
        assign address_b[14:0] = {jtag_addr[11:0], 3'b111};
        assign we_b = {jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB36E2 #(.READ_WIDTH_A              (9),
                 .WRITE_WIDTH_A             (9),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (9),
                 .WRITE_WIDTH_B             (9),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .CASCADE_ORDER_A           ("NONE"),
                 .CASCADE_ORDER_B           ("NONE"),
                 .CLOCK_DOMAINS             ("INDEPENDENT"),
                 .ENADDRENA                 ("FALSE"),
                 .ENADDRENB                 ("FALSE"),
                 .EN_ECC_PIPE               ("FALSE"),
                 .RDADDRCHANGEA             ("FALSE"),
                 .RDADDRCHANGEB             ("FALSE"),
                 .SLEEP_ASYNC               ("FALSE"),
                 .IS_CLKARDCLK_INVERTED     (0),
                 .IS_CLKBWRCLK_INVERTED     (0),
                 .IS_ENARDEN_INVERTED       (0),
                 .IS_ENBWREN_INVERTED       (0),
                 .IS_RSTRAMARSTRAM_INVERTED (0),
                 .IS_RSTRAMB_INVERTED       (0),
                 .IS_RSTREGARSTREG_INVERTED (0),
                 .IS_RSTREGB_INVERTED       (0),
                 .INIT_00                   (256'h100C080007002B2C012C2D01072B14162C0114012D2C1313132D2C0004040404),
                 .INIT_01                   (256'h02262644B0A498851B0AF9E8310000010F0D900B9009200403020116120E0A14),
                 .INIT_02                   (256'h0D150C140B130A1209110810070F060E050D040C020A030B0008010931000000),
                 .INIT_03                   (256'h2225212420231F221E211D201C1F1B1E1A1D191C171B151A131911180F170E16),
                 .INIT_04                   (256'hC921E01D0F0E0D0C00182C0F962C009402BC24C920E01C0B0A09080024272326),
                 .INIT_05                   (256'h00C2C003001BBC27C923E01F17161514001ABC26C922E01E131211100019BC25),
                 .INIT_06                   (256'h0000DFDE02E001DA2002DF02E001D30100DE02E001CC2001DF02E001C52000D0),
                 .INIT_07                   (256'h331D2F0F0E0D0C00321C2E0B0A09082C01321C2E0B0A0908000400002A292827),
                 .INIT_08                   (256'h311716151400341E30131211102C03341E301312111000331D2F0F0E0D0C2C02),
                 .INIT_09                   (256'h4404455C2C043E0345512C03380245462C02320100351F31171615142C04351F),
                 .INIT_0A                   (256'h000260020001507E5B0501000155010000507650050100004A00004545672C05),
                 .INIT_0B                   (256'h810100017D0100017901000175010003507271050100036B030002507A660501),
                 .INIT_0C                   (256'h0000000000000000000000000000000000000000000000000000000000000001),
                 .INIT_0D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_0E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_0F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_10                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_11                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_12                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_13                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_14                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_15                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_16                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_17                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_18                   (256'h00000000000000012C3600002C36011501360403030202012C01000001180100),
                 .INIT_19                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_20                   (256'h00000000000000000014010964000F010932000A010419000501002800010118),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_31                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'hAAAD567A08912244014A14A14A002940000000000000000000C0000000301800),
                 .INITP_01                  (256'h00000000000000000000000000000001998CFF9FF3FE7FDCB2CB255AAAAD5556),
                 .INITP_02                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_03                  (256'h8000000000000000000000000000000000000000000000000000000000110004),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000294050),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_07                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
   kcpsm6_rom_l( .ADDRARDADDR               (address_a[14:0]),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOUTADOUT                 (data_out_a_l[31:0]),
                 .DOUTPADOUTP               (data_out_a_l[35:32]), 
                 .DINADIN                   (data_in_a[31:0]),
                 .DINPADINP                 (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b[14:0]),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOUTBDOUT                 (data_out_b_l[31:0]),
                 .DOUTPBDOUTP               (data_out_b_l[35:32]), 
                 .DINBDIN                   (data_in_b_l[31:0]),
                 .DINPBDINP                 (data_in_b_l[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .INJECTDBITERR             (1'b0),       
                 .INJECTSBITERR             (1'b0),   
                 .ADDRENA                   (1'b1),
                 .ADDRENB                   (1'b1),
                 .CASDIMUXA                 (1'b0),
                 .CASDIMUXB                 (1'b0),
                 .CASDINA                   (32'b00000000000000000000000000000000), 
                 .CASDINB                   (32'b00000000000000000000000000000000),
                 .CASDINPA                  (4'b0000),
                 .CASDINPB                  (4'b0000),
                 .CASDOMUXA                 (1'b0),
                 .CASDOMUXB                 (1'b0),
                 .CASDOMUXEN_A              (1'b1),
                 .CASDOMUXEN_B              (1'b1),
                 .CASINDBITERR              (1'b0),
                 .CASINSBITERR              (1'b0),
                 .CASOREGIMUXA              (1'b0),
                 .CASOREGIMUXB              (1'b0),
                 .CASOREGIMUXEN_A           (1'b0),
                 .CASOREGIMUXEN_B           (1'b0),
                 .ECCPIPECE                 (1'b0),
                 .SLEEP                     (1'b0));
      //
      RAMB36E2 #(.READ_WIDTH_A              (9),
                 .WRITE_WIDTH_A             (9),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (9),
                 .WRITE_WIDTH_B             (9),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .CASCADE_ORDER_A           ("NONE"),
                 .CASCADE_ORDER_B           ("NONE"),
                 .CLOCK_DOMAINS             ("INDEPENDENT"),
                 .ENADDRENA                 ("FALSE"),
                 .ENADDRENB                 ("FALSE"),
                 .EN_ECC_PIPE               ("FALSE"),
                 .RDADDRCHANGEA             ("FALSE"),
                 .RDADDRCHANGEB             ("FALSE"),
                 .SLEEP_ASYNC               ("FALSE"),
                 .IS_CLKARDCLK_INVERTED     (0),
                 .IS_CLKBWRCLK_INVERTED     (0),
                 .IS_ENARDEN_INVERTED       (0),
                 .IS_ENBWREN_INVERTED       (0),
                 .IS_RSTRAMARSTRAM_INVERTED (0),
                 .IS_RSTRAMB_INVERTED       (0),
                 .IS_RSTREGARSTREG_INVERTED (0),
                 .IS_RSTREGB_INVERTED       (0),
                 .INIT_00                   (256'h78787808B0E86878C8587808106890E87888B068585802020278780810101010),
                 .INIT_01                   (256'h08686800000000000000000090E8584078780878087808787878787878787878),
                 .INIT_02                   (256'h685868586858685868586858685868586858685868586858685868581078C058),
                 .INIT_03                   (256'h6858685868586858685868586858685868586858685868586858685868586858),
                 .INIT_04                   (256'h007A005A59595858287B6808106808B06B007A007A005A595958582868586858),
                 .INIT_05                   (256'h2800B0EA287B007A007A005A59595858287B007A007A005A59595858287B007A),
                 .INIT_06                   (256'h280B10B0EA0089F0890BB0EA00C8F0C828B0EA0089F0890BB0EA0088F0882800),
                 .INIT_07                   (256'h5B5B5A5A595958287B7B7A7A797C7C00585B5B5A5A595C5C284A0A0A69696868),
                 .INIT_08                   (256'h5A5A595958287B7B7A7A79797800585B5B5A5A595958287B7B7A7A7979780058),
                 .INIT_09                   (256'hB0E810006808B0E810006808B0E810006808B0E8287B7B7A7A79797800585B5B),
                 .INIT_0A                   (256'h0A0B90EB280B3200B0EA8A0A0B90EB280B3200B0EA8A0A0B90EB280010006808),
                 .INIT_0B                   (256'hF0CA28C8F0C92889F08A288CF08C280B3200B0EA8A0A0B90EB280B3200B0EA8A),
                 .INIT_0C                   (256'h00000000000000000000000000000000000000000000000000000000000028C9),
                 .INIT_0D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_0E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_0F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_10                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_11                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_12                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_13                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_14                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_15                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_16                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_17                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_18                   (256'h000000000000004868780811687808B168587848784878486878487888B16858),
                 .INIT_19                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_1F                   (256'h1100000000000000000000000000000000000000000000000000000000000000),
                 .INIT_20                   (256'h000000000000000028B2C9020928B2C9020928B2C9020928B2C8020828B2C808),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_31                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'h01FF008FB52AD4ABEFE0FE0FE0ED7C1AAAAAAAAAAAAAAAAC7FF9D5FFEB2EA3EF),
                 .INITP_01                  (256'h00000000000000000000000000000002AAAA614C298530BEBAEBAFF807FC03FE),
                 .INITP_02                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_03                  (256'h8000000000000000000000000000000000000000000000000000000001DD2AD4),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000D6B5AC),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_07                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
   kcpsm6_rom_h( .ADDRARDADDR               (address_a[14:0]),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOUTADOUT                 (data_out_a_h[31:0]),
                 .DOUTPADOUTP               (data_out_a_h[35:32]), 
                 .DINADIN                   (data_in_a[31:0]),
                 .DINPADINP                 (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b[14:0]),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOUTBDOUT                 (data_out_b_h[31:0]),
                 .DOUTPBDOUTP               (data_out_b_h[35:32]), 
                 .DINBDIN                   (data_in_b_h[31:0]),
                 .DINPBDINP                 (data_in_b_h[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .INJECTDBITERR             (1'b0),       
                 .INJECTSBITERR             (1'b0),   
                 .ADDRENA                   (1'b1),
                 .ADDRENB                   (1'b1),
                 .CASDIMUXA                 (1'b0),
                 .CASDIMUXB                 (1'b0),
                 .CASDINA                   (32'b00000000000000000000000000000000), 
                 .CASDINB                   (32'b00000000000000000000000000000000),
                 .CASDINPA                  (4'b0000),
                 .CASDINPB                  (4'b0000),
                 .CASDOMUXA                 (1'b0),
                 .CASDOMUXB                 (1'b0),
                 .CASDOMUXEN_A              (1'b1),
                 .CASDOMUXEN_B              (1'b1),
                 .CASINDBITERR              (1'b0),
                 .CASINSBITERR              (1'b0),
                 .CASOREGIMUXA              (1'b0),
                 .CASOREGIMUXB              (1'b0),
                 .CASOREGIMUXEN_A           (1'b0),
                 .CASOREGIMUXEN_B           (1'b0),
                 .ECCPIPECE                 (1'b0),
                 .SLEEP                     (1'b0));
    end // us;  
    //
  end // ram_4k_generate;
endgenerate      
//
// JTAG Loader 
//
generate
  if (C_JTAG_LOADER_ENABLE == 1) begin: instantiate_loader
    jtag_loader_6  #(  .C_FAMILY              (C_FAMILY),
                       .C_NUM_PICOBLAZE       (1),
                       .C_JTAG_LOADER_ENABLE  (C_JTAG_LOADER_ENABLE),        
                       .C_BRAM_MAX_ADDR_WIDTH (BRAM_ADDRESS_WIDTH),        
                       .C_ADDR_WIDTH_0        (BRAM_ADDRESS_WIDTH))
    jtag_loader_6_inst(.picoblaze_reset       (rdl_bus),
                       .jtag_en               (jtag_en),
                       .jtag_din              (jtag_din),
                       .jtag_addr             (jtag_addr[BRAM_ADDRESS_WIDTH-1 : 0]),
                       .jtag_clk              (jtag_clk),
                       .jtag_we               (jtag_we),
                       .jtag_dout_0           (jtag_dout),
                       .jtag_dout_1           (jtag_dout),  // ports 1-7 are not used
                       .jtag_dout_2           (jtag_dout),  // in a 1 device debug 
                       .jtag_dout_3           (jtag_dout),  // session.  However, Synplify
                       .jtag_dout_4           (jtag_dout),  // etc require all ports are
                       .jtag_dout_5           (jtag_dout),  // connected
                       .jtag_dout_6           (jtag_dout),
                       .jtag_dout_7           (jtag_dout));  
    
  end //instantiate_loader
endgenerate 
//
//
endmodule
//
//
//
//
///////////////////////////////////////////////////////////////////////////////////////////
//
// JTAG Loader 
//
///////////////////////////////////////////////////////////////////////////////////////////
//
//
// JTAG Loader 6 - Version 6.00
//
// Kris Chaplin - 4th February 2010
// Nick Sawyer  - 3rd March 2011 - Initial conversion to Verilog
// Ken Chapman  - 16th August 2011 - Revised coding style
//
`timescale 1ps/1ps
module jtag_loader_6 (picoblaze_reset, jtag_en, jtag_din, jtag_addr, jtag_clk, jtag_we, jtag_dout_0, jtag_dout_1, jtag_dout_2, jtag_dout_3, jtag_dout_4, jtag_dout_5, jtag_dout_6, jtag_dout_7);
//
parameter integer C_JTAG_LOADER_ENABLE = 1;
parameter         C_FAMILY = "V6";
parameter integer C_NUM_PICOBLAZE = 1;
parameter integer C_BRAM_MAX_ADDR_WIDTH = 10;
parameter integer C_PICOBLAZE_INSTRUCTION_DATA_WIDTH = 18;
parameter integer C_JTAG_CHAIN = 2;
parameter [4:0]   C_ADDR_WIDTH_0 = 10;
parameter [4:0]   C_ADDR_WIDTH_1 = 10;
parameter [4:0]   C_ADDR_WIDTH_2 = 10;
parameter [4:0]   C_ADDR_WIDTH_3 = 10;
parameter [4:0]   C_ADDR_WIDTH_4 = 10;
parameter [4:0]   C_ADDR_WIDTH_5 = 10;
parameter [4:0]   C_ADDR_WIDTH_6 = 10;
parameter [4:0]   C_ADDR_WIDTH_7 = 10;
//
output [C_NUM_PICOBLAZE-1:0]                    picoblaze_reset;
output [C_NUM_PICOBLAZE-1:0]                    jtag_en;
output [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_din;
output [C_BRAM_MAX_ADDR_WIDTH-1:0]              jtag_addr;
output                                          jtag_clk ;
output                                          jtag_we;  
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_0;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_1;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_2;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_3;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_4;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_5;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_6;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_7;
//
//
wire   [2:0]                                    num_picoblaze;        
wire   [4:0]                                    picoblaze_instruction_data_width; 
//
wire                                            drck;
wire                                            shift_clk;
wire                                            shift_din;
wire                                            shift_dout;
wire                                            shift;
wire                                            capture;
//
reg                                             control_reg_ce;
reg    [C_NUM_PICOBLAZE-1:0]                    bram_ce;
wire   [C_NUM_PICOBLAZE-1:0]                    bus_zero;
wire   [C_NUM_PICOBLAZE-1:0]                    jtag_en_int;
wire   [7:0]                                    jtag_en_expanded;
reg    [C_BRAM_MAX_ADDR_WIDTH-1:0]              jtag_addr_int;
reg    [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_din_int;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] control_din;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] control_dout;
reg    [7:0]                                    control_dout_int;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] bram_dout_int;
reg                                             jtag_we_int;
wire                                            jtag_clk_int;
wire                                            bram_ce_valid;
reg                                             din_load;
//                                                
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_0_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_1_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_2_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_3_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_4_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_5_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_6_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_7_masked;
reg    [C_NUM_PICOBLAZE-1:0]                    picoblaze_reset_int;
//
initial picoblaze_reset_int = 0;
//
genvar i;
//
generate
  for (i = 0; i <= C_NUM_PICOBLAZE-1; i = i+1)
    begin : npzero_loop
      assign bus_zero[i] = 1'b0;
    end
endgenerate
//
generate
  //
  if (C_JTAG_LOADER_ENABLE == 1)
    begin : jtag_loader_gen
      //
      // Insert BSCAN primitive for target device architecture.
      //
      if (C_FAMILY == "7S")
        begin : BSCAN_7SERIES_gen
          BSCANE2 # (       .JTAG_CHAIN   (C_JTAG_CHAIN),
                            .DISABLE_JTAG ("FALSE"))
          BSCAN_BLOCK_inst (.CAPTURE      (capture),
                            .DRCK         (drck),
                            .RESET        (),
                            .RUNTEST      (),
                            .SEL          (bram_ce_valid),
                            .SHIFT        (shift),
                            .TCK          (),
                            .TDI          (shift_din),
                            .TMS          (),
                            .UPDATE       (jtag_clk_int),
                            .TDO          (shift_dout));
        end 
      //
      if (C_FAMILY == "US")
        begin : BSCAN_UltraScale_gen
          BSCANE2 # (       .JTAG_CHAIN   (C_JTAG_CHAIN),
                            .DISABLE_JTAG ("FALSE"))
          BSCAN_BLOCK_inst (.CAPTURE      (capture),
                            .DRCK         (drck),
                            .RESET        (),
                            .RUNTEST      (),
                            .SEL          (bram_ce_valid),
                            .SHIFT        (shift),
                            .TCK          (),
                            .TDI          (shift_din),
                            .TMS          (),
                            .UPDATE       (jtag_clk_int),
                            .TDO          (shift_dout));
        end 
      //
      // Insert clock buffer to ensure reliable shift operations.
      //
      BUFG upload_clock (.I (drck), .O (shift_clk));
      //        
      //
      // Shift Register 
      //
      always @ (posedge shift_clk) begin
        if (shift == 1'b1) begin
          control_reg_ce <= shift_din;
        end
      end
      // 
      always @ (posedge shift_clk) begin
        if (shift == 1'b1) begin
          bram_ce[0] <= control_reg_ce;
        end
      end 
      //
      for (i = 0; i <= C_NUM_PICOBLAZE-2; i = i+1)
      begin : loop0 
        if (C_NUM_PICOBLAZE > 1) begin
          always @ (posedge shift_clk) begin
            if (shift == 1'b1) begin
              bram_ce[i+1] <= bram_ce[i];
            end
          end
        end 
      end
      // 
      always @ (posedge shift_clk) begin
        if (shift == 1'b1) begin
          jtag_we_int <= bram_ce[C_NUM_PICOBLAZE-1];
        end
      end
      // 
      always @ (posedge shift_clk) begin 
        if (shift == 1'b1) begin
          jtag_addr_int[0] <= jtag_we_int;
        end
      end
      //
      for (i = 0; i <= C_BRAM_MAX_ADDR_WIDTH-2; i = i+1)
      begin : loop1
        always @ (posedge shift_clk) begin
          if (shift == 1'b1) begin
            jtag_addr_int[i+1] <= jtag_addr_int[i];
          end
        end 
      end
      // 
      always @ (posedge shift_clk) begin 
        if (din_load == 1'b1) begin
          jtag_din_int[0] <= bram_dout_int[0];
        end
        else if (shift == 1'b1) begin
          jtag_din_int[0] <= jtag_addr_int[C_BRAM_MAX_ADDR_WIDTH-1];
        end
      end       
      //
      for (i = 0; i <= C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-2; i = i+1)
      begin : loop2
        always @ (posedge shift_clk) begin
          if (din_load == 1'b1) begin
            jtag_din_int[i+1] <= bram_dout_int[i+1];
          end
          if (shift == 1'b1) begin
            jtag_din_int[i+1] <= jtag_din_int[i];
          end
        end 
      end
      //
      assign shift_dout = jtag_din_int[C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1];
      //
      //
      always @ (bram_ce or din_load or capture or bus_zero or control_reg_ce) begin
        if ( bram_ce == bus_zero ) begin
          din_load <= capture & control_reg_ce;
        end else begin
          din_load <= capture;
        end
      end
      //
      //
      // Control Registers 
      //
      assign num_picoblaze = C_NUM_PICOBLAZE-3'h1;
      assign picoblaze_instruction_data_width = C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-5'h01;
      //
      always @ (posedge jtag_clk_int) begin
        if (bram_ce_valid == 1'b1 && jtag_we_int == 1'b0 && control_reg_ce == 1'b1) begin
          case (jtag_addr_int[3:0]) 
            0 : // 0 = version - returns (7:4) illustrating number of PB
                // and [3:0] picoblaze instruction data width
                control_dout_int <= {num_picoblaze, picoblaze_instruction_data_width};
            1 : // 1 = PicoBlaze 0 reset / status
                if (C_NUM_PICOBLAZE >= 1) begin 
                  control_dout_int <= {picoblaze_reset_int[0], 2'b00, C_ADDR_WIDTH_0-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            2 : // 2 = PicoBlaze 1 reset / status
                if (C_NUM_PICOBLAZE >= 2) begin 
                  control_dout_int <= {picoblaze_reset_int[1], 2'b00, C_ADDR_WIDTH_1-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            3 : // 3 = PicoBlaze 2 reset / status
                if (C_NUM_PICOBLAZE >= 3) begin 
                  control_dout_int <= {picoblaze_reset_int[2], 2'b00, C_ADDR_WIDTH_2-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            4 : // 4 = PicoBlaze 3 reset / status
                if (C_NUM_PICOBLAZE >= 4) begin 
                  control_dout_int <= {picoblaze_reset_int[3], 2'b00, C_ADDR_WIDTH_3-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            5:  // 5 = PicoBlaze 4 reset / status
                if (C_NUM_PICOBLAZE >= 5) begin 
                  control_dout_int <= {picoblaze_reset_int[4], 2'b00, C_ADDR_WIDTH_4-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            6 : // 6 = PicoBlaze 5 reset / status
                if (C_NUM_PICOBLAZE >= 6) begin 
                  control_dout_int <= {picoblaze_reset_int[5], 2'b00, C_ADDR_WIDTH_5-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            7 : // 7 = PicoBlaze 6 reset / status
                if (C_NUM_PICOBLAZE >= 7) begin 
                  control_dout_int <= {picoblaze_reset_int[6], 2'b00, C_ADDR_WIDTH_6-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            8 : // 8 = PicoBlaze 7 reset / status
                if (C_NUM_PICOBLAZE >= 8) begin 
                  control_dout_int <= {picoblaze_reset_int[7], 2'b00, C_ADDR_WIDTH_7-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            15 : control_dout_int <= C_BRAM_MAX_ADDR_WIDTH -1;
            default : control_dout_int <= 8'h00;
            //
          endcase
        end else begin
          control_dout_int <= 8'h00;
        end
      end 
      //
      assign control_dout[C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-8] = control_dout_int;
      //
      always @ (posedge jtag_clk_int) begin
        if (bram_ce_valid == 1'b1 && jtag_we_int == 1'b1 && control_reg_ce == 1'b1) begin
          picoblaze_reset_int[C_NUM_PICOBLAZE-1:0] <= control_din[C_NUM_PICOBLAZE-1:0];
        end
      end     
      //
      //
      // Assignments 
      //
      if (C_PICOBLAZE_INSTRUCTION_DATA_WIDTH > 8) begin
        assign control_dout[C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-9:0] = 10'h000;
      end
      //
      // Qualify the blockram CS signal with bscan select output
      assign jtag_en_int = (bram_ce_valid) ? bram_ce : bus_zero;
      //
      assign jtag_en_expanded[C_NUM_PICOBLAZE-1:0] = jtag_en_int; 
      //
      for (i = 7; i >= C_NUM_PICOBLAZE; i = i-1)
        begin : loop4 
          if (C_NUM_PICOBLAZE < 8) begin : jtag_en_expanded_gen
            assign jtag_en_expanded[i] = 1'b0;
          end
        end
      //
      assign bram_dout_int = control_dout | jtag_dout_0_masked | jtag_dout_1_masked | jtag_dout_2_masked | jtag_dout_3_masked | jtag_dout_4_masked | jtag_dout_5_masked | jtag_dout_6_masked | jtag_dout_7_masked;
      //
      assign control_din = jtag_din_int;
      //
      assign jtag_dout_0_masked = (jtag_en_expanded[0]) ? jtag_dout_0 : 18'h00000;
      assign jtag_dout_1_masked = (jtag_en_expanded[1]) ? jtag_dout_1 : 18'h00000;
      assign jtag_dout_2_masked = (jtag_en_expanded[2]) ? jtag_dout_2 : 18'h00000;
      assign jtag_dout_3_masked = (jtag_en_expanded[3]) ? jtag_dout_3 : 18'h00000;
      assign jtag_dout_4_masked = (jtag_en_expanded[4]) ? jtag_dout_4 : 18'h00000;
      assign jtag_dout_5_masked = (jtag_en_expanded[5]) ? jtag_dout_5 : 18'h00000;
      assign jtag_dout_6_masked = (jtag_en_expanded[6]) ? jtag_dout_6 : 18'h00000;
      assign jtag_dout_7_masked = (jtag_en_expanded[7]) ? jtag_dout_7 : 18'h00000;
      //       
      assign jtag_en = jtag_en_int;
      assign jtag_din = jtag_din_int;
      assign jtag_addr = jtag_addr_int;
      assign jtag_clk = jtag_clk_int;
      assign jtag_we = jtag_we_int;
      assign picoblaze_reset = picoblaze_reset_int;
      //
    end
endgenerate
   //
endmodule
//
///////////////////////////////////////////////////////////////////////////////////////////
//
//  END OF FILE provider_mod.v
//
///////////////////////////////////////////////////////////////////////////////////////////
//
