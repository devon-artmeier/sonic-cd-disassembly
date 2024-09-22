; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Semi object
; ------------------------------------------------------------------------------

oSemiXVel	EQU	obj.var_2A
oSemiYVel	EQU	obj.var_2E
oSemiTime	EQU	obj.var_32
oSemiPlayerX	EQU	obj.var_34

; ------------------------------------------------------------------------------

ObjSemi:
	tst.b	obj.subtype_2(a0)
	bmi.w	ObjSemiBomb
	
	jsr	DestroyOnGoodFuture

	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjSemi_Init-.Index
	dc.w	ObjSemi_Wait-.Index
	dc.w	ObjSemi_WaitPlayer-.Index
	dc.w	ObjSemi_StartMove-.Index
	dc.w	ObjSemi_Move-.Index
	dc.w	ObjSemi_StartAttack-.Index
	dc.w	ObjSemi_Attack-.Index

; ------------------------------------------------------------------------------

ObjSemi_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#1,obj.sprite_layer(a0)
	move.b	#16,obj.collide_height(a0)
	move.b	#19,obj.collide_width(a0)
	move.b	#19,obj.width(a0)
	move.w	#$A4A8,obj.sprite_tile(a0)
	move.b	#$36,obj.collide_type(a0)
	move.b	obj.subtype_2(a0),oSemiTime+1(a0)
	
	lea	MapSpr_Semi(pc),a1
	tst.b	obj.subtype(a0)
	beq.s	.NotDamaged
	lea	MapSpr_SemiDamaged(pc),a1
	
.NotDamaged:
	move.l	a1,obj.sprites(a0)

; ------------------------------------------------------------------------------

ObjSemi_Wait:
	subq.w	#1,oSemiTime(a0)
	bpl.s	.End
	addq.b	#2,obj.routine(a0)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjSemi_WaitPlayer:
	lea	player_object,a1
	bsr.s	ObjSemi_CheckPlayer
	bcc.s	.End
	addq.b	#2,obj.routine(a0)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjSemi_CheckPlayer:
	move.w	obj.y(a1),d0
	sub.w	obj.y(a0),d0
	subi.w	#-96,d0
	subi.w	#192,d0
	bcc.s	.End
	
	move.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	move.w	d0,oSemiPlayerX(a0)
	subi.w	#-120,d0
	subi.w	#240,d0

.End:
	rts

; ------------------------------------------------------------------------------

ObjSemi_StartMove:
	addq.b	#2,obj.routine(a0)
	move.l	#$10000,d0
	move.l	#-$8000,d1
	move.w	#96,d2
	tst.b	obj.subtype(a0)
	beq.s	.NotDamaged
	move.l	#$C000,d0
	move.l	#$6000,d1
	move.w	#42,d2
	
.NotDamaged:
	tst.w	oSemiPlayerX(a0)
	bmi.s	.StartMove
	neg.l	d0
	
.StartMove:
	move.l	d0,oSemiXVel(a0)
	move.l	d1,oSemiYVel(a0)
	move.w	d2,oSemiTime(a0)

; ------------------------------------------------------------------------------

ObjSemi_Move:
	subq.w	#1,oSemiTime(a0)
	bpl.s	.Move
	addq.b	#2,obj.routine(a0)
	
.Move:
	move.l	oSemiXVel(a0),d0
	add.l	d0,obj.x(a0)
	move.l	oSemiYVel(a0),d0
	add.l	d0,obj.y(a0)
	
	lea	Ani_Semi(pc),a1
	jmp	AnimateObject

; ------------------------------------------------------------------------------

ObjSemi_StartAttack:
	addq.b	#2,obj.routine(a0)
	move.w	#0,oSemiTime(a0)
	move.l	#$10000,d0
	tst.b	obj.subtype(a0)
	beq.s	.NotDamaged
	move.l	#$C000,d0
	
.NotDamaged:
	tst.w	oSemiPlayerX(a0)
	bmi.s	.Move
	neg.l	d0
	
.Move:
	move.l	d0,oSemiXVel(a0)

; ------------------------------------------------------------------------------

ObjSemi_Attack:
	tst.b	obj.subtype(a0)
	bne.s	.Move

	andi.w	#$3F,oSemiTime(a0)
	bne.s	.NoBomb
	lea	player_object,a1
	bsr.w	ObjSemi_CheckPlayer
	bcc.s	.NoBomb
	
	jsr	FindObjSlot
	bne.s	.NoBomb
	move.b	obj.id(a0),obj.id(a1)
	move.l	obj.x(a0),obj.x(a1)
	move.l	obj.y(a0),obj.y(a1)
	addi.w	#10,obj.y(a1)
	move.b	#-1,obj.subtype_2(a1)
	move.b	obj.sprite_flags(a0),obj.sprite_flags(a1)
	move.b	obj.sprite_layer(a0),obj.sprite_layer(a1)
	addq.b	#1,obj.sprite_layer(a1)
	
.NoBomb:
	addq.w	#1,oSemiTime(a0)

.Move:
	move.l	oSemiXVel(a0),d0
	add.l	d0,obj.x(a0)
	
	lea	Ani_Semi(pc),a1
	jmp	AnimateObject

; ------------------------------------------------------------------------------

Ani_Semi:
	include	"Level/Wacky Workbench/Objects/Semi/Data/Animations (Normal).asm"
	even

MapSpr_Semi:
	include	"Level/Wacky Workbench/Objects/Semi/Data/Mappings (Normal).asm"
	even

MapSpr_SemiDamaged:
	include	"Level/Wacky Workbench/Objects/Semi/Data/Mappings (Damaged).asm"
	even

; ------------------------------------------------------------------------------
; Semi bomb
; ------------------------------------------------------------------------------

oSemiBombYVel	EQU	obj.var_2E
oSemiBombTime	EQU	obj.var_32

; ------------------------------------------------------------------------------

ObjSemiBomb:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn
	
; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjSemiBomb_Init-.Index
	dc.w	ObjSemiBomb_Fall-.Index
	dc.w	ObjSemiBomb_Wait-.Index
	dc.w	ObjSemiBomb_Detonate-.Index
	dc.w	ObjSemiBomb_Explode-.Index

; ------------------------------------------------------------------------------

ObjSemiBomb_Init:
	addq.b	#2,obj.routine(a0)
	move.b	#$B7,obj.collide_type(a0)
	move.b	#6,obj.collide_height(a0)
	move.b	#6,obj.collide_width(a0)
	move.b	#6,obj.width(a0)
	move.w	#$84C8,obj.sprite_tile(a0)
	move.l	#MapSpr_SemiBomb,obj.sprites(a0)
	move.l	#$8000,oSemiBombYVel(a0)

; ------------------------------------------------------------------------------

ObjSemiBomb_Fall:
	move.l	oSemiBombYVel(a0),d0
	add.l	d0,obj.y(a0)
	addi.l	#$4000,oSemiBombYVel(a0)
	
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.End
	addq.b	#2,obj.routine(a0)
	add.w	d1,obj.y(a0)
	move.w	#120,oSemiBombTime(a0)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjSemiBomb_Wait:
	subq.w	#1,oSemiBombTime(a0)
	bpl.s	.End
	addq.b	#2,obj.routine(a0)
	move.w	#120,oSemiBombTime(a0)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjSemiBomb_Detonate:
	subq.w	#1,oSemiBombTime(a0)
	bpl.s	.Animate
	addq.b	#2,obj.routine(a0)
	
.Animate:
	lea	Ani_SemiBomb(pc),a1
	jmp	AnimateObject

; ------------------------------------------------------------------------------

ObjSemiBomb_Explode:
	move.b	#$18,obj.id(a0)
	move.b	#0,obj.routine(a0)
	move.b	#1,oExplodeBadnik(a0)
	tst.b	obj.sprite_flags(a0)
	bpl.s	.End
	move.w	#FM_EXPLODE,d0
	jsr	PlayFMSound
	
.End:
	rts

; ------------------------------------------------------------------------------

Ani_SemiBomb:
	include	"Level/Wacky Workbench/Objects/Semi/Data/Animations (Bomb).asm"
	even

MapSpr_SemiBomb:
	include	"Level/Wacky Workbench/Objects/Semi/Data/Mappings (Bomb).asm"
	even

; ------------------------------------------------------------------------------
