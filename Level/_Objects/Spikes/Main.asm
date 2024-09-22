; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Spikes object
; ------------------------------------------------------------------------------

ObjSpikes:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjSpikes_Index(pc,d0.w),d0
	jmp	ObjSpikes_Index(pc,d0.w)
; End of function ObjSpikes

; ------------------------------------------------------------------------------
ObjSpikes_Index:dc.w	ObjSpikes_Init-ObjSpikes_Index
	dc.w	ObjSpikes_Main-ObjSpikes_Index
; ------------------------------------------------------------------------------

ObjSpikes_Init:
	addq.b	#2,obj.routine(a0)
	move.l	#MapSpr_Spikes,obj.sprites(a0)
	ori.b	#%00000100,obj.sprite_flags(a0)
	move.b	#3,obj.sprite_layer(a0)
	moveq	#$A,d0
	jsr	SetObjectTileID(pc)
	move.b	#$10,obj.width(a0)
	move.b	#8,obj.collide_height(a0)
	btst	#1,obj.sprite_flags(a0)
	beq.s	ObjSpikes_Main
	move.b	#$12,obj.width(a0)
	move.b	#$83,obj.collide_type(a0)
; End of function ObjSpikes_Init

; ------------------------------------------------------------------------------

ObjSpikes_Main:
	lea	player_object,a1
	move.w	obj.y(a1),d0
	sub.w	obj.y(a0),d0
	bcc.s	.AbsDY
	neg.w	d0

.AbsDY:
	cmpi.w	#$20,d0
	bcc.s	.Display
	btst	#1,obj.sprite_flags(a0)
	beq.s	.ChkStand
	lea	player_object,a1
	jsr	SolidObject
	bra.s	.Display

; ------------------------------------------------------------------------------

.ChkStand:
	jsr	SolidObject
	beq.s	.Display
	btst	#3,obj.flags(a0)
	beq.s	.Display
	tst.b	time_warp
	bne.s	.Display
	tst.b	invincible
	bne.s	.Display
	move.l	a0,-(sp)
	movea.l	a0,a2
	lea	player_object,a0
	cmpi.b	#4,obj.routine(a0)
	bcc.s	.Restore
	tst.w	oPlayerHurt(a0)
	bne.s	.Restore
	move.l	obj.y(a0),d3
	move.w	obj.y_speed(a0),d0
	ext.l	d0
	asl.l	#8,d0
	sub.l	d0,d3
	move.l	d3,obj.y(a0)
	jsr	HurtPlayer

.Restore:
	movea.l	(sp)+,a0

.Display:
	jsr	DrawObject
	jmp	CheckObjDespawn
; End of function ObjSpikes_Main

; ------------------------------------------------------------------------------
MapSpr_Spikes:
	include	"Level/_Objects/Spikes/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
