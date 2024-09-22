; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Snake blocks object
; ------------------------------------------------------------------------------

oSnakePath	EQU	obj.var_2C
oSnakeIndex	EQU	obj.var_32
oSnakeSpawn	EQU	obj.var_34

; ------------------------------------------------------------------------------
; Main block
; ------------------------------------------------------------------------------

ObjSnakeBlocks:
	tst.b	obj.subtype(a0)
	bmi.w	ObjSnakeSub
	
ObjSnakeMain:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	lea	player_object,a1
	jsr	SolidObject
	jsr	DrawObject
	jmp	CheckObjDespawn

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjSnakeMain_Init-.Index
	dc.w	ObjSnakeMain_Main-.Index
	
; ------------------------------------------------------------------------------

ObjSnakeMain_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#1,obj.sprite_layer(a0)
	move.b	#16,obj.collide_width(a0)
	move.b	#16,obj.width(a0)
	move.b	#16,obj.collide_height(a0)
	move.w	#$3A8,obj.sprite_tile(a0)
	move.l	#MapSpr_SnakeBlocks,obj.sprites(a0)
	move.w	a0,oSnakeParent(a0)
	st	oSnakeSpawn(a0)
	move.w	#0,oSnakeIndex(a0)

; ------------------------------------------------------------------------------

ObjSnakeMain_Main:
	tst.b	oSnakeSpawn(a0)
	beq.s	.End
	sf	oSnakeSpawn(a0)
	
	lea	ObjSnakeBlocks_Paths(pc),a1
	moveq	#0,d0
	move.b	obj.subtype(a0),d0
	add.w	d0,d0
	adda.w	(a1,d0.w),a1
	move.w	oSnakeIndex(a0),d0
	adda.w	(a1,d0.w),a1
	move.l	a1,oSnakePath(a0)
	
	addq.w	#2,oSnakeIndex(a0)
	cmpi.w	#8,oSnakeIndex(a0)
	blt.s	.SpawnBlock
	clr.w	oSnakeIndex(a0)
	
.SpawnBlock:
	bsr.w	ObjSnakeBlocks_Spawn
	beq.s	.End
	jmp	DeleteObject
	
.End:
	rts

; ------------------------------------------------------------------------------
; Sub block
; ------------------------------------------------------------------------------

oSnakeParent	EQU	obj.var_2A
oSnakeTime	EQU	obj.var_30
oSnakeSolidYVel	EQU	obj.var_34
oSnakePrev	EQU	obj.var_36
oSnakeXVel	EQU	obj.var_38
oSnakeYVel	EQU	obj.var_3C

; ------------------------------------------------------------------------------

ObjSnakeSub:
	movea.w	oSnakeParent(a0),a1
	cmpi.b	#$2A,obj.id(a1)
	bne.w	ObjSnakeSub_Delete
	move.b	obj.subtype_2(a0),d0
	cmp.b	obj.subtype_2(a1),d0
	bne.w	ObjSnakeSub_Delete
	
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	lea	player_object,a1
	jsr	SolidObject
	jmp	DrawObject

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjSnakeSub_Init-.Index
	dc.w	ObjSnakeSub_Move-.Index
	dc.w	ObjSnakeSub_StartWait-.Index
	dc.w	ObjSnakeSub_Wait-.Index
	dc.w	ObjSnakeSub_WaitMove-.Index
	dc.w	ObjSnakeSub_StartMoveBack-.Index
	dc.w	ObjSnakeSub_MoveBack-.Index
	dc.w	ObjSnakeSub_StartWait2-.Index
	dc.w	ObjSnakeSub_Wait2-.Index
	dc.w	ObjSnakeSub_Done-.Index

; ------------------------------------------------------------------------------

ObjSnakeSub_Init:
	addq.b	#2,obj.routine(a0)
	move.w	#63,oSnakeTime(a0)
	move.l	#0,oSnakeXVel(a0)
	move.l	#0,oSnakeYVel(a0)
	
	movea.l	oSnakePath(a0),a1
	move.b	-1(a1),d0
	bne.s	.NotUp
	move.l	#-$8000,oSnakeYVel(a0)
	
.NotUp:
	subq.b	#1,d0
	bne.s	.NotRight
	move.l	#$8000,oSnakeXVel(a0)
	
.NotRight:
	subq.b	#1,d0
	bne.s	.NotDown
	move.l	#$8000,oSnakeYVel(a0)
	
.NotDown:
	subq.b	#1,d0
	bne.s	.NotLeft
	move.l	#-$8000,oSnakeXVel(a0)
	
.NotLeft:
	movea.w	oSnakeParent(a0),a1
	cmpi.b	#2,obj.subtype(a1)
	bne.s	ObjSnakeSub_Move
	
	moveq	#1,d0
	tst.w	oSnakeYVel(a0)
	bpl.s	.SetSolidYVel
	moveq	#-1,d0
	
.SetSolidYVel:
	move.w	d0,oSnakeSolidYVel(a0)
	move.w	d0,obj.y_speed(a0)

; ------------------------------------------------------------------------------

ObjSnakeSub_Move:
	move.l	oSnakeXVel(a0),d0
	add.l	d0,obj.x(a0)
	move.l	oSnakeYVel(a0),d0
	add.l	d0,obj.y(a0)
	
	subq.w	#1,oSnakeTime(a0)
	bpl.s	.End
	addq.b	#2,obj.routine(a0)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjSnakeSub_StartWait:
	addq.b	#2,obj.routine(a0)
	clr.w	obj.y_speed(a0)
	
	move.w	#30,d0
	cmpi.b	#2,obj.subtype(a1)
	bne.s	.SetTime
	move.w	#0,d0
	
.SetTime:
	move.w	d0,oSnakeTime(a0)

; ------------------------------------------------------------------------------

ObjSnakeSub_Wait:
	subq.w	#1,oSnakeTime(a0)
	bpl.s	.End
	addq.b	#2,obj.routine(a0)
	
	bsr.w	ObjSnakeBlocks_Spawn
	beq.s	.End
	addq.b	#2,obj.routine(a0)
	movea.w	oSnakeParent(a0),a1
	st	oSnakeSpawn(a1)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjSnakeSub_WaitMove:
	rts

; ------------------------------------------------------------------------------

ObjSnakeSub_StartMoveBack:
	addq.b	#2,obj.routine(a0)
	move.w	#63,oSnakeTime(a0)
	move.w	oSnakeSolidYVel(a0),obj.y_speed(a0)
	neg.w	obj.y_speed(a0)

; ------------------------------------------------------------------------------

ObjSnakeSub_MoveBack:
	move.l	oSnakeXVel(a0),d0
	sub.l	d0,obj.x(a0)
	move.l	oSnakeYVel(a0),d0
	sub.l	d0,obj.y(a0)
	
	subq.w	#1,oSnakeTime(a0)
	bpl.s	.End
	addq.b	#2,obj.routine(a0)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjSnakeSub_StartWait2:
	addq.b	#2,obj.routine(a0)
	clr.w	obj.y_speed(a0)
	
	move.w	#30,d0
	cmpi.b	#2,obj.subtype(a1)
	bne.s	.SetTime
	move.w	#0,d0
	
.SetTime:
	move.w	d0,oSnakeTime(a0)

; ------------------------------------------------------------------------------

ObjSnakeSub_Wait2:
	subq.w	#1,oSnakeTime(a0)
	bpl.s	.End
	
	movea.w	oSnakePrev(a0),a1
	tst.b	obj.subtype(a1)
	bpl.s	.Done
	addq.b	#2,obj.routine(a1)
	
.Done:
	addq.b	#2,obj.routine(a0)
	
.End:
	rts

; ------------------------------------------------------------------------------

ObjSnakeSub_Done:
	lea	player_object,a1
	jsr	SolidObject
	beq.s	.Done
	jsr	GetOffObject
	
.Done:
	addq.l	#4,sp

; ------------------------------------------------------------------------------

ObjSnakeSub_Delete:
	jmp	DeleteObject

; ------------------------------------------------------------------------------

ObjSnakeBlocks_Spawn:
	movea.l	oSnakePath(a0),a6
	tst.b	(a6)+
	bmi.s	.End
	jsr	FindObjSlot
	bne.s	.End
	
	movea.l	a0,a2
	movea.l	a1,a3
	rept	oSnakePath/4
		move.l	(a2)+,(a3)+
	endr
	if (oSnakePath&2)<>0
		move.w	(a2)+,(a3)+
	endif
	if (oSnakePath&1)<>0
		move.b	(a2)+,(a3)+
	endif
	
	move.b	#-1,obj.subtype(a1)
	move.w	a0,oSnakePrev(a1)
	move.l	a6,oSnakePath(a1)
	addq.b	#1,obj.sprite_layer(a1)
	clr.b	obj.routine(a1)
	
.End:
	rts

; ------------------------------------------------------------------------------

MapSpr_SnakeBlocks:
	include	"Level/Wacky Workbench/Objects/Snake Blocks/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------

ObjSnakeBlocks_Paths:
	dc.w ObjSnakeBlocks_Path0-ObjSnakeBlocks_Paths
	dc.w ObjSnakeBlocks_Path1-ObjSnakeBlocks_Paths
	dc.w ObjSnakeBlocks_Path2-ObjSnakeBlocks_Paths
	dc.w ObjSnakeBlocks_Path3-ObjSnakeBlocks_Paths
	dc.w ObjSnakeBlocks_Path4-ObjSnakeBlocks_Paths
		
ObjSnakeBlocks_Path0:
	dc.w unk_20EE9A-ObjSnakeBlocks_Path0
	dc.w unk_20EE9E-ObjSnakeBlocks_Path0
	dc.w unk_20EEA2-ObjSnakeBlocks_Path0
	dc.w unk_20EEA6-ObjSnakeBlocks_Path0
	
ObjSnakeBlocks_Path3:
	dc.w unk_20EEA6-ObjSnakeBlocks_Path3
	dc.w unk_20EEA2-ObjSnakeBlocks_Path3
	dc.w unk_20EE9E-ObjSnakeBlocks_Path3
	dc.w unk_20EE9A-ObjSnakeBlocks_Path3
	
unk_20EE9A:
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	$FF
	
unk_20EE9E:
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	$FF
	
unk_20EEA2:
	dc.b	2 
	dc.b	2
	dc.b	2
	dc.b	$FF
	
unk_20EEA6:
	dc.b	3
	dc.b	3
	dc.b	3
	dc.b	$FF
	
ObjSnakeBlocks_Path1:
	dc.w unk_20EEB2-ObjSnakeBlocks_Path1
	dc.w unk_20EEB6-ObjSnakeBlocks_Path1
	dc.w unk_20EEBA-ObjSnakeBlocks_Path1
	dc.w unk_20EEBE-ObjSnakeBlocks_Path1
	
unk_20EEB2:
	dc.b	0
	dc.b	0
	dc.b	1
	dc.b	$FF
	
unk_20EEB6:
	dc.b	1
	dc.b	0
	dc.b	1
	dc.b	$FF
	
unk_20EEBA:
	dc.b	2
	dc.b	2
	dc.b	1
	dc.b	$FF
	
unk_20EEBE:
	dc.b	3
	dc.b	3
	dc.b	3
	dc.b	$FF
	
ObjSnakeBlocks_Path2:
	dc.w unk_20EECA-ObjSnakeBlocks_Path2
	dc.w unk_20EECD-ObjSnakeBlocks_Path2
	dc.w unk_20EECA-ObjSnakeBlocks_Path2
	dc.w unk_20EECD-ObjSnakeBlocks_Path2
	
unk_20EECA:
	dc.b	0 
	dc.b	0
	dc.b	$FF
	
unk_20EECD:
	dc.b	2 
	dc.b	2
	dc.b	$FF
	
ObjSnakeBlocks_Path4:
	dc.w unk_20EED8-ObjSnakeBlocks_Path4
	dc.w unk_20EEDC-ObjSnakeBlocks_Path4
	dc.w unk_20EEE0-ObjSnakeBlocks_Path4
	dc.w unk_20EEE4-ObjSnakeBlocks_Path4
	
unk_20EED8:
	dc.b	1 
	dc.b	1
	dc.b	0
	dc.b	$FF
	
unk_20EEDC:
	dc.b	2
	dc.b	3
	dc.b	3
	dc.b	$FF
	
unk_20EEE0:
	dc.b	3
	dc.b	0
	dc.b	3
	dc.b	$FF
	
unk_20EEE4:
	dc.b	0
	dc.b	1
	dc.b	0
	dc.b	$FF

; ------------------------------------------------------------------------------
