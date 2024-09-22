; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Spinning disc object
; ------------------------------------------------------------------------------

ObjSpinningDisc_SolidObj:
	move.w	obj.x(a0),d3
	move.w	obj.y(a0),d4
	jmp	SolidObject
; End of function ObjSpinningDisc_SolidObj

; ------------------------------------------------------------------------------

ObjSpinningDisc:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjSpinningDisc_Index(pc,d0.w),d0
	jsr	ObjSpinningDisc_Index(pc,d0.w)
	tst.w	time_stop
	bne.s	.SkipAnim
	lea	Ani_SpinningDisc,a1
	bsr.w	AnimateObject

.SkipAnim:
	jsr	DrawObject
	jmp	CheckObjDespawn
; End of function ObjSpinningDisc

; ------------------------------------------------------------------------------
ObjSpinningDisc_Index:
	dc.w	ObjSpinningDisc_Init-ObjSpinningDisc_Index
	dc.w	ObjSpinningDisc_Main-ObjSpinningDisc_Index
; ------------------------------------------------------------------------------

ObjSpinningDisc_Init:
	addq.b	#2,obj.routine(a0)
	move.b	#4,obj.sprite_flags(a0)
	move.b	#4,obj.sprite_layer(a0)
	move.l	#MapSpr_SpinningDisc,obj.sprites(a0)
	moveq	#6,d0
	jsr	SetObjectTileID(pc)
	move.b	#$10,obj.width(a0)
	move.b	#8,obj.collide_height(a0)
; End of function ObjSpinningDisc_Init

; ------------------------------------------------------------------------------

ObjSpinningDisc_Main:
	tst.b	obj.sprite_flags(a0)
	bpl.w	.End
	lea	player_object,a1
	bsr.s	ObjSpinningDisc_SolidObj
	beq.s	.End
	bset	#0,oPlayerCtrl(a1)
	bne.s	.DidInit
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

.DidInit:
	cmpi.b	#6,obj.routine(a1)
	bcc.s	.End
	bra.s	.MoveSonic

; ------------------------------------------------------------------------------

.End:
	rts

; ------------------------------------------------------------------------------

.MoveSonic:
	addq.b	#8,oPlayerRotAngle(a1)
	move.b	oPlayerRotAngle(a1),d0
	jsr	CalcSine
	moveq	#0,d0
	move.b	oPlayerRotDist(a1),d0
	muls.w	d1,d0
	lsr.l	#8,d0
	move.w	obj.x(a0),obj.x(a1)
	add.w	d0,obj.x(a1)
	moveq	#0,d0
	move.b	oPlayerRotAngle(a1),d0
	move.b	d0,d1
	andi.b	#$F0,d0
	lsr.b	#4,d0
	move.b	ObjSpinningDisc_PlayerFrames(pc,d0.w),obj.anim_frame(a1)
	andi.b	#$3F,d1
	bne.s	.ChkInput
	addq.b	#1,oPlayerRotDist(a1)

.ChkInput:
	move.w	p1_ctrl,player_ctrl
	bsr.w	ObjSpinningDisc_CheckDirs
	bra.w	ObjSpinningDisc_CheckJump
; End of function ObjSpinningDisc_Main

; ------------------------------------------------------------------------------
	rts

; ------------------------------------------------------------------------------
ObjSpinningDisc_PlayerFrames:dc.b	0, 0, 0, 1, 1,	2, 2, 2, 3, 3, 3, 4, 4,	5, 5, 5
; ------------------------------------------------------------------------------

ObjSpinningDisc_CheckDirs:
	move.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	bcc.s	.ChkRight2
	btst	#2,player_ctrl_hold
	beq.s	.ChkRight
	addq.b	#1,oPlayerRotDist(a1)
	bra.s	.End

; ------------------------------------------------------------------------------

.ChkRight:
	btst	#3,player_ctrl_hold
	beq.s	.End
	subq.b	#1,oPlayerRotDist(a1)
	bcc.s	.End
	move.b	#0,oPlayerRotDist(a1)
	bra.s	.End

; ------------------------------------------------------------------------------

.ChkRight2:
	btst	#3,player_ctrl_hold
	beq.s	.ChkLeft
	addq.b	#1,oPlayerRotDist(a1)
	bra.s	.End

; ------------------------------------------------------------------------------

.ChkLeft:
	btst	#2,player_ctrl_hold
	beq.s	.End
	subq.b	#1,oPlayerRotDist(a1)
	bcc.s	.End
	move.b	#0,oPlayerRotDist(a1)

.End:
	rts
; End of function ObjSpinningDisc_CheckDirs

; ------------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjSpinningDisc_Main

ObjSpinningDisc_CheckJump:
	move.b	player_ctrl_tap,d0
	andi.b	#$70,d0
	beq.w	.End2
	clr.b	oPlayerCtrl(a1)
	move.w	#$680,d2
	btst	#6,obj.flags(a0)
	beq.s	.NoWater
	move.w	#$380,d2

.NoWater:
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
	move.w	#FM_A0,d0
	jsr	PlayFMSound
	tst.b	mini_player
	beq.s	.NotMini
	move.b	#$A,obj.collide_height(a1)
	move.b	#5,obj.collide_width(a1)
	bra.s	.GotSize

; ------------------------------------------------------------------------------

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

; ------------------------------------------------------------------------------

.NotMini2:
	move.b	#$E,obj.collide_height(a1)
	move.b	#7,obj.collide_width(a1)
	addq.w	#5,obj.y(a1)

.SetRoll:
	bset	#2,obj.flags(a1)
	move.b	#2,obj.anim_id(a1)

.End2:
	rts

; ------------------------------------------------------------------------------

.RollJump:
	bset	#4,obj.flags(a1)
	rts
; END OF FUNCTION CHUNK	FOR ObjSpinningDisc_Main

; ------------------------------------------------------------------------------

Ani_SpinningDisc:
	include	"Level/Palmtree Panic/Objects/Spinning Disc/Data/Animations.asm"
	even
MapSpr_SpinningDisc:
	include	"Level/Palmtree Panic/Objects/Spinning Disc/Data/Mappings.asm"
	even
	
; ------------------------------------------------------------------------------
