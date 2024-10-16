; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------

; Time zones
TIME_PAST		equ 0					; Past
TIME_PRESENT		equ 1					; Present
TIME_FUTURE		equ 2					; Future

; Objects
MAP_OBJECT_STATE_SLOTS	equ $FF					; Map object state entry count

; ------------------------------------------------------------------------------
; Variables
; ------------------------------------------------------------------------------

	rsset WORK_RAM+$F00
game_variables		rs.b 0					; Game variables

ipx_vsync		rs.b 1					; IPX VSync flag
time_attack_mode	rs.b 1					; Time attack mode flag
saved_stage		rs.w 1					; Saved stage
			rs.b $C
time_attack_time	rs.l 1					; Time attack time
time_attack_stage	rs.w 1					; Time attack stage
ipx_vdp_reg_81		rs.w 1					; IPX VDP register $81
time_attack_unlock	rs.b 1					; Last unlocked time attack zone
unknown_buram_var	rs.b 1					; Unknown Backup RAM variable
good_future_zones	rs.b 1					; Good future zone flags
			rs.b 1
demo_id			rs.b 1					; Demo ID
title_flags		rs.b 1					; Title screen flags
			rs.b 1
save_disabled		rs.b 1					; Save disabled flag
time_stones		rs.b 1					; Time stones retrieved flags
current_special_stage	rs.b 1					; Current special stage
palette_clear_flags	rs.b 1					; Palette clear flags
			rs.b 1
ending_id		rs.b 1					; Ending ID
special_stage_lost	rs.b 1					; Special stage lost flag
			rs.b $DA
unknown_buffer 		rs.b $200				; Unknown buffer

map_object_states 	rs.b 2+(MAP_OBJECT_STATE_SLOTS*3)	; Map object states
			rs.b __RS&1
			
			rs.b 2
stage_restart		rs.w 1					; Stage restart flag
stage_frames 		rs.w 1					; Stage frame count
zone_act		rs.b 0					; Zone and act ID
zone			rs.b 1					; Zone ID
act			rs.b 1					; Act ID
lives			rs.b 1					; Life count
use_player_2 		rs.b 1					; Use player 2
drown_timer 		rs.w 1					; Drown timer
time_over 		rs.b 1					; Time over
lives_flags 		rs.b 1					; Lives flags
update_hud_lives 	rs.b 1					; Update HUD life count
update_hud_rings 	rs.b 1					; Update HUD ring count
update_hud_time 	rs.b 1					; Update HUD timer
update_hud_score 	rs.b 1					; Update HUD score
rings			rs.w 1					; Ring count
time			rs.b 1					; Time
time_minutes		rs.b 1					; Minutes
time_seconds		rs.b 1					; Seconds
time_frames		rs.b 1					; Centiseconds
score			rs.l 1					; Score
nemesis_queue_flags	rs.b 1					; Nemesis queue flags
palette_fade_flags	rs.b 1					; Palette fade flags
shield			rs.b 1					; Shield flag
invincible 		rs.b 1					; Invincible flag
speed_shoes 		rs.b 1					; Speed shoes flag
time_warp 		rs.b 1					; Time warp flag
spawn_mode		rs.b 1					; Spawn mode flag
saved_spawn_mode	rs.b 1					; Saved spawn mode flag
saved_x 		rs.w 1					; Saved X position
saved_y 		rs.w 1					; Saved Y position
warp_rings		rs.w 1					; Time warp ring count
saved_time 		rs.l 1					; Saved time
time_zone		rs.b 1					; Time zone
			rs.b 1
saved_bottom_bound	rs.w 1					; Saved bottom boundary
saved_camera_fg_x	rs.w 1					; Saved camera X position
saved_camera_fg_y	rs.w 1					; Saved camera Y position
saved_camera_bg_x	rs.w 1					; Saved background camera X position
saved_camera_bg_y	rs.w 1					; Saved background camera Y position
saved_camera_bg2_x	rs.w 1					; Saved background camera X position 2
saved_camera_bg2_y	rs.w 1					; Saved background camera Y position 2
saved_camera_bg3_x	rs.w 1					; Saved background camera X position 3
saved_camera_bg3_y	rs.w 1					; Saved background camera Y position 3
saved_water_height	rs.b 1					; Saved water height
saved_water_routine	rs.b 1					; Saved water routine
saved_water_fullscreen	rs.b 1					; Saved water fullscreen flag
warp_lives_flags	rs.b 1					; Time warp lives flags
warp_spawn_mode		rs.b 1					; Time warp spawn mode flag
			rs.b 1
warp_x 			rs.w 1					; Time warp X position
warp_y 			rs.w 1					; Time warp Y position
warp_player_flags	rs.b 1					; Time warp flags
			rs.b 1
warp_bottom_bound	rs.w 1					; Time warp bottom boundary
warp_camera_fg_x	rs.w 1					; Time warp camera X position
warp_camera_fg_y	rs.w 1					; Time warp camera Y position
warp_camera_bg_x	rs.w 1					; Time warp background camera X position
warp_camera_bg_y	rs.w 1					; Time warp background camera Y position
warp_camera_bg2_x	rs.w 1					; Time warp background camera X position 2
warp_camera_bg2_y	rs.w 1					; Time warp background camera Y position 2
warp_camera_bg3_x	rs.w 1					; Time warp background camera X position 3
warp_camera_bg3_y	rs.w 1					; Time warp background camera Y position 3
warp_water_height	rs.w 1					; Time warp water height
warp_water_routine	rs.b 1					; Time warp water routine
warp_water_fullscreen	rs.b 1					; Time warp water fullscreen flag
warp_ground_speed 	rs.w 1					; Time warp ground velocity
warp_x_speed 		rs.w 1					; Time warp X velocity
warp_y_speed 		rs.w 1					; Time warp Y velocity
good_future		rs.b 1					; Good future flag
powerup			rs.b 1					; Powerup ID
unknown_stage_flag 	rs.b 1					; Unknown stage flag
projector_destroyed	rs.b 1					; Projector destroyed flag
special_stage		rs.b 1					; Special stage flag
combine_ring 		rs.b 1					; Combine ring flag (leftover)
warp_time 		rs.l 1					; Time warp time
section_id		rs.w 1					; Section ID
			rs.b 1
amy_captured		rs.b 1					; Amy captured flag
next_1up_score		rs.l 1					; Next 1UP score
debug_angle 		rs.b 1					; Debug angle
debug_angle_shift	rs.b 1					; Debug angle (shifted)
debug_quadrant		rs.b 1					; Debug quadrant
debug_floor_dist 	rs.b 1					; Debug floor distance
demo_mode		rs.w 1					; Demo mode flag
			rs.w 1
s1_credits_index	rs.w 1					; Credits index (leftover from Sonic 1)
hardware_version 	rs.b 1					; Hardware version
			rs.b 1
debug_cheat		rs.w 1					; Debug cheat flag
init_flag 		rs.l 1					; Initialized flag
checkpoint		rs.b 1					; Checkpoint ID
			rs.b 1
good_future_acts	rs.b 1					; Good future act flags
saved_mini_player	rs.b 1					; Saved mini player flag
			rs.b 1
warp_mini_player	rs.b 1					; Time warp mini player flag
			rs.b $6C
flower_positions	rs.b $300				; Flower position buffer
flower_count		rs.b 3					; Flower count
fade_enable_display	rs.b 1					; Enable display when fading
debug_object 		rs.b 1					; Debug object
			rs.b 1
debug_mode 		rs.w 1					; Debug mode
			rs.b 2
stage_vblank_frames	rs.l 1					; Stage V-BLANK frame count
time_stop		rs.w 1					; Time stop timer
log_spike_anim_timer	rs.b 1					; Log spike animation timer (leftover from Sonic 1)
log_spike_anim_frame	rs.b 1					; Log spike animation frame (leftover from Sonic 1)
ring_anim_timer		rs.b 1					; Ring animation timer
ring_anim_frame		rs.b 1					; Ring animation frame
unknown_anim_timer	rs.b 1					; Unknown animation timer (leftover from Sonic 1)
unknown_anim_frame	rs.b 1					; Unknown animation frame (leftover from Sonic 1)
ring_loss_anim_timer	rs.b 1					; Ring loss animation timer
ring_loss_anim_frame	rs.b 1					; Ring loss animation frame
ring_loss_anim_accum	rs.w 1					; Ring loss animation accumulator
			rs.b $C
camera_fg_x_copy	rs.l 1					; Camera X position copy
camera_fg_y_copy	rs.l 1					; Camera Y position copy
camera_bg_x_copy	rs.l 1					; Camera background X position copy
camera_bg_y_copy	rs.l 1					; Camera background Y position copy
camera_bg2_x_copy	rs.l 1					; Camera background X position 2 copy
camera_bg2_y_copy	rs.l 1					; Camera background Y position 2 copy
camera_bg3_x_copy	rs.l 1					; Camera background X position 3 copy
camera_bg3_y_copy	rs.l 1					; Camera background Y position 3 copy
scroll_flags_fg_copy	rs.w 1					; Scroll flags copy
scroll_flags_bg_copy	rs.w 1					; Scroll flags copy (background)
scroll_flags_bg2_copy	rs.w 1					; Scroll flags copy (background 2)
scroll_flags_bg3_copy	rs.w 1					; Scroll flags copy (background 3)
debug_map_block 	rs.w 1					; Debug map block ID
ccz_no_bumper		rs.b 1
			rs.b 3
debug_subtype_2		rs.b 1					; Debug subtype 2 ID
water_sway_angle	rs.b 1					; Water sway angle
layer			rs.b 1					; Layer ID
stage_started		rs.b 1					; Stage started flag
boss_music		rs.b 1					; Boss music flag
			rs.b 1
wwz_beam_mode		rs.b 1					; Wacky Workbench electric beam mode
mini_player 		rs.b 1					; Mini player flag
			rs.b $24
anim_art_buffer 	rs.b $480				; Animated art buffer
scroll_section_speeds	rs.b $200				; Scroll section speeds
work_ram_file		rs.b 0					; Work RAM file data

GAME_VARIABLES_SIZE	equ __RS-game_variables			; Size of global variables
WORK_RAM_FILE_SIZE	equ (WORK_RAM+$FB00)-work_ram_file	; Size of Work RAM file

; ------------------------------------------------------------------------------
