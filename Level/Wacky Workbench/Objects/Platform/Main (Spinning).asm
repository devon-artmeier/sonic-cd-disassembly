; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Spinning platform object
; ------------------------------------------------------------------------------

oSPtfmY		EQU	obj.var_32
oSPtfmX		EQU	obj.var_36
oSPtfm3A	EQU	obj.var_3A

; ------------------------------------------------------------------------------

ObjSpinPlatform:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	move.w	oSPtfmX(a0),d0
	jmp	CheckObjDespawn2

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjSpinPlatform_Init-.Index
	dc.w	ObjSpinPlatform_Main-.Index

; ------------------------------------------------------------------------------

ObjSpinPlatform_Solid:
	move.w	obj.x(a0),d3
	move.w	obj.y(a0),d4
	jmp	TopSolidObject

; ------------------------------------------------------------------------------

ObjSpinPlatform_Init:
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#1,obj.sprite_layer(a0)
	move.w	#$436A,obj.sprite_tile(a0)
	move.l	#MapSpr_SpinPlatform,obj.sprites(a0)
	move.w	obj.x(a0),oSPtfmX(a0)
	move.w	obj.y(a0),oSPtfmY(a0)
	move.b	#12,obj.collide_height(a0)
	move.b	#16,obj.width(a0)
	addq.b	#2,obj.routine(a0)

; ------------------------------------------------------------------------------

ObjSpinPlatform_Main:
	bsr.w	ObjSpinPlatform_Move

	lea	Ani_SpinPlatform(pc),a1
	jsr	AnimateObject

	lea	player_object,a1
	bsr.w	ObjSpinPlatform_Solid
	beq.s	.End

	bset	#0,obj.flags(a1)
	andi.b	#$FC,obj.sprite_flags(a1)
	ori.b	#1,obj.sprite_flags(a1)
	bset	#0,oPlayerCtrl(a1)
	bne.s	.AlreadySpinning
	move.b	#$2D,obj.anim_id(a1)
	moveq	#0,d0
	move.b	d0,oPlayerRotAngle(a1)
	move.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	bcc.s	.PlayerRight
	neg.w	d0
	move.b	#$80,oPlayerRotAngle(a1)

.PlayerRight:
	move.b	d0,oPlayerRotDist(a1)

.AlreadySpinning:
	cmpi.b	#6,obj.routine(a1)
	bcc.s	.End
	bra.s	ObjSpinPlatform_MoveSonic

.End:
	rts

; ------------------------------------------------------------------------------

ObjSpinPlatform_CheckYDist:
	moveq	#0,d0
	move.b	obj.collide_height(a1),d0
	add.w	obj.y(a1),d0
	sub.w	obj.y(a0),d0
	bmi.s	.Away
	cmpi.w	#16,d0
	bcs.s	.Away

.Near:
	moveq	#-1,d0
	rts

.Away:
	moveq	#0,d0
	rts

; ------------------------------------------------------------------------------

ObjSpinPlatform_MoveSonic:
	addq.b	#4,oPlayerRotAngle(a1)
	move.b	oPlayerRotAngle(a1),d0
	jsr	CalcSine

	moveq	#0,d0
	move.b	oPlayerRotDist(a1),d0
	muls.w	d1,d0
	asr.l	#8,d0
	move.w	obj.x(a0),obj.x(a1)
	add.w	d0,obj.x(a1)

	moveq	#0,d0
	move.b	oPlayerRotAngle(a1),d0
	move.b	d0,d1
	andi.b	#$F0,d0
	lsr.b	#4,d0
	move.b	.PlayerFrames(pc,d0.w),obj.anim_frame(a1)
	andi.b	#$3F,d1
	bne.s	.ChkInput
	addq.b	#1,oPlayerRotDist(a1)

.ChkInput:
	move.w	p1_ctrl,player_ctrl
	cmpi.b	#1,obj.id(a1)
	beq.s	.NotPlayer2
	move.w	p2_ctrl,player_ctrl

.NotPlayer2:
	bsr.w	ObjSpinPlatform_CheckDirs
	bra.w	ObjSpinPlatform_CheckJump

	rts

; ------------------------------------------------------------------------------

.PlayerFrames:
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	1
	dc.b	1
	dc.b	2
	dc.b	2
	dc.b	2
	dc.b	3
	dc.b	3
	dc.b	3
	dc.b	4
	dc.b	4
	dc.b	5
	dc.b	5
	dc.b	5

; ------------------------------------------------------------------------------

ObjSpinPlatform_CheckDirs:
	move.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	bcc.s	.ChkRight2
	btst	#2,player_ctrl_hold
	beq.s	.ChkRight
	addq.b	#1,oPlayerRotDist(a1)
	bra.s	.End

.ChkRight:
	btst	#3,player_ctrl_hold
	beq.s	.End
	subq.b	#1,oPlayerRotDist(a1)
	bcc.s	.End
	clr.b	oPlayerRotDist(a1)
	bra.s	.End

.ChkRight2:
	btst	#3,player_ctrl_hold
	beq.s	.ChkLeft
	addq.b	#1,oPlayerRotDist(a1)
	bra.s	.End

.ChkLeft:
	btst	#2,player_ctrl_hold
	beq.s	.End
	subq.b	#1,oPlayerRotDist(a1)
	bcc.s	.End
	clr.b	oPlayerRotDist(a1)

.End:
	rts

; ------------------------------------------------------------------------------

ObjSpinPlatform_CheckJump:
	move.b	player_ctrl_tap,d0
	andi.b	#$70,d0
	beq.w	.End

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
	tst.b	mini_player
	beq.s	.NotMini
	move.b	#$A,obj.collide_height(a1)
	move.b	#5,obj.collide_width(a1)
	bra.s	.GotSize

.NotMini:
	move.b	#$13,obj.collide_height(a1)
	move.b	#9,obj.collide_width(a1)

.GotSize:
	btst	#2,obj.flags(a1)
	bne.s	.RollJump
	tst.b	mini_player
	beq.s	.NotMini2
	move.b	#$A,obj.collide_height(a1)
	move.b	#5,obj.collide_width(a1)
	bra.s	.SetRoll

.NotMini2:
	move.b	#$E,obj.collide_height(a1)
	move.b	#7,obj.collide_width(a1)
	addq.w	#5,obj.y(a1)

.SetRoll:
	bset	#2,obj.flags(a1)
	move.b	#2,obj.anim_id(a1)

.End:
	rts

.RollJump:
	bset	#4,obj.flags(a1)
	rts

; ------------------------------------------------------------------------------

ObjSpinPlatform_Move:
	moveq	#0,d0
	move.b	obj.subtype(a0),d0
	add.w	d0,d0
	move.w	.MoveTypes(pc,d0.w),d0
	jmp	.MoveTypes(pc,d0.w)

; ------------------------------------------------------------------------------

.MoveTypes:
	dc.w	ObjSpinPlatform_MoveX-.MoveTypes
	dc.w	ObjSpinPlatform_MoveX2-.MoveTypes
	dc.w	ObjSpinPlatform_MoveY-.MoveTypes
	dc.w	ObjSpinPlatform_MoveY2-.MoveTypes

; ------------------------------------------------------------------------------

ObjSpinPlatform_MoveY:
	bsr.w	ObjSpinPlatform_GetOffset
	neg.w	d0
	add.w	oSPtfmY(a0),d0
	move.w	d0,obj.y(a0)
	rts

; ------------------------------------------------------------------------------

ObjSpinPlatform_MoveY2:
	bsr.w	ObjSpinPlatform_GetOffset
	add.w	oSPtfmY(a0),d0
	move.w	d0,obj.y(a0)
	rts

; ------------------------------------------------------------------------------

ObjSpinPlatform_MoveX:
	move.l	obj.x(a0),-(sp)
	bsr.w	ObjSpinPlatform_GetOffset
	add.w	oSPtfmX(a0),d0
	move.w	d0,obj.x(a0)

	move.l	obj.x(a0),d0
	sub.l	(sp)+,d0
	lsr.l	#8,d0
	move.w	d0,obj.x_speed(a0)
	rts

; ------------------------------------------------------------------------------

ObjSpinPlatform_MoveX2:
	move.l	obj.x(a0),-(sp)
	bsr.w	ObjSpinPlatform_GetOffset
	neg.w	d0
	add.w	oSPtfmX(a0),d0
	move.w	d0,obj.x(a0)

	move.l	obj.x(a0),d0
	sub.l	(sp)+,d0
	lsr.l	#8,d0
	move.w	d0,obj.x_speed(a0)
	rts

; ------------------------------------------------------------------------------

ObjSpinPlatform_GetOffset:
	move.w	stage_frames,d0
	andi.w	#$FF,d0
	jsr	CalcSine
	add.w	d0,d0
	add.w	d0,d0
	asr.w	#4,d0

	addq.b	#1,oSPtfm3A(a0)
	rts

; ------------------------------------------------------------------------------

Ani_SpinPlatform:
	include	"Level/Wacky Workbench/Objects/Platform/Data/Animations (Spinning).asm"
	even

MapSpr_SpinPlatform:
	include	"Level/Wacky Workbench/Objects/Platform/Data/Mappings (Spinning).asm"
	even

; ------------------------------------------------------------------------------
