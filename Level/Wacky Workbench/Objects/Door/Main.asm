; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Door object
; ------------------------------------------------------------------------------

oDoorSwitch	EQU	obj.var_30
oDoorY		EQU	obj.var_32
oDoorPlayerX	EQU	obj.var_38
oDoorOff	EQU	obj.var_3A
oDoorDir	EQU	obj.var_3C
oDoorPlayerY	EQU	obj.var_3E

; ------------------------------------------------------------------------------

ObjDoor:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjDoor_Init-.Index
	dc.w	ObjDoor_Main-.Index
	dc.w	ObjDoor_Opened-.Index
	dc.w	ObjDoor_Close-.Index

; ------------------------------------------------------------------------------

ObjDoor_Solid:
	lea	player_object,a1
	move.w	obj.x(a0),d3
	move.w	obj.y(a0),d4
	jmp	SolidObject

; ------------------------------------------------------------------------------

ObjDoor_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#3,obj.sprite_layer(a0)
	move.l	#MapSpr_Door,obj.sprites(a0)
	move.w	obj.y(a0),oDoorY(a0)
	move.w	#$3A0,obj.sprite_tile(a0)
	move.b	#32,obj.collide_height(a0)
	move.b	#8,obj.width(a0)
	
	cmpi.b	#2,act
	bne.s	.NotAct3
	move.w	#$330,obj.sprite_tile(a0)
	move.b	#32,obj.collide_height(a0)
	move.b	#32,obj.width(a0)
	move.b	#1,obj.sprite_frame(a0)

.NotAct3:
	move.b	obj.subtype(a0),d0
	andi.b	#$F,d0
	move.b	d0,oDoorSwitch(a0)
	move.b	#-1,oDoorDir(a0)

; ------------------------------------------------------------------------------

ObjDoor_Main:
	moveq	#0,d0
	move.b	oDoorSwitch(a0),d0
	lea	button_flags,a1
	btst	#7,(a1,d0.w)
	beq.s	.NoSwitch
	clr.b	oDoorDir(a0)

.NoSwitch:
	lea	player_object,a1
	move.w	obj.x(a1),oDoorPlayerX(a0)
	move.w	obj.y(a1),oDoorPlayerY(a0)
	bsr.w	ObjDoor_Move
	bsr.w	ObjDoor_Solid

	cmpi.b	#64,oDoorOff(a0)
	bne.s	.End
	addq.b	#2,obj.routine(a0)

.End:
	rts

; ------------------------------------------------------------------------------

ObjDoor_Opened:
	lea	player_object,a1
	move.w	obj.x(a0),d0
	sub.w	oDoorPlayerX(a0),d0
	bcc.s	.LeftSide

	move.b	obj.collide_width(a1),d0
	ext.w	d0
	add.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	bcc.s	.End
	neg.w	d0
	cmp.b	obj.width(a0),d0
	bcs.s	.End
	bra.s	.Close

.LeftSide:
	move.b	obj.collide_width(a1),d0
	neg.b	d0
	ext.w	d0
	add.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	bcs.s	.End
	cmp.b	obj.width(a0),d0
	bcs.s	.End

.Close:
	addq.b	#2,obj.routine(a0)

.End:
	rts

; ------------------------------------------------------------------------------

ObjDoor_Close:
	st	oDoorDir(a0)
	bsr.w	ObjDoor_Move
	tst.b	oDoorOff(a0)
	bne.s	.NotClosed
	move.b	#2,obj.routine(a0)

.NotClosed:
	bra.w	ObjDoor_Solid

; ------------------------------------------------------------------------------

ObjDoor_Move:
	bsr.w	.MoveY
	moveq	#0,d0
	move.b	oDoorOff(a0),d0
	neg.w	d0
	add.w	oDoorY(a0),d0
	move.w	d0,obj.y(a0)
	rts

.MoveY:
	tst.b	oDoorDir(a0)
	beq.s	.Open

.Close:
	subq.b	#4,oDoorOff(a0)
	bcc.s	.End
	clr.b	oDoorOff(a0)
	bra.s	.End

.Open:
	addq.b	#4,oDoorOff(a0)
	move.b	oDoorOff(a0),d0
	cmpi.b	#64,d0
	bcs.s	.End
	move.b	#64,oDoorOff(a0)

.End:
	rts

; ------------------------------------------------------------------------------

MapSpr_Door:
	include	"Level/Wacky Workbench/Objects/Door/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
