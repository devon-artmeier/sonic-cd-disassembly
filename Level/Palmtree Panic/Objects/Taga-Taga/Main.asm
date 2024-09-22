; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Taga-Taga object
; ------------------------------------------------------------------------------

ObjTagaTaga:
	jsr	DestroyOnGoodFuture
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjTagaTaga_Index(pc,d0.w),d0
	jsr	ObjTagaTaga_Index(pc,d0.w)
	jsr	DrawObject
	move.w	obj.var_2A(a0),d0
	jmp	CheckObjDespawn2
; End of function ObjTagaTaga

; ------------------------------------------------------------------------------
ObjTagaTaga_Index:dc.w	ObTagaTaga_Init-ObjTagaTaga_Index
	dc.w	ObjTagaTaga_Init2-ObjTagaTaga_Index
	dc.w	ObjTagaTaga_Animate-ObjTagaTaga_Index
	dc.w	ObjTagaTaga_Jump-ObjTagaTaga_Index
	dc.w	ObjTagaTaga_Main-ObjTagaTaga_Index
; ------------------------------------------------------------------------------

ObTagaTaga_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#3,obj.sprite_layer(a0)
	move.b	#$10,obj.collide_width(a0)
	move.b	#$10,obj.width(a0)
	move.b	#$16,obj.collide_height(a0)
	move.w	obj.x(a0),obj.var_2A(a0)
	move.w	obj.y(a0),obj.var_2C(a0)
	moveq	#3,d0
	jsr	SetObjectTileID
	tst.b	obj.subtype(a0)
	bne.s	.Damaged
	lea	MapSpr_TagaTaga1(pc),a1
	lea	Ani_TagaTaga1(pc),a2
	move.l	#-$3C000,d0
	move.l	#$1000,d1
	bra.s	.SetInfo

; ------------------------------------------------------------------------------

.Damaged:
	lea	MapSpr_TagaTaga2(pc),a1
	lea	Ani_TagaTaga2(pc),a2
	move.l	#-$30000,d0
	move.l	#$1000,d1

.SetInfo:
	move.l	a1,obj.sprites(a0)
	move.l	a2,obj.var_3C(a0)
	move.l	d0,obj.var_30(a0)
	move.l	d1,obj.var_38(a0)
; End of function ObTagaTaga_Init

; ------------------------------------------------------------------------------

ObjTagaTaga_Init2:
	addq.b	#2,obj.routine(a0)
	move.w	#$FF,obj.anim_id(a0)
	move.b	#0,obj.collide_type(a0)
	move.l	obj.var_2C(a0),obj.y(a0)
; End of function ObjTagaTaga_Init2

; ------------------------------------------------------------------------------

ObjTagaTaga_Animate:
	movea.l	obj.var_3C(a0),a1
	jmp	AnimateObject
; End of function ObjTagaTaga_Animate

; ------------------------------------------------------------------------------

ObjTagaTaga_Jump:
	addq.b	#2,obj.routine(a0)
	move.w	#$1FF,obj.anim_id(a0)
	move.b	#$2E,obj.collide_type(a0)
	move.l	obj.var_2C(a0),obj.y(a0)
	move.l	obj.var_30(a0),obj.var_34(a0)
	tst.b	obj.sprite_flags(a0)
	bpl.s	ObjTagaTaga_Main
	move.w	#FM_A2,d0
	jsr	PlayFMSound
; End of function ObjTagaTaga_Jump

; ------------------------------------------------------------------------------

ObjTagaTaga_Main:
	move.l	obj.var_34(a0),d0
	add.l	d0,obj.y(a0)
	move.l	obj.var_38(a0),d0
	add.l	d0,obj.var_34(a0)
	move.w	obj.y(a0),d0
	cmp.w	obj.var_2C(a0),d0
	ble.s	ObjTagaTaga_Dobj.anim_id
	move.b	#2,obj.routine(a0)
	tst.b	obj.sprite_flags(a0)
	bpl.s	ObjTagaTaga_Dobj.anim_id
	move.w	#FM_A2,d0
	jsr	PlayFMSound

ObjTagaTaga_Dobj.anim_id:
	movea.l	obj.var_3C(a0),a1
	jmp	AnimateObject
; End of function ObjTagaTaga_Main

; ------------------------------------------------------------------------------
Ani_TagaTaga1:
	include	"Level/Palmtree Panic/Objects/Taga-Taga/Data/Animations (Normal).asm"
	even
Ani_TagaTaga2:
	include	"Level/Palmtree Panic/Objects/Taga-Taga/Data/Animations (Damaged).asm"
	even
	include	"Level/Palmtree Panic/Objects/Taga-Taga/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
