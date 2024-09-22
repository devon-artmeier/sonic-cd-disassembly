; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Checkpoint object
; ------------------------------------------------------------------------------

oChkBallX	EQU	obj.var_2A			; Ball X origin
oChkBallY	EQU	obj.var_2C			; Ball Y origin
oChkActive	EQU	obj.var_2E			; Activated flag
oChkParent	EQU	obj.var_30			; Parent object
oChkBallAngle	EQU	obj.var_34			; Ball angle

; ------------------------------------------------------------------------------
; Save data at a checkpoint
; ------------------------------------------------------------------------------

ObjCheckpoint_SaveData:
	move.b	spawn_mode,saved_spawn_mode	; Save some values
	move.w	player_object+obj.x,saved_x
	move.w	player_object+obj.y,saved_y
	move.b	water_routine,saved_water_routine
	move.w	bottom_bound,saved_bottom_bound
	move.w	camera_fg_x,saved_camera_fg_x
	move.w	camera_fg_y,saved_camera_fg_y
	move.w	camera_bg_x,saved_camera_bg_x
	move.w	camera_bg_y,saved_camera_bg_y
	move.w	camera_bg2_x,saved_camera_bg2_x
	move.w	camera_bg2_y,saved_camera_bg2_y
	move.w	camera_bg3_x,saved_camera_bg3_x
	move.w	camera_bg3_y,saved_camera_bg3_y
	move.w	water_height_logical,saved_water_height
	move.b	water_routine,saved_water_routine
	move.b	water_fullscreen,saved_water_fullscreen

	move.l	time,d0				; Move the time to 5:00 if we are past that
	cmpi.l	#(5<<16)|(0<<8)|0,d0
	bcs.s	.StoreTime
	move.l	#(5<<16)|(0<<8)|0,d0

.StoreTime:
	move.l	d0,saved_time

	move.b	mini_player,saved_mini_player
	rts

; ------------------------------------------------------------------------------
; Checkpoint object
; ------------------------------------------------------------------------------

ObjCheckpoint:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject			; Draw sprite
	jmp	CheckObjDespawn			; Check if we should despawn

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjCheckpoint_Init-.Index
	dc.w	ObjCheckpoint_Main-.Index
	dc.w	ObjCheckpoint_Ball-.Index
	dc.w	ObjCheckpoint_Animate-.Index

; ------------------------------------------------------------------------------
; Initialization
; ------------------------------------------------------------------------------

ObjCheckpoint_Init:
	addq.b	#2,obj.routine(a0)			; Advance routine

	move.l	#MapSpr_Checkpoint,obj.sprites(a0)	; Set mappings
	move.w	#$6CB,obj.sprite_tile(a0)		; Set base tile
	move.b	#%00000100,obj.sprite_flags(a0)		; Set sprite flags
	move.b	#8,obj.width(a0)			; Set width
	move.b	#$18,obj.collide_height(a0)		; Set Y radius
	move.b	#4,obj.sprite_layer(a0)			; Set priority

	move.b	checkpoint,d0			; Has a later checkpoint been activated?
	cmp.b	obj.subtype(a0),d0
	bcs.s	.Unactivated			; If not, branch

	move.b	#1,oChkActive(a0)		; Mark as activated
	bra.s	.GenBall			; Continue initialization

.Unactivated:
	move.b	#$C0|$23,obj.collide_type(a0)		; Enable collision

.GenBall:
	jsr	FindObjSlot			; Spawn checkpoint ball object
	bne.s	.Delete
	move.b	#$13,obj.id(a1)
	addq.b	#4,obj.routine(a1)			; Set ball routine to the main ball routine
	tst.b	oChkActive(a0)			; Were we already activated?
	beq.s	.Unactivated2			; If not, branch
	addq.b	#2,obj.routine(a1)			; Set ball routine to just animate

.Unactivated2:
	move.l	#MapSpr_Checkpoint,obj.sprites(a1)	; Set mappings
	move.w	#$6CB,obj.sprite_tile(a1)		; Set base tile
	move.b	#%00000100,obj.sprite_flags(a1)	; Set sprite flags
	move.b	#8,obj.width(a1)			; Set width
	move.b	#8,obj.collide_height(a1)			; Set Y radius
	move.b	#3,obj.sprite_layer(a1)		; Set priority
	move.b	#1,obj.sprite_frame(a1)		; Set sprite frame
	move.l	a0,oChkParent(a1)		; Set parent object

	move.w	obj.x(a0),obj.x(a1)			; Set position
	move.w	obj.y(a0),obj.y(a1)
	subi.w	#32,obj.y(a1)

	move.w	obj.x(a0),oChkBallX(a1)		; Set center position
	move.w	obj.y(a0),oChkBallY(a1)
	subi.w	#32-8,oChkBallY(a1)
	rts

.Delete:
	jmp	DeleteObject			; Delete ourselves

; ------------------------------------------------------------------------------
; Main routine
; ------------------------------------------------------------------------------

ObjCheckpoint_Main:
	tst.b	oChkActive(a0)			; Have we been activated?
	bne.s	.End				; If so, branch
	tst.b	obj.collide_status(a0)			; Has the player touched us yet?
	beq.s	.End				; If not, branch

	clr.b	obj.collide_type(a0)			; Disable collision
	move.b	#1,oChkActive(a0)		; Mark as activated
	move.b	obj.subtype(a0),checkpoint	; Set checkpoint ID

	move.b	#1,spawn_mode			; Spawn at checkpoint
	bsr.w	ObjCheckpoint_SaveData		; Save level data at this point

	move.w	#FM_CHECKPOINT,d0		; Play checkpoint sound
	jmp	PlayFMSound

.End:
	rts

; ------------------------------------------------------------------------------
; Ball
; ------------------------------------------------------------------------------

ObjCheckpoint_Ball:
	tst.b	oChkActive(a0)			; Have we been activated?
	bne.s	.Spin				; If not, branch

	movea.l	oChkParent(a0),a1		; Has the main checkpoint object been touched by the player?
	tst.b	oChkActive(a1)
	beq.s	.End				; If not, branch

	move.b	#1,oChkActive(a0)		; Mark as activated

.Spin:
	addq.b	#8,oChkBallAngle(a0)		; Increment angle

	moveq	#0,d0				; Get sine and cosine of our angle
	move.b	oChkBallAngle(a0),d0
	jsr	CalcSine

	muls.w	#8,d0				; Get X offset (center X + (sin(angle) * 8))
	lsr.l	#8,d0
	move.w	oChkBallX(a0),obj.x(a0)
	add.w	d0,obj.x(a0)

	muls.w	#-8,d1				; Get Y offset (center Y + (cos(angle) * -8))
	lsr.l	#8,d1
	move.w	oChkBallY(a0),obj.y(a0)
	add.w	d1,obj.y(a0)

	tst.b	oChkBallAngle(a0)		; Have we fully spun around?
	bne.s	.End				; If not, branch
	addq.b	#2,obj.routine(a0)			; Set routine to just animate now

.End:
	rts

; ------------------------------------------------------------------------------
; Animation
; ------------------------------------------------------------------------------

ObjCheckpoint_Animate:
	lea	Ani_Checkpoint,a1		; Animate sprite
	bra.w	AnimateObject
	
; ------------------------------------------------------------------------------
