module wpn_draw_melee (
    input  logic clk,
    input  logic rst,
    input  logic [11:0] pos_x_wpn,
    input  logic [11:0] pos_x_wpn_offset,
    input  logic [11:0] pos_y_wpn,
    input  logic [11:0] pos_y_wpn_offset,
    input  logic flip_mouse_left_right,
    input  logic flip_h,
    input  logic mouse_clicked,
    
    output logic [11:0] wpn_hgt,
    output logic [11:0] wpn_lng,

    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    localparam WPN_HGT   = 26;
    localparam IMG_WIDTH  = 54;
    localparam IMG_HEIGHT = 28;
    
    localparam WPN_LNG   = IMG_WIDTH/2; 


    logic [11:0] draw_y,draw_x, rgb_nxt;

    typedef enum logic [1:0] {IDLE, SWING_FWD, SWING_BACK} anim_state_t;
    anim_state_t anim_state;

    logic [4:0] anim_counter;   // licznik kroków animacji
    logic signed [11:0] anim_x_offset; // przesunięcie X broni w animacji


    logic [11:0] wpn_rom [0:IMG_WIDTH*IMG_HEIGHT-1];

    initial $readmemh("../../GameSprites/Melee_wpn.dat", wpn_rom);

    logic [5:0] rel_x;
    logic [5:0] rel_y;
    logic [11:0] pixel_color;
    logic [15:0] rom_addr; 

    logic [11:0] rgb_d1;
    logic [10:0] vcount_d1, hcount_d1;
    logic vsync_d1, hsync_d1, vblnk_d1, hblnk_d1;

    
    logic [11:0] rgb_d2;
    logic [10:0] vcount_d2, hcount_d2;
    logic vsync_d2, hsync_d2, vblnk_d2, hblnk_d2;


    always_ff @(posedge clk) begin
        if (rst) begin
            // draw_x <= HOR_PIXELS / 2;
            // draw_y <= VER_PIXELS - 20 - WPN_HGT;

            rgb_d1    <= '0;
            vcount_d1 <= '0;
            hcount_d1 <= '0;
            vsync_d1  <= '0;
            hsync_d1  <= '0;
            vblnk_d1  <= '0;
            hblnk_d1  <= '0;

            rgb_d2    <= '0;
            vcount_d2 <= '0;
            hcount_d2 <= '0;
            vsync_d2  <= '0;
            hsync_d2  <= '0;
            vblnk_d2  <= '0;
            hblnk_d2  <= '0;

            vga_out.vcount <= '0;
            vga_out.hcount <= '0;
            vga_out.vsync  <= '0;
            vga_out.hsync  <= '0;
            vga_out.vblnk  <= '0;
            vga_out.hblnk  <= '0;
            vga_out.rgb    <= '0;
        end else begin
            // draw_x <= pos_x_wpn;
            // draw_y <= pos_y_wpn;

        

            rgb_d1    <= rgb_nxt;
            vcount_d1 <= vga_in.vcount;
            hcount_d1 <= vga_in.hcount;
            vsync_d1  <= vga_in.vsync;
            hsync_d1  <= vga_in.hsync;
            vblnk_d1  <= vga_in.vblnk;
            hblnk_d1  <= vga_in.hblnk;

            rgb_d2    <= rgb_d1;
            vcount_d2 <= vcount_d1;
            hcount_d2 <= hcount_d1;
            vsync_d2  <= vsync_d1;
            hsync_d2  <= hsync_d1;
            vblnk_d2  <= vblnk_d1;
            hblnk_d2  <= hblnk_d1;

            vga_out.vcount <= vcount_d2;
            vga_out.hcount <= hcount_d2;
            vga_out.vsync  <= vsync_d2;
            vga_out.hsync  <= hsync_d2;
            vga_out.vblnk  <= vblnk_d2;
            vga_out.hblnk  <= hblnk_d2;
            vga_out.rgb    <= rgb_d2;

            wpn_hgt <= WPN_HGT;
            wpn_lng <= WPN_LNG;
        end
    end

    // always_ff @(posedge clk) begin
    //     if (rst) begin
    //         anim_state    <= IDLE;
    //         anim_counter      <= 0;
    //         anim_x_offset <= 0;
    //     end else begin
    //         case (anim_state)
    //             IDLE: begin
    //                 anim_x_offset <= 0;
    //                 if (mouse_clicked) begin
    //                     anim_state <= SWING_FWD;
    //                     anim_counter   <= 0;
    //                 end
    //             end
    //             SWING_FWD: begin
    //                 anim_counter <= anim_counter + 1;
    //                 anim_x_offset <= anim_counter;  // przesuwanie w prawo (np. +1 px / tick)
    //                 if (anim_counter == 10) begin   // max wychylenie
    //                     anim_state <= SWING_BACK;
    //                     anim_counter   <= 0;
    //                 end
    //             end
    //             SWING_BACK: begin
    //                 anim_counter <= anim_counter + 1;
    //                 anim_x_offset <= 10 - anim_counter; // cofanie w lewo
    //                 if (anim_counter == 10) begin
    //                     anim_state <= IDLE;
    //                     anim_counter   <= 0;
    //                     anim_x_offset <= 0;
    //                 end
    //             end
    //         endcase
    //     end
    // end


    always_comb begin
        rgb_nxt = vga_in.rgb;

        // if (mouse_clicked &&
        //     !vga_in.vblnk && !vga_in.hblnk &&
        //     vga_in.hcount >= draw_x - WPN_LNG &&
        //     vga_in.hcount <  draw_x + WPN_LNG &&
        //     vga_in.vcount >= draw_y - WPN_HGT &&
        //     vga_in.vcount <  draw_y + WPN_HGT) begin

        //     rel_y = vga_in.vcount - (draw_y - WPN_HGT);
        //     rel_x = flip_h ? (IMG_WIDTH - 1) - (vga_in.hcount - (draw_x - WPN_LNG)) : 
        //                                     (vga_in.hcount - (draw_x - WPN_LNG));

        //     if (rel_x < IMG_WIDTH && rel_y < IMG_HEIGHT) begin
        //         rom_addr = rel_y * IMG_WIDTH + rel_x;
        //         pixel_color = wpn_rom[rom_addr];
        //         if (pixel_color != 12'h02F) rgb_nxt = pixel_color;
        //     end
        // end

        if (mouse_clicked &&
            !vga_in.vblnk && !vga_in.hblnk &&
            vga_in.hcount >= pos_x_wpn_offset - WPN_LNG &&
            vga_in.hcount <  pos_x_wpn_offset + WPN_LNG &&
            vga_in.vcount >= pos_y_wpn_offset - WPN_HGT &&
            vga_in.vcount <  pos_y_wpn_offset + WPN_HGT) begin

            rel_y = vga_in.vcount - (pos_y_wpn_offset - WPN_HGT);
            //rel_x = vga_in.hcount - (pos_x_wpn_offset - WPN_LNG);


            rel_x = flip_h ? (IMG_WIDTH - 1) - (vga_in.hcount - (pos_x_wpn_offset - WPN_LNG)) : 
                                            (vga_in.hcount - (pos_x_wpn_offset - WPN_LNG));
            // rel_x = flip_mouse_left_right ? (IMG_WIDTH/2 + (IMG_WIDTH/2 - (vga_in.hcount - (pos_x_wpn_offset - WPN_LNG)))) 
            //                   : (vga_in.hcount - (pos_x_wpn_offset - WPN_LNG));

            if (rel_x < IMG_WIDTH && rel_y < IMG_HEIGHT) begin
                rom_addr = rel_y * IMG_WIDTH + rel_x;
                pixel_color = wpn_rom[rom_addr];
                if (pixel_color != 12'h02F) rgb_nxt = pixel_color;
            end
        end

        
end


    

endmodule
