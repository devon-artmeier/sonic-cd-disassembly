; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Robot generator object
; ------------------------------------------------------------------------------

ObjRobotGenerator:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjRobotGenerator_Index(pc,d0.w),d0
	jsr	ObjRobotGenerator_Index(pc,d0.w)
	jsr	DrawObject
	cmpi.b	#2,obj.routine(a0)
	bgt.s	.End
	jmp	CheckObjDespawn

; ------------------------------------------------------------------------------

.End:
	rts
; End of function ObjRobotGenerator

; ------------------------------------------------------------------------------
ObjRobotGenerator_Index:
	dc.w	ObjRobotGenerator_Init-ObjRobotGenerator_Index
	dc.w	ObjRobotGenerator_Main-ObjRobotGenerator_Index
	dc.w	ObjRobotGenerator_Exploding-ObjRobotGenerator_Index
	dc.w	ObjRobotGenerator_BreakDown-ObjRobotGenerator_Index
; ------------------------------------------------------------------------------

ObjRobotGenerator_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#%00000100,obj.sprite_flags(a0)
	move.b	#4,obj.sprite_layer(a0)
	move.b	#$22,obj.collide_width(a0)
	move.b	#$22,obj.width(a0)
	move.b	#$20,obj.collide_height(a0)
	lea	ObjRobotGenerator_BaseTileList(pc),a1
	moveq	#0,d0
	move.b	act,d0
	asl.w	#2,d0
	add.b	time_zone,d0
	add.w	d0,d0
	move.w	(a1,d0.w),obj.sprite_tile(a0)
	move.l	#MapSpr_RobotGenerator,obj.sprites(a0)
	move.l	#ObjRobotGenerator_ExplosionLocs,obj.var_2C(a0)
	move.w	obj.y(a0),obj.var_30(a0)
	move.w	#4,obj.var_2A(a0)
	move.w	#1,obj.var_32(a0)
	moveq	#0,d0
	tst.b	good_future
	bne.s	.GoodFuture
	addq.b	#2,d0

.GoodFuture:
	tst.b	time_zone
	bne.s	.NotPast
	addq.b	#1,d0

.NotPast:
	move.b	d0,obj.sprite_frame(a0)
	tst.b	good_future
	bne.s	ObjRobotGenerator_Main
	tst.b	time_zone
	bne.s	ObjRobotGenerator_Main
	move.b	#$FA,obj.collide_type(a0)
	subi.w	#$10,obj.y(a0)
; End of function ObjRobotGenerator_Init

; ------------------------------------------------------------------------------

ObjRobotGenerator_Main:
	tst.b	good_future
	bne.s	.End2
	tst.b	time_zone
	bne.s	.End2
	bsr.w	ObjRobotGenerator_Float
	tst.b	obj.collide_status(a0)
	beq.s	.Solid
	clr.w	obj.collide_type(a0)
	clr.w	obj.var_2A(a0)
	move.b	#7,obj.sprite_frame(a0)
	addq.b	#2,obj.routine(a0)
	move.b	#1,good_future
	move.l	#$96,d0
	jsr	AddPoints
	lea	player_object,a1
	jsr	SolidObject
	beq.s	.End
	jsr	GetOffObject

.End:
	rts

; ------------------------------------------------------------------------------

.Solid:
	lea	player_object,a1
	jsr	SolidObject
	lea	Ani_RobotGenerator(pc),a1
	jmp	AnimateObject

; ------------------------------------------------------------------------------

.End2:
	rts
; End of function ObjRobotGenerator_Main

; ------------------------------------------------------------------------------

ObjRobotGenerator_Exploding:
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
	move.b	#1,obj.routine_2(a1)
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
	move.b	#8,obj.var_2A(a0)
	rts
; End of function ObjRobotGenerator_Exploding

; ------------------------------------------------------------------------------

ObjRobotGenerator_BreakDown:
	subq.b	#1,obj.var_2A(a0)
	bne.s	.End
	subq.b	#6,obj.routine(a0)
	move.w	obj.var_30(a0),obj.y(a0)
	move.w	#FM_D9,d0
	jmp	PlayFMSound

; ------------------------------------------------------------------------------

.End:
	rts
; End of function ObjRobotGenerator_BreakDown

; ------------------------------------------------------------------------------

ObjRobotGenerator_Float:
	addq.w	#1,obj.var_2A(a0)
	move.w	obj.var_2A(a0),d0
	andi.w	#7,d0
	bne.s	.Stay
	move.w	obj.var_32(a0),d0
	add.w	d0,obj.y(a0)

.Stay:
	move.w	obj.var_2A(a0),d0
	andi.w	#$1F,d0
	bne.s	.End
	neg.w	obj.var_32(a0)

.End:
	rts
; End of function ObjRobotGenerator_Float

; ------------------------------------------------------------------------------
Ani_RobotGenerator:
	include	"Level/_Objects/Robot Generator/Data/Animations.asm"
	even
MapSpr_RobotGenerator:
	include	"Level/_Objects/Robot Generator/Data/Mappings.asm"
	even
ObjRobotGenerator_ExplosionLocs:
	dc.b	1, 0, 0
	dc.b	2, $D8, $EC
	dc.b	3, $1C, $A
	dc.b	4, $12, $EE
	dc.b	5, $EE, $F6
	dc.b	6, 8, $F8
	dc.b	8, $EE, $E
	dc.b	$A, $F6, $A
	dc.b	$C, $1E, $F6
	dc.b	$F, 0, $EE
	dc.b	$12, $14, $F6
	dc.b	$14, $F6, $12
	dc.b	$16, 8, $17
	dc.b	$19, $D, $F6
	dc.b	$1A, $17, $EA
	dc.b	$1C, $FD, $E7
	dc.b	$1E, $A, $14
	dc.b	$20, $F6, 2
	dc.b	$22, $1E, $F8
	dc.b	$23, $D, $F6
	dc.b	$28, $F6, $A
	dc.b	$FF

; ------------------------------------------------------------------------------
