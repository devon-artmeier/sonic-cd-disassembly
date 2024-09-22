; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Bata-pyon object
; ------------------------------------------------------------------------------

oBataXVel	EQU	obj.var_2A
oBataYVel	EQU	obj.var_2E
oBataJumpsLeft	EQU	obj.var_32
oBataJumpCnt	EQU	obj.var_33
oBataSensorX	EQU	obj.var_34
oBataWallChk	EQU	obj.var_36
oBataLandTime	EQU	obj.var_3A
oBataColDist	EQU	obj.var_3E

; ------------------------------------------------------------------------------

ObjBataPyon:
	jsr	DestroyOnGoodFuture

	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjBataPyon_Init-.Index
	dc.w	ObjBataPyon_Fall-.Index
	dc.w	ObjBataPyon_Landed-.Index
	dc.w	ObjBataPyon_Jump-.Index

; ------------------------------------------------------------------------------

ObjBataPyon_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#3,obj.sprite_layer(a0)
	move.w	#$2438,obj.sprite_tile(a0)
	move.b	#16,obj.collide_width(a0)
	move.b	#16,obj.width(a0)
	
	move.l	#$70000,oBataYVel(a0)
	move.l	#ObjGetLWallDist,oBataWallChk(a0)
	move.w	#-16,oBataSensorX(a0)
	move.b	#1,obj.sprite_frame(a0)
	bsr.w	ObjBataPyon_SwapFrames

	movea.l	#MapSpr_BataPyon,a1
	move.l	#-$A000,d0
	move.b	#7,d1
	tst.b	obj.subtype(a0)
	beq.s	.NotDamaged
	movea.l	#MapSpr_BataPyonDamaged,a1
	move.l	#-$8000,d0
	move.b	#3,d1

.NotDamaged:
	move.l	a1,obj.sprites(a0)
	move.l	d0,oBataXVel(a0)
	move.l	#$70000,oBataYVel(a0)
	move.b	d1,oBataJumpCnt(a0)
	move.b	d1,oBataJumpsLeft(a0)
	addq.b	#1,oBataJumpsLeft(a0)

; ------------------------------------------------------------------------------

ObjBataPyon_Fall:
	move.l	oBataXVel(a0),d0
	add.l	d0,obj.x(a0)
	move.l	oBataYVel(a0),d0
	add.l	d0,obj.y(a0)

	jsr	ObjGetFloorDist
	move.w	d1,oBataColDist(a0)
	move.w	oBataSensorX(a0),d3
	movea.l	oBataWallChk(a0),a1
	jsr	(a1)
	tst.w	d1
	bpl.s	.NoWall

.Wall:
	tst.w	oBataColDist(a0)
	bpl.w	ObjBataPyon_Flip
	cmp.w	oBataColDist(a0),d1
	ble.w	ObjBataPyon_Flip
	bra.s	.Landed

.NoWall:
	tst.w	oBataColDist(a0)
	bmi.s	.Landed
	addi.l	#$2000,oBataYVel(a0)
	cmpi.l	#$70000,oBataYVel(a0)
	blt.s	.End
	move.l	#$70000,oBataYVel(a0)

.End:
	rts

.Landed:
	addq.b	#2,obj.routine(a0)
	move.w	oBataColDist(a0),d0
	add.w	d0,obj.y(a0)
	
	move.w	#1,d0
	tst.b	obj.subtype(a0)
	beq.s	.SetLandTime
	move.w	#20,d0

.SetLandTime:
	move.w	d0,oBataLandTime(a0)
	rts

; ------------------------------------------------------------------------------

ObjBataPyon_Landed:
	tst.b	obj.subtype(a0)
	beq.s	.CheckJump

	move.w	#7,d6
	move.w	oBataLandTime(a0),d0
	cmpi.w	#6,d0
	beq.s	.StutterDown
	cmpi.w	#11,d0
	beq.s	.StutterUp
	cmpi.w	#15,d0
	beq.s	.StutterDown
	cmpi.w	#18,d0
	bne.s	.CheckJump

.StutterUp:
	neg.w	d6

.StutterDown:
	add.w	d6,obj.y(a0)
	bsr.w	ObjBataPyon_SwapFrames

.CheckJump:
	subq.w	#1,oBataLandTime(a0)
	bne.s	.End
	addq.b	#2,obj.routine(a0)
	subq.w	#7,obj.y(a0)
	bsr.w	ObjBataPyon_SwapFrames

	move.l	#-$60000,d0
	tst.b	obj.subtype(a0)
	beq.s	.Jump
	move.l	#-$50000,d0

.Jump:
	move.l	d0,oBataYVel(a0)
	subq.b	#1,oBataJumpsLeft(a0)
	bmi.s	ObjBataPyon_Flip

.End:
	rts

; ------------------------------------------------------------------------------

ObjBataPyon_Jump:
	move.l	oBataXVel(a0),d0
	add.l	d0,obj.x(a0)
	move.l	oBataYVel(a0),d0
	add.l	d0,obj.y(a0)

	jsr	ObjGetCeilDist
	move.w	d1,oBataColDist(a0)
	move.w	oBataSensorX(a0),d3
	movea.l	oBataWallChk(a0),a1
	jsr	(a1)
	tst.w	d1
	bpl.s	.NoWall

.Wall:
	tst.w	oBataColDist(a0)
	bpl.s	ObjBataPyon_Flip
	cmp.w	oBataColDist(a0),d1
	ble.s	ObjBataPyon_Flip
	bra.s	.HitCeiling

.NoWall:
	tst.w	oBataColDist(a0)
	bmi.s	.HitCeiling
	addi.l	#$2000,oBataYVel(a0)
	bpl.s	.Falling
	rts

.HitCeiling:
	move.w	oBataColDist(a0),d0
	sub.w	d0,obj.y(a0)
	clr.l	oBataYVel(a0)

.Falling:
	subq.b	#4,obj.routine(a0)
	subi.w	#11,obj.y(a0)
	bra.s	ObjBataPyon_SwapFrames

; ------------------------------------------------------------------------------

ObjBataPyon_Flip:
	move.b	oBataJumpCnt(a0),oBataJumpsLeft(a0)

	bchg	#0,obj.sprite_flags(a0)
	bchg	#0,obj.flags(a0)
	neg.l	oBataXVel(a0)
	neg.w	oBataSensorX(a0)

	lea	ObjGetLWallDist,a1
	lea	ObjGetRWallDist,a2
	cmpa.l	oBataWallChk(a0),a1
	bne.s	.SwapWallChk
	exg	a1,a2

.SwapWallChk:
	move.l	a1,oBataWallChk(a0)
	rts

; ------------------------------------------------------------------------------

ObjBataPyon_SwapFrames:
	tst.b	obj.sprite_frame(a0)
	beq.s	.Frame0

	moveq	#0,d0
	moveq	#19,d1
	moveq	#$2F,d2
	bra.s	.SetFrame

.Frame0:
	moveq	#1,d0
	moveq	#28,d1
	moveq	#$30,d2

.SetFrame:
	move.b	d0,obj.sprite_frame(a0)
	move.b	d1,obj.collide_height(a0)
	move.b	d2,obj.collide_type(a0)
	rts

; ------------------------------------------------------------------------------

MapSpr_BataPyon:
	include	"Level/Wacky Workbench/Objects/Bata-pyon/Data/Mappings (Normal).asm"
	even

MapSpr_BataPyonDamaged:
	include	"Level/Wacky Workbench/Objects/Bata-pyon/Data/Mappings (Damaged).asm"
	even

; ------------------------------------------------------------------------------
