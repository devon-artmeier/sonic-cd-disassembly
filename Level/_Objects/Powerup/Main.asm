; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Powerup object
; ------------------------------------------------------------------------------

ObjPowerup:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjPowerup_Index(pc,d0.w),d1
	jmp	ObjPowerup_Index(pc,d1.w)

; ------------------------------------------------------------------------------
ObjPowerup_Index:
	dc.w	ObjPowerup_Init-ObjPowerup_Index
	dc.w	ObjPowerup_Shield-ObjPowerup_Index
	dc.w	ObjPowerup_InvStars-ObjPowerup_Index
	dc.w	ObjPowerup_TimeStars-ObjPowerup_Index
; ------------------------------------------------------------------------------

ObjPowerup_Init:
	addq.b	#2,obj.routine(a0)
	move.l	#MapSpr_Powerup,obj.sprites(a0)
	move.b	#%00000100,obj.sprite_flags(a0)
	move.b	#1,obj.sprite_layer(a0)
	move.b	#$10,obj.width(a0)
	move.w	#$544,obj.sprite_tile(a0)
	tst.b	obj.anim_id(a0)
	beq.s	.End
	addq.b	#2,obj.routine(a0)
	cmpi.b	#5,obj.anim_id(a0)
	bcs.s	.End
	addq.b	#2,obj.routine(a0)

.End:
	rts

; ------------------------------------------------------------------------------

ObjPowerup_Shield:
	tst.b	shield
	beq.s	.Delete
	tst.b	time_warp
	bne.s	.End
	tst.b	invincible
	bne.s	.End
	move.w	player_object+obj.x,obj.x(a0)
	move.w	player_object+obj.y,obj.y(a0)
	move.b	player_object+obj.flags,obj.flags(a0)
	cmpi.b	#6,zone
	bne.s	.Animate
	ori.b	#$80,obj.sprite_tile(a0)
	tst.b	layer
	beq.s	.Animate
	andi.b	#$7F,obj.sprite_tile(a0)

.Animate:
	lea	Ani_Powerup,a1
	jsr	AnimateObject
	bra.w	ObjPowerup_ChkSaveRout

; ------------------------------------------------------------------------------

.End:
	rts

; ------------------------------------------------------------------------------

.Delete:
	jmp	DeleteObject

; ------------------------------------------------------------------------------

ObjPowerup_InvStars:
	tst.b	time_warp
	beq.s	.NoTimeWarp
	rts

; ------------------------------------------------------------------------------

.NoTimeWarp:
	tst.b	invincible
	bne.s	ObjPowerup_ShowStars
	jmp	DeleteObject

; ------------------------------------------------------------------------------

ObjPowerup_TimeStars:
	tst.b	time_warp
	bne.s	ObjPowerup_ShowStars
	jmp	DeleteObject

; ------------------------------------------------------------------------------

ObjPowerup_ShowStars:
	cmpi.b	#6,zone
	bne.s	.GotPriority
	ori.b	#$80,obj.sprite_tile(a0)
	tst.b	layer
	beq.s	.GotPriority
	andi.b	#$7F,obj.sprite_tile(a0)

.GotPriority:
	move.w	player_positions_index,d0
	move.b	obj.anim_id(a0),d1
	subq.b	#1,d1
	cmpi.b	#4,d1
	bcs.s	.GotDelta
	subq.b	#4,d1

.GotDelta:
	lsl.b	#3,d1
	move.b	d1,d2
	add.b	d1,d1
	add.b	d2,d1
	addq.b	#4,d1
	sub.b	d1,d0
	move.b	obj.var_30(a0),d1
	sub.b	d1,d0
	addq.b	#4,d1
	cmpi.b	#$18,d1
	bcs.s	.NoCap
	moveq	#0,d1

.NoCap:
	move.b	d1,obj.var_30(a0)
	lea	player_positions,a1
	lea	(a1,d0.w),a1
	move.w	(a1)+,obj.x(a0)
	move.w	(a1)+,obj.y(a0)
	move.b	player_object+obj.flags,obj.flags(a0)
	lea	Ani_Powerup,a1
	jsr	AnimateObject

; ------------------------------------------------------------------------------

ObjPowerup_ChkSaveRout:
	move.b	powerup,d0
	andi.b	#$F,d0
	cmpi.b	#8,d0
	bcs.s	.SaveRout
	rts

; ------------------------------------------------------------------------------

.SaveRout:
	cmp.b	obj.routine(a0),d0
	beq.s	.Display
	move.b	obj.routine(a0),powerup
	bset	#7,powerup

.Display:
	jmp	DrawObject
	
; ------------------------------------------------------------------------------

LoadShieldArt:
	bclr	#7,powerup
	beq.s	.End
	moveq	#0,d0
	move.b	powerup,d0
	subq.b	#2,d0
	add.w	d0,d0
	movea.l	ShieldArtIndex(pc,d0.w),a1
	
	lea	anim_art_buffer,a2
	move.w	#$FF,d0

.Loop:
	move.l	(a1)+,(a2)+
	dbf	d0,.Loop

	LVLDMA	anim_art_buffer,$A880,$480,VRAM

.End:
	rts
; End of function LoadShieldArt

; ------------------------------------------------------------------------------

ShieldArtIndex:
	dc.l	Art_Shield
	dc.l	Art_InvStars
	dc.l	Art_TimeStars
	dc.l	Art_GameOver
	dc.l	Art_TimeOver

; ------------------------------------------------------------------------------
