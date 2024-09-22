; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Moving spring object
; ------------------------------------------------------------------------------

ObjMovingSpring:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjMovingSpring_Index(pc,d0.w),d0
	jsr	ObjMovingSpring_Index(pc,d0.w)
	move.w	obj.var_36(a0),d0
	andi.w	#$FF80,d0
	move.w	camera_fg_x,d1
	subi.w	#$80,d1
	andi.w	#$FF80,d1
	sub.w	d1,d0
	cmpi.w	#$280,d0
	bhi.w	DeleteObject
	rts

; ------------------------------------------------------------------------------
ObjMovingSpring_Index:
	dc.w	ObjMovingSpring_Init-ObjMovingSpring_Index
	dc.w	ObjMovingSpring_AlignToGround-ObjMovingSpring_Index
	dc.w	ObjMovingSpring_Main-ObjMovingSpring_Index
; ------------------------------------------------------------------------------

ObjMovingSpring_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#4,obj.sprite_layer(a0)
	move.l	#MapSpr_MovingSpring,obj.sprites(a0)
	move.b	#8,obj.width(a0)
	move.b	#7,obj.collide_height(a0)
	move.w	obj.x(a0),obj.var_36(a0)
	move.w	#$180,obj.x_speed(a0)
	moveq	#$E,d0
	jsr	SetObjectTileID
	jsr	FindObjSlot
	beq.s	.GenSpring
	jmp	DeleteObject

; ------------------------------------------------------------------------------

.GenSpring:
	move.b	#$A,obj.id(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	subi.w	#$10,obj.y(a1)
	move.b	#$F0,obj.var_39(a1)
	move.w	a0,obj.var_34(a1)
	move.b	obj.subtype(a0),obj.subtype(a1)
; End of function ObjMovingSpring_Init

; ------------------------------------------------------------------------------

ObjMovingSpring_AlignToGround:
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.Sink
	add.w	d1,obj.y(a0)
	move.w	obj.y(a0),obj.var_32(a0)
	addq.b	#2,obj.routine(a0)
	rts

; ------------------------------------------------------------------------------

.Sink:
	addq.w	#1,obj.y(a0)
	rts
; End of function ObjMovingSpring_AlignToGround

; ------------------------------------------------------------------------------

ObjMovingSpring_Main:
	tst.w	time_stop
	bne.s	.Display
	jsr	ObjGetFloorDist
	add.w	d1,obj.y(a0)
	move.w	obj.var_32(a0),d0
	sub.w	obj.y(a0),d0
	cmpi.w	#$C,d0
	bcs.s	.NotEdge
	neg.w	obj.x_speed(a0)

.NotEdge:
	jsr	ObjMove
	lea	Ani_MovingSpring,a1
	jsr	AnimateObject

.Display:
	jmp	DrawObject


; ------------------------------------------------------------------------------

ObjSpring2:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjSpring2_Index(pc,d0.w),d0
	jmp	ObjSpring2_Index(pc,d0.w)
; End of function ObjSpring2

; ------------------------------------------------------------------------------
ObjSpring2_Index:dc.w	ObjSpring2_Init-ObjSpring2_Index
	dc.w	ObjSpring2_Main-ObjSpring2_Index
; ------------------------------------------------------------------------------

ObjSpring2_Init:
	move.l	#MapSpr_Spring1,obj.sprites(a0)
	move.w	#$8520,obj.sprite_tile(a0)
	ori.b	#%00000100,obj.sprite_flags(a0)
	move.b	#$10,obj.width(a0)
	move.b	#8,obj.collide_height(a0)
	move.b	#4,obj.sprite_layer(a0)
	addq.b	#2,obj.routine(a0)
; End of function ObjSpring2_Init

; ------------------------------------------------------------------------------

ObjSpring2_Main:
	move.w	player_object+obj.x.w,obj.x(a0)
	move.w	player_object+obj.y.w,obj.y(a0)
	jmp	DrawObject
; End of function ObjSpring2_Main

; ------------------------------------------------------------------------------

ObjSpring:
	cmpi.b	#5,obj.routine_2(a0)
	beq.s	ObjSpring2
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	beq.s	.DoControl
	tst.b	obj.sprite_flags(a0)
	bpl.s	.DisplayOnly

.DoControl:
	move.w	ObjSpring_Index(pc,d0.w),d1
	jsr	ObjSpring_Index(pc,d1.w)

.DisplayOnly:
	bsr.w	DrawObject
	move.l	#$FFFF0000,d1
	move.w	obj.var_34(a0),d1
	beq.s	.ChkDel
	movea.l	d1,a1
	move.w	obj.x(a1),obj.x(a0)
	move.w	obj.y(a1),obj.y(a0)
	move.b	obj.var_38(a0),d0
	ext.w	d0
	add.w	d0,obj.x(a0)
	move.b	obj.var_39(a0),d0
	ext.w	d0
	add.w	d0,obj.y(a0)

.ChkDel:
	move.w	obj.var_36(a0),d0
	andi.w	#$FF80,d0
	move.w	camera_fg_x,d1
	subi.w	#$80,d1
	andi.w	#$FF80,d1
	sub.w	d1,d0
	cmpi.w	#$280,d0
	bhi.w	DeleteObject
	rts
; End of function ObjSpring

; ------------------------------------------------------------------------------
ObjSpring_Index:dc.w	ObjSpring_Init-ObjSpring_Index
	dc.w	ObjSpring_Main_Up-ObjSpring_Index
	dc.w	ObjSpring_Anim_Up-ObjSpring_Index
	dc.w	ObjSpring_Reset_Up-ObjSpring_Index
	dc.w	ObjSpring_Main_Side-ObjSpring_Index
	dc.w	ObjSpring_Anim_Side-ObjSpring_Index
	dc.w	ObjSpring_Reset_Side-ObjSpring_Index
	dc.w	ObjSpring_Main_Down-ObjSpring_Index
	dc.w	ObjSpring_Anim_Down-ObjSpring_Index
	dc.w	ObjSpring_Reset_Down-ObjSpring_Index
	dc.w	ObjSpring_Main_Diag-ObjSpring_Index
	dc.w	ObjSpring_Anim_Diag-ObjSpring_Index
	dc.w	ObjSpring_Reset_Diag-ObjSpring_Index
; ------------------------------------------------------------------------------

ObjSpring_Init:
	addq.b	#2,obj.routine(a0)
	move.l	#MapSpr_Spring1,obj.sprites(a0)
	move.w	#$520,obj.sprite_tile(a0)
	ori.b	#%00000100,obj.sprite_flags(a0)
	move.b	#$10,obj.width(a0)
	move.b	#8,obj.collide_height(a0)
	move.w	obj.x(a0),obj.var_36(a0)
	move.b	#4,obj.sprite_layer(a0)
	move.b	obj.subtype(a0),d0
	btst	#2,d0
	beq.s	.SubtypeB2Clear
	move.b	#8,obj.routine(a0)
	move.b	#8,obj.width(a0)
	move.b	#$10,obj.collide_height(a0)
	move.l	#MapSpr_Spring2,obj.sprites(a0)
	bra.s	.NoFlip

; ------------------------------------------------------------------------------

.SubtypeB2Clear:
	btst	#3,d0
	beq.s	.SubtypeB3Clear
	move.b	#$14,obj.routine(a0)
	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		move.b	#$18,obj.width(a0)
		move.b	#$C,obj.collide_height(a0)
	else
		move.b	#$10,obj.collide_height(a0)
	endif
	move.l	#MapSpr_Spring3,obj.sprites(a0)
	move.l	d0,-(sp)
	moveq	#$F,d0
	jsr	SetObjectTileID
	move.l	(sp)+,d0
	bra.s	.NoFlip

; ------------------------------------------------------------------------------

.SubtypeB3Clear:
	btst	#1,obj.sprite_flags(a0)
	beq.s	.NoFlip
	move.b	#$E,obj.routine(a0)
	bset	#1,obj.flags(a0)

.NoFlip:
	btst	#1,d0
	beq.s	.RedSpring
	bset	#5,obj.sprite_tile(a0)

.RedSpring:
	andi.w	#2,d0
	move.w	ObjSpring_Speeds(pc,d0.w),obj.var_30(a0)
	rts
; End of function ObjSpring_Init

; ------------------------------------------------------------------------------
ObjSpring_Speeds:
	dc.w	$F000
	dc.w	$F600
; ------------------------------------------------------------------------------

ObjSpring_SolidObject:
	move.w	obj.x(a0),d3
	move.w	obj.y(a0),d4
	jmp	SolidObject
; End of function ObjSpring_SolidObject

; ------------------------------------------------------------------------------

ObjSpring_Main_Up:
	tst.b	obj.sprite_flags(a0)
	bpl.s	.End
	lea	player_object,a1
	bsr.s	ObjSpring_SolidObject
	bne.s	.Action

.End:
	rts

; ------------------------------------------------------------------------------

.Action:
	move.b	#4,obj.routine(a0)
	addq.w	#8,obj.y(a1)
	move.w	obj.var_30(a0),obj.y_speed(a1)
	bset	#1,obj.flags(a1)
	bclr	#3,obj.flags(a1)
	move.b	#$10,obj.anim_id(a1)
	bclr	#3,obj.flags(a0)
	move.w	#FM_SPRING,d0
	jmp	PlayFMSound
; End of function ObjSpring_Main_Up

; ------------------------------------------------------------------------------

ObjSpring_Anim_Up:
	lea	Ani_Spring,a1
	bra.w	AnimateObject
; End of function ObjSpring_Anim_Up

; ------------------------------------------------------------------------------

ObjSpring_Reset_Up:
	bclr	#3,obj.flags(a0)
	move.b	#1,obj.prev_anim_id(a0)
	subq.b	#4,obj.routine(a0)
	move.b	#0,obj.sprite_frame(a0)
	rts
; End of function ObjSpring_Reset_Up

; ------------------------------------------------------------------------------

ObjSpring_SolidObject2:
	move.w	obj.x(a0),d3
	move.w	obj.y(a0),d4
	jmp	SolidObject
; End of function ObjSpring_SolidObject2

; ------------------------------------------------------------------------------

ObjSpring_Main_Side:
	tst.b	obj.sprite_flags(a0)
	bpl.s	.End
	lea	player_object,a1
	bsr.s	ObjSpring_SolidObject2
	btst	#5,obj.flags(a0)
	bne.s	.Action

.End:
	rts

; ------------------------------------------------------------------------------

.Action:
	move.b	#$A,obj.routine(a0)
	move.w	obj.var_30(a0),obj.x_speed(a1)
	addq.w	#8,obj.x(a1)
	bset	#0,obj.flags(a1)
	btst	#0,obj.flags(a0)
	bne.s	.NoFlip
	subi.w	#$10,obj.x(a1)
	neg.w	obj.x_speed(a1)
	bclr	#0,obj.flags(a1)

.NoFlip:
	move.w	#$F,oPlayerMoveLock(a1)
	move.w	obj.x_speed(a1),oPlayerGVel(a1)
	btst	#2,obj.flags(a1)
	bne.s	.ClearAngle
	move.b	#0,obj.anim_id(a1)

.ClearAngle:
	clr.b	obj.angle(a1)
	bclr	#5,obj.flags(a0)
	bclr	#5,obj.flags(a1)
	move.w	#FM_SPRING,d0
	jmp	PlayFMSound
; End of function ObjSpring_Main_Side

; ------------------------------------------------------------------------------

ObjSpring_Anim_Side:
	lea	Ani_Spring,a1
	bra.w	AnimateObject
; End of function ObjSpring_Anim_Side

; ------------------------------------------------------------------------------

ObjSpring_Reset_Side:
	move.b	#1,obj.prev_anim_id(a0)
	subq.b	#4,obj.routine(a0)
	move.b	#0,obj.sprite_frame(a0)
	rts
; End of function ObjSpring_Reset_Side

; ------------------------------------------------------------------------------

ObjSpring_SolidObject3:
	move.w	obj.x(a0),d3
	move.w	obj.y(a0),d4
	jmp	BtmSolidObject
; End of function ObjSpring_SolidObject3

; ------------------------------------------------------------------------------

ObjSpring_Main_Down:
	tst.b	obj.sprite_flags(a0)
	bpl.s	.End
	lea	player_object,a1
	bsr.s	ObjSpring_SolidObject3
	bne.s	.Action

.End:
	rts

; ------------------------------------------------------------------------------

.Action:
	move.b	#$10,obj.routine(a0)
	subq.w	#8,obj.y(a1)
	move.w	obj.var_30(a0),obj.y_speed(a1)
	neg.w	obj.y_speed(a1)
	bset	#1,obj.flags(a1)
	bclr	#3,obj.flags(a1)
	bclr	#3,obj.flags(a0)
	move.w	#FM_SPRING,d0
	jsr	PlayFMSound
; End of function ObjSpring_Main_Down

; ------------------------------------------------------------------------------

ObjSpring_Anim_Down:
	lea	Ani_Spring,a1
	bra.w	AnimateObject
; End of function ObjSpring_Anim_Down

; ------------------------------------------------------------------------------

ObjSpring_Reset_Down:
	move.b	#1,obj.prev_anim_id(a0)
	subq.b	#4,obj.routine(a0)
	move.b	#0,obj.sprite_frame(a0)
	rts
; End of function ObjSpring_Reset_Down

; ------------------------------------------------------------------------------

ObjSpring_Main_Diag:
	tst.b	obj.sprite_flags(a0)
	bpl.s	.End
	lea	player_object,a1
	bsr.w	ObjSpring_SolidObject
	bne.s	.Action
	btst	#5,obj.flags(a0)
	bne.s	.Action

.End:
	rts

; ------------------------------------------------------------------------------

.Action:
	move.b	#$16,obj.routine(a0)
	moveq	#0,d0
	move.b	#$E0,d0
	jsr	CalcSine
	move.w	obj.var_30(a0),d2
	neg.w	d2
	mulu.w	d2,d0
	mulu.w	d2,d1
	lsr.l	#8,d0
	lsr.l	#8,d1
	move.w	d0,obj.y_speed(a1)
	move.w	d1,obj.x_speed(a1)
	addq.w	#8,obj.y(a1)
	btst	#1,obj.sprite_flags(a0)
	beq.s	.NoVFlip
	subi.w	#$10,obj.y(a1)
	neg.w	obj.y_speed(a1)

.NoVFlip:
	bclr	#0,obj.flags(a1)
	subq.w	#8,obj.x(a1)
	btst	#0,obj.flags(a0)
	beq.s	.NoHFlip
	addi.w	#$10,obj.x(a1)
	bset	#0,obj.flags(a1)
	neg.w	obj.x_speed(a1)

.NoHFlip:
	bset	#1,obj.flags(a1)
	bclr	#3,obj.flags(a1)
	bclr	#5,obj.flags(a1)
	bclr	#3,obj.flags(a0)
	bclr	#5,obj.flags(a0)
	move.w	#FM_SPRING,d0
	jsr	PlayFMSound
; End of function ObjSpring_Main_Diag

; ------------------------------------------------------------------------------

ObjSpring_Anim_Diag:
	lea	Ani_Spring,a1
	bra.w	AnimateObject
; End of function ObjSpring_Anim_Diag

; ------------------------------------------------------------------------------

ObjSpring_Reset_Diag:
	move.b	#1,obj.prev_anim_id(a0)
	subq.b	#4,obj.routine(a0)
	move.b	#0,obj.sprite_frame(a0)
	rts
; End of function ObjSpring_Reset_Diag

; ------------------------------------------------------------------------------

Ani_S1Spring:
	include	"Level/_Objects/Spring/Data/Animations (Sonic 1).asm"
	even
MapSpr_S1Spring:
	include	"Level/_Objects/Spring/Data/Mappings (Sonic 1).asm"
	even
Ani_Spring:
	include	"Level/_Objects/Spring/Data/Animations.asm"
	even
	include	"Level/_Objects/Spring/Data/Mappings.asm"
	even
Ani_MovingSpring:
	include	"Level/_Objects/Spring/Data/Animations (Wheel).asm"
	even
MapSpr_MovingSpring:
	include	"Level/_Objects/Spring/Data/Mappings (Wheel).asm"
	even

; ------------------------------------------------------------------------------
