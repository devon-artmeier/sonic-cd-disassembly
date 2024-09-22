; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Minomusi object
; ------------------------------------------------------------------------------

oMinoTime	EQU	obj.var_2A
oMinoYVel	EQU	obj.var_30
oMinoStartY	EQU	obj.var_34
oMinoDropY	EQU	obj.var_36
oMinoParent	EQU	obj.var_38

; ------------------------------------------------------------------------------

ObjMinomusi:
	tst.b	obj.subtype_2(a0)
	beq.s	.Main
	bmi.w	ObjMinomusiSilk
	bra.w	ObjMinomusiSpikes
	
.Main:
	jsr	DestroyOnGoodFuture
	
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	jsr	DrawObject
	jmp	CheckObjDespawn

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjMinomusi_Init-.Index
	dc.w	ObjMinomusi_SetWait-.Index
	dc.w	ObjMinomusi_WaitPlayer-.Index
	dc.w	ObjMinomusi_StartDrop-.Index
	dc.w	ObjMinomusi_Drop-.Index
	dc.w	ObjMinomusi_StartRetract-.Index
	dc.w	ObjMinomusi_Retract-.Index
	dc.w	ObjMinomusi_StartAttack-.Index
	dc.w	ObjMinomusi_Attack-.Index

; ------------------------------------------------------------------------------

ObjMinomusi_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#3,obj.sprite_layer(a0)
	move.b	#16,obj.collide_height(a0)
	move.b	#16,obj.collide_width(a0)
	move.b	#16,obj.width(a0)
	move.w	#$2488,obj.sprite_tile(a0)
	move.b	#$34,obj.collide_type(a0)
	addq.w	#8,obj.y(a0)
	move.w	obj.y(a0),oMinoStartY(a0)
	move.w	obj.y(a0),oMinoDropY(a0)
	addi.w	#95,oMinoDropY(a0)
	
	lea	MapSpr_Minomusi(pc),a1
	tst.b	obj.subtype(a0)
	beq.s	.NotDamaged
	lea	MapSpr_MinomusiDamaged(pc),a1
	
.NotDamaged:
	move.l	a1,obj.sprites(a0)
	
	jsr	FindNextObjSlot
	beq.s	.SpawnSilk
	jmp	DeleteObject

.SpawnSilk:
	move.b	obj.id(a0),obj.id(a1)
	move.b	#-1,obj.subtype_2(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	move.b	obj.sprite_flags(a0),obj.sprite_flags(a1)
	move.b	obj.sprite_layer(a0),obj.sprite_layer(a1)
	addq.b	#1,obj.sprite_layer(a1)
	move.w	obj.sprite_tile(a0),obj.sprite_tile(a1)
	move.l	obj.sprites(a0),obj.sprites(a1)
	move.b	#32,obj.collide_height(a1)
	move.b	#1,obj.collide_width(a1)
	move.b	#1,obj.width(a1)
	move.w	a0,oMinoParent(a1)

; ------------------------------------------------------------------------------

ObjMinomusi_SetWait:
	addq.b	#2,obj.routine(a0)
	move.b	#9,obj.sprite_frame(a0)
	move.w	#121,oMinoTime(a0)

; ------------------------------------------------------------------------------

ObjMinomusi_WaitPlayer:
	subq.w	#1,oMinoTime(a0)
	bne.s	.End
	move.w	#121,oMinoTime(a0)
	
	move.b	#2,d6
	lea	player_object,a1
	bsr.w	ObjMinomusi_CheckPlayer
	bcs.s	.NextRoutine
	neg.b	d6
	
.NextRoutine:
	add.b	d6,obj.routine(a0)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjMinomusi_CheckPlayer:
	move.w	obj.y(a1),d0
	sub.w	obj.y(a0),d0
	subi.w	#40,d0
	subi.w	#120,d0
	bcc.s	.End
	
	move.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	subi.w	#-168,d0
	subi.w	#336,d0
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjMinomusi_StartDrop:
	addq.b	#2,obj.routine(a0)
	move.l	#$80000,oMinoYVel(a0)

; ------------------------------------------------------------------------------

ObjMinomusi_Drop:
	move.l	oMinoYVel(a0),d0
	add.l	d0,obj.y(a0)
	move.w	oMinoDropY(a0),d0
	sub.w	obj.y(a0),d0
	bgt.s	.End
	add.w	d0,obj.y(a0)
	move.b	#$E,obj.routine(a0)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjMinomusi_StartRetract:
	addq.b	#2,obj.routine(a0)
	move.l	#$70000,d0
	tst.b	obj.subtype(a0)
	beq.s	.NotDamaged
	move.l	#$20000,d0
	
.NotDamaged:
	move.l	d0,oMinoYVel(a0)

; ------------------------------------------------------------------------------

ObjMinomusi_Retract:
	move.l	oMinoYVel(a0),d0
	sub.l	d0,obj.y(a0)
	move.w	oMinoStartY(a0),d0
	sub.w	obj.y(a0),d0
	blt.s	.End
	add.w	d0,obj.y(a0)
	move.b	#2,obj.routine(a0)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjMinomusi_StartAttack:
	addq.b	#2,obj.routine(a0)
	
	move.w	#230,d0
	move.w	#$00FF,d1
	tst.b	obj.subtype(a0)
	beq.s	.NotDamaged
	move.w	#61,d0
	move.w	#$01FF,d1
	
.NotDamaged:
	move.w	d0,oMinoTime(a0)
	move.w	d1,obj.anim_id(a0)

; ------------------------------------------------------------------------------

ObjMinomusi_Attack:
	subq.w	#1,oMinoTime(a0)
	bne.s	.Attack
	move.b	#$A,obj.routine(a0)
	
.Attack:
	lea	Ani_Minomusi(pc),a1
	jsr	AnimateObject
	
	tst.b	obj.subtype(a0)
	bne.w	.End
	cmpi.b	#$1E,obj.anim_frame(a0)
	bne.w	.End
	
	jsr	FindNextObjSlot
	bne.w	.End
	move.b	obj.id(a0),obj.id(a1)
	move.b	#1,obj.subtype_2(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	addq.w	#4,obj.y(a1)
	move.b	obj.sprite_flags(a0),obj.sprite_flags(a1)
	move.b	obj.sprite_layer(a0),obj.sprite_layer(a1)
	move.w	obj.sprite_tile(a0),obj.sprite_tile(a1)
	move.l	obj.sprites(a0),obj.sprites(a1)
	move.b	obj.collide_height(a0),obj.collide_height(a1)
	move.b	obj.collide_width(a0),obj.collide_width(a1)
	move.b	obj.width(a0),obj.width(a1)
	move.w	a0,oMinoParent(a1)
	move.b	#$B5,obj.collide_type(a1)
	
	tst.b	obj.sprite_flags(a0)
	bpl.s	.End
	move.w	#FM_B7,d0
	jsr	PlayFMSound
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjMinomusiSpikes:
	movea.w	oMinoParent(a0),a1
	cmpi.b	#$33,obj.id(a1)
	bne.s	.Delete
	cmpi.b	#1,obj.anim_frame(a1)
	beq.s	.Delete
	jmp	DrawObject
	
.Delete:
	jmp	DeleteObject

; ------------------------------------------------------------------------------

ObjMinomusiSilk:
	movea.w	oMinoParent(a0),a1
	cmpi.b	#$33,obj.id(a1)
	beq.s	.Draw
	jmp	DeleteObject
	
.Draw:
	move.w	obj.y(a1),d0
	sub.w	oMinoStartY(a1),d0
	subi.w	#24,d0
	asr.w	#3,d0
	bpl.s	.SetFrame
	moveq	#0,d0

.SetFrame:
	move.b	d0,obj.sprite_frame(a0)

	asl.w	#2,d0
	add.w	oMinoStartY(a1),d0
	addi.w	#16,d0
	move.w	d0,obj.y(a0)
	
	jmp	DrawObject

; ------------------------------------------------------------------------------

Ani_Minomusi:
	include	"Level/Wacky Workbench/Objects/Minomusi/Data/Animations.asm"
	even

	include	"Level/Wacky Workbench/Objects/Minomusi/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
