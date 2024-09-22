; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Debug mode
; ------------------------------------------------------------------------------

UpdateDebugMode:
	move.b	p1_ctrl_hold,d0
	andi.b	#$F,d0
	bne.s	.Accel
	move.l	#$4000,debug_speed
	bra.s	.GotSpeed

; ------------------------------------------------------------------------------

.Accel:
	addi.l	#$2000,debug_speed
	cmpi.l	#$80000,debug_speed
	bls.s	.GotSpeed
	move.l	#$80000,debug_speed

.GotSpeed:
	move.l	debug_speed,d0
	btst	#0,p1_ctrl_hold
	beq.s	.ChkDown
	sub.l	d0,obj.y(a0)

.ChkDown:
	btst	#1,p1_ctrl_hold
	beq.s	.ChkLeft
	add.l	d0,obj.y(a0)

.ChkLeft:
	btst	#2,p1_ctrl_hold
	beq.s	.ChkRight
	sub.l	d0,obj.x(a0)

.ChkRight:
	btst	#3,p1_ctrl_hold
	beq.s	.SetPos
	add.l	d0,obj.x(a0)

.SetPos:
	move.w	obj.y(a0),d2
	move.b	obj.collide_height(a0),d0
	ext.w	d0
	add.w	d0,d2
	move.w	obj.x(a0),d3
	jsr	GetLevelBlock
	move.w	(a1),debug_map_block
	lea	DebugItemIndex,a2
	btst	#6,p1_ctrl_tap
	beq.s	.NoInc
	moveq	#0,d1
	move.b	debug_object,d1
	addq.b	#1,d1
	cmp.b	(a2),d1
	bcs.s	.NoWrap
	move.b	#0,d1

.NoWrap:
	move.b	d1,debug_object

.NoInc:
	btst	#7,p1_ctrl_tap
	beq.s	.NoDec
	moveq	#0,d1
	move.b	debug_object,d1
	subq.b	#1,d1
	cmpi.b	#$FF,d1
	bne.s	.NoWrap2
	add.b	(a2),d1

.NoWrap2:
	move.b	d1,debug_object

.NoDec:
	moveq	#0,d1
	move.b	debug_object,d1
	mulu.w	#$C,d1
	move.l	4(a2,d1.w),obj.sprites(a0)
	move.w	8(a2,d1.w),obj.sprite_tile(a0)
	move.b	3(a2,d1.w),obj.sprite_layer(a0)
	move.b	$D(a2,d1.w),obj.sprite_frame(a0)
	move.b	$C(a2,d1.w),debug_subtype_2
	move.b	$B(a2,d1.w),d0
	ori.b	#4,d0
	move.b	d0,obj.sprite_flags(a0)
	move.b	#0,obj.anim_id(a0)
	btst	#5,p1_ctrl_tap
	beq.s	.NoPlace
	bsr.w	FindObjSlot
	bne.s	.NoPlace
	moveq	#0,d1
	move.b	debug_object,d1
	mulu.w	#$C,d1
	move.b	2(a2,d1.w),obj.id(a1)
	move.b	$A(a2,d1.w),obj.subtype(a1)
	move.b	$C(a2,d1.w),obj.subtype_2(a1)
	move.b	$D(a2,d1.w),obj.sprite_frame(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	move.b	obj.sprite_flags(a0),d0
	andi.b	#3,d0
	move.b	d0,obj.sprite_flags(a1)
	move.b	d0,obj.flags(a1)

.NoPlace:
	btst	#4,p1_ctrl_tap
	beq.s	.NoRevert
	move.b	#0,debug_mode
	move.l	#MapSpr_Sonic,obj.sprites(a0)
	move.w	#$780,obj.sprite_tile(a0)
	move.b	#2,obj.sprite_layer(a0)
	move.b	#0,obj.sprite_frame(a0)
	move.b	#4,obj.sprite_flags(a0)

.NoRevert:
	jmp	DrawObject

; ------------------------------------------------------------------------------

debug_speed:
	dc.l	$4000

; ------------------------------------------------------------------------------
