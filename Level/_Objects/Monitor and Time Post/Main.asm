; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Monitor and time post object
; ------------------------------------------------------------------------------

ObjTimeIcon:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	tst.b	time_warp_direction			; Has a time post been activated?
	beq.s	.End				; If not, branch
	cmpi.w	#90,time_warp_timer		; Is the time warp almost done?
	bcs.s	.Draw				; If not, branch
	btst	#0,stage_frames+1		; Flash
	bne.s	.End

.Draw:
	jmp	DrawObject			; Draw sprite

.End:
	rts

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjTimeIcon_Init-.Index
	dc.w	ObjTimeIcon_Main-.Index

; ------------------------------------------------------------------------------
; Initialize
; ------------------------------------------------------------------------------

ObjTimeIcon_Init:
	addq.b	#2,obj.routine(a0)			; Next routine
	move.l	#MapSpr_MonitorTime,obj.sprites(a0)	; Set mappings
	move.w	#$85A8,obj.sprite_tile(a0)		; Set base tile ID
	move.w	#68+128,obj.x(a0)			; Set position
	move.w	#210+128,obj.screen_y(a0)

; ------------------------------------------------------------------------------
; Main routine
; ------------------------------------------------------------------------------

ObjTimeIcon_Main:
	move.b	#$12,obj.sprite_frame(a0)		; Set past sprite frame
	tst.b	time_warp_direction			; Was a past time post activated?
	bmi.s	.End				; If so, branch
	move.b	#$13,obj.sprite_frame(a0)		; Set future sprite frame

.End:
	rts

; ------------------------------------------------------------------------------
; Time post object
; ------------------------------------------------------------------------------

oTimePostSpin	EQU	obj.var_2A			; Spin timer

; ------------------------------------------------------------------------------

ObjTimePostTimeIcon:
	tst.b	time_attack_mode		; Are we in time attack mode?
	beq.s	.NoTimeAttack			; If not, branch
	jmp	DeleteObject			; If so, delete ourselves

.NoTimeAttack:
	cmpi.b	#$A,obj.subtype(a0)		; Is this a time icon in the HUD?
	beq.w	ObjTimeIcon			; If so, branch

; ------------------------------------------------------------------------------

ObjTimePost:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	jsr	DrawObject			; Draw sprite
	jmp	CheckObjDespawn			; Check despawn

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjTimePost_Init-.Index
	dc.w	ObjTimePost_Main-.Index
	dc.w	ObjTimePost_Spin-.Index
	dc.w	ObjTimePost_Done-.Index

; ------------------------------------------------------------------------------
; Initialization
; ------------------------------------------------------------------------------

ObjTimePost_Init:
	addq.b	#2,obj.routine(a0)			; Next routine
	move.b	#$20,obj.collide_height(a0)		; Set height
	move.b	#$E,obj.collide_width(a0)		; Set width
	move.l	#MapSpr_MonitorTime,obj.sprites(a0)	; Set mappings
	move.w	#$5A8,obj.sprite_tile(a0)			; Set base tile ID
	move.b	#%00000100,obj.sprite_flags(a0)	; Set sprite flags
	move.b	#3,obj.sprite_layer(a0)		; Set priority
	
	cmpi.b	#6,zone				; Are we in Metallic Madness?
	bne.s	.NotFront			; If not, branch
	tst.b	obj.layer(a0)			; Are we on layer 1?
	bne.s	.NotFront			; If not, branch
	move.b	#0,obj.sprite_layer(a0)		; Set high priority
	ori.b	#$80,obj.sprite_tile(a0)

.NotFront:
	move.b	#$F,obj.width(a0)			; Set width
	move.b	obj.subtype(a0),obj.anim_id(a0)		; Set animation
	
	bsr.w	ObjMonitor_GetSavedFlags	; Mark as unloaded
	bclr	#7,2(a2,d0.w)
	
	move.b	#$A,obj.sprite_frame(a0)		; Set sprite frame
	cmpi.b	#8,obj.subtype(a0)
	beq.s	.ChkActive
	addq.b	#2,obj.sprite_frame(a0)

.ChkActive:
	btst	#0,2(a2,d0.w)			; Have we been activated?
	beq.s	.StillActive			; If not, branch
	addq.b	#1,obj.sprite_frame(a0)		; If so, set as activated
	move.b	#6,obj.routine(a0)
	rts

.StillActive:
	move.b	#$C0|$1F,obj.collide_type(a0)		; Enable collision

; ------------------------------------------------------------------------------
; Main routine
; ------------------------------------------------------------------------------

ObjTimePost_Main:
	tst.b	obj.collide_status(a0)		; Have we been activated?
	beq.s	.End				; If not, branch
	clr.b	obj.collide_status(a0)		; Clear flag
	
	cmpi.b	#6,zone				; Are we in Metallic Madness?
	bne.s	.Touched			; If not, branch
	tst.b	obj.layer(a0)			; Are we on layer 1?
	beq.s	.Layer1				; If so, branch
	tst.b	layer				; Is the player on layer 2?
	beq.s	.End				; If not, branch
	bra.s	.Touched

.Layer1:
	tst.b	layer				; Is the player on layer 1?
	bne.s	.End				; If not, branch

.Touched:
	move.b	#60,oTimePostSpin(a0)		; Set spin timer
	addq.b	#2,obj.routine(a0)			; Start spinning
	
	bsr.w	ObjMonitor_GetSavedFlags	; Mark as activated
	bset	#0,2(a2,d0.w)
	
	move.w	#SCMD_PASTSFX,d0		; Past
	move.b	#-1,time_warp_direction
	cmpi.b	#8,obj.subtype(a0)			; Is this a past time post?
	beq.s	.PlaySound			; If so, branch
	move.b	#1,time_warp_direction		; Future
	subq.w	#SCMD_PASTSFX-SCMD_FUTURESFX,d0

.PlaySound:
	jsr	SubCPUCmd			; Play voice clip

.End:
	rts

; ------------------------------------------------------------------------------
; Spin
; ------------------------------------------------------------------------------

ObjTimePost_Spin:
	subq.b	#1,oTimePostSpin(a0)		; Decrement timer
	beq.s	.StopSpin			; If it has run out, branch
	lea	Ani_Monitor,a1			; Animate sprite
	bra.w	AnimateObject

.StopSpin:
	addq.b	#2,obj.routine(a0)			; Stop spinning
	move.b	#$B,obj.sprite_frame(a0)		; Set activated sprite frame
	cmpi.b	#8,obj.subtype(a0)
	beq.s	ObjTimePost_Done
	addq.b	#2,obj.sprite_frame(a0)

; ------------------------------------------------------------------------------
; Done
; ------------------------------------------------------------------------------

ObjTimePost_Done:
	rts

; ------------------------------------------------------------------------------
; Get saved object flags entry
; ------------------------------------------------------------------------------
; RETURNS:
;	d0.w - Saved object flags entry offset
;	a2.l - Saved object flags array
; ------------------------------------------------------------------------------

ObjMonitor_GetSavedFlags:
	lea	map_object_states,a2		; Saved object flags
	
	moveq	#0,d0				; Get base entry offset
	move.b	obj.state_id(a0),d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	
	moveq	#0,d1				; Get time zone
	move.b	time_zone,d1
	bclr	#7,d1				; Clear time warping flag
	beq.s	.AddTimeZone			; If it wasn't set, branch
	
	move.b	time_warp_direction,d2		; Add time warp direction
	ext.w	d2
	neg.w	d2
	add.w	d2,d1
	bpl.s	.ChkOverflow			; If it hasn't underflowed, branch
	moveq	#TIME_PAST,d1			; Cap at past
	bra.s	.AddTimeZone

.ChkOverflow:
	cmpi.w	#TIME_FUTURE+1,d1		; Has it overflowed?
	bcs.s	.AddTimeZone			; If not, branch
	moveq	#TIME_FUTURE,d1			; If so, cap at future

.AddTimeZone:
	add.w	d1,d0				; Add time zone to entry offset
	rts

; ------------------------------------------------------------------------------
; Handle monitor solidity
; ------------------------------------------------------------------------------

ObjMonitor_Solid:
	cmpi.b	#6,zone				; Are we in Metallic Madness?
	bne.s	.DoSolid			; If not, branch
	tst.b	layer				; Is the player on layer 1?
	beq.s	.Layer1				; If so, branch
	tst.b	obj.layer(a0)			; Are we on layer 2?
	bne.s	.DoSolid			; If so, branch
	rts

.Layer1:
	tst.b	obj.layer(a0)			; Are we on layer 1?
	beq.s	.DoSolid			; If so, branch
	rts

.DoSolid:
	move.w	obj.x(a0),d3			; Handle solidity
	move.w	obj.y(a0),d4
	jmp	SolidObject

; ------------------------------------------------------------------------------
; Monitor object
; ------------------------------------------------------------------------------

oMonitorFall	EQU	obj.routine_2		; Fall flag

; -----------------------------------------------------------------------

ObjMonitorTimepost:
	tst.b	obj.subtype(a0)			; Is this a 1UP monitor?
	bne.s	ObjMonitor			; If not, branch
	tst.b	time_attack_mode		; Are we in time attack mode?
	beq.s	ObjMonitor			; If not, branch
	jmp	CheckObjDespawn			; If so, despawn

; ------------------------------------------------------------------------------

ObjMonitor:
	cmpi.b	#8,obj.subtype(a0)			; Is this a time post?
	bcc.w	ObjTimePostTimeIcon		; If so, branch
	
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d1
	jmp	.Index(pc,d1.w)

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjMonitor_Init-.Index
	dc.w	ObjMonitor_Main-.Index
	dc.w	ObjMonitor_Break-.Index
	dc.w	ObjMonitor_Animate-.Index
	dc.w	ObjMonitor_Draw-.Index
	
; ------------------------------------------------------------------------------
; Initialization
; ------------------------------------------------------------------------------

ObjMonitor_Init:
	addq.b	#2,obj.routine(a0)			; Next routine
	move.b	#$E,obj.collide_height(a0)		; Set height
	move.b	#$E,obj.collide_width(a0)		; Set width
	move.l	#MapSpr_MonitorTime,obj.sprites(a0)	; Set mappings
	move.w	#$5A8,obj.sprite_tile(a0)			; Set base tile ID
	move.b	#3,obj.sprite_layer(a0)		; Set priority
	
	cmpi.b	#6,zone				; Are we in Metallic Madness?
	bne.s	.NotMMZ				; If not, branch
	tst.b	obj.layer(a0)			; Are we on layer 1?
	bne.s	.NotMMZ				; If not, branch
	ori.b	#$80,obj.sprite_tile(a0)			; Set high priority
	move.b	#0,obj.sprite_layer(a0)

.NotMMZ:
	move.b	#%00000100,obj.sprite_flags(a0)	; Set sprite flags
	move.b	#$F,obj.width(a0)			; Set width
	
	bsr.w	ObjMonitor_GetSavedFlags	; Mark as unloaded
	bclr	#7,2(a2,d0.w)
	
	btst	#0,2(a2,d0.w)			; Is this monitor already broken?
	beq.s	.NotBroken			; If not, branch
	move.b	#8,obj.routine(a0)			; If so, set as broken
	move.b	#$11,obj.sprite_frame(a0)
	rts

.NotBroken:
	move.b	#$40|6,obj.collide_type(a0)		; Enable collision
	move.b	obj.subtype(a0),obj.anim_id(a0)		; Set animation

; ------------------------------------------------------------------------------
; Main routine
; ------------------------------------------------------------------------------

ObjMonitor_Main:
	tst.b	obj.sprite_flags(a0)			; Are we on screen?
	bpl.w	ObjMonitor_Draw			; If not, branch
	
	move.b	oMonitorFall(a0),d0		; Are we set to fall?
	beq.s	.CheckSolid			; If not, branch
	
	bsr.w	ObjMoveGrv			; Fall
	jsr	ObjGetFloorDist			; Check floor collision
	tst.w	d1
	bpl.w	ObjMonitor_Animate		; If we have not hit the floor, branch
	add.w	d1,obj.y(a0)			; Align with floor
	clr.w	obj.y_speed(a0)			; Stop falling
	clr.b	oMonitorFall(a0)
	bra.w	ObjMonitor_Animate

.CheckSolid:
	tst.b	obj.sprite_flags(a0)			; Are we on screen?
	bpl.s	ObjMonitor_Animate		; If not, branch
	
	lea	player_object,a1		; Handle solidity
	bsr.w	ObjMonitor_Solid

; ------------------------------------------------------------------------------
; Animate sprite
; ------------------------------------------------------------------------------

ObjMonitor_Animate:
	tst.w	time_stop				; Is time stopped?
	bne.s	ObjMonitor_Draw			; If so, branch
	lea	Ani_Monitor,a1			; Animate sprite
	bsr.w	AnimateObject

; ------------------------------------------------------------------------------
; Draw sprite
; ------------------------------------------------------------------------------

ObjMonitor_Draw:
	bsr.w	DrawObject			; Draw sprite
	jmp	CheckObjDespawn			; Check despawn

; ------------------------------------------------------------------------------
; Break
; ------------------------------------------------------------------------------

ObjMonitor_Break:
	move.w	#FM_DESTROY,d0			; Play explosion sound
	jsr	PlayFMSound
	addq.b	#4,obj.routine(a0)			; Destroyed
	move.b	#0,obj.collide_type(a0)
	
	bsr.w	FindObjSlot			; Spawn item
	bne.s	.NoItem
	move.b	#$1A,obj.id(a1)
	move.w	obj.x(a0),obj.x(a1)			; Set position
	move.w	obj.y(a0),obj.y(a1)
	move.b	obj.anim_id(a0),obj.anim_id(a1)		; Set animation
	move.b	obj.layer(a0),obj.layer(a1)		; Set layer

.NoItem:
	bsr.w	FindObjSlot			; Spawn explosion
	bne.s	.NoExplosion
	move.b	#$18,obj.id(a1)
	move.w	obj.x(a0),obj.x(a1)			; Set position
	move.w	obj.y(a0),obj.y(a1)
	move.b	#1,oExplodeBadnik(a1)		; Not from badnik
	move.b	#1,obj.subtype(a1)
	move.b	obj.layer(a0),obj.layer(a1)		; Set layer

.NoExplosion:
	bsr.w	ObjMonitor_GetSavedFlags	; Mark as destroyed
	bset	#0,2(a2,d0.w)
	move.b	#$11,obj.sprite_frame(a0)		; Set broken sprite frame
	bra.w	DrawObject			; Draw sprite

; ------------------------------------------------------------------------------
; Monitor item object
; ------------------------------------------------------------------------------

oMonItemDel	EQU	obj.anim_time		; Deletion timer

; ------------------------------------------------------------------------------

ObjMonitorItem:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d1
	jsr	.Index(pc,d1.w)
	
	bra.w	DrawObject			; Draw sprite

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjMonitorItem_Init-.Index
	dc.w	ObjMonitorItem_Main-.Index
	dc.w	ObjMonitorItem_Delete-.Index
	
; ------------------------------------------------------------------------------
; Initialization
; ------------------------------------------------------------------------------

ObjMonitorItem_Init:
	addq.b	#2,obj.routine(a0)			; Next routine
	move.w	#$85A8,obj.sprite_tile(a0)		; Set base tile ID
	tst.b	obj.layer(a0)			; Are we on layer 2?
	beq.s	.NotPriority			; If so, branch
	andi.b	#$7F,obj.sprite_tile(a0)			; Set low priority

.NotPriority:
	move.b	#%00100100,obj.sprite_flags(a0)	; Set sprite flags
	move.b	#3,obj.sprite_layer(a0)		; Set priority
	move.b	#8,obj.width(a0)			; Set width
	move.w	#-$300,obj.y_speed(a0)		; Move up
	
	moveq	#0,d0				; Set sprite frame
	move.b	obj.anim_id(a0),d0
	move.b	d0,obj.sprite_frame(a0)
	
	movea.l	#MapSpr_MonitorTime,a1		; Set mappings
	add.b	d0,d0
	adda.w	(a1,d0.w),a1
	addq.w	#1,a1
	move.l	a1,obj.sprites(a0)

; ------------------------------------------------------------------------------
; Main routine
; ------------------------------------------------------------------------------

ObjMonitorItem_Main:
	tst.w	obj.y_speed(a0)			; Are we moving up still?
	bpl.w	.GiveItem			; If not, branch
	bsr.w	ObjMove				; Move
	addi.w	#$18,obj.y_speed(a0)			; Slow down
	rts

.GiveItem:
	addq.b	#2,obj.routine(a0)			; Disappear
	move.w	#30-1,oMonItemDel(a0)		; Set deletion timer

; ------------------------------------------------------------------------------

.Check1UP:
	move.b	obj.anim_id(a0),d0			; Get item type
	bne.s	.CheckRing			; Branch if this is not a 1UP

.Give1UP:
	addq.b	#1,lives			; Increment lives
	addq.b	#1,update_hud_lives
	move.w	#SCMD_YESSFX,d0			; Play 1UP sound
	jmp	SubCPUCmd

; ------------------------------------------------------------------------------

.CheckRing:
	cmpi.b	#1,d0				; Is this a rings item?
	bne.s	.CheckShield			; If not, branch

.GiveRings:
	addi.w	#10,rings			; Add 10 rings
	ori.b	#1,update_hud_rings
	
	cmpi.w	#100,rings			; Have 100 rings been accumulated?
	bcs.s	.RingSound			; If not, branch
	bset	#1,lives_flags			; Set 100 rings flag
	beq.w	.Give1UP			; If it wasn't already set, branch
	cmpi.w	#200,rings			; Have 200 rings been accumulated?
	bcs.s	.RingSound			; If not, branch
	bset	#2,lives_flags			; Set 200 rings flag
	beq.w	.Give1UP			; If it wasn't already set, branch

.RingSound:
	move.w	#FM_RING,d0			; Play ring sound
	jmp	PlayFMSound

; ------------------------------------------------------------------------------

.CheckShield:
	cmpi.b	#2,d0				; Is this a shield item?
	bne.s	.CheckInvinc			; If not, branch

.GiveShield:
	move.b	#1,shield			; Set shield flag
	move.b	#3,shield_object		; Spawn shield
	move.w	#FM_SHIELD,d0			; Play shield sound
	jmp	PlayFMSound

; ------------------------------------------------------------------------------

.CheckInvinc:
	cmpi.b	#3,d0				; Is this an invincibility item?
	bne.s	.CheckSpeedShoes		; If not, branch

.GiveInvinc:
	move.b	#1,invincible			; Set invincible flag
	if REGION=USA				; Set invincibility timer
		move.w	#1320,player_object+oPlayerInvinc
	else
		move.w	#1200,player_object+oPlayerInvinc
	endif
	
	move.b	#3,inv_stars_1_object		; Spawn invincibility stars
	move.b	#1,inv_stars_1_object+obj.anim_id
	move.b	#3,inv_stars_2_object
	move.b	#2,inv_stars_2_object+obj.anim_id
	move.b	#3,inv_stars_3_object
	move.b	#3,inv_stars_3_object+obj.anim_id
	move.b	#3,inv_stars_4_object
	move.b	#4,inv_stars_4_object+obj.anim_id
	
	tst.b	time_zone			; Are we in the past?
	bne.s	.NotPast			; If not, branch
	move.w	#SCMD_FADEPCM,d0		; If so, fade out PCM
	jsr	SubCPUCmd

.NotPast:
	move.w	#SCMD_INVINCMUS,d0		; Play invincibility music
	jmp	SubCPUCmd
	rts

; ------------------------------------------------------------------------------

.CheckSpeedShoes:
	cmpi.b	#4,d0				; Is this a speed shoes item?
	bne.s	.CheckTimeStop			; If not, branch

.GiveSpeedShoes:
	move.b	#1,speed_shoes			; Set speed shoes flag
	if REGION=USA				; Set speed shoes timer
		move.w	#1320,player_object+oPlayerShoes
	else
		move.w	#1200,player_object+oPlayerShoes
	endif
	
	move.w	#$C00,player_top_speed		; Speed the player up
	move.w	#$18,player_acceleration
	move.w	#$80,player_deceleration
	
	tst.b	time_zone			; Are we in the past?
	bne.s	.NotPast2			; If not, branch
	move.w	#SCMD_FADEPCM,d0		; If so, fade out PCM
	jsr	SubCPUCmd

.NotPast2:
	move.w	#SCMD_SHOESMUS,d0		; Play speed shoes music
	jmp	SubCPUCmd

; ------------------------------------------------------------------------------

.CheckTimeStop:
	cmpi.b	#5,d0				; Is this a time stop item?
	bne.s	.CheckCombine			; If not, branch
	
.GiveTimeStop:
	move.w	#300,time_stop			; Set time stop timer
	rts

; ------------------------------------------------------------------------------

.CheckCombine:
	cmpi.b	#6,d0				; Is this a combine ring item?
	bne.s	.CheckS				; If not, branch
	
.GiveCombineRing:
	move.w	#FM_SIGNPOST,d0			; Play sound
	jsr	PlayFMSound
	move.b	#1,combine_ring			; Set combine ring flag
	rts

; ------------------------------------------------------------------------------

.CheckS:
	bsr.w	.GiveShield			; Give shield
	bsr.w	.GiveInvinc			; Give invincibility
	bra.s	.GiveSpeedShoes			; Give speed shoes
	
; ------------------------------------------------------------------------------
; Delete
; ------------------------------------------------------------------------------

ObjMonitorItem_Delete:
	subq.w	#1,oMonItemDel(a0)		; Decrement timer
	bmi.w	DeleteObject			; If it has run out, delete ourselves
	rts

; ------------------------------------------------------------------------------
; Data
; ------------------------------------------------------------------------------

Ani_Monitor:
	include	"Level/_Objects/Monitor and Time Post/Data/Animations.asm"
	even
	
MapSpr_MonitorTime:
	include	"Level/_Objects/Monitor and Time Post/Data/Mappings.asm"
	even
	
; ------------------------------------------------------------------------------
