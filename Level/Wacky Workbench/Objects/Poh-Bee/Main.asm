; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Poh-Bee object
; ------------------------------------------------------------------------------

oPohTime	EQU	obj.var_2A
oPohXVel	EQU	obj.var_2C
oPohShootX	EQU	obj.var_30
oPohChkTime	EQU	obj.var_32

; ------------------------------------------------------------------------------

ObjPohBee:
	tst.b	obj.subtype(a0)
	bmi.w	ObjPohBeeMissile

	jsr	DestroyOnGoodFuture

	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	lea	Ani_PohBee(pc),a1
	jsr	AnimateObject
	jsr	DrawObject
	jmp	CheckObjDespawn

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjPohBee_Init-.Index
	dc.w	ObjPohBee_MoveStart-.Index
	dc.w	ObjPohBee_Move-.Index
	dc.w	ObjPohBee_WaitFlipStart-.Index
	dc.w	ObjPohBee_WaitFlip-.Index
	dc.w	ObjPohBee_WaitMove-.Index
	dc.w	ObjPohBee_WaitShootStart-.Index
	dc.w	ObjPohBee_WaitShoot-.Index
	dc.w	ObjPohBee_Shoot-.Index
	dc.w	ObjPohBee_ShootDone-.Index

; ------------------------------------------------------------------------------

ObjPohBee_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#1,obj.sprite_layer(a0)
	move.b	#24,obj.collide_width(a0)
	move.b	#24,obj.width(a0)
	move.b	#12,obj.collide_height(a0)
	move.w	#$A457,obj.sprite_tile(a0)
	move.b	#$31,obj.collide_type(a0)
	move.w	#-8,oPohShootX(a0)

	lea	MapSpr_PohBee(pc),a1
	move.l	#-$10000,d0
	tst.b	obj.subtype(a0)
	beq.s	.NotDamaged
	lea	MapSpr_PohBeeDamaged(pc),a1
	move.l	#-$8000,d0

.NotDamaged:
	move.l	a1,obj.sprites(a0)
	move.l	d0,oPohXVel(a0)

; ------------------------------------------------------------------------------

ObjPohBee_MoveStart:
	addq.b	#2,obj.routine(a0)
	move.w	#$200,d0
	tst.b	obj.subtype(a0)
	beq.s	.SetTime
	move.w	#$400,d0

.SetTime:
	move.w	d0,oPohTime(a0)

; ------------------------------------------------------------------------------

ObjPohBee_Move:
	move.l	oPohXVel(a0),d0
	add.l	d0,obj.x(a0)
	tst.b	obj.subtype(a0)
	bne.s	.DecTime
	tst.w	oPohChkTime(a0)
	beq.s	.CheckPlayer
	subq.w	#1,oPohChkTime(a0)
	bra.s	.DecTime

.CheckPlayer:
	lea	player_object,a1
	bsr.s	ObjPohBee_CheckPlayer
	beq.s	.DecTime
	move.b	#$C,obj.routine(a0)
	rts

.DecTime:
	subq.w	#1,oPohTime(a0)
	bpl.s	.End
	move.b	#6,obj.routine(a0)

.End:
	rts

; ------------------------------------------------------------------------------

ObjPohBee_CheckPlayer:
	move.w	obj.y(a1),d0
	sub.w	obj.y(a0),d0
	subi.w	#-96,d0
	subi.w	#192,d0
	bcc.s	.NotFound

	move.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	spl	d1
	subi.w	#-120,d0
	subi.w	#240,d0
	bcc.s	.NotFound

	btst	#0,obj.sprite_flags(a0)
	sne	d2
	eor.b	d1,d2
	beq.s	.FoundPlayer

	neg.l	oPohXVel(a0)
	neg.w	oPohShootX(a0)
	bchg	#0,obj.sprite_flags(a0)
	bchg	#0,obj.flags(a0)

.FoundPlayer:
	moveq	#-1,d0
	rts

.NotFound:
	moveq	#0,d0
	rts

; ------------------------------------------------------------------------------

ObjPohBee_WaitFlipStart:
	addq.b	#2,obj.routine(a0)
	move.w	#30,oPohTime(a0)

; ------------------------------------------------------------------------------

ObjPohBee_WaitFlip:
	subq.w	#1,oPohTime(a0)
	bpl.s	.End
	addq.b	#2,obj.routine(a0)
	move.w	#30,oPohTime(a0)

	neg.l	oPohXVel(a0)
	neg.w	oPohShootX(a0)
	bchg	#0,obj.sprite_flags(a0)
	bchg	#0,obj.flags(a0)

.End:
	rts

; ------------------------------------------------------------------------------

ObjPohBee_WaitMove:
	subq.w	#1,oPohTime(a0)
	bpl.s	.End
	move.b	#2,obj.routine(a0)

.End:
	rts

; ------------------------------------------------------------------------------

ObjPohBee_WaitShootStart:
	addq.b	#2,obj.routine(a0)
	move.w	#30,oPohTime(a0)

; ------------------------------------------------------------------------------

ObjPohBee_WaitShoot:
	subq.w	#1,oPohTime(a0)
	bpl.s	.End
	addq.b	#2,obj.routine(a0)
	move.w	#30,oPohTime(a0)

	move.b	#1,obj.anim_id(a0)
	move.b	#$32,obj.collide_type(a0)
	move.b	#16,obj.collide_height(a0)
	move.b	#16,obj.collide_width(a0)
	move.b	#16,obj.width(a0)

	move.w	oPohShootX(a0),d0
	add.w	d0,obj.x(a0)
	addq.w	#4,obj.y(a0)

.End:
	rts

; ------------------------------------------------------------------------------

ObjPohBee_Shoot:
	subq.w	#1,oPohTime(a0)
	bpl.w	.End
	addq.b	#2,obj.routine(a0)
	move.w	#30,oPohTime(a0)

	jsr	FindObjSlot
	bne.w	.End
	move.b	obj.id(a0),obj.id(a1)
	move.b	#-1,obj.subtype(a1)
	move.b	obj.sprite_flags(a0),obj.sprite_flags(a1)
	move.w	obj.sprite_tile(a0),obj.sprite_tile(a1)
	move.l	#MapSpr_PohBeeMissile,obj.sprites(a1)
	move.b	#1,obj.sprite_layer(a1)
	move.b	#16,obj.collide_height(a1)
	move.b	#16,obj.collide_width(a1)
	move.b	#16,obj.width(a1)
	move.b	#$B3,obj.collide_type(a1)
	move.w	obj.y(a0),obj.y(a1)
	addi.w	#23,obj.y(a1)
	move.l	#$20000,oPohMissYVel(a1)

	move.w	obj.x(a0),obj.x(a1)
	move.w	#7,d0
	move.l	#$20000,d1
	btst	#0,obj.sprite_flags(a0)
	bne.s	.SetX
	neg.w	d0
	neg.l	d1

.SetX:
	add.w	d0,obj.x(a1)
	move.l	d1,oPohMissXVel(a1)

	tst.b	obj.sprite_flags(a0)
	bpl.s	.End
	move.w	#FM_A0,d0
	jsr	PlayFMSound

.End:
	rts

; ------------------------------------------------------------------------------

ObjPohBee_ShootDone:
	subq.w	#1,oPohTime(a0)
	bpl.s	.End
	move.b	#2,obj.routine(a0)
	move.w	#60,oPohChkTime(a0)

	move.b	#0,obj.anim_id(a0)
	move.b	#$31,obj.collide_type(a0)
	move.b	#12,obj.collide_height(a0)
	move.b	#24,obj.collide_width(a0)
	move.b	#24,obj.width(a0)
	move.w	oPohShootX(a0),d0
	sub.w	d0,obj.x(a0)
	subq.w	#4,obj.y(a0)

.End:
	rts

; ------------------------------------------------------------------------------

Ani_PohBee:
	include	"Level/Wacky Workbench/Objects/Poh-Bee/Data/Animations (Normal).asm"
	even

MapSpr_PohBee:
	include	"Level/Wacky Workbench/Objects/Poh-Bee/Data/Mappings (Normal).asm"
	even

MapSpr_PohBeeDamaged:
	include	"Level/Wacky Workbench/Objects/Poh-Bee/Data/Mappings (Damaged).asm"
	even

; ------------------------------------------------------------------------------
; Poh-Bee missile
; ------------------------------------------------------------------------------

oPohMissTime	EQU	obj.var_2A
oPohMissXVel	EQU	obj.var_2C
oPohMissYVel	EQU	obj.var_30

; ------------------------------------------------------------------------------

ObjPohBeeMissile:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	jsr	DrawObject
	jmp	CheckObjDespawn

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjPohBeeMissile_Init-.Index
	dc.w	ObjPohBeeMissile_Main-.Index
	dc.w	ObjPohBeeMissile_Move-.Index
	dc.w	ObjPohBeeMissile_Move2-.Index

; ------------------------------------------------------------------------------

ObjPohBeeMissile_Init:
	addq.b	#2,obj.routine(a0)
	move.w	#3,oPohMissTime(a0)

; ------------------------------------------------------------------------------

ObjPohBeeMissile_Main:
	subq.w	#1,oPohMissTime(a0)
	bpl.s	.End

	addq.b	#2,obj.routine(a0)
	move.b	#1,obj.sprite_frame(a0)
	move.w	#10,oPohMissTime(a0)

.End:
	rts

; ------------------------------------------------------------------------------

ObjPohBeeMissile_Move:
	move.l	oPohMissXVel(a0),d0
	add.l	d0,obj.x(a0)
	move.l	oPohMissYVel(a0),d0
	add.l	d0,obj.y(a0)

	subq.w	#1,oPohMissTime(a0)
	bpl.s	.End
	addq.b	#2,obj.routine(a0)

.End:
	rts

; ------------------------------------------------------------------------------

ObjPohBeeMissile_Move2:
	tst.b	obj.sprite_flags(a0)
	bmi.s	.OnScreen
	jmp	DeleteObject

.OnScreen:
	move.l	oPohMissXVel(a0),d0
	add.l	d0,obj.x(a0)
	move.l	oPohMissYVel(a0),d0
	add.l	d0,obj.y(a0)

	lea	Ani_PohBeeMissile(pc),a1
	jmp	AnimateObject

; ------------------------------------------------------------------------------

Ani_PohBeeMissile:
	include	"Level/Wacky Workbench/Objects/Poh-Bee/Data/Animations (Missile).asm"
	even


MapSpr_PohBeeMissile:
	include	"Level/Wacky Workbench/Objects/Poh-Bee/Data/Mappings (Missile).asm"
	even

; ------------------------------------------------------------------------------
