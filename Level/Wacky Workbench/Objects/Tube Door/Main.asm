; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Tube door object
; ------------------------------------------------------------------------------

oTDoorTime	EQU	obj.var_3A
oTDoorClose	EQU	obj.var_3C

; ------------------------------------------------------------------------------

ObjTubeDoor:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjTubeDoor_Init-.Index
	dc.w	ObjTubeDoor_Main-.Index
	dc.w	ObjTubeDoor_Open-.Index
	dc.w	ObjTubeDoor_CheckClose-.Index
	dc.w	ObjTubeDoor_Close-.Index

; ------------------------------------------------------------------------------

ObjTubeDoor_Solid:
	tst.b	obj.sprite_frame(a0)
	beq.s	.Solid
	rts

.Solid:
	lea	player_object,a1
	move.w	obj.x(a0),d3
	move.w	obj.y(a0),d4
	jmp	SolidObject

; ------------------------------------------------------------------------------

ObjTubeDoor_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#3,obj.sprite_layer(a0)
	move.w	#$4410,obj.sprite_tile(a0)
	move.l	#MapSpr_TubeDoor,obj.sprites(a0)
	move.b	#4,obj.width(a0)
	move.b	#32,obj.collide_height(a0)
	
	tst.b	obj.subtype(a0)
	beq.s	ObjTubeDoor_Main
	bset	#0,obj.sprite_flags(a0)
	bset	#0,obj.flags(a0)

; ------------------------------------------------------------------------------

ObjTubeDoor_Main:
	lea	player_object,a1
	move.w	obj.y(a0),d0
	sub.w	obj.y(a1),d0
	bcc.s	.CheckYDist
	neg.w	d0

.CheckYDist:
	cmpi.w	#64,d0
	bcc.s	.Solid
	
	move.w	obj.x(a0),d1
	move.w	obj.x(a1),d0
	tst.b	obj.subtype(a0)
	bne.s	.CheckXDist
	move.w	obj.x(a0),d0
	move.w	obj.x(a1),d1

.CheckXDist:
	sub.w	d1,d0
	bcs.s	.Solid
	cmpi.w	#64,d0
	bcc.s	.Solid

.Open:
	clr.w	oTDoorTime(a0)
	addq.b	#2,obj.routine(a0)
	btst	#7,obj.sprite_flags(a0)
	beq.s	.Solid
	move.w	#FM_A4,d0
	jsr	PlayFMSound

.Solid:
	bra.w	ObjTubeDoor_Solid

; ------------------------------------------------------------------------------

ObjTubeDoor_Open:
	clr.b	oTDoorClose(a0)
	jsr	ObjTubeDoor_Move(pc)
	cmpi.b	#3,obj.sprite_frame(a0)
	bne.s	.Solid
	addq.b	#2,obj.routine(a0)

.Solid:
	bra.w	ObjTubeDoor_Solid

; ------------------------------------------------------------------------------

ObjTubeDoor_CheckClose:
	lea	player_object,a1
	move.w	obj.y(a0),d0
	sub.w	obj.y(a1),d0
	bcc.s	.CheckYDist
	neg.w	d0

.CheckYDist:
	cmpi.w	#64,d0
	bcc.s	.Solid
	
	move.w	obj.x(a1),d1
	move.w	obj.x(a0),d0
	tst.b	obj.subtype(a0)
	bne.s	.CheckXDist
	move.w	obj.x(a1),d0
	move.w	obj.x(a0),d1

.CheckXDist:
	sub.w	d1,d0
	bcs.s	.Solid
	cmpi.w	#64,d0
	bcs.s	.Solid

.Close:
	clr.w	oTDoorTime(a0)
	addq.b	#2,obj.routine(a0)
	move.w	#FM_A4,d0
	jsr	PlayFMSound

.Solid:
	bra.w	ObjTubeDoor_Solid

; ------------------------------------------------------------------------------

ObjTubeDoor_Close:
	move.b	#1,oTDoorClose(a0)
	jsr	ObjTubeDoor_Move(pc)
	tst.b	obj.sprite_frame(a0)
	bne.s	.Solid
	move.b	#2,obj.routine(a0)

.Solid:
	bra.w	ObjTubeDoor_Solid

; ------------------------------------------------------------------------------

ObjTubeDoor_Move:
	addi.b	#$40,oTDoorTime(a0)
	bcs.s	.Move
	rts

.Move:
	tst.b	oTDoorClose(a0)
	bne.s	.Close
	addq.b	#1,obj.sprite_frame(a0)
	rts

.Close:
	subq.b	#1,obj.sprite_frame(a0)
	bcc.s	.End
	clr.b	obj.sprite_frame(a0)

.End:
	rts

; ------------------------------------------------------------------------------

MapSpr_TubeDoor:
	include	"Level/Wacky Workbench/Objects/Tube Door/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
