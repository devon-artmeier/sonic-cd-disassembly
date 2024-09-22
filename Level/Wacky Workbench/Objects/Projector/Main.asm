; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Projector object
; ------------------------------------------------------------------------------

ObjProjector:
	tst.b	obj.subtype(a0)
	bne.w	ObjMetalSonicHologram
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjProjector_Index(pc,d0.w),d0
	jsr	ObjProjector_Index(pc,d0.w)
	jsr	DrawObject
	cmpi.b	#2,obj.routine(a0)
	bgt.s	.End
	jsr	CheckObjDespawn
	tst.b	(a0)
	bne.s	.End
	move.w	#4,d0
	jmp	LoadPLC

; ------------------------------------------------------------------------------

.End:
	rts
; End of function ObjProjector

; ------------------------------------------------------------------------------
ObjProjector_Index:dc.w	ObjProjector_Init-ObjProjector_Index
	dc.w	ObjProjector_Main-ObjProjector_Index
	dc.w	ObjProjector_StartExploding-ObjProjector_Index
	dc.w	ObjProjector_Exploding-ObjProjector_Index
	dc.w	ObjProjector_Destroyed-ObjProjector_Index

; ------------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjProjector

ObjProjector_Destroy:
	jmp	DeleteObject
; END OF FUNCTION CHUNK	FOR ObjProjector
; ------------------------------------------------------------------------------

ObjProjector_Init:
	tst.b	projector_destroyed
	bne.s	ObjProjector_Destroy
	move.w	#5,d0
	jsr	LoadPLC
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#4,obj.sprite_layer(a0)
	move.b	#$C,obj.collide_width(a0)
	move.b	#$C,obj.width(a0)
	move.b	#$C,obj.collide_height(a0)
	move.b	#$FB,obj.collide_type(a0)
	move.l	#MapSpr_Projector,obj.sprites(a0)
	move.l	#ObjProjector_ExplosionLocs,obj.var_2C(a0)
	move.w	#$4E8,obj.sprite_tile(a0)
	tst.b	act
	beq.s	.SpawnSubObjs
	move.w	#$300,obj.sprite_tile(a0)

.SpawnSubObjs:
	jsr	FindObjSlot
	bne.w	ObjProjector_Destroy
	move.b	obj.id(a0),obj.id(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	subi.w	#$15,obj.x(a1)
	subq.w	#7,obj.y(a1)
	move.b	#$FF,obj.subtype(a1)
	move.w	a0,obj.var_3E(a1)
	jsr	FindObjSlot
	bne.w	ObjProjector_Destroy
	move.b	obj.id(a0),obj.id(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	subi.w	#$48,obj.x(a1)
	subq.w	#4,obj.y(a1)
	move.b	#1,obj.subtype(a1)
	move.w	a0,obj.var_3E(a1)
	jsr	FindObjSlot
	bne.w	ObjProjector_Destroy
	move.b	#$29,obj.id(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	subi.w	#$48,obj.x(a1)
	addi.w	#-$18,obj.y(a1)
	move.b	#$80,obj.subtype(a1)
	move.w	a0,obj.var_3E(a1)
	jsr	FindObjSlot
	bne.w	ObjProjector_Destroy
	move.b	#$29,obj.id(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	subi.w	#$54,obj.x(a1)
	addq.w	#7,obj.y(a1)
	move.b	#$81,obj.subtype(a1)
	move.w	a0,obj.var_3E(a1)

ObjProjector_Main:
	tst.b	obj.collide_status(a0)
	beq.s	.Solid
	clr.w	obj.collide_type(a0)
	addq.b	#2,obj.routine(a0)

.Solid:
	lea	player_object,a1
	jmp	SolidObject
; End of function ObjProjector_Init

; ------------------------------------------------------------------------------

ObjProjector_StartExploding:
	addq.b	#2,obj.routine(a0)
	move.b	#1,obj.sprite_frame(a0)
	st	obj.var_3F(a0)
	move.w	#4,d0
	jsr	LoadPLC
	lea	player_object,a1
	jsr	SolidObject
	beq.s	ObjProjector_Exploding
	jsr	GetOffObject

ObjProjector_Exploding:
	movea.l	obj.var_2C(a0),a6
	move.b	(a6)+,d0
	bmi.s	.Finished
	addq.b	#1,obj.var_2A(a0)
	cmp.b	obj.var_2A(a0),d0
	bne.s	.End
	move.b	(a6)+,d5
	move.b	(a6)+,d6
	move.l	a6,obj.var_2C(a0)
	ext.w	d5
	ext.w	d6
	jsr	FindObjSlot
	bne.s	.End
	move.b	#$18,obj.id(a1)
	move.b	#1,oExplodeBadnik(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	add.w	d5,obj.x(a1)
	add.w	d6,obj.y(a1)
	move.w	#FM_EXPLODE,d0
	jsr	PlayFMSound

.End:
	rts

; ------------------------------------------------------------------------------

.Finished:
	addq.b	#2,obj.routine(a0)
	move.w	#60,obj.var_2A(a0)
	rts
; End of function ObjProjector_StartExploding

; ------------------------------------------------------------------------------

ObjProjector_Destroyed:
	subq.w	#1,obj.var_2A(a0)
	bne.s	locret_20E6E6
	st	projector_destroyed
	bra.w	ObjProjector_Destroy

; ------------------------------------------------------------------------------

locret_20E6E6:
	rts
; End of function ObjProjector_Destroyed

; ------------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjProjector

ObjMetalSonicHologram:
	movea.w	obj.var_3E(a0),a1
	cmpi.b	#$2F,obj.id(a1)
	bne.w	ObjProjector_Destroy
	tst.b	obj.var_3F(a1)
	bne.w	ObjProjector_Destroy
	tst.b	obj.routine(a0)
	bne.s	.Animate
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#4,obj.sprite_layer(a0)
	move.l	#MapSpr_Projector,obj.sprites(a0)
	move.w	#$4E8,obj.sprite_tile(a0)
	tst.b	act
	beq.s	.SetProperties
	move.w	#$300,obj.sprite_tile(a0)

.SetProperties:
	moveq	#8,d0
	moveq	#4,d1
	moveq	#0,d2
	tst.b	obj.subtype(a0)
	bmi.s	.GotSize
	moveq	#$14,d0
	moveq	#$18,d1
	moveq	#1,d2

.GotSize:
	move.b	d0,obj.collide_width(a0)
	move.b	d0,obj.width(a0)
	move.b	d1,obj.collide_height(a0)
	move.b	d2,obj.anim_id(a0)

.Animate:
	lea	Ani_MetalSonicHologram(pc),a1
	jsr	AnimateObject
	jmp	DrawObject
; END OF FUNCTION CHUNK	FOR ObjProjector

; ------------------------------------------------------------------------------

Ani_MetalSonicHologram:
	include	"Level/Wacky Workbench/Objects/Projector/Data/Animations.asm"
	even
MapSpr_Projector:
	include	"Level/Wacky Workbench/Objects/Projector/Data/Mappings.asm"
	even
ObjProjector_ExplosionLocs:dc.b	1, 0, 0
	dc.b	5,	$EE, $F6
	dc.b	$A, $F6, $A
	dc.b	$F, 0, $EE
	dc.b	$14, $F6, $12
	dc.b	$16, 8, $17
	dc.b	$19, $D, $F6
	dc.b	$1C, $FD, $E7
	dc.b	$1E, $A, $14
	dc.b	$20, $F6, 2
	dc.b	$23, $D, $F6
	dc.b	$28, $F6, $A
	dc.b	$FF
	dc.b	0

; ------------------------------------------------------------------------------
