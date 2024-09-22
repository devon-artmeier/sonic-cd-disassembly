; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Mosqui object
; ------------------------------------------------------------------------------

ObjMosqui:
	jsr	DestroyOnGoodFuture
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjMosqui_Index(pc,d0.w),d0
	jsr	ObjMosqui_Index(pc,d0.w)
	jsr	DrawObject
	move.w	obj.var_2A(a0),d0
	jmp	CheckObjDespawn2
; End of function ObjMosqui

; ------------------------------------------------------------------------------
ObjMosqui_Index:dc.w	ObjMosqui_Init-ObjMosqui_Index
	dc.w	ObjMosqui_Main-ObjMosqui_Index
	dc.w	ObjMosqui_Animate-ObjMosqui_Index
	dc.w	ObjMosqui_Dive-ObjMosqui_Index
	dc.w	ObjMosqui_Wait-ObjMosqui_Index
; ------------------------------------------------------------------------------

ObjMosqui_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#3,obj.sprite_layer(a0)
	move.b	#$10,obj.collide_width(a0)
	move.b	#$10,obj.width(a0)
	move.b	#$10,obj.collide_height(a0)
	move.b	#$2B,obj.collide_type(a0)
	move.w	obj.x(a0),obj.var_2A(a0)
	moveq	#0,d0
	jsr	SetObjectTileID
	tst.b	obj.subtype(a0)
	bne.s	.Damaged
	lea	MapSpr_Mosqui1(pc),a1
	lea	Ani_Mosqui1(pc),a2
	move.l	#-$10000,d0
	bra.s	.SetInfo

; ------------------------------------------------------------------------------

.Damaged:
	lea	MapSpr_Mosqui2(pc),a1
	lea	Ani_Mosqui2(pc),a2
	move.l	#-$8000,d0

.SetInfo:
	move.l	a1,obj.sprites(a0)
	move.l	a2,obj.var_30(a0)
	move.l	d0,obj.var_2C(a0)
; End of function ObjMosqui_Init

; ------------------------------------------------------------------------------

ObjMosqui_Main:
	tst.w	debug_mode
	bne.s	.SkipRange
	lea	player_object,a1
	bsr.s	ObjMosqui_CheckInRange
	bcs.s	.StartDive

.SkipRange:
	move.l	obj.var_2C(a0),d0
	add.l	d0,obj.x(a0)
	move.w	obj.x(a0),d0
	sub.w	obj.var_2A(a0),d0
	bpl.s	.ChkTurn
	neg.w	d0

.ChkTurn:
	cmpi.w	#$80,d0
	blt.s	.Animate
	neg.l	obj.var_2C(a0)
	bchg	#0,obj.sprite_flags(a0)
	bchg	#0,obj.flags(a0)
	bra.s	.SkipRange

; ------------------------------------------------------------------------------

.Animate:
	movea.l	obj.var_30(a0),a1
	jmp	AnimateObject

; ------------------------------------------------------------------------------

.StartDive:
	addq.b	#2,obj.routine(a0)
	move.b	#1,obj.anim_id(a0)
	rts
; End of function ObjMosqui_Main

; ------------------------------------------------------------------------------

ObjMosqui_CheckInRange:
	move.w	obj.y(a1),d0
	sub.w	obj.y(a0),d0
	subi.w	#-$30,d0
	subi.w	#$70,d0
	bcc.s	.End
	move.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	move.w	d0,d1
	subi.w	#-$30,d1
	subi.w	#$60,d1

.End:
	rts
; End of function ObjMosqui_CheckInRange

; ------------------------------------------------------------------------------

ObjMosqui_Animate:
	movea.l	obj.var_30(a0),a1
	jmp	AnimateObject
; End of function ObjMosqui_Animate

; ------------------------------------------------------------------------------

ObjMosqui_Dive:
	addq.w	#6,obj.y(a0)
	jsr	ObjGetFloorDist
	cmpi.w	#-8,d1
	bgt.s	.End
	subi.w	#-8,d1
	add.w	d1,obj.y(a0)
	addq.b	#2,obj.routine(a0)
	tst.b	obj.sprite_flags(a0)
	bpl.s	.End
	move.w	#FM_A7,d0
	jsr	PlayFMSound

.End:
	rts
; End of function ObjMosqui_Dive

; ------------------------------------------------------------------------------

ObjMosqui_Wait:
	tst.b	obj.sprite_flags(a0)
	bmi.s	.End
	jmp	DespawnObject

; ------------------------------------------------------------------------------

.End:
	rts
; End of function ObjMosqui_Wait

; ------------------------------------------------------------------------------
Ani_Mosqui1:
	include	"Level/Palmtree Panic/Objects/Mosqui/Data/Animations (Normal).asm"
	even
Ani_Mosqui2:
	include	"Level/Palmtree Panic/Objects/Mosqui/Data/Animations (Damaged).asm"
	even
MapSpr_Mosqui1:
	include	"Level/Palmtree Panic/Objects/Mosqui/Data/Mappings (Normal).asm"
	even
MapSpr_Mosqui2:
	include	"Level/Palmtree Panic/Objects/Mosqui/Data/Mappings (Damaged).asm"
	even

; ------------------------------------------------------------------------------
