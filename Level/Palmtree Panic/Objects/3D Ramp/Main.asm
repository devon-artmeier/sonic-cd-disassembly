; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; 3D ramp objects
; ------------------------------------------------------------------------------

Obj3DPlant:
	lea	player_object,a6
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	Obj3DPlant_Index(pc,d0.w),d0
	jsr	Obj3DPlant_Index(pc,d0.w)
	jsr	DrawObject
	move.w	obj.var_2A(a0),d0
	bra.w	CheckObjDespawn2
; End of function Obj3DPlant

; ------------------------------------------------------------------------------
Obj3DPlant_Index:
	dc.w	Obj3DPlant_Init-Obj3DPlant_Index
	dc.w	Obj3DPlant_Main-Obj3DPlant_Index
; ------------------------------------------------------------------------------

Obj3DPlant_Init:
	ori.b	#4,obj.sprite_flags(a0)
	move.l	#MapSpr_3DPlant,obj.sprites(a0)
	move.w	#$4424,obj.sprite_tile(a0)
	move.b	#$18,obj.width(a0)
	move.b	#$14,obj.collide_height(a0)
	move.w	obj.x(a0),d3
	movea.l	a0,a1
	moveq	#3,d6
	bclr	#0,obj.subtype(a0)
	beq.s	.GotCount
	moveq	#1,d6

.GotCount:
	moveq	#0,d2
	bra.s	.Init

; ------------------------------------------------------------------------------

.Loop:
	jsr	FindObjSlot

.Init:
	addq.b	#2,obj.routine(a1)
	move.b	#$2C,obj.id(a1)
	move.w	d3,obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	move.w	d3,obj.var_2A(a1)
	move.l	obj.sprites(a0),obj.sprites(a1)
	move.w	obj.sprite_tile(a0),obj.sprite_tile(a1)
	move.b	obj.width(a0),obj.width(a1)
	move.b	obj.collide_height(a0),obj.collide_height(a1)
	ori.b	#4,obj.sprite_flags(a1)
	move.w	Obj3DPlant_Offsets1(pc,d2.w),d1
	add.w	d1,obj.x(a1)
	move.w	obj.x(a1),obj.var_2C(a1)
	addq.b	#2,d2
	dbf	d6,.Loop

	moveq	#2,d6
	moveq	#0,d2

.Loop2:
	jsr	FindObjSlot
	addq.b	#2,obj.routine(a1)
	move.b	#$2C,obj.id(a1)
	move.b	#1,obj.subtype(a1)
	move.b	#1,obj.sprite_frame(a1)
	move.b	#4,obj.sprite_layer(a1)
	move.w	d3,obj.x(a1)
	move.w	d3,obj.var_2A(a1)
	move.w	obj.y(a0),obj.y(a1)
	move.l	obj.sprites(a0),obj.sprites(a1)
	move.w	obj.sprite_tile(a0),obj.sprite_tile(a1)
	move.b	#$C,obj.width(a1)
	move.b	#$C,obj.collide_height(a1)
	ori.b	#4,obj.sprite_flags(a1)
	move.w	Obj3DPlant_Offsets2(pc,d2.w),d1
	add.w	d1,obj.x(a1)
	addq.b	#2,d2
	dbf	d6,.Loop2
	rts

; ------------------------------------------------------------------------------
Obj3DPlant_Offsets1:
	dc.w	$40, $80, $FFC0, $FF80
Obj3DPlant_Offsets2:
	dc.w	0, $60, $FFA0
; ------------------------------------------------------------------------------

Obj3DPlant_Main:
	tst.b	obj.subtype(a0)
	bne.s	.End
	moveq	#0,d0
	btst	#1,obj.var_2C(a6)
	beq.s	.MovePlant
	moveq	#0,d3
	move.w	obj.x(a6),d0
	move.w	d0,d2
	andi.w	#$FF,d0
	cmp.w	obj.var_2A(a0),d2
	bcc.s	.GetChunkPos
	move.w	d0,d1
	move.w	#$FF,d0
	sub.w	d1,d0

.GetChunkPos:
	cmpi.w	#$C0,d0
	bcs.s	.GotChunkPos
	cmpi.w	#$F0,d0
	bcc.s	.CapChunkPos
	move.w	#$BF,d0
	bra.s	.GotChunkPos

; ------------------------------------------------------------------------------

.CapChunkPos:
	moveq	#0,d0

.GotChunkPos:
	lsr.w	#1,d0
	cmp.w	obj.var_2A(a0),d2
	bcc.s	.MovePlant
	neg.w	d0

.MovePlant:
	add.w	obj.var_2C(a0),d0
	move.w	d0,obj.x(a0)

.End:
	rts
; End of function Obj3DPlant_Main

; ------------------------------------------------------------------------------

Obj3DFall:
	move.w	Obj3DFall_Index(pc,d0.w),d0
	jsr	Obj3DFall_Index(pc,d0.w)
	bra.w	CheckObjDespawn
; End of function Obj3DFall

; ------------------------------------------------------------------------------
Obj3DFall_Index:
	dc.w	Obj3DFall_Init-Obj3DFall_Index
	dc.w	Obj3DFall_Main-Obj3DFall_Index
; ------------------------------------------------------------------------------

Obj3DFall_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
; End of function Obj3DFall_Init

; ------------------------------------------------------------------------------

Obj3DFall_Main:
	if (REGION=USA)|((REGION<>USA)&(DEMO=0))
		cmpi.b	#$2B,obj.anim_id(a6)
		beq.w	.End
	endif
	move.w	obj.y(a0),d0
	sub.w	obj.y(a6),d0
	addi.w	#$40,d0
	cmpi.w	#$80,d0
	bcc.s	.End
	move.w	obj.x(a0),d0
	sub.w	obj.x(a6),d0
	addi.w	#$20,d0
	cmpi.w	#$40,d0
	bcc.s	.End
	move.w	obj.x(a0),d0
	move.w	obj.x_speed(a6),d1
	tst.w	d1
	bpl.s	.End
	cmp.w	obj.x(a6),d0
	bcs.s	.End
	move.w	d0,obj.x(a6)
	move.w	#0,obj.x_speed(a6)
	move.w	#0,oPlayerGVel(a6)
	move.b	#$37,obj.anim_id(a6)
	move.b	#1,oPlayerJump(a6)
	clr.b	oPlayerStick(a6)
	move.b	#$E,obj.collide_height(a0)
	move.b	#7,obj.collide_width(a0)
	addq.w	#5,obj.y(a0)
	bset	#2,obj.flags(a6)

.End:
	rts
; End of function Obj3DFall_Main

; ------------------------------------------------------------------------------

Obj3DRamp:
	lea	player_object,a6
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	tst.b	obj.subtype_2(a0)
	bne.w	Obj3DFall
	move.w	Obj3DRamp_Index(pc,d0.w),d0
	jsr	Obj3DRamp_Index(pc,d0.w)
	jsr	DrawObject
	move.w	obj.var_2A(a0),d0
	bra.w	CheckObjDespawn2
; End of function Obj3DRamp

; ------------------------------------------------------------------------------
Obj3DRamp_Index:dc.w	Obj3DRamp_Init-Obj3DRamp_Index
	dc.w	Obj3DRamp_Main-Obj3DRamp_Index
; ------------------------------------------------------------------------------

Obj3DRamp_Init:
	addq.b	#2,obj.routine(a0)
	move.b	#4,obj.sprite_flags(a0)
	move.b	#1,obj.sprite_layer(a0)
	move.l	#MapSpr_3DRamp,obj.sprites(a0)
	move.w	#$441,obj.sprite_tile(a0)
	move.b	#$20,obj.width(a0)
	move.b	#$20,obj.collide_height(a0)
	move.w	obj.x(a0),obj.var_2A(a0)
	tst.b	obj.subtype(a0)
	beq.s	Obj3DRamp_Main
	bset	#0,obj.sprite_flags(a0)
	bset	#0,obj.flags(a0)
; End of function Obj3DRamp_Init

; ------------------------------------------------------------------------------

Obj3DRamp_Main:
	tst.b	obj.var_2E(a0)
	beq.s	.TimeRunSet
	move.b	#1,obj.anim_id(a0)
	btst	#1,oPlayerCtrl(a6)
	bne.s	.Animate
	addq.b	#1,obj.anim_id(a0)

.Animate:
	lea	Ani_3DRamp,a1
	jsr	AnimateObject
	bra.s	.GetChunkPos

; ------------------------------------------------------------------------------

.TimeRunSet:
	move.b	#0,obj.sprite_frame(a0)
	moveq	#0,d1
	btst	#1,oPlayerCtrl(a6)
	beq.s	.Move3D

.GetChunkPos:
	move.w	obj.x(a6),d0
	andi.w	#$FF,d0
	tst.b	obj.subtype(a0)
	beq.s	.NoFlip
	move.w	d0,d1
	move.w	#$FF,d0
	sub.w	d1,d0

.NoFlip:
	cmpi.w	#$C0,d0
	bcs.s	.GotChunkPos
	cmpi.w	#$F0,d0
	bcc.s	.CapChunkPos
	move.w	#$BF,d0
	bra.s	.GotChunkPos

; ------------------------------------------------------------------------------

.CapChunkPos:
	moveq	#0,d0

.GotChunkPos:
	ext.l	d0
	move.w	d0,d1
	tst.b	obj.var_2E(a0)
	bne.s	.KeepFrame
	divu.w	#$30,d0
	move.b	d0,obj.sprite_frame(a0)

.KeepFrame:
	lsr.w	#2,d1
	move.w	d1,d2
	lsr.w	#1,d2
	add.w	d2,d1
	tst.b	obj.subtype(a0)
	beq.s	.Move3D
	neg.w	d1

.Move3D:
	add.w	obj.var_2A(a0),d1
	move.w	d1,obj.x(a0)
	tst.b	obj.var_2E(a0)
	beq.s	.SkipTimer
	subq.b	#1,obj.var_2E(a0)
	bra.s	.ChkTouch

; ------------------------------------------------------------------------------

.SkipTimer:
	btst	#1,obj.flags(a6)
	bne.s	.End

.ChkTouch:
	move.b	obj.width(a0),d1
	ext.w	d1
	move.w	obj.x(a6),d0
	sub.w	obj.x(a0),d0
	add.w	d1,d0
	bmi.s	.End
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.End
	move.b	obj.collide_height(a0),d1
	ext.w	d1
	move.w	obj.y(a6),d0
	sub.w	obj.y(a0),d0
	add.w	d1,d0
	bmi.s	.End
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.End
	cmpi.b	#$2B,obj.anim_id(a6)
	beq.s	.End
	tst.b	obj.var_2E(a0)
	bne.s	.TimerSet
	move.b	#60,obj.var_2E(a0)

.TimerSet:
	tst.w	obj.y_speed(a6)
	bpl.s	.LaunchDown
	move.w	#-$C00,obj.y_speed(a6)
	rts

; ------------------------------------------------------------------------------

.LaunchDown:
	move.w	#$C00,obj.y_speed(a6)

.End:
	rts
; End of function Obj3DRamp_Main

; ------------------------------------------------------------------------------
MapSpr_3DPlant:
	include	"Level/Palmtree Panic/Objects/3D Ramp/Data/Mappings (Plant).asm"
	even
Ani_3DRamp:
	include	"Level/Palmtree Panic/Objects/3D Ramp/Data/Animations (Booster).asm"
	even

; ------------------------------------------------------------------------------
