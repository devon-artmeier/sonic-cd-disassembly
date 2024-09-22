; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Eggman statue object
; ------------------------------------------------------------------------------

oEggStatExplode	EQU	obj.var_2C
oEggStatTime	EQU	obj.var_3F

; ------------------------------------------------------------------------------

ObjEggmanStatue:
	tst.b	obj.subtype(a0)
	bne.w	ObjSpikeBomb

	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	jsr	DrawObject
	cmpi.b	#2,obj.routine(a0)
	bgt.s	.End
	jmp	CheckObjDespawn
	
.End:
	rts

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjEggmanStatue_Init-.Index
	dc.w	ObjEggmanStatue_Main-.Index
	dc.w	ObjEggmanStatue_Explode-.Index
	dc.w	ObjEggmanStatue_Wait-.Index
	dc.w	ObjEggmanStatue_DropBombs-.Index

; ------------------------------------------------------------------------------

ObjEggmanStatue_Init:
	tst.b	good_future
	beq.s	.BadFuture
	addq.l	#4,sp
	jmp	DeleteObject

.BadFuture:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#3,obj.sprite_layer(a0)
	move.b	#20,obj.collide_width(a0)
	move.b	#20,obj.width(a0)
	move.b	#28,obj.collide_height(a0)
	move.w	#$44E8,obj.sprite_tile(a0)
	move.l	#MapSpr_EggmanStatue,obj.sprites(a0)
	move.b	#$F8,obj.collide_type(a0)
	move.l	#ObjEggmanStatue_ExplodeLocs,oEggStatExplode(a0)

; ------------------------------------------------------------------------------

ObjEggmanStatue_Main:
	tst.b	obj.collide_status(a0)
	beq.s	.NoExplode
	clr.w	obj.collide_type(a0)
	addq.b	#2,obj.routine(a0)
	
	lea	player_object,a1
	jsr	SolidObject
	beq.s	.End
	jsr	GetOffObject
	
.End:
	rts
	
.NoExplode:
	lea	player_object,a1
	jmp	SolidObject

; ------------------------------------------------------------------------------

ObjEggmanStatue_Explode:
	movea.l	oEggStatExplode(a0),a6
	move.b	(a6)+,d0
	bmi.s	.Done
	addq.b	#1,oEggStatTime(a0)
	cmp.b	oEggStatTime(a0),d0
	bne.s	.End
	
	move.b	(a6)+,d5
	move.b	(a6)+,d6
	move.l	a6,oEggStatExplode(a0)
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
	
.Done:
	addq.b	#2,obj.routine(a0)
	move.b	#1,obj.sprite_frame(a0)
	move.b	#60,oEggStatTime(a0)
	rts

; ------------------------------------------------------------------------------

ObjEggmanStatue_Wait:
	subq.b	#1,oEggStatTime(a0)
	bne.s	.End
	addq.b	#2,obj.routine(a0)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjEggmanStatue_DropBombs:
	lea	ObjEggmanStatue_BombLocs(pc),a6
	move.b	obj.id(a0),d1
	moveq	#-1,d2
	move.w	obj.x(a0),d3
	move.w	obj.y(a0),d4
	
.SpawnBombs:
	move.b	(a6)+,d5
	cmpi.b	#-1,d5
	beq.s	.Done
	move.b	(a6)+,d6
	ext.w	d5
	ext.w	d6
	
	jsr	FindObjSlot
	bne.s	.Done
	move.b	d1,obj.id(a1)
	move.b	d2,obj.subtype(a1)
	move.w	d3,obj.x(a1)
	move.w	d4,obj.y(a1)
	subi.w	#160,obj.y(a1)
	add.w	d5,obj.x(a1)
	add.w	d6,obj.y(a1)
	move.w	d4,oSpikeFloorY(a1)
	addi.w	#38,oSpikeFloorY(a1)
	bra.s	.SpawnBombs
	
.Done:
	jmp	DeleteObject

; ------------------------------------------------------------------------------

MapSpr_EggmanStatue:
	include	"Level/Wacky Workbench/Objects/Eggman Statue/Data/Mappings (Statue).asm"
	even

ObjEggmanStatue_ExplodeLocs:
	dc.b	1, 0, 0
	dc.b	5, $EE, $F6
	dc.b	$A, $F6, $A
	dc.b	$F, 0, $F6
	dc.b	$14, $F6, $F6
	dc.b	$19, $D, $F6
	dc.b	$1E, $F6, $14
	dc.b	$23, $D, $F6
	dc.b	$28, $F6, $A
	dc.b	-1
	even

ObjEggmanStatue_BombLocs:
	dc.b	$E8, $C0
	dc.b	$F8, $40
	dc.b	8, 0
	dc.b	$18, $80
	dc.b	$28, $80
	dc.b	$38, $40
	dc.b	$48, $40
	dc.b	$58, $80
	dc.b	$68, $40
	dc.b	$78, $C0
	dc.b	-1
	even

; ------------------------------------------------------------------------------
; Spike bomb
; ------------------------------------------------------------------------------

oSpikeYVel	EQU	obj.var_2A
oSpikeFloorY	EQU	obj.var_2E

; ------------------------------------------------------------------------------

ObjSpikeBomb:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	jmp	DrawObject

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjSpikeBomb_Init-.Index
	dc.w	ObjSpikeBomb_Main-.Index
	dc.w	ObjSpikeBomb_Explode-.Index

; ------------------------------------------------------------------------------

ObjSpikeBomb_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#3,obj.sprite_layer(a0)
	move.b	#6,obj.collide_height(a0)
	move.b	#6,obj.collide_width(a0)
	move.b	#6,obj.width(a0)
	move.w	#$4C8,obj.sprite_tile(a0)
	move.l	#MapSpr_SpikeBomb,obj.sprites(a0)
	move.b	#$B7,obj.collide_type(a0)
	move.l	#0,oSpikeYVel(a0)

; ------------------------------------------------------------------------------

ObjSpikeBomb_Main:
	move.l	oSpikeYVel(a0),d0
	add.l	d0,obj.y(a0)
	addi.l	#$400,oSpikeYVel(a0)
	
	move.w	obj.y(a0),d0
	cmp.w	oSpikeFloorY(a0),d0
	blt.s	.Animate
	addq.b	#2,obj.routine(a0)
	
.Animate:
	lea	Ani_SpikeBomb(pc),a1
	jmp	AnimateObject

; ------------------------------------------------------------------------------

ObjSpikeBomb_Explode:
	move.b	#$18,obj.id(a0)
	move.b	#0,obj.routine(a0)
	move.b	#1,oExplodeBadnik(a0)
	move.w	#FM_EXPLODE,d0
	jmp	PlayFMSound

; ------------------------------------------------------------------------------

Ani_SpikeBomb:
	include	"Level/Wacky Workbench/Objects/Eggman Statue/Data/Animations (Bomb).asm"
	even

MapSpr_SpikeBomb:
	include	"Level/Wacky Workbench/Objects/Eggman Statue/Data/Mappings (Bomb).asm"
	even

; ------------------------------------------------------------------------------
