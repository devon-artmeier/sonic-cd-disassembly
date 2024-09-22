; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Anton object
; ------------------------------------------------------------------------------

ObjAnton:
	jsr	DestroyOnGoodFuture
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjAnton_Index(pc,d0.w),d0
	jsr	ObjAnton_Index(pc,d0.w)
	jsr	DrawObject
	move.w	obj.var_2E(a0),d0
	jmp	CheckObjDespawn2
; End of function ObjAnton

; ------------------------------------------------------------------------------
ObjAnton_Index:	dc.w	ObjAnton_Init-ObjAnton_Index
	dc.w	ObjAnton_Place-ObjAnton_Index
	dc.w	ObjAnton_Main-ObjAnton_Index
; ------------------------------------------------------------------------------

ObjAnton_Init:
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#4,obj.sprite_layer(a0)
	move.l	#MapSpr_Anton,obj.sprites(a0)
	move.b	#$18,obj.collide_width(a0)
	move.b	#$18,obj.width(a0)
	move.b	#$13,obj.collide_height(a0)
	move.b	#$29,obj.collide_type(a0)
	move.w	obj.x(a0),obj.var_2E(a0)
	moveq	#2,d0
	jsr	SetObjectTileID
	tst.b	obj.subtype(a0)
	bne.s	.Damaged
	move.l	#-$10000,d0
	moveq	#0,d1
	bra.s	.SetInfo

; ------------------------------------------------------------------------------

.Damaged:
	move.l	#-$8000,d0
	moveq	#1,d1

.SetInfo:
	move.l	d0,obj.var_2A(a0)
	move.b	d1,obj.anim_id(a0)
; End of function ObjAnton_Init

; ------------------------------------------------------------------------------

ObjAnton_Place:
	move.l	#$10000,d0
	add.l	d0,obj.y(a0)
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.End
	addq.b	#2,obj.routine(a0)

.End:
	rts
; End of function ObjAnton_Place

; ------------------------------------------------------------------------------

ObjAnton_Main:
	move.l	obj.var_2A(a0),d0
	add.l	d0,obj.x(a0)
	move.w	obj.x(a0),d0
	sub.w	obj.var_2E(a0),d0
	bpl.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#$80,d0
	bge.s	.TurnAround
	jsr	ObjGetFloorDist
	cmpi.w	#-7,d1
	blt.s	.TurnAround
	cmpi.w	#7,d1
	bgt.s	.TurnAround
	add.w	d1,obj.y(a0)
	lea	Ani_Anton(pc),a1
	jmp	AnimateObject

; ------------------------------------------------------------------------------

.TurnAround:
	neg.l	obj.var_2A(a0)
	bchg	#0,obj.sprite_flags(a0)
	bchg	#0,obj.flags(a0)
	bra.s	ObjAnton_Main
; End of function ObjAnton_Main

; ------------------------------------------------------------------------------
Ani_Anton:
	include	"Level/Palmtree Panic/Objects/Anton/Data/Animations.asm"
	even
MapSpr_Anton:
	include	"Level/Palmtree Panic/Objects/Anton/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
