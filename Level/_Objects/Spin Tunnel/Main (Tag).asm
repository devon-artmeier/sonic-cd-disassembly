; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Spin tunnel flag object
; ------------------------------------------------------------------------------

ObjSpinTunnel:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjSpinTunnel_Index(pc,d0.w),d0
	jsr	ObjSpinTunnel_Index(pc,d0.w)
	tst.b	debug_cheat
	beq.s	.NoDisplay
	jsr	DrawObject

.NoDisplay:
	jmp	CheckObjDespawn
; End of function ObjSpinTunnel

; ------------------------------------------------------------------------------
ObjSpinTunnel_Index:
	dc.w	ObjSpinTunnel_Init-ObjSpinTunnel_Index
	dc.w	ObjSpinTunnel_Main-ObjSpinTunnel_Index
; ------------------------------------------------------------------------------

ObjSpinTunnel_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#%00000100,obj.sprite_flags(a0)
	move.w	#$544,obj.sprite_tile(a0)
	move.l	#MapSpr_Powerup,obj.sprites(a0)
	move.b	obj.subtype(a0),obj.sprite_frame(a0)
	addq.b	#1,obj.sprite_frame(a0)
; End of function ObjSpinTunnel_Init

; ------------------------------------------------------------------------------

ObjSpinTunnel_Main:
	lea	player_object,a1
	cmpi.b	#$2B,obj.anim_id(a1)
	beq.w	.End
	cmpi.b	#6,obj.routine(a1)
	bcc.w	.End
	bsr.w	ObjSpinTunnel_CheckInRange
	beq.w	.End
	tst.b	obj.subtype(a0)
	bne.s	.ChkSubtype1
	move.w	obj.x_speed(a1),d0
	bpl.s	.AbsVX
	neg.w	d0

.AbsVX:
	move.w	#$A00,d1
	cmpi.b	#5,zone
	bne.s	.GotXCap
	move.w	#$D00,d1

.GotXCap:
	cmp.w	d1,d0
	bcc.s	.CheckXSign
	move.w	d1,d0

.CheckXSign:
	tst.w	obj.x_speed(a1)
	bpl.s	.GotSpeed
	neg.w	d0

.GotSpeed:
	move.w	d0,obj.x_speed(a1)
	move.w	d0,oPlayerGVel(a1)
	move.b	obj.angle(a1),d0
	addi.b	#$20,d0
	andi.b	#$C0,d0
	cmpi.b	#$80,d0
	bne.s	.SetRoll
	neg.w	oPlayerGVel(a1)
	bra.s	.SetRoll

; ------------------------------------------------------------------------------

.ChkSubtype1:
	cmpi.b	#2,obj.subtype(a0)
	bcc.s	.HighSubtype

.Subtype1:
	move.w	obj.y_speed(a1),d0
	bpl.s	.AbsVY
	neg.w	d0

.AbsVY:
	cmpi.w	#$D00,d0
	bcc.s	.GotYCap
	move.w	#$D00,d0

.GotYCap:
	tst.w	obj.y_speed(a1)
	bpl.s	.CheckYSign
	neg.w	d0

.CheckYSign:
	move.w	d0,obj.y_speed(a1)
	move.w	d0,oPlayerGVel(a1)
	bset	#1,obj.flags(a1)

.SetRoll:
	bset	#2,obj.flags(a1)
	bne.s	.End
	move.b	#$E,obj.collide_height(a1)
	move.b	#7,obj.collide_width(a1)
	addq.w	#5,obj.y(a1)
	move.b	#2,obj.anim_id(a1)

.End:
	rts

; ------------------------------------------------------------------------------

.HighSubtype:
	move.b	p1_ctrl_hold,d1
	cmpi.b	#4,obj.subtype(a0)
	beq.s	.Subtype4
	cmpi.b	#2,obj.subtype(a0)
	bne.s	.Subtype3

.Subtype2:
	tst.w	obj.y_speed(a1)
	bpl.s	.SetRoll
	bra.s	.ChkLaunch

; ------------------------------------------------------------------------------

.Subtype3:
	tst.w	obj.y_speed(a1)
	bmi.s	.SetRoll

.ChkLaunch:
	move.w	#$D00,d0
	btst	#3,d1
	bne.s	.GotLaunch
	btst	#2,d1
	beq.s	.SetRoll
	neg.w	d0

.GotLaunch:
	cmpi.b	#2,obj.subtype(a0)
	beq.s	.SkipAir
	bset	#1,obj.flags(a1)

.SkipAir:
	move.w	d0,obj.x_speed(a1)
	move.w	d0,oPlayerGVel(a1)
	bra.s	.SetRoll

; ------------------------------------------------------------------------------

.Subtype4:
	tst.w	obj.x_speed(a1)
	bmi.s	.SetRoll
	btst	#0,d1
	beq.w	.SetRoll
	move.w	#-$A00,d0
	bra.w	.CheckYSign
; End of function ObjSpinTunnel_Main

; ------------------------------------------------------------------------------

ObjSpinTunnel_CheckInRange:
	tst.b	debug_mode
	bne.s	.NotInRange
	move.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	addi.w	#$28,d0
	bmi.s	.NotInRange
	cmpi.w	#$50,d0
	bcc.s	.NotInRange
	move.w	obj.y(a1),d0
	sub.w	obj.y(a0),d0
	addi.w	#$28,d0
	bmi.s	.NotInRange
	cmpi.w	#$50,d0
	bcc.s	.NotInRange
	moveq	#1,d0
	rts

; ------------------------------------------------------------------------------

.NotInRange:
	moveq	#0,d0
	rts

; ------------------------------------------------------------------------------
