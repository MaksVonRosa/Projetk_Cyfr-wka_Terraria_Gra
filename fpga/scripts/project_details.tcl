# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Description:
# Project detiles required for generate_bitstream.tcl
# Make sure that project_name, top_module and target are correct.
# Provide paths to all the files required for synthesis and implementation.
# Depending on the file type, it should be added in the corresponding section.
# If the project does not use files of some type, leave the corresponding section commented out.

#-----------------------------------------------------#
#                   Project details                   #
#-----------------------------------------------------#
# Project name                                  -- EDIT
set project_name vga_project

# Top module name                               -- EDIT
set top_module top_vga_basys3

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                   -- EDIT
set xdc_files {
    constraints/top_vga_basys3.xdc
    constraints/clk_wiz_0.xdc
}

# Specify SystemVerilog design files location   -- EDIT
set sv_files {
    ../rtl/Weapon/weapon_top.sv
    ../rtl/Weapon/melee_wpn_animated.sv
    ../rtl/Weapon/weapon_draw.sv
    ../rtl/Weapon/weapon_position.sv
    ../rtl/Weapon/archer_projectile_draw.sv
    ../rtl/Weapon/archer_projectile_animated.sv
    ../rtl/Mouse/draw_mouse.sv 
    ../rtl/vga/vga_pkg.sv
    ../rtl/vga/vga_timing.sv
    ../rtl/Game/draw_bg.sv
    ../rtl/Character/char.sv
    ../rtl/Character/char_ctrl.sv
    ../rtl/Character/char_draw.sv
    ../rtl/Character/draw_player_2.sv
    ../rtl/Boss/boss_hp.sv
    ../rtl/Boss/boss_move.sv
    ../rtl/Boss/boss_render.sv
    ../rtl/Boss/boss_top.sv
    ../rtl/Game/platform.sv
    ../rtl/Game/game_fsm.sv
    ../rtl/Game/read_rom.sv
    ../rtl/Game/game_screen.sv
    ../rtl/Character/class_selector.sv
    ../rtl/uart/uart_game_encoder.sv
    ../rtl/uart/uart_game_decoder.sv
    ../rtl/Character/hearts_display.sv
    ../rtl/vga/top_vga.sv
    ../rtl/vga/vga_if.sv
    ../rtl/tick_gen.sv
    rtl/top_vga_basys3.sv
}

 # Specify Verilog design files location         -- EDIT
 set verilog_files {
    ../rtl/clk_wiz_0_clk_wiz.v 
    ../rtl/uart/list_ch08_01_uart_rx.v
    ../rtl/uart/list_ch08_02_flag_buf.v
    ../rtl/uart/list_ch08_03_uart_tx.v
    ../rtl/uart/list_ch08_04_uart.v
    ../rtl/uart/list_ch04_11_mod_m_counter.v
    ../rtl/uart/list_ch04_20_fifo.v

 }

# Specify VHDL design files location            -- EDIT
set vhdl_files {
    ../rtl/Mouse/MouseCtl.vhd \
    ../rtl/Mouse/Ps2Interface.vhd \
    ../rtl/Mouse/MouseDisplay.vhd \
}

# Specify files for a memory initialization     -- EDIT
# set mem_files {
#    path/to/file.data
# }
