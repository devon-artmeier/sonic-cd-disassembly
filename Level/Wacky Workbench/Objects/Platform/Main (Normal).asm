; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Platform object
; ------------------------------------------------------------------------------

oPtfmY		EQU	obj.var_32
oPtfmX		EQU	obj.var_36
oPtfm3A		EQU	obj.var_3A

; ------------------------------------------------------------------------------

ObjPlatform:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	move.w	oPtfmX(a0),d0
	jmp	CheckObjDespawn2

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjPlatform_Init-.Index
	dc.w	ObjPlatform_Main-.Index

; ------------------------------------------------------------------------------

ObjPlatform_Solid:
	lea	player_object,a1
	move.w	obj.x(a0),d3
	move.w	obj.y(a0),d4
	jmp	TopSolidObject

; ------------------------------------------------------------------------------

ObjPlatform_Init:
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#1,obj.sprite_layer(a0)
	move.w	#$436A,obj.sprite_tile(a0)
	move.l	#MapSpr_Platform,obj.sprites(a0)
	move.w	obj.x(a0),oPtfmX(a0)
	move.w	obj.y(a0),oPtfmY(a0)
	move.b	#12,obj.collide_height(a0)
	move.b	#24,obj.width(a0)
	addq.b	#2,obj.routine(a0)

; ------------------------------------------------------------------------------

ObjPlatform_Main:
	moveq	#0,d0
	move.b	obj.subtype(a0),d0
	add.w	d0,d0
	move.w	.MoveTypes(pc,d0.w),d0
	jmp	.MoveTypes(pc,d0.w)

; ------------------------------------------------------------------------------

.MoveTypes:
	dc.w	ObjPlatform_MoveX-.MoveTypes
	dc.w	ObjPlatform_MoveX2-.MoveTypes
	dc.w	ObjPlatform_MoveY-.MoveTypes
	dc.w	ObjPlatform_MoveY2-.MoveTypes

; ------------------------------------------------------------------------------

ObjPlatform_MoveY:
	bsr.w	ObjPlatform_GetOffset
	neg.w	d0
	add.w	oPtfmY(a0),d0
	move.w	d0,obj.y(a0)
	bra.w	ObjPlatform_Solid

; ------------------------------------------------------------------------------

ObjPlatform_MoveY2:
	bsr.w	ObjPlatform_GetOffset
	add.w	oPtfmY(a0),d0
	move.w	d0,obj.y(a0)
	bra.w	ObjPlatform_Solid

; ------------------------------------------------------------------------------

ObjPlatform_MoveX:
	move.l	obj.x(a0),-(sp)
	bsr.w	ObjPlatform_GetOffset
	add.w	oPtfmX(a0),d0
	move.w	d0,obj.x(a0)

	move.l	obj.x(a0),d0
	sub.l	(sp)+,d0
	lsr.l	#8,d0
	move.w	d0,obj.x_speed(a0)
	bra.w	ObjPlatform_Solid

; ------------------------------------------------------------------------------

ObjPlatform_MoveX2:
	move.l	obj.x(a0),-(sp)
	bsr.w	ObjPlatform_GetOffset
	neg.w	d0
	add.w	oPtfmX(a0),d0
	move.w	d0,obj.x(a0)

	move.l	obj.x(a0),d0
	sub.l	(sp)+,d0
	lsr.l	#8,d0
	move.w	d0,obj.x_speed(a0)
	bra.w	ObjPlatform_Solid

; ------------------------------------------------------------------------------

ObjPlatform_GetOffset:
	move.w	stage_frames,d0
	andi.w	#$FF,d0
	jsr	CalcSine
	add.w	d0,d0
	add.w	d0,d0
	asr.w	#4,d0

	addq.b	#1,oPtfm3A(a0)
	rts

; ------------------------------------------------------------------------------

MapSpr_Platform:
	include	"Level/Wacky Workbench/Objects/Platform/Data/Mappings (Normal).asm"
	even

; ------------------------------------------------------------------------------
