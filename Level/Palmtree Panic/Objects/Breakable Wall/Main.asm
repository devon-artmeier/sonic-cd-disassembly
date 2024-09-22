; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Breakable wall object
; ------------------------------------------------------------------------------

ObjBreakableWall:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjBreakableWall_Index(pc,d0.w),d0
	jmp	ObjBreakableWall_Index(pc,d0.w)
; End of function ObjBreakableWall

; ------------------------------------------------------------------------------
ObjBreakableWall_Index:
	dc.w	ObjBreakableWall_Init-ObjBreakableWall_Index
	dc.w	ObjBreakableWall_Main-ObjBreakableWall_Index
	dc.w	ObjBreakableWall_Fall-ObjBreakableWall_Index
; ------------------------------------------------------------------------------

ObjBreakableWall_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#1,obj.sprite_layer(a0)
	move.b	#$10,obj.collide_width(a0)
	move.b	#$10,obj.width(a0)
	move.b	#$18,obj.collide_height(a0)
	move.b	#$EF,obj.collide_type(a0)
	move.w	#$44BE,obj.sprite_tile(a0)
	move.l	#MapSpr_BreakableWall,obj.sprites(a0)
	move.b	obj.subtype(a0),obj.sprite_frame(a0)
; End of function ObjBreakableWall_Init

; ------------------------------------------------------------------------------

ObjBreakableWall_Main:
	tst.b	obj.collide_status(a0)
	beq.s	.Solid
	clr.w	obj.collide_type(a0)
	addq.b	#2,obj.routine(a0)
	lea	player_object,a1
	move.w	obj.x_speed(a1),obj.var_2A(a0)
	move.w	obj.y_speed(a1),obj.var_2E(a0)
	bra.s	.BreakUp

; ------------------------------------------------------------------------------

.Solid:
	lea	player_object,a1
	jsr	SolidObject
	jsr	DrawObject
	jmp	CheckObjDespawn

; ------------------------------------------------------------------------------

.BreakUp:
	move.w	#FM_B0,d0
	jsr	PlayFMSound
	lea	player_object,a6
	asr	obj.x_speed(a6)
	lea	ObjBreakableWall_PieceFrames(pc),a5
	moveq	#0,d0
	move.b	obj.subtype(a0),d0
	lsl.w	#3,d0
	adda.w	d0,a5
	lea	ObjBreakableWall_PieceDeltas(pc),a4
	lea	ObjBreakableWall_PieceSpeeds(pc),a3
	moveq	#5,d6
	movea.w	a0,a1
	bra.s	.InitLoop

; ------------------------------------------------------------------------------

.Loop:
	jsr	FindObjSlot
	bne.s	ObjBreakableWall_Fall
	move.b	obj.id(a0),obj.id(a1)
	move.b	obj.routine(a0),obj.routine(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	move.b	obj.sprite_flags(a0),obj.sprite_flags(a1)
	move.b	obj.sprite_layer(a0),obj.sprite_layer(a1)
	move.l	obj.sprites(a0),obj.sprites(a1)
	move.w	obj.sprite_tile(a0),obj.sprite_tile(a1)

.InitLoop:
	move.b	#8,obj.collide_width(a1)
	move.b	#8,obj.width(a1)
	move.b	#8,obj.collide_height(a1)
	move.b	(a5)+,obj.sprite_frame(a1)
	move.w	(a4)+,d0
	move.w	(a4)+,d1
	add.w	d0,obj.x(a1)
	add.w	d1,obj.y(a1)
	move.l	(a3)+,d0
	move.l	(a3)+,obj.var_2E(a1)
	tst.w	obj.x_speed(a6)
	bpl.s	.NoFlip
	neg.l	d0

.NoFlip:
	move.l	d0,obj.var_2A(a1)
	dbf	d6,.Loop
; End of function ObjBreakableWall_Main

; ------------------------------------------------------------------------------

ObjBreakableWall_Fall:
	addi.l	#$4000,obj.var_2E(a0)
	move.l	obj.var_2A(a0),d0
	move.l	obj.var_2E(a0),d1
	add.l	d0,obj.x(a0)
	add.l	d1,obj.y(a0)
	lea	player_object,a1
	move.w	obj.y(a1),d0
	sub.w	obj.y(a0),d0
	cmpi.w	#-$E0,d0
	ble.s	.Destroy
	jmp	DrawObject

; ------------------------------------------------------------------------------

.Destroy:
	jmp	DeleteObject
; End of function ObjBreakableWall_Fall

; ------------------------------------------------------------------------------
MapSpr_BreakableWall:
	include	"Level/Palmtree Panic/Objects/Breakable Wall/Data/Mappings.asm"
	even
ObjBreakableWall_PieceFrames:
	dc.b	8, 9,	8, $C, $D, $C, 0, 0
	dc.b	8, 9, 8, $A, $B, $A, 0, 0
	dc.b	$A, $B, $A, $A, $B, $A, 0, 0
	dc.b	$A, $B, $A, $C, $D, $C, 0, 0
	dc.b	9, 8, 9, $D, $C, $D, 0, 0
	dc.b	9, 8, 9, $B, $A, $B, 0, 0
	dc.b	$B, $A, $B, $B, $A, $B, 0, 0
	dc.b	$B, $A, $B, $D, $C, $D, 0, 0
ObjBreakableWall_PieceDeltas:
	dc.w	$FFF8, $FFF0
	dc.w	0,	$10
	dc.w	0,	$20
	dc.w	$10, 0
	dc.w	$10, $10
	dc.w	$10, $20
ObjBreakableWall_PieceSpeeds:
	dc.w	$FFFD, $97C
	dc.w	$FFFE, $B750
	dc.w	$FFFC, $25EE
	dc.w	0,	0
	dc.w	$FFFD, $97C
	dc.w	1,	$48B0
	dc.w	$FFFD, $97C
	dc.w	$FFFE, $4445
	dc.w	$FFFC, $97B5
	dc.w	0,	0
	dc.w	$FFFD, $97C
	dc.w	1,	$BBBB

; ------------------------------------------------------------------------------
