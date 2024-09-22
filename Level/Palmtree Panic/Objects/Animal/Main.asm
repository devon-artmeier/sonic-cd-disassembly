; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Palmtree Panic animal object
; ------------------------------------------------------------------------------

ObjAnimal:
	jsr	CheckAnimalPrescence
	move.b	obj.subtype(a0),d0
	andi.b	#$7F,d0
	bne.w	ObjGroundAnimal

ObjFlyingAnimal:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjFlyingAnimal_Index(pc,d0.w),d0
	jmp	ObjFlyingAnimal_Index(pc,d0.w)

; ------------------------------------------------------------------------------
ObjFlyingAnimal_Index:
	dc.w	ObjFlyingAnimal_Init-ObjFlyingAnimal_Index
	dc.w	ObjFlyingAnimal_Flying-ObjFlyingAnimal_Index
	dc.w	ObjFlyingAnimal_Hologram-ObjFlyingAnimal_Index
; ------------------------------------------------------------------------------

ObjFlyingAnimal_Init:
	addq.b	#2,obj.routine(a0)
	move.b	#4,obj.sprite_flags(a0)
	move.l	#$8080408,obj.collide_height(a0)
	move.l	#MapSpr_FlyingAnimal,obj.sprites(a0)
	move.w	obj.x(a0),obj.var_2A(a0)
	move.w	obj.y(a0),obj.var_2C(a0)
	bsr.w	ObjAnimal_XFlip
	bsr.w	ObjAnimal_SetBaseTile
	tst.b	obj.subtype(a0)
	bmi.s	.Holographic
	move.b	#4,obj.sprite_layer(a0)
	ori.w	#$8000,obj.sprite_tile(a0)
	move.w	#$101,obj.var_2E(a0)
	rts

; ------------------------------------------------------------------------------

.Holographic:
	addq.b	#2,obj.routine(a0)
	move.b	#1,obj.anim_id(a0)
	move.b	#3,obj.sprite_layer(a0)
	rts
; End of function ObjFlyingAnimal_Init

; ------------------------------------------------------------------------------

ObjFlyingAnimal_Flying:
	moveq	#1,d2
	moveq	#1,d3
	bsr.w	ObjFlyingAnimal_Move
	move.b	obj.var_2E(a0),d0
	add.b	obj.var_2F(a0),d0
	move.b	d0,d1
	subq.b	#1,d1
	subi.b	#$7F,d1
	bcs.s	.NoFlip
	move.b	obj.var_2E(a0),d0
	neg.b	obj.var_2F(a0)
	bsr.w	ObjAnimal_XFlip

.NoFlip:
	move.b	d0,obj.var_2E(a0)
	lea	Ani_FlyingAnimal(pc),a1
	jsr	AnimateObject
	jsr	DrawObject
	move.w	obj.var_2A(a0),d0
	jmp	CheckObjDespawn2
; End of function ObjFlyingAnimal_Flying

; ------------------------------------------------------------------------------

ObjFlyingAnimal_Hologram:

; FUNCTION CHUNK AT 0020D17C SIZE 00000006 BYTES

	movea.w	obj.var_3E(a0),a1
	cmpi.b	#$2E,obj.id(a1)
	bne.w	ObjAnimal_Destroy
	tst.b	obj.var_3F(a1)
	bne.w	ObjAnimal_Destroy
	moveq	#3,d2
	moveq	#4,d3
	bsr.w	ObjFlyingAnimal_Move
	addq.b	#4,obj.var_2E(a0)
	move.b	obj.var_2E(a0),d0
	andi.b	#$7F,d0
	beq.w	ObjAnimal_XFlip
	lea	Ani_FlyingAnimal(pc),a1
	jsr	AnimateObject
	jmp	DrawObject
; End of function ObjFlyingAnimal_Hologram

; ------------------------------------------------------------------------------

ObjFlyingAnimal_Move:
	move.b	obj.var_2E(a0),d0
	jsr	CalcSine
	asr.w	d2,d1
	asr.w	d3,d0
	add.w	obj.var_2A(a0),d1
	add.w	obj.var_2C(a0),d0
	move.w	d1,obj.x(a0)
	move.w	d0,obj.y(a0)
	rts
; End of function ObjFlyingAnimal_Move

; ------------------------------------------------------------------------------

ObjGroundAnimal:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjGroundAnimal_Index(pc,d0.w),d0
	jmp	ObjGroundAnimal_Index(pc,d0.w)
; End of function ObjGroundAnimal

; ------------------------------------------------------------------------------
ObjGroundAnimal_Index:dc.w	ObjGroundAnimal_Init-ObjGroundAnimal_Index
	dc.w	ObjGroundAnimal_Main-ObjGroundAnimal_Index
	dc.w	ObjGroundAnimal_Hologram-ObjGroundAnimal_Index
; ------------------------------------------------------------------------------

ObjGroundAnimal_Init:
	addq.b	#2,obj.routine(a0)
	move.b	#4,obj.sprite_flags(a0)
	move.l	#$8080408,obj.collide_height(a0)
	move.l	#MapSpr_GroundAnimal,obj.sprites(a0)
	move.w	obj.x(a0),obj.var_2A(a0)
	bsr.w	ObjAnimal_SetBaseTile
	tst.b	obj.subtype(a0)
	bmi.s	.Holographic
	move.l	#$10000,obj.var_2C(a0)
	move.l	#-$40000,obj.var_30(a0)
	rts

; ------------------------------------------------------------------------------

.Holographic:
	move.b	#4,obj.routine(a0)
	bra.w	ObjAnimal_XFlip
; End of function ObjGroundAnimal_Init

; ------------------------------------------------------------------------------

ObjGroundAnimal_Main:
	move.l	obj.var_2C(a0),d0
	add.l	d0,obj.x(a0)
	move.l	obj.var_30(a0),d0
	add.l	d0,obj.y(a0)
	addi.l	#$2000,obj.var_30(a0)
	smi	d0
	addq.b	#1,d0
	move.b	d0,obj.sprite_frame(a0)
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.NoFlip
	add.w	d1,obj.y(a0)
	move.l	#-$40000,obj.var_30(a0)
	neg.l	obj.var_2C(a0)
	bsr.s	ObjAnimal_XFlip

.NoFlip:
	jsr	DrawObject
	jmp	CheckObjDespawn
; End of function ObjGroundAnimal_Main

; ------------------------------------------------------------------------------

ObjGroundAnimal_Hologram:
	movea.w	obj.var_3E(a0),a1
	cmpi.b	#$2E,obj.id(a1)
	bne.w	ObjAnimal_Destroy
	tst.b	obj.var_3F(a1)
	bne.w	ObjAnimal_Destroy
	lea	Ani_GroundAnimal(pc),a1
	jsr	AnimateObject
	jmp	DrawObject
; End of function ObjGroundAnimal_Hologram

; ------------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjFlyingAnimal_Hologram

ObjAnimal_Destroy:
	jmp	DeleteObject
; END OF FUNCTION CHUNK	FOR ObjFlyingAnimal_Hologram
; ------------------------------------------------------------------------------

ObjAnimal_XFlip:
	bchg	#0,obj.sprite_flags(a0)
	bchg	#0,obj.flags(a0)
	rts
; End of function ObjAnimal_XFlip

; ------------------------------------------------------------------------------

ObjAnimal_SetBaseTile:
	lea	ObjAnimal_BaseTileList(pc),a1
	moveq	#0,d0
	move.b	act,d0
	asl.w	#2,d0
	add.b	time_zone,d0
	add.w	d0,d0
	move.w	(a1,d0.w),obj.sprite_tile(a0)
	rts
; End of function ObjAnimal_SetBaseTile

; ------------------------------------------------------------------------------
Ani_FlyingAnimal:
	include	"Level/Palmtree Panic/Objects/Animal/Data/Animations (Flying).asm"
	even
Ani_GroundAnimal:
	include	"Level/Palmtree Panic/Objects/Animal/Data/Animations (Ground).asm"
	even
MapSpr_FlyingAnimal:
	include	"Level/Palmtree Panic/Objects/Animal/Data/Mappings (Flying).asm"
	even
MapSpr_GroundAnimal:
	include	"Level/Palmtree Panic/Objects/Animal/Data/Mappings (Ground).asm"
	even
ObjAnimal_BaseTileList:
	dc.w	$4F7
	dc.w	$388
	dc.w	$463
	dc.w	0
	dc.w	$4F7
	dc.w	$38F
	dc.w	$461
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$3CF
	
; ------------------------------------------------------------------------------
