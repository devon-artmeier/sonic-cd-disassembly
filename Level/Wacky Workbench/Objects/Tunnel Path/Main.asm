; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Tunnel path object
; ------------------------------------------------------------------------------

oTunnelSteps	EQU	obj.var_2E
oTunnelVar32	EQU	obj.var_32
oTunnelX	EQU	obj.var_36
oTunnelY	EQU	obj.var_38
oTunnelIndex	EQU	obj.var_3A
oTunnelEnd	EQU	obj.var_3B
oTunnelData	EQU	obj.var_3C

; ------------------------------------------------------------------------------

ObjTunnelPath:
	btst	#7,time_zone
	beq.s	.NoTimeTravel

	moveq	#0,d0
	move.b	obj.state_id(a0),d0
	beq.s	.NoTimeTravel
	
	lea	map_object_states,a1
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	time_zone,d1
	bclr	#7,d1
	move.b	time_warp_direction,d2
	ext.w	d2
	neg.w	d2
	add.w	d2,d1
	bpl.s	.CapTimeZone
	moveq	#0,d1
	bra.s	.MarkUnloaded
	
.CapTimeZone:
	cmpi.w	#3,d1
	bcs.s	.MarkUnloaded
	moveq	#2,d1
	
.MarkUnloaded:
	add.w	d1,d0
	bclr	#7,2(a1,d0.w)

.NoTimeTravel:
	lea	player_object,a6
	cmpi.b	#$2B,obj.anim_id(a6)
	beq.s	.End
	cmpi.b	#6,obj.routine(a6)
	bcc.s	.End
	
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d1
	jsr	.Index(pc,d1.w)
	
	cmpi.b	#4,obj.routine(a0)
	bcc.s	.End
	jmp	CheckObjDespawn

.End:
	rts
	
; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjTunnelPath_Init-.Index
	dc.w	ObjTunnelPath_Main-.Index
	dc.w	ObjTunnelPath_GotPlayer-.Index
	dc.w	ObjTunnelPath_MovePlayer-.Index
	
; ------------------------------------------------------------------------------

ObjTunnelPath_Init:
	move.l	#MapSpr_Powerup,obj.sprites(a0)
	move.b	#4,obj.sprite_flags(a0)
	move.b	#1,obj.sprite_layer(a0)
	move.b	#$10,obj.width(a0)
	move.w	#$541,obj.sprite_tile(a0)
	addq.b	#2,obj.routine(a0)
	
	move.b	obj.subtype(a0),d0
	andi.b	#$7F,d0
	add.w	d0,d0
	andi.w	#$FE,d0
	lea	ObjTunnelPath_Paths(pc),a2
	adda.w	(a2,d0.w),a2
	move.w	(a2)+,oTunnelIndex(a0)
	move.l	a2,oTunnelData(a0)
	move.w	(a2)+,oTunnelX(a0)
	move.w	(a2)+,oTunnelY(a0)
	
; ------------------------------------------------------------------------------

ObjTunnelPath_Main:
	cmpi.b	#6,obj.routine(a6)
	bcc.w	.End
	
	move.w	obj.x(a6),d0
	sub.w	obj.x(a0),d0
	addi.w	#32,d0
	cmpi.w	#64,d0
	bcc.w	.End
	
	move.w	obj.y(a6),d1
	sub.w	obj.y(a0),d1
	addi.w	#48,d1
	cmpi.w	#96,d1
	bcc.w	.End
	
	tst.b	oPlayerCtrl(a6)
	bne.w	.End
	
	cmpi.b	#4,obj.routine(a6)
	bne.s	.NotHurt
	subq.b	#2,obj.routine(a6)
	move.w	#$78,oPlayerHurt(a6)
	
.NotHurt:
	addq.b	#2,obj.routine(a0)
	move.b	#%10000001,oPlayerCtrl(a6)
	tst.b	obj.subtype_2(a0)
	beq.s	.NoInvisiblePlayer
	bset	#6,oPlayerCtrl(a6)
	
.NoInvisiblePlayer:
	move.b	#2,obj.anim_id(a6)
	move.w	#$800,oPlayerGVel(a6)
	bclr	#6,obj.sprite_flags(a6)
	tst.b	obj.subtype(a0)
	bpl.s	.NotHighLayer
	bset	#6,obj.sprite_flags(a6)
	
.NotHighLayer:
	cmpi.b	#4,obj.routine(a6)
	bne.s	.NotHurt2
	subq.b	#2,obj.routine(a6)
	
.NotHurt2:
	move.w	#0,obj.x_speed(a6)
	move.w	#0,obj.y_speed(a6)
	bclr	#5,obj.flags(a0)
	bclr	#5,obj.flags(a6)
	bset	#1,obj.flags(a6)
	move.w	obj.x(a0),obj.x(a6)
	move.w	obj.y(a0),obj.y(a6)
	clr.b	oTunnelVar32(a0)
	move.w	#FM_91,d0
	jsr	PlayFMSound
	
.End:
	rts
	
; ------------------------------------------------------------------------------

ObjTunnelPath_GotPlayer:
	move.b	#2,obj.anim_id(a6)
	bsr.w	ObjTunnelPath_SetPlayerSpeed
	addq.b	#2,obj.routine(a0)
	move.w	#FM_91,d0
	jsr	PlayFMSound
	rts
	
; ------------------------------------------------------------------------------

ObjTunnelPath_MovePlayer:
	move.b	#2,obj.anim_id(a6)
	addq.l	#4,sp
	
	subq.b	#1,oTunnelSteps(a0)
	bpl.s	.Move
	
	move.w	oTunnelX(a0),d0
	add.w	obj.x(a0),d0
	move.w	d0,obj.x(a6)
	move.w	oTunnelY(a0),d0
	add.w	obj.y(a0),d0
	move.w	d0,obj.y(a6)
	
	moveq	#0,d1
	move.b	oTunnelIndex(a0),d1
	addq.b	#6,d1
	cmp.b	oTunnelEnd(a0),d1
	bcs.s	.NotEnd
	moveq	#0,d1
	bra.s	.Release
	
.NotEnd:
	move.b	d1,oTunnelIndex(a0)
	
.SetTargetPos:
	movea.l	oTunnelData(a0),a2
	move.w	(a2,d1.w),oTunnelX(a0)
	move.w	2(a2,d1.w),oTunnelY(a0)
	bra.w	ObjTunnelPath_SetPlayerSpeed
	
.Move:
	move.l	obj.x(a6),d2
	move.l	obj.y(a6),d3
	move.w	obj.x_speed(a6),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d2
	move.w	obj.y_speed(a6),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d3
	move.l	d2,obj.x(a6)
	move.l	d3,obj.y(a6)
	
	moveq	#0,d1
	move.b	oTunnelIndex(a0),d1
	movea.l	oTunnelData(a0),a2
	move.w	4(a2,d1.w),d1
	bmi.s	.CheckExit
	
.End:
	rts
	
.CheckExit:
	move.b	p1_ctrl_hold,d0
	andi.b	#$70,d0
	beq.s	.End
	
	andi.w	#$7FFF,d1
	add.b	d1,d1
	move.b	d1,d0
	add.b	d0,d0
	add.b	d0,d1
	add.b	oTunnelEnd(a0),d1
	move.b	d1,oTunnelIndex(a0)
	bra.s	.SetTargetPos

.Release:
	andi.w	#$7FF,obj.y(a6)
	clr.b	obj.routine(a0)
	clr.b	oPlayerCtrl(a6)
	move.w	#2,obj.routine(a0)
	rts

; ------------------------------------------------------------------------------

ObjTunnelPath_SetPlayerSpeed:
	moveq	#0,d0
	move.w	oPlayerGVel(a6),d2
	move.w	oPlayerGVel(a6),d3
	move.w	oTunnelX(a0),d0
	add.w	obj.x(a0),d0
	sub.w	obj.x(a6),d0
	bge.s	.PlayerLeft
	neg.w	d0
	neg.w	d2

.PlayerLeft:
	moveq	#0,d1
	move.w	oTunnelY(a0),d1
	add.w	obj.y(a0),d1
	sub.w	obj.y(a6),d1
	bge.s	.PlayerAbove
	neg.w	d1
	neg.w	d3

.PlayerAbove:
	cmp.w	d0,d1
	bcs.s	.XGreater
	moveq	#0,d1
	move.w	oTunnelY(a0),d1
	add.w	obj.y(a0),d1
	sub.w	obj.y(a6),d1
	swap	d1
	divs.w	d3,d1
	moveq	#0,d0
	move.w	oTunnelX(a0),d0
	add.w	obj.x(a0),d0
	sub.w	obj.x(a6),d0
	beq.s	.SetSpeed
	swap	d0
	divs.w	d1,d0

.SetSpeed:
	move.w	d0,obj.x_speed(a6)
	move.w	d3,obj.y_speed(a6)
	tst.w	d1
	bpl.s	.SetSteps
	neg.w	d1

.SetSteps:
	move.w	d1,oTunnelSteps(a0)
	rts

; ------------------------------------------------------------------------------

.XGreater:
	moveq	#0,d0
	move.w	oTunnelX(a0),d0
	add.w	obj.x(a0),d0
	sub.w	obj.x(a6),d0
	swap	d0
	divs.w	d2,d0
	moveq	#0,d1
	move.w	oTunnelY(a0),d1
	add.w	obj.y(a0),d1
	sub.w	obj.y(a6),d1
	beq.s	.SetSpeed2
	swap	d1
	divs.w	d0,d1

.SetSpeed2:
	move.w	d1,obj.y_speed(a6)
	move.w	d2,obj.x_speed(a6)
	tst.w	d0
	bpl.s	.SetSteps2
	neg.w	d0

.SetSteps2:
	move.w	d0,oTunnelSteps(a0)
	rts

; ------------------------------------------------------------------------------

ObjTunnelPath_Paths:
	dc.w	ObjTunnelPath_Path0-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path1-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path2-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path3-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path4-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path5-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path6-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path7-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path8-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path9-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path10-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path11-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path12-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path13-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path14-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path15-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path16-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path17-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path18-ObjTunnelPath_Paths
	
ObjTunnelPath_Path0:
	dc.w	$4E
	dc.w	0, 0, 0
	dc.w	8, $20, 0
	dc.w	0, $48, 0
	dc.w	$FFE8, $60, 0
	dc.w	$FFB8, $70, 0
	dc.w	$FF88, $60, 0
	dc.w	$FF70, $48, 0
	dc.w	$FF68, $20, 0
	dc.w	$FF70, 0, 0
	dc.w	$FF88, $FFE0, $8001
	dc.w	$FFB8, $FFD0, 0
	dc.w	$FFE8, $FFE0, $8000
	dc.w	0, 0, $8000
	dc.w	$50, $FFE0, 0
	dc.w	$FF88, $FF98, 0
	
ObjTunnelPath_Path1:
	dc.w	$18
	dc.w	0, 0, 0
	dc.w	$30, $FFF0, 0
	dc.w	$60, 0, $8000
	dc.w	$78, $20, $8000
	dc.w	$C8, 0, 0
	
ObjTunnelPath_Path2:
	dc.w	$96
	dc.w	0, 0, 0
	dc.w	8, $20, 0
	dc.w	0, $40, 0
	dc.w	$FFE8, $60, 0
	dc.w	$FFB8, $70, 0
	dc.w	$FF88, $80, 0
	dc.w	$FF70, $A0, 0
	dc.w	$FF68, $C0, 0
	dc.w	$FF70, $E0, $8002
	dc.w	$FF88, $100, $8002
	dc.w	$FFB8, $110, 0
	dc.w	$FFE8, $100, 0
	dc.w	0, $E0, 0
	dc.w	8, $C0, 0
	dc.w	0, $A0, 0
	dc.w	$FFE8, $80, 0
	dc.w	$FFB8, $70, 0
	dc.w	$FF88, $60, 0
	dc.w	$FF70, $40, 0
	dc.w	$FF68, $20, 0
	dc.w	$FF70, 0, $8001
	dc.w	$FF88, $FFE0, $8001
	dc.w	$FFB8, $FFD0, 0
	dc.w	$FFE8, $FFE0, $8000
	dc.w	0, 0, $8000
	dc.w	$40, $FFE0, 0
	dc.w	$FF28, $FFE0, 0
	dc.w	$FF48, $F0, 0
	
ObjTunnelPath_Path3:
	dc.w	$1E
	dc.w	0, 0, $8001
	dc.w	$18, $FFE0, $8001
	dc.w	$48, $FFD0, 0
	dc.w	$78, $FFE0, $8000
	dc.w	$90, 0, $8000
	dc.w	$D0, $FFE0, 0
	dc.w	$FFB8, $FFE0, 0
	
ObjTunnelPath_Path4:
	dc.w	$4E
	dc.w	0, 0, $8002
	dc.w	$18, $20, $8002
	dc.w	$48, $30, 0
	dc.w	$78, $20, 0
	dc.w	$90, 0, 0
	dc.w	$98, $FFE0, 0
	dc.w	$90, $FFC0, 0
	dc.w	$78, $FFA0, 0
	dc.w	$48, $FF90, 0
	dc.w	$18, $FF80, 0
	dc.w	0, $FF60, 0
	dc.w	$FFF8, $FF40, 0
	dc.w	0, $FF20, $8001
	dc.w	$D0, $FF00, 0
	dc.w	$FFB8, $FF00, 0
	dc.w	$FFD8, $10, 0
	
ObjTunnelPath_Path5:
	dc.w	$3C
	dc.w	0, 0, 0
	dc.w	0, $150, 0
	dc.w	$FF98, $150, 0
	dc.w	$FF98, $200, 0
	dc.w	$FFF8, $200, 0
	dc.w	$FFC8, $200, 0
	dc.w	$FFC8, $328, 0
	dc.w	$218, $328, 0
	dc.w	$218, $370, 0
	dc.w	$3C0, $370, 0
	
ObjTunnelPath_Path6:
	dc.w	$C 
	dc.w	0, 0, 0
	dc.w	$38, 0, 0
	
ObjTunnelPath_Path7:
	dc.w	$12
	dc.w	0, 0, 0
	dc.w	0, $2A8, 0
	dc.w	$50, $2A8, 0
	
ObjTunnelPath_Path8:
	dc.w	$18
	dc.w	0, 0, 0
	dc.w	8, 0, 0
	dc.w	8, $FF00, 0
	dc.w	$38, $FF00, 0
	
ObjTunnelPath_Path9:
	dc.w	$18
	dc.w	0, 0, 0
	dc.w	8, 0, 0
	dc.w	8, $100, 0
	dc.w	$38, $100, 0
	
ObjTunnelPath_Path10:
	dc.w	$18
	dc.w	0, 0, 0
	dc.w	8, 0, 0
	dc.w	8, $FF00, 0
	dc.w	$38, $FF00, 0
	
ObjTunnelPath_Path11:
	dc.w	$C
	dc.w	0, 0, 0
	dc.w	$60, 0, 0
	
ObjTunnelPath_Path12:
	dc.w	$18
	dc.w	0, 0, 0
	dc.w	$1B0, 0, 0
	dc.w	$1B0, $100, 0
	dc.w	$3E0, $100, 0
	
ObjTunnelPath_Path13:
	dc.w	$1E
	dc.w	0, 0, 0
	dc.w	0, $2A8, 0
	dc.w	$3C0, $2A8, 0
	dc.w	$3C0, $1A8, 0
	dc.w	$190, $1A8, 0
	
ObjTunnelPath_Path14:
	dc.w	$C
	dc.w	0, 0, 0
	dc.w	$160, 0, 0
	
ObjTunnelPath_Path15:
	dc.w	$4E
	dc.w	0, 0, 0
	dc.w	0, $2B8, 0
	dc.w	$FF88, $2B8, 0
	dc.w	$FF88, $368, 0
	dc.w	$FFE8, $368, 0
	dc.w	$FFB8, $3B8, 0
	dc.w	$FF58, $3B8, 0
	dc.w	$FFB8, $3B8, 0
	dc.w	$FFB8, $3F8, 0
	dc.w	$18, $3F8, 0
	dc.w	$18, $458, 0
	dc.w	$FFC8, $458, 0
	dc.w	$FFC8, $4E0, 0
	
ObjTunnelPath_Path16:
	dc.w	$2A
	dc.w	0, 0, 0
	dc.w	0, $2A8, 0
	dc.w	$FF88, $2A8, 0
	dc.w	$FF88, $358, 0
	dc.w	$FFE8, $358, 0
	dc.w	$FFB8, $358, 0
	dc.w	$FFB8, $4D0, 0
	
ObjTunnelPath_Path17:
	dc.w	$30
	dc.w	0, 0, 0
	dc.w	0, $208, 0
	dc.w	$FF88, $208, 0
	dc.w	$FF88, $2B8, 0
	dc.w	$FFE8, $2B8, 0
	dc.w	$FFC8, $2B8, 0
	dc.w	$FFC8, $318, 0
	dc.w	$250, $318, 0
	
ObjTunnelPath_Path18:
	dc.w	$C
	dc.w	0, 0, 0
	dc.w	$128, 0, 0

; ------------------------------------------------------------------------------
