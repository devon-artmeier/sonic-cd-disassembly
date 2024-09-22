; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Freezer object
; ------------------------------------------------------------------------------

oFreezerTime	EQU	obj.var_2A
oFreezerParent	EQU	obj.var_2A
oFreezerBreak	EQU	obj.var_30
oFreezerPiece	EQU	obj.var_31

; ------------------------------------------------------------------------------

ObjFreezer:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawn
	
; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjFreezer_Init-.Index
	dc.w	ObjFreezer_Main-.Index
	dc.w	ObjFreezer_Freezer-.Index
	dc.w	ObjFreezer_Reset-.Index
	dc.w	ObjFreezer_IceBlock-.Index
	dc.w	ObjFreezer_IceLanded-.Index
	dc.w	ObjFreezer_IcePiece-.Index
	
; ------------------------------------------------------------------------------

ObjFreezer_Init:
	ori.b	#4,obj.sprite_flags(a0)
	move.w	#$310,obj.sprite_tile(a0)
	move.l	#MapSpr_Freezer,obj.sprites(a0)
	move.b	#120,oFreezerTime(a0)
	addq.b	#2,obj.routine(a0)

; ------------------------------------------------------------------------------

ObjFreezer_Main:
	tst.b	oFreezerTime(a0)
	beq.s	.End
	subq.b	#1,oFreezerTime(a0)
	bne.s	.End
	
	jsr	FindObjSlot
	bne.s	.End
	
	move.l	a0,oFreezerParent(a1)
	move.b	#5,obj.id(a1)
	move.b	#3,obj.sprite_layer(a1)
	ori.b	#4,obj.sprite_flags(a1)
	move.w	obj.sprite_tile(a0),obj.sprite_tile(a1)
	move.l	obj.sprites(a0),obj.sprites(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	addi.w	#36,obj.y(a1)
	move.b	#4,obj.routine(a1)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjFreezer_Freezer:
	bsr.w	ObjFreezer_ChkSonicFreeze
	lea	Ani_Freezer,a1
	jmp	AnimateObject

; ------------------------------------------------------------------------------

ObjFreezer_Reset:
	movea.l	oFreezerParent(a0),a1
	move.b	#120,oFreezerTime(a1)
	jmp	DeleteObject

; ------------------------------------------------------------------------------

ObjFreezer_IceBlock:
	addi.w	#$38,obj.y_speed(a0)
	move.l	obj.y(a0),d3
	move.w	obj.y_speed(a0),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d3
	move.l	d3,obj.y(a0)
	
	jsr	ObjGetFloorDist
	tst.w	d1
	bpl.s	.UpdateY
	
	move.w	#SCMD_BREAKSFX,d0
	jsr	SubCPUCmd
	move.b	#$F,oFreezerBreak(a0)
	add.w	d1,obj.y(a0)
	addq.b	#2,obj.routine(a0)
		
.UpdateY:
	movea.l	oFreezerParent(a0),a1
	move.l	obj.y(a0),obj.y(a1)
	rts

; ------------------------------------------------------------------------------

ObjFreezer_IceLanded:
	movea.l	oFreezerParent(a0),a1
	tst.b	oFreezerBreak(a0)
	beq.s	.Hurt
	subq.b	#1,oFreezerBreak(a0)
	
	move.b	p1_ctrl_tap,d0
	andi.b	#$70,d0
	beq.s	.End
	
	bclr	#0,oPlayerCtrl(a1)
	bclr	#6,oPlayerCtrl(a1)
	
	move.w	#-$680,obj.y_speed(a1)
	move.b	#$E,obj.collide_height(a1)
	move.b	#7,obj.collide_width(a1)
	addq.w	#5,obj.y(a1)
	bset	#2,obj.flags(a1)
	bclr	#5,obj.flags(a1)
	move.b	#2,obj.anim_id(a1)
	move.w	#FM_JUMP,d0
	jsr	PlayFMSound
	
	bra.s	.Broken
	
.Hurt:
	movea.l	a0,a3
	movea.l	a0,a2
	movea.l	oFreezerParent(a0),a0
	bclr	#0,oPlayerCtrl(a0)
	bclr	#6,oPlayerCtrl(a0)
	jsr	HurtPlayer
	movea.l	a3,a0

.Broken:
	addq.b	#2,obj.routine(a0)
	move.b	#$A,obj.sprite_frame(a0)
	move.b	#20,oFreezerBreak(a0)
	move.b	#2,oFreezerPiece(a0)
	bsr.w	ObjFreezer_IceBlockBreak

.End:
	rts

; ------------------------------------------------------------------------------

ObjFreezer_IcePiece:
	subq.b	#1,oFreezerBreak(a0)
	bne.s	.Move
	
	cmpi.b	#$B,obj.sprite_frame(a0)
	beq.s	.Delete
	
	moveq	#0,d0
	move.b	oFreezerPiece(a0),d0
	add.w	d0,d0
	move.w	.Pieces(pc,d0.w),d0
	lea	.Pieces(pc,d0.w),a3
	moveq	#4-1,d6
	bsr.w	ObjFreezer_IcePieceBreak
	
.Delete:
	jmp	DeleteObject
	
.Move:
	move.w	obj.x_speed(a0),d0
	add.w	d0,obj.x(a0)
	move.w	obj.y_speed(a0),d0
	add.w	d0,obj.y(a0)
	rts

; ------------------------------------------------------------------------------

.Pieces:
	dc.w	.Piece0-.Pieces
	dc.w	.Piece1-.Pieces
	dc.w	.Piece2-.Pieces

.Piece0:
	dc.b	0, 0, $A, $B, 0, 0, -1, 0
	dc.b	0, 0, $A, $B, 0, 1, 0, 0
	dc.b	0, 0, $A, $B, 0, 0, 1, 0
	dc.b	0, 0, $A, $B, 0, -1, 0, 0

.Piece1:
	dc.b	0, 0, $A, $B, 0, -1, -1, 0
	dc.b	0, 0, $A, $B, 0, 1, -1, 0
	dc.b	0, 0, $A, $B, 0, 0, 1, 0
	dc.b	0, 0, 1, $B, 0, -1, 0, 0

.Piece2:
	dc.b	0, 0, $A, $B, 0, -1, -1, 0
	dc.b	0, 0, $A, $B, 0, 1, -1, 0
	dc.b	0, 0, $A, $B, 0, 1, 1, 0
	dc.b	0, 0, $A, $B, 0, -1, 1, 0

; ------------------------------------------------------------------------------

ObjFreezer_IceBlockBreak:
	moveq	#6-1,d6
	lea	ObjFreezer_IceBlockPieces,a3

ObjFreezer_IcePieceBreak:
	moveq	#0,d1
	
.Loop:
	jsr	FindObjSlot
	bne.s	.End
	
	move.b	#5,obj.id(a1)
	move.b	#$C,obj.routine(a1)
	ori.b	#4,obj.sprite_flags(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	move.w	#$2E1,obj.sprite_tile(a1)
	move.l	#MapSpr_Freezer,obj.sprites(a1)
	
	move.b	(a3,d1.w),d2
	ext.w	d2
	add.w	d2,obj.x(a1)
	move.b	1(a3,d1.w),d2
	ext.w	d2
	add.w	d2,obj.y(a1)
	
	move.b	2(a3,d1.w),oFreezerBreak(a1)
	move.b	3(a3,d1.w),obj.sprite_frame(a1)
	move.b	4(a3,d1.w),d2
	or.b	d2,obj.sprite_flags(a1)
	
	move.b	5(a3,d1.w),d2
	ext.w	d2
	move.w	d2,obj.x_speed(a1)
	move.b	6(a3,d1.w),d2
	ext.w	d2
	move.w	d2,obj.y_speed(a1)
	
	move.b	7(a3,d1.w),oFreezerPiece(a1)
	
	addq.w	#8,d1
	dbf	d6,.Loop
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjFreezer_IceBlockPieces:
	dc.b	-$10, -$C, $A, 9, 0, -1, -1, 0
	dc.b	-$10, $C, $A, 9, 2, -1, 1, 0
	dc.b	$10, -$C, $A, 9, 1, 1, -1, 0
	dc.b	$10, $C, $A, 9, 3, 1, 1, 0
	dc.b	0, -$10, $F, $A, 1, 0, -1, 1
	dc.b	0, $10, $F, $A, 3, 0, 1, 1

; ------------------------------------------------------------------------------

ObjFreezer_FreezeSonic:
	movea.l	a1,a2
	jsr	FindObjSlot
	bne.s	.End
	
	bset	#0,oPlayerCtrl(a2)
	bset	#6,oPlayerCtrl(a2)
	move.l	a2,oFreezerParent(a1)
	
	move.b	#5,obj.id(a1)
	ori.b	#4,obj.sprite_flags(a1)
	move.w	obj.x(a2),obj.x(a1)
	move.w	obj.y(a2),obj.y(a1)
	move.w	#$2E1,obj.sprite_tile(a1)
	move.l	#MapSpr_Freezer,obj.sprites(a1)
	move.b	#$18,obj.collide_width(a1)
	move.b	#$18,obj.width(a1)
	move.b	#$18,obj.collide_height(a1)
	move.b	#8,obj.sprite_frame(a1)
	move.b	#8,obj.routine(a1)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjFreezer_ChkSonicFreeze:
	cmpi.b	#1,obj.anim_id(a0)
	bne.s	.End
	
	lea	player_object,a1
	cmpi.b	#$2B,obj.anim_id(a1)
	beq.s	.End
	bsr.s	ObjFreezer_CheckSonic
	bne.s	ObjFreezer_FreezeSonic
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjFreezer_CheckSonic:
	tst.b	invincible
	bne.s	.NoFreeze
	tst.b	time_warp
	bne.s	.NoFreeze
	cmpi.b	#4,obj.routine(a1)
	bcc.s	.NoFreeze
	tst.b	oPlayerCtrl(a1)
	bne.s	.NoFreeze
	
	move.b	obj.collide_width(a1),d1
	ext.w	d1
	addi.w	#16,d1
	move.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	add.w	d1,d0
	bmi.s	.NoFreeze
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoFreeze
	
	move.b	obj.collide_height(a1),d1
	ext.w	d1
	addi.w	#32,d1
	move.w	obj.y(a1),d0
	sub.w	obj.y(a0),d0
	add.w	d1,d0
	bmi.s	.NoFreeze
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoFreeze
	
.Freeze:
	moveq	#1,d0
	rts
	
.NoFreeze:
	moveq	#0,d0
	rts
	
; ------------------------------------------------------------------------------

Ani_Freezer:
	include	"Level/Wacky Workbench/Objects/Freezer/Data/Animations.asm"
	even

MapSpr_Freezer:
	include	"Level/Wacky Workbench/Objects/Freezer/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
