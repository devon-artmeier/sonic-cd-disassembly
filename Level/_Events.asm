; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Level events
; ------------------------------------------------------------------------------

RunLevelEvents:
	moveq	#0,d0				; Run level events
	move.b	zone,d0
	add.w	d0,d0
	move.w	.Events(pc,d0.w),d0
	jsr	.Events(pc,d0.w)

	cmpi.b	#$2B,player_object+obj.anim_id	; Is the player giving up from boredom?
	bne.s	.NotGivingUp			; If not, branch
	move.w	camera_fg_y,bottom_bound	; Set the bottom boundary of the level to wherever the camera is
	move.w	camera_fg_y,target_bottom_bound

.NotGivingUp:
	moveq	#4,d1				; Bottom boundary shift speed
	move.w	target_bottom_bound,d0		; Is the bottom boundary shifting?
	sub.w	bottom_bound,d0
	beq.s	.End				; If not, branch
	bcc.s	.MoveDown			; If it's scrolling down, branch

	neg.w	d1				; Set the speed to go up
	move.w	camera_fg_y,d0			; Is the camera past the target bottom boundary?
	cmp.w	target_bottom_bound,d0
	bls.s	.ShiftUp			; If not, branch
	move.w	d0,bottom_bound			; Set the bottom boundary to be where the camera id
	andi.w	#$FFFE,bottom_bound

.ShiftUp:
	add.w	d1,bottom_bound			; Shift the boundary up
	move.b	#1,bottom_bound_shift		; Mark as shifting

.End:
	rts

.MoveDown:
	move.w	camera_fg_y,d0			; Is the camera near the bottom boundary?
	addq.w	#8,d0
	cmp.w	bottom_bound,d0
	bcs.s	.ShiftDown			; If not, branch
	btst	#1,player_object+obj.flags	; Is the player in the air?
	beq.s	.ShiftDown			; If not, branch
	add.w	d1,d1				; If so, quadruple the shift speed
	add.w	d1,d1

.ShiftDown:
	add.w	d1,bottom_bound			; Shift the boundary down
	move.b	#1,bottom_bound_shift		; Mark as shifting
	rts

; ------------------------------------------------------------------------------

.Events:
	dc.w	LevEvents_PPZ-.Events		; PPZ
	dc.w	LevEvents_CCZ-.Events		; CCZ
	dc.w	LevEvents_TTZ-.Events		; TTZ
	dc.w	LevEvents_QQZ-.Events		; QQZ
	dc.w	LevEvents_WWZ-.Events		; WWZ
	dc.w	LevEvents_SSZ-.Events		; SSZ
	dc.w	LevEvents_MMZ-.Events		; MMZ

; ------------------------------------------------------------------------------
; Palmtree Panic level events
; ------------------------------------------------------------------------------

LevEvents_PPZ:
	moveq	#0,d0				; Run act specific level events
	move.b	act,d0
	add.w	d0,d0
	move.w	LevEvents_PPZ_Index(pc,d0.w),d0
	jmp	LevEvents_PPZ_Index(pc,d0.w)

; ------------------------------------------------------------------------------

LevEvents_PPZ_Index:
	dc.w	LevEvents_PPZ1-LevEvents_PPZ_Index
	dc.w	LevEvents_PPZ2-LevEvents_PPZ_Index
	dc.w	LevEvents_PPZ3-LevEvents_PPZ_Index

; ------------------------------------------------------------------------------

LevEvents_PPZ1:
	cmpi.b	#TIME_PRESENT,time_zone		; Are we in the present?
	bne.s	LevEvents_PPZ2			; If not, branch

	cmpi.w	#$1C16,player_object+obj.x	; Is the player within the second 3D ramp?
	bcs.s	.Not3DRamp			; If not, branch
	cmpi.w	#$21C6,player_object+obj.x
	bcc.s	.Not3DRamp			; If not, branch
	move.w	#$88,camera_y_center		; If so, change the camera Y center

.Not3DRamp:
	move.w	#$710,target_bottom_bound	; Set bottom boundary before the first 3D ramp

	cmpi.w	#$840,camera_fg_x		; Is the camera's X position < $840?
	bcs.s	.End				; If so, branch

	tst.b	update_hud_time			; Is the level timer running?
	beq.s	.AlreadySet			; If not, branch

	cmpi.w	#$820,left_bound		; Has the left boundary been set
	bcc.s	.AlreadySet			; If not, branch
	move.w	#$820,left_bound		; Set the left boundary so that the player can't go back to the first 3D ramp
	move.w	#$820,target_left_bound

.AlreadySet:
	move.w	#$410,target_bottom_bound	; Set bottom boundary after the first 3D ramp
	cmpi.w	#$E00,camera_fg_x		; Is the camera's X position < $E00?
	bcs.s	.End				; If so, branch
	move.w	#$310,target_bottom_bound	; Update the bottom boundary

.End:
	rts

; ------------------------------------------------------------------------------

LevEvents_PPZ2:
	move.w	#$310,target_bottom_bound	; Set default bottom boundary
	rts

; ------------------------------------------------------------------------------

LevEvents_PPZ3:
	tst.b	boss_flags			; Is the boss active?
	bne.s	.End				; If so, branch

	move.w	#$310,target_bottom_bound	; Set default bottom boundary
	move.w	#$D70,d0			; Handle end of act 3 boundary
	move.w	#$310,d1
	bsr.w	CheckBossStart

.End:
	rts

; ------------------------------------------------------------------------------
; Collision Chaos level events
; ------------------------------------------------------------------------------

LevEvents_CCZ:
	moveq	#0,d0				; Run act specific level events
	move.b	act,d0
	add.w	d0,d0
	move.w	LevEvents_CCZ_Index(pc,d0.w),d0
	jmp	LevEvents_CCZ_Index(pc,d0.w)

; ------------------------------------------------------------------------------

LevEvents_CCZ_Index:
	dc.w	LevEvents_CCZ12-LevEvents_CCZ_Index
	dc.w	LevEvents_CCZ12-LevEvents_CCZ_Index
	dc.w	LevEvents_CCZ3-LevEvents_CCZ_Index

; ------------------------------------------------------------------------------

LevEvents_CCZ12:
	move.w	#$510,target_bottom_bound	; Set default bottom boundary
	rts

; ------------------------------------------------------------------------------

LevEvents_CCZ3:
	tst.b	boss_flags			; Was the boss defeated?
	bne.w	.ChkLock			; If so, branch
	move.w	#$510,target_bottom_bound	; Set default bottom boundary
	rts

.ChkLock:
	move.w	#$60,d1				; Handle end of act 3 boundary
	bra.w	SetBossBounds

; ------------------------------------------------------------------------------
; Wacky Workbench level events
; ------------------------------------------------------------------------------

LevEvents_WWZ:
	btst	#4,boss_flags			; Is the boss active?
	bne.s	.BossActive			; If so, branch
	move.w	#$710,target_bottom_bound	; Set default bottom boundary
	rts

.BossActive:
	move.w	#$BA0,d0			; Handle end of act 3 boundary
	move.w	#$1D0,d1
	bsr.w	CheckBossStart
	bne.w	.End				; If the boundary was set, branch

	lea	player_object,a1		; Check where the player is
	cmpi.w	#$298,obj.y(a1)			; Are they at the top of the boss arena?
	ble.s	.BoundTop			; If so, branch
	cmpi.w	#$498,obj.y(a1)			; Are they in the middle of the boss arena?
	ble.s	.BoundMiddle			; If so, branch

.BoundBottom:
	move.w	#$5D0,d0			; Set the bottom boundary at the bottom
	bra.s	.SetBound

.BoundMiddle:
	move.w	#$3D0,d0			; Set the bottom boundary in the middle
	bra.s	.SetBound

.BoundTop:
	move.w	#$1D0,d0			; Set the bottom boundary at the top

.SetBound:
	move.w	d0,d1				; Set target bottom boundary
	move.w	d0,target_bottom_bound

	sub.w	bottom_bound,d0			; Is the current bottom boundary near the target?
	bge.s	.CheckNearBound
	neg.w	d0

.CheckNearBound:
	cmpi.w	#2,d0
	bgt.s	.End				; If not, branch
	move.w	d1,bottom_bound			; Update bottom boundary

.End:
	rts

; ------------------------------------------------------------------------------
; Quartz Quadrant level events
; ------------------------------------------------------------------------------

LevEvents_QQZ:
	moveq	#0,d0				; Run act specific level events
	move.b	act,d0
	add.w	d0,d0
	move.w	LevEvents_QQZ_Index(pc,d0.w),d0
	jmp	LevEvents_QQZ_Index(pc,d0.w)

; ------------------------------------------------------------------------------

LevEvents_QQZ_Index:
	dc.w	LevEvents_QQZ12-LevEvents_QQZ_Index
	dc.w	LevEvents_QQZ12-LevEvents_QQZ_Index
	dc.w	LevEvents_QQZ3-LevEvents_QQZ_Index

; ------------------------------------------------------------------------------

LevEvents_QQZ12:
	move.w	#$310,target_bottom_bound	; Set default bottom boundary
	rts

; ------------------------------------------------------------------------------

LevEvents_QQZ3:
	move.w	#$E10,d0			; Handle end of act 3 boundary
	move.w	#$1F8,d1
	bsr.w	CheckBossStart
	bne.s	.End				; If the boundary was set, branch

	tst.b	boss_flags			; Is the boss active?
	bne.s	.BossActive			; If so, branch
	if (REGION=USA)|((REGION<>USA)&(DEMO=0)); Set default bottom boundary
		move.w	#$320,target_bottom_bound
	else
		move.w	#$310,target_bottom_bound
	endif
	
.End:
	rts

.BossActive:
	move.w	#$1F8,bottom_bound		; Set bottom boundary for the boss
	move.w	#$1F8,target_bottom_bound
	rts

; ------------------------------------------------------------------------------
; Metallic Madness level events
; ------------------------------------------------------------------------------

LevEvents_MMZ:
	moveq	#0,d0				; Run act specific level events
	move.b	act,d0
	add.w	d0,d0
	move.w	LevEvents_MMZ_Index(pc,d0.w),d0
	jmp	LevEvents_MMZ_Index(pc,d0.w)

; ------------------------------------------------------------------------------

LevEvents_MMZ_Index:
	dc.w	LevEvents_MMZ12-LevEvents_MMZ_Index
	dc.w	LevEvents_MMZ12-LevEvents_MMZ_Index
	dc.w	LevEvents_MMZ3-LevEvents_MMZ_Index

; ------------------------------------------------------------------------------

LevEvents_MMZ12:
	move.w	#$710,target_bottom_bound	; Set default bottom boundary
	rts

; ------------------------------------------------------------------------------

LevEvents_MMZ3:
	tst.b	boss_flags			; Is the boss active?
	bne.s	.BossActive			; If so, branch
	move.w	#$310,target_bottom_bound	; Set default bottom boundary
	rts

.BossActive:
	move.w	#$10C,d0			; Set boundaries for the boss
	move.w	d0,top_bound
	move.w	d0,target_top_bound
	move.w	d0,bottom_bound
	move.w	d0,target_bottom_bound
	rts

; ------------------------------------------------------------------------------
; Tidal Tempest level events
; ------------------------------------------------------------------------------

LevEvents_TTZ:
	moveq	#0,d0				; Run act specific level events
	move.b	act,d0
	add.w	d0,d0
	move.w	LevEvents_TTZ_Index(pc,d0.w),d0
	jmp	LevEvents_TTZ_Index(pc,d0.w)

; ------------------------------------------------------------------------------

LevEvents_TTZ_Index:
	dc.w	LevEvents_TTZ1-LevEvents_TTZ_Index
	dc.w	LevEvents_TTZ2-LevEvents_TTZ_Index
	dc.w	LevEvents_TTZ3-LevEvents_TTZ_Index

; ------------------------------------------------------------------------------

LevEvents_TTZ1:
	move.w	#$510,target_bottom_bound		; Set default bottom boundary
	rts

; ------------------------------------------------------------------------------

LevEvents_TTZ2:
	cmpi.b	#$2B,player_object+obj.anim_id	; Is the player giving up from boredom?
	beq.s	.NoWrap				; If so, branch
	cmpi.b	#6,player_object+obj.routine	; Is the player dead?
	bcc.s	.NoWrap				; If so, branch

	move.w	#$800,bottom_bound		; Set bottom boundary for wrapping section
	move.w	#$800,target_bottom_bound
	cmpi.w	#$200,camera_fg_x			; Is the camera's X position < $200?
	bcs.s	.End				; If so, branch

.NoWrap:
	move.w	#$710,bottom_bound		; Set bottom boundary after the wrapping section
	move.w	#$710,target_bottom_bound

.End:
	rts

; ------------------------------------------------------------------------------

LevEvents_TTZ3:
	move.w	#$AF8,d0			; Handle end of act 3 boundary
	move.w	#$4C0,d1
	bsr.w	CheckBossStart
	bne.s	.End				; If the boundary was set, branch

	tst.b	boss_flags			; Has the boss fight been started?
	bne.s	.BossActive			; If so, branch

.End:
	rts

.BossActive:
	move.w	#$4F0,bottom_bound		; Set bottom boundary for the boss fight
	move.w	#$4F0,target_bottom_bound
	rts

; ------------------------------------------------------------------------------
; Stardust Speedway level events
; ------------------------------------------------------------------------------

LevEvents_SSZ:
	moveq	#0,d0				; Run act specific level events
	move.b	act,d0
	add.w	d0,d0
	move.w	LevEvents_SSZ_Index(pc,d0.w),d0
	jmp	LevEvents_SSZ_Index(pc,d0.w)

; ------------------------------------------------------------------------------

LevEvents_SSZ_Index:
	dc.w	LevEvents_SSZ1-LevEvents_SSZ_Index
	dc.w	LevEvents_SSZ2-LevEvents_SSZ_Index
	dc.w	LevEvents_SSZ3-LevEvents_SSZ_Index

; ------------------------------------------------------------------------------

LevEvents_SSZ1:
	move.w	#$510,target_bottom_bound	; Set default bottom boundary
	rts

; ------------------------------------------------------------------------------

LevEvents_SSZ2:
	move.w	#$710,target_bottom_bound	; Set default bottom boundary
	rts

; ------------------------------------------------------------------------------

LevEvents_SSZ3:
	lea	player_object,a1		; Have we reached Metal Sonic?
	cmpi.w	#$930,obj.x(a1)
	bge.s	.FoundMetalSonic		; If so, branch
	move.w	#$210,target_bottom_bound	; If not, set default bottom boundary
	rts

.FoundMetalSonic:
	cmpi.w	#$DC0,obj.x(a1)			; Has the race started?
	blt.s	.RaceStarted			; If so, branch
	move.w	#$210,target_bottom_bound	; If not, set default bottom boundary
	rts

.RaceStarted:
	move.w	#$120,d0			; Set bottom boundary for the race
	move.w	d0,d1
	move.w	d0,target_bottom_bound

	sub.w	bottom_bound,d1			; Is the current bottom boundary near the target?
	bpl.s	.CheckNearBound
	neg.w	d1

.CheckNearBound:
	cmpi.w	#4,d1
	bge.s	.End				; If not, branch
	move.w	d0,bottom_bound			; Update bottom boundary

.End:
	rts

; ------------------------------------------------------------------------------
; Check if the boss arena boundaries should be set
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - X position in which boundaries are set
;	d1.w - Bottom boundary value
; ------------------------------------------------------------------------------

CheckBossStart:
	cmp.w	player_object+obj.x,d0		; Has the player reached the point where boundaries should be set?
	ble.s	SetBossBounds			; If so, branch

	moveq	#0,d0				; Mark boundaries as not set
	rts

; ------------------------------------------------------------------------------

SetBossBounds:
	move.w	d1,target_bottom_bound		; Set bottom boundary

	sub.w	bottom_bound,d1			; Is the current bottom boundary near the target?
	bpl.s	.CheckNearBound
	neg.w	d1

.CheckNearBound:
	cmpi.w	#4,d1
	bge.s	.NoYLock			; If not, branch
	move.w	target_bottom_bound,bottom_bound; Update bottom boundary

.NoYLock:
	move.w	player_object+obj.x,d0		; Get player's position
	subi.w	#320/2,d0
	cmp.w	left_bound,d0			; Has the left boundary already been set?
	blt.s	.BoundsSet			; If so, branch
	cmp.w	right_bound,d0			; Have we reached the right boundary?
	ble.s	.NoBoundSet			; If not, branch
	move.w	right_bound,d0			; Set to bound at the right boundary

.NoBoundSet:
	move.w	d0,left_bound			; Update the left boundary
	move.w	d0,target_left_bound

.BoundsSet:
	moveq	#1,d0				; Mark boundaries as set
	rts

; ------------------------------------------------------------------------------
