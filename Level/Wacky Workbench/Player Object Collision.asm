; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Wacky Workbench object collision
; ------------------------------------------------------------------------------

Player_ObjCollide:
	btst	#6,oPlayerCtrl(a0)
	beq.s	.NotInvisible
	moveq	#0,d0
	rts

.NotInvisible:
	nop
	move.w	obj.x(a0),d2
	move.w	obj.y(a0),d3
	subq.w	#8,d2
	moveq	#0,d5
	move.b	obj.collide_height(a0),d5
	subq.b	#3,d5
	sub.w	d5,d3
	cmpi.b	#$39,obj.sprite_frame(a0)
	bne.s	.NoDuck
	addi.w	#$C,d3
	moveq	#$A,d5

.NoDuck:
	move.w	#$10,d4
	add.w	d5,d5
	lea	object_spawn_pool,a1
	move.w	#OBJECT_SPAWN_COUNT-1,d6

.Loop:
	tst.b	obj.sprite_flags(a1)
	bpl.s	.Next
	move.b	obj.collide_type(a1),d0
	bne.s	.CheckWidth

.Next:
	lea	obj.struct_size(a1),a1
	dbf	d6,.Loop
	moveq	#0,d0
	rts

; ------------------------------------------------------------------------------

.CheckWidth:
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	ObjColSizes,a2
	lea	-2(a2,d0.w),a2
	moveq	#0,d1
	move.b	(a2)+,d1
	move.w	obj.x(a1),d0
	sub.w	d1,d0
	sub.w	d2,d0
	bcc.s	.TouchRight
	add.w	d1,d1
	add.w	d1,d0
	bcs.s	.CheckHeight
	bra.w	.Next

; ------------------------------------------------------------------------------

.TouchRight:
	cmp.w	d4,d0
	bhi.w	.Next

.CheckHeight:
	moveq	#0,d1
	move.b	(a2)+,d1
	move.w	obj.y(a1),d0
	sub.w	d1,d0
	sub.w	d3,d0
	bcc.s	.TouchBottom
	add.w	d1,d1
	add.w	d0,d1
	bcs.s	.CheckColType
	bra.w	.Next

; ------------------------------------------------------------------------------

.TouchBottom:
	cmp.w	d5,d0
	bhi.w	.Next

.CheckColType:
	move.b	obj.collide_type(a1),d1
	andi.b	#$C0,d1
	beq.w	Player_TouchEnemy
	cmpi.b	#$C0,d1
	beq.w	Player_TouchSpecial
	tst.b	d1
	bmi.w	Player_TouchHazard
	move.b	obj.collide_type(a1),d0
	andi.b	#$3F,d0
	cmpi.b	#6,d0
	beq.s	Player_TouchMonitor
	cmpi.w	#$5A,oPlayerHurt(a0)
	bcc.w	.End
	addq.b	#2,obj.routine(a1)

.End:
	rts

; ------------------------------------------------------------------------------

Player_TouchMonitor:
	tst.w	obj.y_speed(a0)
	bpl.s	.GoingDown
	move.w	obj.y(a0),d0
	subi.w	#$10,d0
	cmp.w	obj.y(a1),d0
	bcs.s	.End2
	neg.w	obj.y_speed(a0)
	move.w	#-$180,obj.y_speed(a1)
	tst.b	oMonitorFall(a1)
	bne.s	.End2
	addq.b	#4,oMonitorFall(a1)
	rts

; ------------------------------------------------------------------------------

.GoingDown:
	cmpi.b	#2,obj.anim_id(a0)
	bne.s	.End2
	neg.w	obj.y_speed(a0)
	addq.b	#2,obj.routine(a1)

.End2:
	rts
; End of function ObjSonic_ObjCollide

; ------------------------------------------------------------------------------

Player_TouchEnemy:
	tst.b	time_warp
	bne.s	.DamageEnemy
	tst.b	invincible
	bne.s	.DamageEnemy
	cmpi.b	#2,obj.anim_id(a0)
	bne.w	Player_TouchHazard

.DamageEnemy:
	tst.b	obj.collide_status(a1)
	beq.s	.KillEnemy
	neg.w	obj.x_speed(a0)
	neg.w	obj.y_speed(a0)
	asr	obj.x_speed(a0)
	asr	obj.y_speed(a0)
	move.b	#0,obj.collide_type(a1)
	subq.b	#1,obj.collide_status(a1)
	bne.s	.End
	bset	#7,obj.flags(a1)

.End:
	rts

; ------------------------------------------------------------------------------

.KillEnemy:
	bset	#7,obj.flags(a1)
	moveq	#0,d0
	move.w	score_chain,d0
	addq.w	#2,score_chain
	cmpi.w	#6,d0
	bcs.s	.CappedChain
	moveq	#6,d0

.CappedChain:
	move.w	d0,obj.var_3E(a1)
	move.w	EnemyPoints(pc,d0.w),d0
	cmpi.w	#$20,score_chain
	bcs.s	.GivePoints
	move.w	#1000,d0
	move.w	#$A,obj.var_3E(a1)

.GivePoints:
	bsr.w	AddPoints
	move.w	#FM_DESTROY,d0
	jsr	PlayFMSound
	move.b	#$18,obj.id(a1)
	move.b	#0,obj.routine(a1)
	move.b	#1,obj.subtype(a1)
	tst.w	obj.y_speed(a0)
	bmi.s	.BounceDown
	move.w	obj.y(a0),d0
	cmp.w	obj.y(a1),d0
	bcc.s	.BounceUp
	neg.w	obj.y_speed(a0)
	rts

; ------------------------------------------------------------------------------

.BounceDown:
	addi.w	#$100,obj.y_speed(a0)
	rts

; ------------------------------------------------------------------------------

.BounceUp:
	subi.w	#$100,obj.y_speed(a0)
	rts

; ------------------------------------------------------------------------------

EnemyPoints:
	dc.w	10
	dc.w	20
	dc.w	50
	dc.w	100

; ------------------------------------------------------------------------------

Player_TouchHazard2:
	bset	#7,obj.flags(a1)

Player_TouchHazard:
	tst.b	time_warp
	bne.s	.NoHurt
	tst.b	invincible
	beq.s	.ChkHurt

.NoHurt:
	moveq	#-1,d0
	rts

; ------------------------------------------------------------------------------

.ChkHurt:
	nop
	tst.w	oPlayerHurt(a0)
	bne.s	.NoHurt
	movea.l	a1,a2

HurtPlayer:
	clr.b	oPlayerCharge(a0)
	andi.b	#%11100111,oPlayerCtrl(a0)
	clr.w	oPlayerMoveLock(a0)

	tst.b	shield
	bne.s	.ClearShield
	tst.w	rings
	beq.w	.CheckKill
	jsr	FindObjSlot
	bne.s	.ClearShield
	move.b	#$11,obj.id(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)

.ClearShield:
	bclr	#0,shield
	bne.s	.SetHurt
	move.b	#0,combine_ring

.SetHurt:
	move.b	#4,obj.routine(a0)
	bsr.w	Player_ResetOnFloor
	bset	#1,obj.flags(a0)
	move.w	#-$400,obj.y_speed(a0)
	move.w	#-$200,obj.x_speed(a0)
	btst	#6,obj.flags(a0)
	beq.s	.NoWater
	move.w	#-$200,obj.y_speed(a0)
	move.w	#-$100,obj.x_speed(a0)

.NoWater:
	move.w	obj.x(a0),d0
	cmp.w	obj.x(a2),d0
	bcs.s	.GotXVel
	neg.w	obj.x_speed(a0)

.GotXVel:
	move.w	#0,oPlayerGVel(a0)
	move.b	#$1A,obj.anim_id(a0)
	move.w	#$78,oPlayerHurt(a0)
	moveq	#-1,d0
	rts

; ------------------------------------------------------------------------------

.CheckKill:
	tst.w	debug_cheat
	bne.w	.ClearShield
; End of function Player_TouchEnemy

; ------------------------------------------------------------------------------

KillPlayer:
	tst.w	debug_mode
	bne.s	.End
	move.b	#0,invincible
	move.b	#6,obj.routine(a0)
	bsr.w	Player_ResetOnFloor
	bset	#1,obj.flags(a0)
	move.w	#-$700,obj.y_speed(a0)
	move.w	#0,obj.x_speed(a0)
	move.w	#0,oPlayerGVel(a0)
	move.w	obj.y(a0),oPlayerStick(a0)
	move.b	#$18,obj.anim_id(a0)
	bset	#7,obj.sprite_tile(a0)
	move.b	#0,obj.sprite_layer(a0)
	move.w	#FM_HURT,d0
	jsr	PlayFMSound

.End:
	moveq	#-1,d0
	rts
; End of function KillPlayer
; ------------------------------------------------------------------------------

Player_TouchSpecial:
	move.b	obj.collide_type(a1),d1
	andi.b	#$3F,d1
	cmpi.b	#$1F,d1
	beq.w	.FlagCollision
	cmpi.b	#$23,d1
	beq.w	.FlagCollision
	
	cmpi.b	#$38,d1
	beq.w	.FlagColRoll
	cmpi.b	#$3A,d1
	beq.w	.FlagColRoll
	cmpi.b	#$3B,d1
	beq.w	.FlagColRoll
	
	tst.b	boss_fight
	beq.w	.End
	cmpi.b	#1,boss_fight
	beq.s	.Boss
	cmpi.b	#4,boss_fight
	beq.s	.TTZBoss
	cmpi.b	#5,boss_fight
	beq.s	.QQZBoss
	
.Boss:
	cmpi.b	#$3C,d1
	blt.s	.End
	cmpi.b	#$3F,d1
	bgt.s	.End
	bsr.w	Player_TouchEnemy
	tst.b	obj.collide_type(a1)
	bne.s	.NoResetHits
	addq.b	#3,obj.collide_status(a1)

.NoResetHits:
	clr.b	obj.collide_type(a1)
	bra.w	.FlagCollision

.TTZBoss:
	cmpi.b	#$3F,d1
	beq.s	.Bubble
	cmpi.b	#$3E,d1
	beq.s	.Hazard
	bra.s	.End

.QQZBoss:
	cmpi.b	#$3D,d1
	beq.s	.Hazard
	
.End:
	rts

; ------------------------------------------------------------------------------

.FlagCollision:
	addq.b	#1,obj.collide_status(a1)
	rts

; ------------------------------------------------------------------------------

.Hazard:
	bsr.w	Player_TouchHazard
	bra.s	.FlagCollision

; ------------------------------------------------------------------------------

.Bubble:
	move.b	obj.flags(a0),d0
	andi.b	#%10100,d0
	beq.s	.End2
	bclr	#2,obj.flags(a0)
	bclr	#4,obj.flags(a0)
	clr.b	obj.collide_type(a1)
	move.b	#$15,obj.anim_id(a0)
	move.w	#$400,obj.y_speed(a0)
	move.w	#-$200,obj.x_speed(a0)
	move.w	obj.x(a0),d0
	cmp.w	obj.x(a1),d0
	bcs.s	.End2
	neg.w	obj.x_speed(a0)
	
.End2:
	rts

; ------------------------------------------------------------------------------

.FlagColRoll:
	cmpi.b	#2,obj.anim_id(a0)
	bne.s	.End3
	addq.b	#1,obj.collide_status(a1)
	
.End3:
	rts

; ------------------------------------------------------------------------------
ObjColSizes:
	dc.b	$14, $14
	dc.b	$12, $C
	dc.b	$10, $10
	dc.b	4, $10
	dc.b	$C, $12
	dc.b	$10, $10
	dc.b	6, 6
	dc.b	$18, $C
	dc.b	$C, $10
	dc.b	$10, $C
	dc.b	8, 8
	dc.b	$14, $10
	dc.b	$14, 8
	dc.b	$E, $E
	dc.b	$18, $18
	dc.b	$28, $10
	dc.b	$10, $18
	dc.b	8, $10
	dc.b	$20, $70
	dc.b	$40, $20
	dc.b	$80, $20
	dc.b	$20, $20
	dc.b	8, 8
	dc.b	4, 4
	dc.b	$20, 8
	dc.b	$C, $C
	dc.b	8, 4
	dc.b	$18, 4
	dc.b	$28, 4
	dc.b	4, 8
	dc.b	4, $18
	dc.b	4, $28
	dc.b	4, $20
	dc.b	$18, $18
	dc.b	$C, $18
	dc.b	$48, 8
	dc.b	8, $C
	dc.b	$10, 8
	dc.b	$20, $10
	dc.b	$20, $10
	dc.b	0, 0
	dc.b	0, 0
	dc.b	0, 0
	dc.b	0, 0
	dc.b	0, 0
	dc.b	0, 0
	dc.b	8, $13
	dc.b	8, $1C
	dc.b	$18, $C
	dc.b	$10, $10
	dc.b	4, 4
	dc.b	8, $10
	dc.b	$10, 5
	dc.b	$C, $C
	dc.b	8, 8
	dc.b	$1A, $1E
	dc.b	8, 8
	dc.b	$28, $24
	dc.b	$12, $11
	dc.b	$1E, $30
	dc.b	$3C, $20
	dc.b	$10, 8
	dc.b	2, $C

; ------------------------------------------------------------------------------
