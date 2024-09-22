; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Piston object
; ------------------------------------------------------------------------------

oPistonY	EQU	obj.var_32
oPistonParent	EQU	obj.var_34
oPistonX	EQU	obj.var_36
oPistonTime	EQU	obj.var_3A
oPistonOff	EQU	obj.var_3B
oPistonDir	EQU	obj.var_3C

; ------------------------------------------------------------------------------

ObjPiston:
	tst.b	obj.subtype(a0)
	bmi.w	ObjPiston_SolidSide

	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjPiston_Init-.Index
	dc.w	ObjPiston_Main-.Index

; ------------------------------------------------------------------------------

ObjPiston_Solid:
	lea	player_object,a1
	jmp	TopSolidObject

; ------------------------------------------------------------------------------

ObjPiston_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.w	#$340,obj.sprite_tile(a0)
	move.l	#MapSpr_Piston,obj.sprites(a0)
	move.b	#40,obj.collide_height(a0)
	move.b	#32,obj.width(a0)
	move.w	obj.x(a0),oPistonX(a0)
	move.w	obj.y(a0),oPistonY(a0)

	jsr	FindObjSlot
	bne.s	.RightSolid
	move.w	#-32,d0
	bsr.w	ObjPiston_SetupSolidSide

.RightSolid:
	jsr	FindObjSlot
	bne.s	ObjPiston_Main
	move.w	#32,d0
	bsr.w	ObjPiston_SetupSolidSide

; ------------------------------------------------------------------------------

ObjPiston_Main:
	jsr	ObjPiston_Move(pc)

	moveq	#0,d0
	move.b	oPistonOff(a0),d0
	neg.w	d0
	add.w	oPistonY(a0),d0
	move.w	d0,obj.y(a0)

	tst.b	oPistonDir(a0)
	beq.s	.CheckSolid
	tst.b	oPistonTime(a0)
	beq.s	.Solid

.CheckSolid:
	cmpi.b	#$21,oPistonOff(a0)
	bcs.s	.Solid
	lea	player_object,a1
	jmp	GetOffObject

.Solid:
	jmp	ObjPiston_Solid(pc)

; ------------------------------------------------------------------------------

ObjPiston_Move:
	tst.b	oPistonTime(a0)
	beq.s	.Moving
	subq.b	#1,oPistonTime(a0)
	bne.s	.End

.Moving:
	tst.b	oPistonDir(a0)
	beq.s	.MovingUp

.MovingDown:
	subq.b	#1,oPistonOff(a0)
	bcc.s	.End
	clr.b	oPistonOff(a0)
	clr.b	oPistonDir(a0)
	move.b	#60,oPistonTime(a0)
	rts

; ------------------------------------------------------------------------------

.MovingUp:
	addq.b	#8,oPistonOff(a0)
	cmpi.b	#80,oPistonOff(a0)
	bcs.s	.End
	move.b	#80,oPistonOff(a0)
	move.b	#1,oPistonDir(a0)
	move.b	#60,oPistonTime(a0)

.End:
	rts

; ------------------------------------------------------------------------------

ObjPiston_SetupSolidSide:
	move.b	#$20,obj.id(a1)
	move.w	a0,oPistonParent(a1)
	move.b	#-1,obj.subtype(a1)
	add.w	obj.x(a0),d0
	move.w	d0,obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	ori.b	#4,obj.sprite_flags(a1)
	move.l	#MapSpr_Piston,obj.sprites(a1)
	move.b	#40,obj.collide_height(a1)
	move.b	#1,obj.sprite_frame(a1)
	rts

; ------------------------------------------------------------------------------

ObjPiston_SolidSide:
	movea.w	oPistonParent(a0),a1
	cmpi.b	#$20,obj.id(a1)
	bne.s	.Delete
	
	move.w	obj.y(a1),obj.y(a0)
	lea	player_object,a1
	jsr	SolidObject
	jmp	DrawObject

.Delete:
	jmp	DeleteObject

; ------------------------------------------------------------------------------

MapSpr_Piston:
	include	"Level/Wacky Workbench/Objects/Piston/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
