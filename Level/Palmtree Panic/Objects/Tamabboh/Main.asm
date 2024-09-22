; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Tamabboh object
; ------------------------------------------------------------------------------

ObjTamabboh:
	cmpi.b	#1,obj.subtype(a0)
	beq.w	ObjTamabbohMissile
	jsr	DestroyOnGoodFuture
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjTamabboh_Index(pc,d0.w),d0
	jsr	ObjTamabboh_Index(pc,d0.w)
	jsr	DrawObject
	move.w	obj.var_2A(a0),d0
	jmp	CheckObjDespawn2
; End of function ObjTamabboh

; ------------------------------------------------------------------------------
ObjTamabboh_Index:dc.w	ObjTamabboh_Init-ObjTamabboh_Index
	dc.w	ObjTamabboh_Position-ObjTamabboh_Index
	dc.w	ObjTamabboh_Main-ObjTamabboh_Index
	dc.w	ObjTamabboh_Wait1-ObjTamabboh_Index
	dc.w	ObjTamabboh_Wait2-ObjTamabboh_Index
	dc.w	ObjTamabboh_Fire-ObjTamabboh_Index
; ------------------------------------------------------------------------------

ObjTamabboh_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#4,obj.sprite_layer(a0)
	move.b	#$2C,obj.collide_type(a0)
	move.b	#$10,obj.collide_width(a0)
	move.b	#$10,obj.width(a0)
	move.b	#$F,obj.collide_height(a0)
	move.w	obj.x(a0),obj.var_2A(a0)
	moveq	#4,d0
	jsr	SetObjectTileID
	tst.b	obj.subtype(a0)
	bne.s	.AltMaps
	lea	MapSpr_Tamabboh1(pc),a1
	lea	Ani_Tamabboh1(pc),a2
	move.l	#-$A000,d0
	bra.s	.SetMaps

; ------------------------------------------------------------------------------

.AltMaps:
	lea	MapSpr_Tamabboh2(pc),a1
	lea	Ani_Tamabboh2(pc),a2
	move.l	#-$5000,d0

.SetMaps:
	move.l	a1,obj.sprites(a0)
	move.l	a2,obj.var_30(a0)
	move.l	d0,obj.var_2C(a0)
; End of function ObjTamabboh_Init

; ------------------------------------------------------------------------------

ObjTamabboh_Position:
	move.l	#$10000,d0
	add.l	d0,obj.y(a0)
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.End
	addq.b	#2,obj.routine(a0)

.End:
	rts
; End of function ObjTamabboh_Position

; ------------------------------------------------------------------------------

ObjTamabboh_Main:
	tst.w	debug_mode
	bne.s	.SkipRange
	tst.b	obj.subtype(a0)
	bne.s	.SkipRange
	tst.w	obj.var_34(a0)
	beq.s	.DoRange
	subq.w	#1,obj.var_34(a0)
	bra.s	.SkipRange

; ------------------------------------------------------------------------------

.DoRange:
	lea	player_object,a1
	bsr.s	ObjTamabboh_CheckInRange
	bcs.s	.NextState

.SkipRange:
	move.l	obj.var_2C(a0),d0
	add.l	d0,obj.x(a0)
	move.w	obj.x(a0),d0
	sub.w	obj.var_2A(a0),d0
	bpl.s	.ChlTirm
	neg.w	d0

.ChlTirm:
	cmpi.w	#$80,d0
	bge.s	.TurnAround
	jsr	ObjGetFloorDist
	cmpi.w	#-7,d1
	blt.s	.TurnAround
	cmpi.w	#7,d1
	bgt.s	.TurnAround
	add.w	d1,obj.y(a0)
	movea.l	obj.var_30(a0),a1
	jmp	AnimateObject

; ------------------------------------------------------------------------------

.TurnAround:
	neg.l	obj.var_2C(a0)
	bchg	#0,obj.sprite_flags(a0)
	bchg	#0,obj.flags(a0)
	bra.s	ObjTamabboh_Main

; ------------------------------------------------------------------------------

.NextState:
	addq.b	#2,obj.routine(a0)
	rts
; End of function ObjTamabboh_Main

; ------------------------------------------------------------------------------

ObjTamabboh_CheckInRange:
	move.w	obj.y(a1),d0
	sub.w	obj.y(a0),d0
	subi.w	#-$50,d0
	subi.w	#$A0,d0
	bcc.s	.End
	move.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	move.w	d0,d1
	subi.w	#-$50,d1
	subi.w	#$A0,d1

.End:
	rts
; End of function ObjTamabboh_CheckInRange

; ------------------------------------------------------------------------------

ObjTamabboh_Wait1:
	addq.b	#2,obj.routine(a0)
	move.b	#1,obj.anim_id(a0)
; End of function ObjTamabboh_Wait1

; ------------------------------------------------------------------------------

ObjTamabboh_Wait2:
	movea.l	obj.var_30(a0),a1
	jmp	AnimateObject
; End of function ObjTamabboh_Wait2

; ------------------------------------------------------------------------------

ObjTamabboh_Fire:
	move.b	#4,obj.routine(a0)
	move.b	#0,obj.anim_id(a0)
	move.w	#$78,obj.var_34(a0)
	tst.b	obj.subtype(a0)
	bne.s	.End
	jsr	FindObjSlot
	bne.s	.End
	tst.b	obj.sprite_flags(a0)
	bpl.s	.SkipSound
	move.w	#FM_A0,d0
	jsr	PlayFMSound

.SkipSound:
	bsr.s	ObjTamabboh_InitMissile
	sf	obj.var_3F(a1)
	jsr	FindObjSlot
	bne.s	.End
	bsr.s	ObjTamabboh_InitMissile
	st	obj.var_3F(a1)

.End:
	rts
; End of function ObjTamabboh_Fire

; ------------------------------------------------------------------------------

ObjTamabboh_InitMissile:
	move.b	obj.id(a0),obj.id(a1)
	move.b	#1,obj.subtype(a1)
	move.w	obj.sprite_tile(a0),obj.sprite_tile(a1)
	move.b	obj.sprite_layer(a0),obj.sprite_layer(a1)
	addq.b	#1,obj.sprite_layer(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	subi.w	#10,obj.y(a1)
	rts
; End of function ObjTamabboh_InitMissile

; ------------------------------------------------------------------------------
Ani_Tamabboh1:
	include	"Level/Palmtree Panic/Objects/Tamabboh/Data/Animations (Normal).asm"
	even
Ani_Tamabboh2:
	include	"Level/Palmtree Panic/Objects/Tamabboh/Data/Animations (Damaged).asm"
	even
	include	"Level/Palmtree Panic/Objects/Tamabboh/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------

ObjTamabbohMissile:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjTamabbohMissile_Index(pc,d0.w),d0
	jsr	ObjTamabbohMissile_Index(pc,d0.w)
	jmp	DrawObject
; End of function ObjTamabbohMissile

; ------------------------------------------------------------------------------
ObjTamabbohMissile_Index:dc.w	ObjTamabbohMissile_Init-ObjTamabbohMissile_Index
	dc.w	ObjTamabbohMissile_Main-ObjTamabbohMissile_Index
; ------------------------------------------------------------------------------

ObjTamabbohMissile_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#$AD,obj.collide_type(a0)
	move.b	#8,obj.collide_width(a0)
	move.b	#8,obj.width(a0)
	move.b	#8,obj.collide_height(a0)
	move.l	#MapSpr_TamabbohMissile,obj.sprites(a0)
	move.l	#0,obj.var_32(a0)
	move.l	#$2000,obj.var_36(a0)
	tst.b	obj.var_3F(a0)
	bne.s	.FlipX
	move.l	#$20000,d0
	move.l	#-$40000,d1
	bra.s	.SetSpeeds

; ------------------------------------------------------------------------------

.FlipX:
	move.l	#-$20000,d0
	move.l	#-$40000,d1

.SetSpeeds:
	move.l	d0,obj.var_2A(a0)
	move.l	d1,obj.var_2E(a0)
	rts
; End of function ObjTamabbohMissile_Init

; ------------------------------------------------------------------------------

ObjTamabbohMissile_Main:
	tst.b	obj.sprite_flags(a0)
	bmi.s	.Action
	jmp	DeleteObject

; ------------------------------------------------------------------------------

.Action:
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.MoveAnim
	jmp	DeleteObject

; ------------------------------------------------------------------------------

.MoveAnim:
	move.l	obj.var_2A(a0),d0
	add.l	d0,obj.x(a0)
	move.l	obj.var_2E(a0),d0
	add.l	d0,obj.y(a0)
	move.l	obj.var_32(a0),d0
	add.l	d0,obj.var_2A(a0)
	move.l	obj.var_36(a0),d0
	add.l	d0,obj.var_2E(a0)
	lea	Ani_TamabbohMissile(pc),a1
	jmp	AnimateObject
; End of function ObjTamabbohMissile_Main

; ------------------------------------------------------------------------------
Ani_TamabbohMissile:
	include	"Level/Palmtree Panic/Objects/Tamabboh/Data/Animations (Missile).asm"
	even
MapSpr_TamabbohMissile:
	include	"Level/Palmtree Panic/Objects/Tamabboh/Data/Mappings (Missile).asm"
	even

; ------------------------------------------------------------------------------
