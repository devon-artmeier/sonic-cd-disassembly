; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Load saved data
; ------------------------------------------------------------------------------

LoadTimeWarpData:
	move.w	warp_x,obj.x(a6)
	move.w	warp_y,obj.y(a6)
	move.b	warp_player_flags,obj.flags(a6)
	move.w	warp_ground_speed,oPlayerGVel(a6)
	move.w	warp_x_speed,obj.x_speed(a6)
	move.w	warp_y_speed,obj.y_speed(a6)
	move.w	warp_rings,rings
	move.b	warp_lives_flags,lives_flags
	move.l	warp_time,time
	move.b	warp_water_routine,water_routine
	move.w	warp_bottom_bound,bottom_bound
	move.w	warp_bottom_bound,target_bottom_bound
	move.w	warp_camera_fg_x,camera_fg_x
	move.w	warp_camera_fg_y,camera_fg_y
	move.w	warp_camera_bg_x,camera_bg_x
	move.w	warp_camera_bg_y,camera_bg_y
	move.w	warp_camera_bg2_x,camera_bg2_x
	move.w	warp_camera_bg2_y,camera_bg2_y
	move.w	warp_camera_bg3_x,camera_bg3_x
	move.w	warp_camera_bg3_y,camera_bg3_y
	cmpi.b	#6,zone
	bne.s	.NoMini2
	move.b	warp_mini_player,mini_player

.NoMini2:
	tst.b	spawn_mode
	bpl.s	.End
	move.w	warp_x,d0
	subi.w	#320/2,d0
	move.w	d0,left_bound

.End:
	rts
	
; ------------------------------------------------------------------------------

LoadCheckpointData:
	lea	player_object,a6
	cmpi.b	#2,spawn_mode
	beq.w	LoadTimeWarpData
	
	move.b	saved_spawn_mode,spawn_mode
	move.w	saved_x,obj.x(a6)
	move.w	saved_y,obj.y(a6)
	clr.w	rings
	clr.b	lives_flags
	move.l	saved_time,time
	move.b	#59,time_frames
	subq.b	#1,time_seconds
	move.b	saved_water_routine,water_routine
	move.w	saved_bottom_bound,bottom_bound
	move.w	saved_bottom_bound,target_bottom_bound
	move.w	saved_camera_fg_x,camera_fg_x
	move.w	saved_camera_fg_y,camera_fg_y
	move.w	saved_camera_bg_x,camera_bg_x
	move.w	saved_camera_bg_y,camera_bg_y
	move.w	saved_camera_bg2_x,camera_bg2_x
	move.w	saved_camera_bg2_y,camera_bg2_y
	move.w	saved_camera_bg3_x,camera_bg3_x
	move.w	saved_camera_bg3_y,camera_bg3_y
	cmpi.b	#6,zone
	bne.s	.NoMini
	move.b	saved_mini_player,mini_player

.NoMini:
	cmpi.b	#2,zone
	bne.s	.NoWater
	move.w	saved_water_height,water_height_logical
	move.b	saved_water_routine,water_routine
	move.b	saved_water_fullscreen,water_fullscreen

.NoWater:
	tst.b	spawn_mode
	bpl.s	.End
	move.w	saved_x,d0
	subi.w	#320/2,d0
	move.w	d0,left_bound

.End:
	rts

; ------------------------------------------------------------------------------
