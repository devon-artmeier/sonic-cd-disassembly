; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Collapsing platform object
; ------------------------------------------------------------------------------

ObjCollapsePlatform:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjCollapsePlatform_Index(pc,d0.w),d0
	jsr	ObjCollapsePlatform_Index(pc,d0.w)
	jsr	DrawObject
	cmpi.b	#4,obj.routine(a0)
	bge.s	.End
	jmp	CheckObjDespawn

; ------------------------------------------------------------------------------

.End:
	rts
; End of function ObjCollapsePlatform

; ------------------------------------------------------------------------------
ObjCollapsePlatform_Index:
	dc.w	ObjCollapsePlatform_Init-ObjCollapsePlatform_Index
	dc.w	ObjCollapsePlatform_Main-ObjCollapsePlatform_Index
	dc.w	ObjCollapsePlatform_Delay-ObjCollapsePlatform_Index
	dc.w	ObjCollapsePlatform_Fall-ObjCollapsePlatform_Index
; ------------------------------------------------------------------------------

ObjCollapsePlatform_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#3,obj.sprite_layer(a0)
	move.w	#$44BE,obj.sprite_tile(a0)
	lea	MapSpr_CollapsePlatform1(pc),a1
	lea	ObjCollapsePlatform_Sizes1(pc),a2
	move.b	obj.subtype(a0),d0
	bpl.s	.SetMaps
	lea	MapSpr_CollapsePlatform2(pc),a1
	lea	ObjCollapsePlatform_Sizes2(pc),a2

.SetMaps:
	move.l	a1,obj.sprites(a0)
	btst	#4,d0
	beq.s	.NoFlip
	bset	#0,obj.sprite_flags(a0)
	bset	#0,obj.flags(a0)

.NoFlip:
	andi.w	#$F,d0
	move.b	d0,obj.sprite_frame(a0)
	add.w	d0,d0
	move.w	(a2,d0.w),d0
	move.b	(a2,d0.w),d1
	addq.b	#1,d1
	asl.b	#3,d1
	move.b	d1,obj.collide_width(a0)
	move.b	d1,obj.width(a0)
	move.b	1(a2,d0.w),d1
	bpl.s	.AbsDY
	neg.b	d1

.AbsDY:
	addq.b	#1,d1
	asl.b	#3,d1
	addq.b	#2,d1
	move.b	d1,obj.collide_height(a0)
; End of function ObjCollapsePlatform_Init

; ------------------------------------------------------------------------------

ObjCollapsePlatform_Main:
	lea	player_object,a1
	jsr	TopSolidObject
	bne.s	.StandOn
	rts

; ------------------------------------------------------------------------------

.StandOn:
	jsr	GetOffObject
	move.w	#FM_A3,d0
	jsr	PlayFMSound
	addq.b	#2,obj.routine(a0)
	move.b	obj.subtype(a0),d0
	bpl.w	ObjCollapsePlatform_BreakUp_MultiRow
	bra.w	ObjCollapsePlatform_BreakUp_SingleRow
; End of function ObjCollapsePlatform_Main

; ------------------------------------------------------------------------------

ObjCollapsePlatform_Delay:
	addi.w	#-1,obj.var_2A(a0)
	bne.s	.KeepOn
	addq.b	#2,obj.routine(a0)

.KeepOn:
	move.b	obj.var_3E(a0),d0
	beq.s	.End
	lea	player_object,a1
	jsr	TopSolidObject
	beq.s	.End
	tst.w	obj.var_2A(a0)
	bne.s	.End
	jsr	GetOffObject

.End:
	rts
; End of function ObjCollapsePlatform_Delay

; ------------------------------------------------------------------------------

ObjCollapsePlatform_Fall:
	move.l	obj.var_2C(a0),d0
	add.l	d0,obj.y(a0)
	addi.l	#$4000,obj.var_2C(a0)
	move.w	obj.y(a0),d0
	lea	player_object,a1
	sub.w	obj.y(a1),d0
	cmpi.w	#$200,d0
	bgt.w	.Delete
	rts

; ------------------------------------------------------------------------------

.Delete:
	jmp	DeleteObject
; End of function ObjCollapsePlatform_Fall

; ------------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR ObjCollapsePlatform_Main

ObjCollapsePlatform_BreakUp_MultiRow:
	move.b	obj.subtype(a0),d0
	suba.l	a4,a4
	btst	#4,d0
	beq.s	.SkipThis
	lea	ObjCollapsePlatform_BreakUp_MultiRow(pc),a4

.SkipThis:
	lea	ObjCollapsePlatform_Sizes1(pc),a6
	andi.w	#$F,d0
	add.w	d0,d0
	move.w	(a6,d0.w),d0
	lea	(a6,d0.w),a6
	moveq	#0,d0
	move.b	(a6)+,d0
	movea.w	d0,a5
	asl.w	#3,d0
	move.w	#$FFF0,d1
	cmpa.w	#0,a4
	bne.s	.SkipThis2
	neg.w	d0
	neg.w	d1

.SkipThis2:
	add.w	obj.x(a0),d0
	movea.w	d0,a2
	movea.w	d1,a3
	moveq	#0,d6
	move.b	(a6)+,d6
	move.w	d6,d4
	asl.w	#3,d4
	add.w	obj.y(a0),d4
	move.w	#9,d2
	move.b	obj.id(a0),obj.var_3F(a0)

.Loop:
	move.w	a5,d5
	move.w	a2,d3
	move.w	d2,d1

.Loop2:
	jsr	FindObjSlot
	bne.w	.Solid
	move.b	(a6)+,d0
	bmi.w	.Endxt
	move.b	d0,obj.sprite_frame(a1)
	ori.b	#4,obj.sprite_flags(a1)
	move.b	#3,obj.sprite_layer(a1)
	move.w	#$44BE,obj.sprite_tile(a1)
	move.l	#MapSpr_CollapsePlatform3,obj.sprites(a1)
	move.l	#$20000,obj.var_2C(a1)
	move.b	obj.var_3F(a0),obj.id(a1)
	move.b	obj.routine(a0),obj.routine(a1)
	cmpa.w	#0,a4
	beq.s	.SkipThis3
	bset	#0,obj.sprite_flags(a1)
	bset	#0,obj.flags(a1)

.SkipThis3:
	tst.w	d6
	bne.s	.NotLast
	st	obj.var_3E(a1)
	move.b	#8,obj.collide_width(a1)
	move.b	#8,obj.width(a1)
	move.b	#9,obj.collide_height(a1)

.NotLast:
	move.w	d4,obj.y(a1)
	move.w	d3,obj.x(a1)
	move.w	d1,obj.var_2A(a1)

.Endxt:
	add.w	a3,d3
	addi.w	#$C,d1
	dbf	d5,.Loop2
	addi.w	#-$10,d4
	addq.w	#5,d2
	dbf	d6,.Loop
	bra.s	.Delete

; ------------------------------------------------------------------------------

.Solid:
	lea	player_object,a1
	jsr	TopSolidObject
	beq.s	.Delete
	jsr	GetOffObject

.Delete:
	jmp	DeleteObject

; ------------------------------------------------------------------------------

ObjCollapsePlatform_BreakUp_SingleRow:
	move.b	obj.subtype(a0),d2
	lea	ObjCollapsePlatform_Sizes2(pc),a6
	move.b	d2,d0
	andi.w	#$1F,d0
	add.w	d0,d0
	move.w	(a6,d0.w),d0
	lea	(a6,d0.w),a6
	move.b	(a6)+,d5
	move.b	(a6)+,d1
	addq.b	#1,d1
	asl.b	#3,d1
	addq.b	#2,d1
	andi.w	#$FF,d5
	move.w	d5,d4
	lsl.w	#3,d4
	neg.w	d4
	move.w	#$10,d3
	moveq	#1,d6
	btst	#6,d2
	bne.w	.GetSpeed
	lsl.b	#2,d2
	bra.s	.SkipSpeed

; ------------------------------------------------------------------------------

.GetSpeed:
	lea	player_object,a1
	move.w	obj.x_speed(a1),d0
	btst	#5,d2
	beq.s	.GotSpeed
	neg.w	d0

.GotSpeed:
	tst.w	d0

.SkipSpeed:
	bpl.s	.InitX
	lea	(a6,d5.w),a6
	neg.w	d4
	neg.w	d3
	neg.w	d6

.InitX:
	add.w	obj.x(a0),d4
	move.w	#9,d2
	move.b	obj.id(a0),obj.var_3F(a0)

.Loop3:
	jsr	FindObjSlot
	bne.w	.Solid2
	move.b	#3,obj.sprite_layer(a1)
	move.w	#$44BE,obj.sprite_tile(a1)
	ori.b	#4,obj.sprite_flags(a1)
	move.l	#MapSpr_CollapsePlatform4,obj.sprites(a1)
	move.l	#$20000,obj.var_2C(a1)
	move.b	obj.var_3F(a0),obj.id(a1)
	move.b	obj.routine(a0),obj.routine(a1)
	move.w	obj.y(a0),obj.y(a1)
	st	obj.var_3E(a1)
	move.b	#8,obj.collide_width(a1)
	move.b	#8,obj.width(a1)
	move.b	d1,obj.collide_height(a1)
	move.b	(a6),obj.sprite_frame(a1)
	lea	(a6,d6.w),a6
	move.w	d4,obj.x(a1)
	add.w	d3,d4
	move.w	d2,obj.var_2A(a1)
	addi.w	#$C,d2
	dbf	d5,.Loop3
	bra.s	.Delete2

; ------------------------------------------------------------------------------

.Solid2:
	lea	player_object,a1
	jsr	TopSolidObject
	beq.s	.Delete2
	jsr	GetOffObject

.Delete2:
	jmp	DeleteObject
	
; ------------------------------------------------------------------------------
