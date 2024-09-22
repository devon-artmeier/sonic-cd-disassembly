; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Seesaw object
; ------------------------------------------------------------------------------

oSeesawParent	EQU	obj.var_2A
oSeesawPtfm1	EQU	obj.var_2A
oSeesawPtfm2	EQU	obj.var_2C
oSeesawTime	EQU	obj.var_2E
oSeesawStood	EQU	obj.var_3F

; ------------------------------------------------------------------------------

ObjSeesaw:
	tst.b	obj.subtype(a0)
	bne.w	ObjSeesawPtfm

	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	jsr	DrawObject
	jmp	CheckObjDespawn
	
; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjSeesaw_Init-.Index
	dc.w	ObjSeesaw_Main-.Index
	dc.w	ObjSeesaw_PushUp-.Index
	
; ------------------------------------------------------------------------------

ObjSeesaw_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#3,obj.sprite_layer(a0)
	move.b	#24,obj.collide_width(a0)
	move.b	#24,obj.width(a0)
	move.b	#24,obj.collide_height(a0)
	move.w	#$3B8,obj.sprite_tile(a0)
	move.l	#MapSpr_Seesaw,obj.sprites(a0)

	jsr	FindObjSlot
	bne.w	ObjSeesaw_Delete
	bsr.w	ObjSeesaw_InitSub
	move.w	a1,oSeesawPtfm1(a0)
	subi.w	#40,obj.x(a1)
	subi.w	#24,obj.y(a1)

	jsr	FindObjSlot
	bne.w	ObjSeesaw_Delete
	bsr.w	ObjSeesaw_InitSub
	move.w	a1,oSeesawPtfm2(a0)
	addi.w	#40,obj.x(a1)
	addi.w	#24,obj.y(a1)
	bset	#0,obj.sprite_flags(a1)
	bset	#0,obj.flags(a1)
	rts

; ------------------------------------------------------------------------------

ObjSeesaw_InitSub:
	move.b	obj.id(a0),obj.id(a1)
	move.b	obj.sprite_flags(a0),obj.sprite_flags(a1)
	move.b	obj.sprite_layer(a0),obj.sprite_layer(a1)
	move.w	obj.sprite_tile(a0),obj.sprite_tile(a1)
	move.l	obj.sprites(a0),obj.sprites(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	move.b	#-1,obj.subtype(a1)
	move.b	#16,obj.collide_width(a1)
	move.b	#16,obj.width(a1)
	move.b	#8,obj.collide_height(a1)
	move.b	#9,obj.sprite_frame(a1)
	move.w	a0,oSeesawParent(a1)
	move.w	#120,oSeesawTime(a0)
	rts

; ------------------------------------------------------------------------------

ObjSeesaw_Main:
	lea	ObjSeesaw_CheckSlideDown(pc),a1
	tst.w	obj.y_speed(a0)
	beq.s	.RunRoutine
	lea	ObjSeesaw_SlideDown(pc),a1

.RunRoutine:
	jsr	(a1)

	move.w	a0,-(sp)
	movea.w	oSeesawPtfm2(a0),a0
	lea	player_object,a1
	jsr	TopSolidObject
	jsr	DrawObject
	movea.w	(sp)+,a0

	move.w	a0,-(sp)
	movea.w	oSeesawPtfm1(a0),a0
	lea	player_object,a1
	jsr	TopSolidObject
	sne	oSeesawStood(a0)
	jsr	DrawObject
	movea.w	(sp)+,a0

	movea.w	oSeesawPtfm1(a0),a1
	tst.b	oSeesawStood(a1)
	bne.s	.StoodOn

	lea	Ani_Seesaw(pc),a1
	jmp	AnimateObject

.StoodOn:
	move.b	#4,obj.routine(a0)
	move.w	#3,oSeesawTime(a0)
	move.b	#8,obj.sprite_frame(a0)
	rts

; ------------------------------------------------------------------------------

ObjSeesaw_CheckSlideDown:
	tst.w	oSeesawTime(a0)
	bmi.s	.End
	subq.w	#1,oSeesawTime(a0)
	bmi.s	.SlideDown
	cmpi.w	#60,oSeesawTime(a0)
	beq.s	.Animate
	bra.s	.End

.SlideDown:
	move.w	#$100,obj.y_speed(a0)

.Animate:
	addq.b	#1,obj.anim_id(a0)

.End:
	rts

; ------------------------------------------------------------------------------

ObjSeesaw_SlideDown:
	movea.w	oSeesawPtfm1(a0),a1
	movea.w	oSeesawPtfm2(a0),a2

	moveq	#0,d0
	move.b	obj.y_speed(a0),d0
	add.w	d0,obj.y(a0)
	add.w	d0,obj.y(a1)
	add.w	d0,obj.y(a2)

	moveq	#0,d0
	move.b	obj.width(a2),d0
	move.w	obj.x(a2),d3
	cmp.w	obj.x(a0),d3
	blt.s	.CheckFloor
	neg.w	d0

.CheckFloor:
	add.w	d0,d3
	
	move.w	a0,-(sp)
	movea.w	a2,a0
	jsr	ObjGetFloorDist2
	movea.w	(sp)+,a0
	tst.w	d1
	bmi.s	.Landed
	rts

.Landed:
	movea.w	oSeesawPtfm1(a0),a1
	movea.w	oSeesawPtfm2(a0),a2
	add.w	d1,obj.y(a0)
	add.w	d1,obj.y(a1)
	add.w	d1,obj.y(a2)
	move.w	#0,obj.y_speed(a0)
	rts

; ------------------------------------------------------------------------------

ObjSeesaw_PushUp:
	movea.w	oSeesawPtfm2(a0),a1
	subi.w	#24,obj.y(a1)
	subi.w	#12,obj.y(a0)

	subq.w	#1,oSeesawTime(a0)
	bpl.s	.Draw
	bsr.s	ObjSeesaw_Swap

.Draw:
	move.w	a0,-(sp)
	movea.w	oSeesawPtfm2(a0),a0
	jsr	DrawObject
	movea.w	(sp),a0

	movea.w	oSeesawPtfm1(a0),a0
	jsr	DrawObject
	movea.w	(sp)+,a0

	rts

; ------------------------------------------------------------------------------

ObjSeesaw_Swap:
	move.b	#2,obj.routine(a0)
	move.w	#0,obj.y_speed(a0)
	move.w	#120,oSeesawTime(a0)
	move.w	oSeesawPtfm1(a0),oSeesawPtfm2(a0)
	move.w	a1,oSeesawPtfm1(a0)

	moveq	#0,d0
	cmpi.b	#2,obj.anim_id(a0)
	bgt.s	.SetAnim
	moveq	#3,d0

.SetAnim:
	move.b	d0,obj.anim_id(a0)
	move.b	#-1,obj.prev_anim_id(a0)
	rts

; ------------------------------------------------------------------------------

ObjSeesawPtfm:
	movea.w	oSeesawParent(a0),a1
	cmpi.b	#$2C,obj.id(a1)
	bne.s	ObjSeesaw_Delete
	rts

; ------------------------------------------------------------------------------

ObjSeesaw_Delete:
	jmp	DeleteObject

; ------------------------------------------------------------------------------

Ani_Seesaw:
	include	"Level/Wacky Workbench/Objects/Seesaw/Data/Animations.asm"
	even
	
MapSpr_Seesaw:
	include	"Level/Wacky Workbench/Objects/Seesaw/Data/Mappings.asm"
	even
	
; ------------------------------------------------------------------------------
