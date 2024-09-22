; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Amy Rose object
; ------------------------------------------------------------------------------

ObjAmyRose:
	tst.b	time_attack_mode
	bne.s	.ResetPal
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjAmyRose_Index(pc,d0.w),d0
	jsr	ObjAmyRose_Index(pc,d0.w)
	bsr.w	ObjAmyRose_MakeHearts
	jsr	DrawObject
	jsr	CheckObjDespawn
	cmpi.b	#$2F,obj.id(a0)
	beq.s	.End

.ResetPal:
	lea	Pal_LevelEnd,a3
	bsr.w	ObjAmyRose_ResetPal

.End:
	rts
; End of function ObjAmyRose

; ------------------------------------------------------------------------------
ObjAmyRose_Index:dc.w	ObjAmyRose_Init-ObjAmyRose_Index
	dc.w	ObjAmyRose_Main-ObjAmyRose_Index
	dc.w	ObjAmyRose_HoldSonic-ObjAmyRose_Index
	dc.w	ObjAmyRose_FollowSonic-ObjAmyRose_Index
	dc.w	ObjAmyRose_WaitLand-ObjAmyRose_Index
; ------------------------------------------------------------------------------

ObjAmyRose_Init:
	ori.b	#4,obj.sprite_flags(a0)
	move.w	#$2370,obj.sprite_tile(a0)
	move.b	#1,obj.sprite_layer(a0)
	move.l	#MapSpr_AmyRose,obj.sprites(a0)
	move.b	#$C,obj.width(a0)
	move.b	#$10,obj.collide_height(a0)
	move.w	obj.x(a0),obj.var_36(a0)
	bsr.w	ObjAmyRose_LoadPal

.PlaceLoop:
	jsr	ObjGetFloorDist
	tst.w	d1
	beq.s	.FoundFloor
	add.w	d1,obj.y(a0)
	bra.w	.PlaceLoop

; ------------------------------------------------------------------------------

.FoundFloor:
	lea	player_object,a1
	bsr.w	ObjAmyRose_SetFacing
	move.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	bcc.s	.ChkRange
	neg.w	d0

.ChkRange:
	cmpi.w	#$70,d0
	bcc.s	.Animate
	addq.b	#2,obj.routine(a0)

.Animate:
	move.b	#5,obj.anim_id(a0)
	lea	Ani_AmyRose,a1
	bra.w	AnimateObjSimple
; End of function ObjAmyRose_Init

; ------------------------------------------------------------------------------

ObjAmyRose_Main:
	lea	player_object,a1
	bsr.w	ObjAmyRose_SetFacing
	btst	#6,obj.var_3E(a0)
	bne.w	.WallBump
	btst	#2,obj.var_3E(a0)
	bne.w	.GetDX2
	tst.w	obj.x_speed(a1)
	bne.s	.GetAccel
	move.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	bcc.s	.GetDX
	neg.w	d0

.GetDX:
	cmpi.w	#$A,d0
	bcc.s	.GetAccel

.InRange:
	bset	#2,obj.var_3E(a0)
	clr.w	obj.x_speed(a0)
	bra.w	.ChkFloor2

; ------------------------------------------------------------------------------

.GetDX2:
	move.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	bcc.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#$20,d0
	bcs.s	.InRange
	bclr	#2,obj.var_3E(a0)

.GetAccel:
	move.w	#-$10,d0
	btst	#0,obj.flags(a0)
	bne.s	.NoFlip
	neg.w	d0

.NoFlip:
	add.w	obj.x_speed(a0),d0
	move.w	d0,d1
	move.w	#$200,d2
	tst.w	d1
	bpl.s	.ChkCap
	neg.w	d1
	neg.w	d2

.ChkCap:
	cmpi.w	#$200,d1
	bcs.s	.SetVX
	move.w	d2,d0

.SetVX:
	move.w	d0,obj.x_speed(a0)
	tst.w	obj.x_speed(a0)
	bpl.s	.NoFlip2
	move.w	obj.var_36(a0),d0
	subi.w	#$130,d0
	cmp.w	obj.x(a0),d0
	bcs.s	.ChkFloor
	bra.w	.WallBump

; ------------------------------------------------------------------------------

.NoFlip2:
	move.w	obj.var_36(a0),d0
	addi.w	#$90,d0
	cmp.w	obj.x(a0),d0
	bcc.s	.ChkFloor
	bra.w	.WallBump

; ------------------------------------------------------------------------------

.ChkFloor:
	jsr	ObjGetFloorDist
	cmpi.w	#7,d1
	bpl.s	.WallBump
	cmpi.w	#-7,d1
	bmi.s	.WallBump
	add.w	d1,obj.y(a0)
	bsr.w	ObjectMoveX
	bsr.w	ObjAmyRose_CheckGrabSonic
	move.b	#2,obj.anim_id(a0)
	lea	Ani_AmyRose,a1
	bra.w	AnimateObjSimple

; ------------------------------------------------------------------------------

.WallBump:
	clr.w	obj.x_speed(a0)
	btst	#7,obj.var_3E(a0)
	bne.s	.ChkIfJump

.ChkFloor2:
	jsr	ObjGetFloorDist
	add.w	d1,obj.y(a0)
	move.b	#1,obj.anim_id(a0)
	lea	Ani_AmyRose,a1
	bra.w	AnimateObjSimple

; ------------------------------------------------------------------------------

.ChkIfJump:
	btst	#6,obj.var_3E(a0)
	bne.s	.MoveFall
	cmpi.b	#3,obj.var_3F(a0)
	bcs.s	.Jump
	addq.b	#4,obj.var_3A(a0)
	bcc.s	.Animate
	clr.b	obj.var_3F(a0)

.Animate:
	move.b	#4,obj.anim_id(a0)
	lea	Ani_AmyRose,a1
	bra.w	AnimateObjSimple

; ------------------------------------------------------------------------------

.Jump:
	move.w	#-$300,obj.y_speed(a0)
	bset	#6,obj.var_3E(a0)

.MoveFall:
	bsr.w	ObjectMoveY
	addi.w	#$40,obj.y_speed(a0)
	move.b	#6,obj.sprite_frame(a0)
	tst.w	obj.y_speed(a0)
	bmi.s	.GoingUp
	move.b	#4,obj.sprite_frame(a0)

.GoingUp:
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.End
	clr.w	obj.y_speed(a0)
	bclr	#6,obj.var_3E(a0)
	addq.b	#1,obj.var_3F(a0)

.End:
	rts
; End of function ObjAmyRose_Main

; ------------------------------------------------------------------------------

ObjAmyRose_HoldSonic:
	lea	player_object,a1
	bset	#0,oPlayerCtrl(a1)
	move.b	#5,obj.anim_id(a1)
	bsr.w	ObjAmyRose_SlowSonic
	bsr.w	ObjAmyRose_SetFacing
	moveq	#$C,d0
	btst	#0,obj.flags(a1)
	bne.s	.NoFlip
	neg.w	d0

.NoFlip:
	add.w	obj.x(a1),d0
	move.w	d0,obj.x(a0)
	move.w	obj.y(a1),obj.y(a0)
	move.w	p1_ctrl,player_ctrl
	bsr.w	Player_Jump
	btst	#0,oPlayerCtrl(a1)
	beq.s	.PlayerJumped
	cmpi.l	#(9<<16)|(50<<8)|0,time
	bcc.s	.ForceJump
	move.b	#3,obj.anim_id(a0)
	lea	Ani_AmyRose,a1
	bra.w	AnimateObjSimple

; ------------------------------------------------------------------------------

.PlayerJumped:
	bclr	#0,obj.var_3E(a0)
	move.b	#6,obj.routine(a0)
	rts

; ------------------------------------------------------------------------------

.ForceJump:
	bsr.w	Player_Jump2
	bclr	#0,obj.var_3E(a0)
	move.b	#2,obj.routine(a0)
	rts
; End of function ObjAmyRose_HoldSonic

; ------------------------------------------------------------------------------

ObjAmyRose_FollowSonic:
	move.b	#6,obj.sprite_frame(a0)
	move.w	#$80,d0
	btst	#0,obj.flags(a0)
	bne.s	.NoFlip
	neg.w	d0

.NoFlip:
	move.w	d0,obj.x_speed(a0)
	move.w	obj.x(a0),d0
	sub.w	obj.var_36(a0),d0
	bcc.s	.ChkRange
	neg.w	d0

.ChkRange:
	cmpi.w	#$80,d0
	bcs.s	.Jump
	clr.w	obj.x_speed(a0)

.Jump:
	move.w	#-$300,obj.y_speed(a0)
	addq.b	#2,obj.routine(a0)
; End of function ObjAmyRose_FollowSonic

; ------------------------------------------------------------------------------

ObjAmyRose_WaitLand:
	bsr.w	ObjectMove
	addi.w	#$40,obj.y_speed(a0)
	tst.w	obj.y_speed(a0)
	bmi.s	.ChkFloor
	move.b	#7,obj.sprite_frame(a0)

.ChkFloor:
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.End
	clr.w	obj.x_speed(a0)
	clr.w	obj.y_speed(a0)
	addi.b	#$10,obj.var_3A(a0)
	bcc.s	.End
	move.b	#2,obj.routine(a0)

.End:
	rts
; End of function ObjAmyRose_WaitLand

; ------------------------------------------------------------------------------

ObjAmyRose_SlowSonic:
	tst.w	obj.x_speed(a0)
	beq.s	.End
	movem.l	a0-a1,-(sp)
	exg	a0,a1
	bsr.w	ObjectMoveX
	jsr	ObjGetFloorDist
	add.w	d1,obj.y(a0)
	movem.l	(sp)+,a0-a1
	tst.w	obj.x_speed(a1)
	bmi.s	.Decel
	subi.w	#$40,obj.x_speed(a1)
	bpl.s	.End
	bra.s	.StopSonic

; ------------------------------------------------------------------------------

.Decel:
	addi.w	#$40,obj.x_speed(a1)
	bmi.s	.End

.StopSonic:
	clr.w	obj.x_speed(a1)

.End:
	rts
; End of function ObjAmyRose_SlowSonic

; ------------------------------------------------------------------------------

Player_Jump:
	move.b	player_ctrl_tap,d0
	andi.b	#$70,d0
	beq.w	Player_Jump_Done
; End of function Player_Jump

; ------------------------------------------------------------------------------

Player_Jump2:
	clr.b	oPlayerCtrl(a1)
	move.w	#$680,d2
	moveq	#0,d0
	move.b	obj.angle(a1),d0
	subi.b	#$40,d0
	jsr	CalcSine
	muls.w	d2,d1
	asr.l	#8,d1
	add.w	d1,obj.x_speed(a1)
	muls.w	d2,d0
	asr.l	#8,d0
	add.w	d0,obj.y_speed(a1)
	bset	#1,obj.flags(a1)
	bclr	#5,obj.flags(a1)
	move.b	#1,oPlayerJump(a1)
	clr.b	oPlayerStick(a1)
	move.b	#$13,obj.collide_height(a1)
	move.b	#9,obj.collide_width(a1)
	btst	#2,obj.flags(a1)
	bne.s	Player_Jump_RollJmp
	move.b	#$E,obj.collide_height(a1)
	move.b	#7,obj.collide_width(a1)
	addq.w	#5,obj.y(a1)
	bset	#2,obj.flags(a1)
	move.b	#2,obj.anim_id(a1)

Player_Jump_Done:
	rts

; ------------------------------------------------------------------------------

Player_Jump_RollJmp:
	bset	#4,obj.flags(a1)
	rts
; End of function Player_Jump2

; ------------------------------------------------------------------------------

ObjAmyRose_CheckGrabSonic:
	tst.w	obj.x_speed(a0)
	bpl.s	.GoingRight
	move.w	obj.var_36(a0),d0
	subi.w	#$130,d0
	cmp.w	obj.x(a0),d0
	bcs.s	.ChkRange
	bra.w	.End

; ------------------------------------------------------------------------------

.GoingRight:
	move.w	obj.var_36(a0),d0
	addi.w	#$90,d0
	cmp.w	obj.x(a0),d0
	bcc.s	.ChkRange
	bra.w	.End

; ------------------------------------------------------------------------------

.ChkRange:
	cmpi.l	#(9<<16)|(50<<8)|0,time
	bcc.w	.End
	lea	player_object,a1
	tst.b	debug_mode
	bne.w	.End
	btst	#0,obj.flags(a1)
	bne.s	.GetDX
	move.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	bra.s	.GotDX

; ------------------------------------------------------------------------------

.GetDX:
	move.w	obj.x(a0),d0
	sub.w	obj.x(a1),d0

.GotDX:
	bcs.w	.End
	cmpi.w	#$C,d0
	bcs.w	.End
	cmpi.w	#$18,d0
	bcc.s	.End
	moveq	#8,d1
	move.w	obj.y(a1),d0
	sub.w	obj.y(a0),d0
	add.w	d1,d0
	bmi.s	.End
	move.w	d1,d2
	add.w	d2,d2
	cmp.w	d2,d0
	bcc.s	.End
	move.w	obj.x_speed(a1),d0
	bpl.s	.AbsVX
	neg.w	d0

.AbsVX:
	btst	#1,obj.flags(a1)
	bne.s	.NoGrab
	btst	#2,obj.flags(a1)
	bne.s	.NoGrab
	tst.b	oPlayerHurt(a1)
	bne.s	.NoGrab
	cmpi.w	#$680,d0
	bcc.s	.NoGrab
	tst.b	shield
	bne.s	.NoGrab
	tst.b	time_warp
	bne.s	.NoGrab
	tst.b	invincible
	bne.s	.NoGrab
	bclr	#2,obj.flags(a1)
	ori.b	#$81,obj.var_3E(a0)
	clr.w	obj.y_speed(a0)
	clr.w	obj.x_speed(a0)
	move.b	#7,obj.sprite_frame(a0)
	move.b	#4,obj.routine(a0)
	move.w	#SCMD_GIGGLESFX,d0
	jsr	SubCPUCmd

.End:
	rts

; ------------------------------------------------------------------------------

.NoGrab:
	move.b	#6,obj.routine(a0)
	rts
; End of function ObjAmyRose_CheckGrabSonic

; ------------------------------------------------------------------------------

CheckPlayerRange1:
	lea	player_object,a1
	move.w	obj.x(a0),d0
	sub.w	obj.x(a1),d0
	bcc.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#52,d0
	rts
; End of function CheckPlayerRange1

; ------------------------------------------------------------------------------

CheckPlayerRange2:
	lea	player_object,a1
	move.w	obj.x(a0),d0
	sub.w	obj.x(a1),d0
	bcc.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#124,d0
	rts
; End of function CheckPlayerRange2

; ------------------------------------------------------------------------------

ObjectMove:
	bsr.s	ObjectMoveX
; End of function ObjectMove

; ------------------------------------------------------------------------------

ObjectMoveY:
	move.w	obj.y_speed(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,obj.y(a0)
	rts
; End of function ObjectMoveY

; ------------------------------------------------------------------------------

ObjectMoveX:
	move.w	obj.x_speed(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,obj.x(a0)
	rts
; End of function ObjectMoveX

; ------------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjAmyRose_Init

AnimateObjSimple:
	moveq	#0,d0
	move.b	obj.anim_id(a0),d0
	cmp.b	obj.prev_anim_id(a0),d0
	beq.s	.run
	move.b	d0,obj.prev_anim_id(a0)
	clr.b	obj.anim_frame(a0)
	clr.b	obj.anim_time(a0)

.run:
	subq.b	#1,obj.anim_time(a0)
	bpl.s	.End
	add.w	d0,d0
	adda.w	(a1,d0.w),a1

.Next:
	move.b	obj.anim_frame(a0),d0
	lea	(a1,d0.w),a2
	move.b	(a2),d0
	bpl.s	.SetFrame
	clr.b	obj.anim_frame(a0)
	bra.s	.Next

; ------------------------------------------------------------------------------

.SetFrame:
	move.b	d0,d1
	andi.b	#$1F,d0
	move.b	d0,obj.sprite_frame(a0)
	move.b	obj.flags(a0),d0
	rol.b	#3,d1
	eor.b	d0,d1
	andi.b	#3,d1
	andi.b	#$FC,obj.sprite_flags(a0)
	or.b	d1,obj.sprite_flags(a0)
	move.b	obj.sprite_flags(a2),obj.anim_time(a0)
	addq.b	#2,obj.anim_frame(a0)

.End:
	rts
; END OF FUNCTION CHUNK	FOR ObjAmyRose_Init
; ------------------------------------------------------------------------------

ObjAmyRose_MakeHearts:
	moveq	#6,d0
	btst	#0,obj.var_3E(a0)
	beq.s	.ChkTimer
	moveq	#$10,d0

.ChkTimer:
	add.b	d0,obj.var_3B(a0)
	bcc.s	.End
	jsr	FindObjSlot
	bne.s	.End
	move.b	#$30,obj.id(a1)
	moveq	#8,d1
	btst	#0,obj.flags(a0)
	beq.s	.NoFlip
	move.w	#-$A,d1

.NoFlip:
	btst	#0,obj.var_3E(a0)
	beq.s	.SetPos
	neg.w	d1

.SetPos:
	move.w	obj.x(a0),d0
	add.w	d1,d0
	move.w	d0,obj.x(a1)
	move.w	obj.y(a0),d0
	subi.w	#$C,d0
	move.w	d0,obj.y(a1)

.End:
	rts
; End of function ObjAmyRose_MakeHearts

; ------------------------------------------------------------------------------

ObjAmyRose_SetFacing:
	bsr.s	ObjAmyRose_XUnflip
	move.w	obj.x(a0),d0
	sub.w	obj.x(a1),d0
	bcs.s	.End
	bsr.s	ObjAmyRose_XFlip

.End:
	rts
; End of function ObjAmyRose_SetFacing

; ------------------------------------------------------------------------------

ObjAmyRose_XUnflip:
	bclr	#0,obj.flags(a0)
	bclr	#0,obj.sprite_flags(a0)
	rts
; End of function ObjAmyRose_XUnflip

; ------------------------------------------------------------------------------

ObjAmyRose_XFlip:
	bset	#0,obj.flags(a0)
	bset	#0,obj.sprite_flags(a0)
	rts
; End of function ObjAmyRose_XFlip

; ------------------------------------------------------------------------------

ObjAmyRose_LoadPal:
	lea	Pal_AmyRose(pc),a3
; End of function ObjAmyRose_LoadPal

; ------------------------------------------------------------------------------

ObjAmyRose_ResetPal:
	lea	palette+$20.w,a4
	movem.l	(a3)+,d0-d3
	movem.l	d0-d3,(a4)
	movem.l	(a3)+,d0-d3
	movem.l	d0-d3,$10(a4)
	rts
; End of function ObjAmyRose_ResetPal

; ------------------------------------------------------------------------------
Pal_AmyRose:
	incbin	"Level/Palmtree Panic/Objects/Amy Rose/Data/Palette.bin"
	even
; ------------------------------------------------------------------------------

ObjAmyHeart:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjAmyHeart_Index(pc,d0.w),d0
	jsr	ObjAmyHeart_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawn
; End of function ObjAmyHeart

; ------------------------------------------------------------------------------
ObjAmyHeart_Index:dc.w	ObjAmyHeart_Init-ObjAmyHeart_Index
	dc.w	ObjAmyHeart_Main-ObjAmyHeart_Index
; ------------------------------------------------------------------------------

ObjAmyHeart_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.w	#$370,obj.sprite_tile(a0)
	move.l	#MapSpr_AmyRose,obj.sprites(a0)
	move.b	#8,obj.sprite_frame(a0)
	move.w	#-$60,obj.y_speed(a0)
	move.b	#3,obj.sprite_layer(a0)
; End of function ObjAmyHeart_Init

; ------------------------------------------------------------------------------

ObjAmyHeart_Main:
	tst.b	obj.var_3C(a0)
	bne.s	.StopRipple
	moveq	#0,d0
	move.b	obj.var_3A(a0),d0
	add.b	d0,d0
	add.b	obj.var_3A(a0),d0
	jsr	CalcSine
	asr.w	#2,d0
	move.w	d0,obj.x_speed(a0)

.StopRipple:
	bsr.w	ObjectMove
	addq.b	#1,obj.var_3A(a0)
	move.b	obj.var_3A(a0),d0
	cmpi.b	#$14,d0
	bne.s	.ChkTimer
	addq.b	#1,obj.sprite_frame(a0)

.ChkTimer:
	cmpi.b	#$6E,d0
	bne.s	.ChkDel
	addq.b	#1,obj.sprite_frame(a0)
	clr.w	obj.y_speed(a0)
	clr.w	obj.x_speed(a0)
	st	obj.var_3C(a0)

.ChkDel:
	cmpi.b	#$78,d0
	bne.s	.End
	jmp	DeleteObject

; ------------------------------------------------------------------------------

.End:
	rts
; End of function ObjAmyHeart_Main

; ------------------------------------------------------------------------------
