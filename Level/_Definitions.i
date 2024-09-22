; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Stage variables
; ------------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/Main CPU Variables.i"
	include	"_Include/Sound.i"
	include	"_Include/System.i"
	include	"_Include/MMD.i"

; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------

; Objects
OBJECT_RESERVE_COUNT	equ 32
OBJECT_SPAWN_COUNT	equ 96
OBJECT_COUNT		equ OBJECT_RESERVE_COUNT+OBJECT_SPAWN_COUNT

; Demo
DemoDataRel		equ $6C00				; Demo data location within chunk data
DemoData		equ LevelChunks+DemoDataRel		; Demo data location

; ------------------------------------------------------------------------------
; Object variables structure
; ------------------------------------------------------------------------------

	rsreset
obj.id			rs.b 1					; ID
obj.sprite_flags	rs.b 1					; Sprite flags
obj.sprite_tile		rs.w 1					; Base tile ID
obj.sprites		rs.l 1					; Sprite data address
obj.x			rs.l 1					; X position
obj.y			rs.l 1					; Y position
obj.screen_x		equ obj.x				; Screen X position
obj.screen_y		equ obj.x+2				; Screen Y position
obj.x_speed		rs.w 1					; X speed
obj.y_speed		rs.w 1					; Y speed
			rs.b 2
obj.collide_height	rs.b 1					; Collision height
obj.collide_width	rs.b 1					; Collision width
obj.sprite_layer	rs.b 1					; Sprite layer
obj.width		rs.b 1					; Width
obj.sprite_frame	rs.b 1					; Sprite frame ID
obj.anim_frame		rs.b 1					; Animation script frame ID
obj.anim_id		rs.b 1					; Animation ID
obj.prev_anim_id	rs.b 1					; Previous previous animation ID
obj.anim_time		rs.b 1					; Animation timer
			rs.b 1
obj.collide_type	rs.b 1					; Collision type
obj.collide_status	rs.b 1					; Collision status
obj.flags		rs.b 1					; Flags
obj.state_id		rs.b 1					; State entry ID
obj.routine		rs.b 1					; Routine ID
obj.solid_type		rs.b 0					; Solidity type
obj.routine_2		rs.b 1					; Secondary routine ID
obj.angle		rs.b 1					; Angle
			rs.b 1					; Object specific variable
obj.subtype		rs.b 1					; Subtype ID
obj.layer		rs.b 0					; Layer ID
obj.subtype_2		rs.b 1					; Secondary subtype ID
			rs.b $40-__rs
obj.struct_size		rs.b 0					; Size of structure		

	c: = 0
	rept obj.struct_size
obj.var_\$c	equ c
		c: = c+1
	endr

; ------------------------------------------------------------------------------
; Player object variables
; ------------------------------------------------------------------------------

oPlayerGVel		equ obj.var_14				; Ground velocity
oPlayerCharge		equ obj.var_2A				; Peelout/spindash charge timer

oPlayerCtrl		equ obj.var_2C				; Control flags
oPlayerJump		equ obj.var_3C				; Jump flag
oPlayerMoveLock		equ obj.var_3E				; Movement lock timer

oPlayerPriAngle		equ obj.var_36				; Primary angle
oPlayerSecAngle		equ obj.var_37				; Secondary angle
oPlayerStick		equ obj.var_38				; Collision stick flag

oPlayerHurt		equ obj.var_30				; Hurt timer
oPlayerInvinc		equ obj.var_32				; Invincibility timer
oPlayerShoes		equ obj.var_34				; Speed shoes timer
oPlayerReset		equ obj.var_3A				; Reset timer

oPlayerRotAngle		equ obj.var_2B				; Rotation angle
oPlayerRotDist		equ obj.var_39				; Rotation distance
oPlayerRotCenter	equ obj.var_3E				; Rotation center

oPlayerPushObj		equ obj.var_20				; ID of object being pushed on
oPlayerStandObj		equ obj.var_3D				; ID of object being stood on

oPlayerHangAni		equ obj.var_1F				; Hanging animation timer

; ------------------------------------------------------------------------------
; Object layout entry structure
; ------------------------------------------------------------------------------

	rsreset
oeX		rs.w	1			; X position
oeY		rs.w	1			; Y position/flags
oeID		rs.b	1			; ID
oeSubtype	rs.b	1			; Subtype
oeTimeZones	rs.b	1			; Time zones
oeSubtype2	rs.b	1			; Subtype 2
oeSize		rs.b	0			; Size of structure

; ------------------------------------------------------------------------------
; RAM
; ------------------------------------------------------------------------------

	rsset WORKRAM+$2000
map_blocks 		rs.b $2000				; Map blocks
unknown_buffer_2 	rs.b $1000				; Unknown buffer

	rsset WORKRAM+$FF00A000
map_layout 		rs.b $800				; Map layout
deform_buffer		rs.b $200				; Deformation buffer
nem_code_table		rs.b $200				; Nemesis decompression code table
object_draw_queue	rs.b 8*(($3F+1)*2)			; Object draw queue
			rs.b $1800
player_art_buffer 	rs.b $300				; Player art buffer
player_positions	rs.b $100				; Player position tracker buffer
hscroll 		rs.b $400				; Horizontal scroll buffer

objects			rs.b 0					; Objects
reserved_objects	rs.b 0					; Reserved objects
player_object 		rs.b obj.struct_size			; Player slot
player_2_object 	rs.b obj.struct_size			; Player 2 slot
hud_score_object	rs.b obj.struct_size			; HUD (score) slot
hud_lives_object	rs.b obj.struct_size			; HUD (lives) slot
title_card_object	rs.b obj.struct_size			; Title card slot
hud_rings_object	rs.b obj.struct_size			; HUD (rings) slot
shield_object 		rs.b obj.struct_size			; Shield slot
bubbles_object 		rs.b obj.struct_size			; Bubbles slot
inv_stars_1_object	rs.b obj.struct_size			; Invincibility star 1 slot
inv_stars_2_object	rs.b obj.struct_size			; Invincibility star 2 slot
inv_stars_3_object	rs.b obj.struct_size			; Invincibility star 3 slot
inv_stars_4_object	rs.b obj.struct_size			; Invincibility star 4 slot
time_star_1_object	rs.b obj.struct_size			; Time warp star 1 slot
time_star_2_object	rs.b obj.struct_size			; Time warp star 2 slot
time_star_3_object	rs.b obj.struct_size			; Time warp star 3 slot
time_star_4_object	rs.b obj.struct_size			; Time warp star 4 slot
			rs.b obj.struct_size
			rs.b obj.struct_size
			rs.b obj.struct_size
			rs.b obj.struct_size
			rs.b obj.struct_size
			rs.b obj.struct_size
			rs.b obj.struct_size
			rs.b obj.struct_size
			rs.b obj.struct_size
			rs.b obj.struct_size
			rs.b obj.struct_size
			rs.b obj.struct_size
			rs.b obj.struct_size
			rs.b obj.struct_size
			rs.b obj.struct_size
hud_icon_object		rs.b obj.struct_size			; HUD (life icon) slot
reserved_objects_end	rs.b 0					; End of reserved objects
object_spawn_pool 	rs.b OBJECT_SPAWN_COUNT*obj.struct_size	; Object spawn pool
object_spawn_pool_End	rs.b 0					; End of object spawn pool
objects_end		rs.b 0					; End of objects

			rs.b $A
fm_sound_queue_1 	rs.b 1					; FM sound queue 1
fm_sound_queue_2 	rs.b 1					; FM sound queue 2
fm_sound_queue_3 	rs.b 1					; FM sound queue 3
			rs.b $5F3
game_mode 		rs.b 1					; Game mode
			rs.b 1
			
player_ctrl		rs.b 0					; Player controller data
player_ctrl_hold 	rs.b 1					; Player held controller data
player_ctrl_tap		rs.b 1					; Player tapped controller data
p1_ctrl			rs.b 0					; Player 1 controller data
p1_ctrl_hold 		rs.b 1					; Player 1 held controller data
p1_ctrl_tap		rs.b 1					; Player 1 tapped controller data
p2_ctrl			rs.b 0					; Player 2 controller data
p2_ctrl_hold 		rs.b 1					; Player 2 held controller data
p2_ctrl_tap		rs.b 1					; Player 2 tapped controller data

			rs.l 1
vdp_reg_81 		rs.w 1					; VDP register $81
			rs.b 6
global_timer 		rs.w 1					; V-BLANK interrupt timer
vscroll_screen 		rs.l 1					; Vertical scroll (full screen)
hscroll_screen 		rs.l 1					; Horizontal scroll (full screen)
			rs.b 6
vdp_reg_8a 		rs.w 1					; H-BLANK interrupt counter
palette_fade_params	rs.b 0					; Palette fade parameters
palette_fade_start	rs.b 1					; Palette fade start
palette_fade_length 	rs.b 1					; Palette fade length

misc_variables		rs.b 0
vblank_e_count 		rs.b 1					; V-BLANK routine $E counter
			rs.b 1
vblank_routine 		rs.b 1					; V-BLANK routine ID
			rs.b 1
sprite_count 		rs.b 1					; Sprite count
			rs.b 9
rng_seed 		rs.l 1					; RNG seed
paused 			rs.w 1					; Paused flag
			rs.l 1
dma_command_low		rs.w 1					; DMA command low word buffer
			rs.l 1
water_height 		rs.w 1					; Water height (actual)
water_height_logical	rs.w 1					; Water height (logical)
target_water_height	rs.w 1					; Target water height
water_move_speed	rs.b 1					; Water height move speed
water_routine		rs.b 1					; Water routine ID
water_fullscreen 	rs.b 1					; Water fullscreen flag
			rs.b $17
anim_art_frames		rs.b 6					; Animated art frames
anim_art_timers		rs.b 6					; Animated art timers
			rs.b $E
misc_variables_end	rs.b 0

nem_art_queue 		rs.b $60				; Nemesis art queue
nem_art_write 		rs.l 1					; PLC 
nem_art_repeat 		rs.l 1					; PLC 
nem_art_pixel 		rs.l 1					; PLC 
nem_art_row 		rs.l 1					; PLC 
nem_art_read 		rs.l 1					; PLC 
nem_art_shift 		rs.l 1					; PLC 
nem_art_tile_count 	rs.w 1					; PLC 
nem_art_proc_tile_count rs.w 1					; PLC 
hblank_flag 		rs.w 1					; H-BLANK flag
			rs.w 1
			
camera_fg_x 		rs.l 1					; Camera X position
camera_fg_y 		rs.l 1					; Camera Y position
camera_bg_x 		rs.l 1					; Background camera X position
camera_bg_y 		rs.l 1					; Background camera Y position
camera_bg2_x 		rs.l 1					; Background 2 camera X position
camera_bg2_y 		rs.l 1					; Background 2 camera Y position
camera_bg3_x 		rs.l 1					; Background 3 camera X position
camera_bg3_y 		rs.l 1					; Background 3 camera Y position
target_left_bound	rs.w 1					; Camera target left boundary
target_right_bound	rs.w 1					; Camera target right boundary
target_top_bound	rs.w 1					; Camera target top boundary
target_bottom_bound	rs.w 1					; Camera target bottom boundary
left_bound 		rs.w 1					; Camera left boundary
right_bound 		rs.w 1					; Camera right boundary
top_bound 		rs.w 1					; Camera top boundary
bottom_bound 		rs.w 1					; Camera bottom boundary
unused_f730 		rs.w 1
left_bound_unknown	rs.w 1
			rs.b 6
scroll_x_diff		rs.w 1					; Horizontal scroll difference
scroll_y_diff		rs.w 1					; Vertical scroll difference
camera_y_center 	rs.w 1					; Camera Y center
unused_f740 		rs.b 1
unused_f741 		rs.b 1
event_routine		rs.w 1					; Level event routine ID
scroll_lock 		rs.w 1					; Scroll lock flag
unused_f746 		rs.w 1
unused_f748 		rs.w 1
map_block_cross_fg_x	rs.b 1					; Horizontal block crossed flag
map_block_cross_fg_y	rs.b 1					; Vertical block crossed flag
map_block_cross_bg_x	rs.b 1					; Horizontal block crossed flag (background)
map_block_cross_bg_y	rs.b 1					; Vertical block crossed flag (background)
map_block_cross_bg2_x	rs.b 1					; Horizontal block crossed flag (background 2)
map_block_cross_bg2_y	rs.b 1					; Vertical block crossed flag (background 2)
map_block_cross_bg3_x	rs.b 1					; Horizontal block crossed flag (background 3)
map_block_cross_bg3_y	rs.b 1					; Vertical block crossed flag (background 3)
			rs.b 1
			rs.b 1
scroll_flags_fg		rs.w 1					; Scroll flags
scroll_flags_bg		rs.w 1					; Scroll flags (background)
scroll_flags_bg2	rs.w 1					; Scroll flags (background 2)
scroll_flags_bg3	rs.w 1					; Scroll flags (background 3)
bottom_bound_shift	rs.w 1					; Bottom boundary shifting flag
			rs.b 1
sneeze_flag		rs.b 1					; Sneeze flag (prototype leftover)

player_top_speed	rs.w 1					; Player top speed
player_acceleration	rs.w 1					; Player acceleration
player_deceleration	rs.w 1					; Player deceleration
player_prev_frame	rs.b 1					; Player's previous sprite frame ID
update_player_art	rs.b 1					; Update player's art flag
angle_buffer_1		rs.b 1					; Angle buffer 1
			rs.b 1
angle_buffer_2		rs.b 1					; Angle buffer 2
			rs.b 1
			
map_object_spawn	rs.b 1					; Map object spawn routine ID
			rs.b 1
prev_map_object_chunk	rs.w 1					; Previous map object layout chunk position
map_object_chunk_right	rs.l 1					; Map object layout right chunk address
map_object_chunk_left	rs.l 1					; Map object layout left chunk address
map_object_chunk_null_1	rs.l 1					; Map object layout right chunk address (null)
map_object_chunk_null_2	rs.l 1					; Map object layout left chunk 2 address (null)
bored_timer 		rs.w 1					; Bored timer
bored_timer_p2 		rs.w 1					; Player 2 bored timer
time_warp_direction	rs.b 1					; Time warp direction
			rs.b 1
time_warp_timer		rs.w 1					; Time warp timer
look_mode 		rs.b 1					; Look mode
			rs.b 1
demo_data 		rs.l 1					; Demo data address
demo_data_cursor	rs.w 1					; Demo data cursor
s1_demo_cursor		rs.w 1					; Demo index (Sonic 1 leftover)
			rs.l 1
map_collision		rs.l 1					; Map collision data address
			rs.b 6
camera_x_center 	rs.w 1					; Camera X center
			rs.b 5
boss_flags		rs.b 1					; Boss flags
player_positions_index	rs.w 1					; Player position tracker index
boss_fight 		rs.b 1					; Boss fight flag
			rs.b 1
special_map_chunks 	rs.l 1					; Special map chunk IDs
palette_cycle_steps 	rs.b 7					; Palette cycle steps
palette_cycle_timers	rs.b 7					; Palette cycle timers
			rs.b 9
wind_tunnel_flag	rs.b 1					; Wind tunnel flag
			rs.b 1
			rs.b 1
water_slide_flag 	rs.b 1					; Water slide flag
			rs.b 1
ctrl_locked 		rs.b 1					; Controls locked flag
			rs.b 3
score_chain		rs.w 1					; Score chain
time_bonus		rs.w 1					; Time bonus
ring_bonus		rs.w 1					; Ring bonus
update_hud_bonus	rs.b 1					; Update results bonus flag
			rs.b 3
saved_sr 		rs.w 1					; Saved status register
			rs.b 4
button_flags		rs.b $20				; Button press flags
sprites 		rs.b $200				; Sprite buffer
water_fade_palette	rs.b $80				; Water fade palette buffer (uses part of sprite buffer)
water_palette		rs.b $80				; Water palette buffer
palette 		rs.b $80				; Palette buffer
fade_palette 		rs.b $80				; Fade palette buffer

; ------------------------------------------------------------------------------
; VDP DMA from 68000 memory to VDP memory
; ------------------------------------------------------------------------------
; PARAMETERS:
;	src  - Source address in 68000 memory
;	dest - Destination address in VDP memory
;	len  - Length of data in bytes
;	type - Type of VDP memory
; ------------------------------------------------------------------------------

LVLDMA macro src, dest, len, type
	lea	VDPCTRL,a5
	move.l	#$94009300|((((\len)/2)&$FF00)<<8)|(((\len)/2)&$FF),(a5)
	move.l	#$96009500|((((\src)/2)&$FF00)<<8)|(((\src)/2)&$FF),(a5)
	move.w	#$9700|(((\src)>>17)&$7F),(a5)
	VDPCMD	move.w,\dest,\type,DMA,>>16,(a5)
	VDPCMD	move.w,\dest,\type,DMA,&$FFFF,dma_command_low
	move.w	dma_command_low,(a5)
	endm

; ------------------------------------------------------------------------------
; Background section
; ------------------------------------------------------------------------------
; PARAMETERS:
;	size - Size of scrion
;	id   - Section type
; ------------------------------------------------------------------------------

BGSTATIC	equ 0
BGDYNAMIC1	equ 2
BGDYNAMIC2	equ 4
BGDYNAMIC3	equ 6

; ------------------------------------------------------------------------------

BGSECT macro size, id
	dcb.b	(\size)/16, \id
	endm

; ------------------------------------------------------------------------------
; Start debug item index
; ------------------------------------------------------------------------------
; PARAMETERS:
;	off - (OPTION) Count offset
; ------------------------------------------------------------------------------

__dbgID = 0
DBSTART macro off
	__dbgCount: = 0
	if narg>0
		dc.b	(__dbgCount\#__dbgID\)+(\off)
	else
		dc.b	__dbgCount\#__dbgID
	endif
	even
	endm

; ------------------------------------------------------------------------------
; Debug item
; ------------------------------------------------------------------------------
; PARAMETERS:
;	id       - Object ID
;	priority - Priority
;	mappings - Mappings
;	tile     - Tile ID
;	subtype  - Subtype
;	flip     - Flip flags
;	subtype2 - Subtype 2
;	frame    - Sprite frame
; ------------------------------------------------------------------------------

DBGITEM macro id, priority, mappings, tile, subtype, flip, subtype2, frame
	dc.b	\id, \priority
	dc.l	\mappings
	dc.w	\tile
	dc.b	\subtype, \flip, \subtype2, \frame
	__dbgCount: = __dbgCount+1
	endm

; ------------------------------------------------------------------------------
; End debug item index
; ------------------------------------------------------------------------------

DBGEND macro
	__dbgCount\#__dbgID: EQU __dbgCount
	endm

; ------------------------------------------------------------------------------
