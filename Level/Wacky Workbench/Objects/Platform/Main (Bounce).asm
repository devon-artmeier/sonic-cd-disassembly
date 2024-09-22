; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Bouncing platform object
; ------------------------------------------------------------------------------

oBPtfmYRad	EQU	obj.var_2E
oBPftmYVel	EQU	obj.var_30
oBPtfmGrav	EQU	obj.var_3E

; ------------------------------------------------------------------------------

ObjBouncePlatform:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjBouncePlatform_Init-.Index
	dc.w	ObjBouncePlatform_Main-.Index
	dc.w	ObjBouncePlatform_Bounced-.Index
	dc.w	ObjBouncePlatform_Landed-.Index

; ------------------------------------------------------------------------------

ObjBouncePlatform_JmpToSolid:
	jmp	ObjBouncePlatform_Solid

; ------------------------------------------------------------------------------

ObjBouncePlatform_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#3,obj.sprite_layer(a0)
	move.w	#$43E8,obj.sprite_tile(a0)
	move.l	#MapSpr_BouncePlatform,obj.sprites(a0)
	move.b	#16,obj.collide_height(a0)
	move.b	#32,obj.width(a0)

; ------------------------------------------------------------------------------

ObjBouncePlatform_Main:
	jsr	ObjBouncePlatform_CheckFloor(pc)
	bne.s	.NoBounce
	move.w	#-$600,obj.y_speed(a0)
	move.w	#$10,oBPtfmGrav(a0)
	addq.b	#2,obj.routine(a0)

.NoBounce:
	bra.w	ObjBouncePlatform_JmpToSolid

; ------------------------------------------------------------------------------

ObjBouncePlatform_Bounced:
	jsr	ObjBouncePlatform_Move(pc)
	jsr	ObjGetCeilDist
	tst.w	d1
	bpl.s	.CheckFloor
	clr.w	obj.y_speed(a0)

.CheckFloor:
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.Solid
	jsr	ObjBouncePlatform_CheckFloor(pc)
	bne.s	.Landed
	move.w	#-$600,obj.y_speed(a0)
	move.w	#$10,oBPtfmGrav(a0)
	btst	#7,obj.sprite_flags(a0)
	beq.s	.Solid
	move.w	#FM_B4,d0
	jsr	PlayFMSound
	bra.s	.Solid

.Landed:
	move.w	#-$180,obj.y_speed(a0)
	move.w	#$10,oBPtfmGrav(a0)
	addq.b	#2,obj.routine(a0)

.Solid:
	bra.w	ObjBouncePlatform_JmpToSolid

; ------------------------------------------------------------------------------

ObjBouncePlatform_Landed:
	jsr	ObjBouncePlatform_Move(pc)
	tst.w	obj.y_speed(a0)
	bmi.s	.Solid
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.Solid
	clr.w	obj.y_speed(a0)
	clr.w	oBPtfmGrav(a0)
	subq.b	#4,obj.routine(a0)

.Solid:
	bra.w	ObjBouncePlatform_JmpToSolid

; ------------------------------------------------------------------------------

ObjBouncePlatform_Move:
	move.w	obj.y_speed(a0),d0
	add.w	oBPtfmGrav(a0),d0
	bmi.s	.MoveY
	cmpi.w	#$600,d0
	bcs.s	.MoveY
	move.w	#$600,d0

.MoveY:
	move.w	d0,obj.y_speed(a0)
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,obj.y(a0)
	rts

; ------------------------------------------------------------------------------

ObjBouncePlatform_CheckFloor:
	cmpi.b	#2,time_zone
	bcc.s	.Bounce
	move.b	#$3C,d0
	tst.b	time_zone
	beq.s	.Check
	addi.b	#$1E,d0

.Check:
	cmp.b	palette_cycle_steps+3,d0
	beq.s	.NoBounce

.Bounce:
	moveq	#0,d0
	rts

.NoBounce:
	moveq	#-1,d0
	rts

; ------------------------------------------------------------------------------

MapSpr_BouncePlatform:
	include	"Level/Wacky Workbench/Objects/Platform/Data/Mappings (Bounce).asm"
	even

; ------------------------------------------------------------------------------

ObjBouncePlatform_Solid:
	lea	player_object,a1
	move.w	obj.y_speed(a1),d0
	bpl.s	.NotNeg
	neg.w	d0
	cmpi.w	#$600,d0
	bgt.w	.End

.NotNeg:
	tst.w	obj.y_speed(a0)
	beq.s	.NotMoving
	move.b	#4,oBPtfmYRad(a0)
	bra.s	.DoSolid

.NotMoving:
	move.b	#0,oBPtfmYRad(a0)

.DoSolid:
	move.b	oBPtfmYRad(a0),d0
	add.b	d0,obj.collide_height(a0)

	lea	player_object,a1
	bsr.s	.Solid

	move.b	oBPtfmYRad(a0),d0
	sub.b	d0,obj.collide_height(a0)
	rts

; ------------------------------------------------------------------------------

.Solid:
	move.w	obj.y_speed(a1),oBPftmYVel(a0)
	btst	#3,obj.flags(a1)
	beq.s	.CheckSolid
	btst	#1,obj.flags(a1)
	bne.s	.CheckSolid
	clr.w	obj.y_speed(a1)

.CheckSolid:
	jsr	SolidObject
	bne.s	.StoodOn
	move.w	oBPftmYVel(a0),obj.y_speed(a1)

.End:
	rts

.StoodOn:
	cmpi.b	#6,obj.routine(a1)
	bcc.s	.StopYVel

	move.l	obj.y(a0),obj.y(a1)
	move.b	obj.collide_height(a1),d0
	ext.w	d0
	addi.w	#$10,d0
	sub.w	d0,obj.y(a1)
	tst.w	obj.y_speed(a0)
	bge.s	.StopYVel
	move.w	obj.y_speed(a0),obj.y_speed(a1)
	rts

.StopYVel:
	clr.w	obj.y_speed(a1)
	rts

; ------------------------------------------------------------------------------
