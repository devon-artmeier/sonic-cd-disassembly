; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Pata-Bata object
; ------------------------------------------------------------------------------

ObjPataBata:
	jsr	DestroyOnGoodFuture
	tst.b	obj.routine(a0)
	bne.w	ObjPataBata_Main
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#3,obj.sprite_layer(a0)
	move.b	#$2A,obj.collide_type(a0)
	move.b	#$10,obj.collide_width(a0)
	move.b	#$10,obj.width(a0)
	move.b	#$10,obj.collide_height(a0)
	move.w	obj.x(a0),obj.var_2A(a0)
	move.w	obj.y(a0),obj.var_2C(a0)
	move.w	#$8000,obj.var_2E(a0)
	moveq	#1,d0
	jsr	SetObjectTileID
	tst.b	obj.subtype(a0)
	bne.s	.Damaged
	move.l	#-$8000,d0
	move.w	#-$200,d1
	moveq	#3,d2
	moveq	#0,d3
	lea	MapSpr_PataBata1(pc),a1
	bra.s	.SetInfo

; ------------------------------------------------------------------------------

.Damaged:
	move.l	#-$4000,d0
	move.w	#-$100,d1
	moveq	#4,d2
	moveq	#1,d3
	lea	MapSpr_PataBata2(pc),a1

.SetInfo:
	move.l	d0,obj.var_30(a0)
	move.w	d1,obj.var_36(a0)
	move.w	d2,obj.var_38(a0)
	move.b	d3,obj.anim_id(a0)
	move.l	a1,obj.sprites(a0)

ObjPataBata_Main:
	move.l	obj.var_30(a0),d0
	add.l	d0,obj.x(a0)
	move.w	obj.x(a0),d0
	sub.w	obj.var_2A(a0),d0
	bpl.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#$80,d0
	blt.s	.NoFlip
	neg.l	obj.var_30(a0)
	move.l	obj.var_30(a0),d0
	add.l	d0,obj.x(a0)
	bchg	#0,obj.sprite_flags(a0)
	bchg	#0,obj.flags(a0)
	clr.w	obj.var_34(a0)

.NoFlip:
	move.w	obj.var_36(a0),d0
	add.w	d0,obj.var_34(a0)
	move.b	obj.var_34(a0),d0
	jsr	CalcSine
	swap	d0
	move.w	obj.var_38(a0),d1
	asr.l	d1,d0
	add.l	obj.var_2C(a0),d0
	move.l	d0,obj.y(a0)
	lea	Ani_PataBata(pc),a1
	jsr	AnimateObject
	jsr	DrawObject
	move.w	obj.var_2A(a0),d0
	jmp	CheckObjDespawn2
; End of function ObjPataBata

; ------------------------------------------------------------------------------
Ani_PataBata:
	include	"Level/Palmtree Panic/Objects/Pata-Bata/Data/Animations.asm"
	even
MapSpr_PataBata1:
	include	"Level/Palmtree Panic/Objects/Pata-Bata/Data/Mappings (Normal).asm"
	even
MapSpr_PataBata2:
	include	"Level/Palmtree Panic/Objects/Pata-Bata/Data/Mappings (Damaged).asm"
	even

; ------------------------------------------------------------------------------
