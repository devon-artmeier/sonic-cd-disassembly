; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Spin tunnel door object
; ------------------------------------------------------------------------------

ObjTunnelDoor:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjTunnelDoor_Index(pc,d0.w),d0
	jsr	ObjTunnelDoor_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawn
; End of function ObjTunnelDoor

; ------------------------------------------------------------------------------
ObjTunnelDoor_Index:
	dc.w	ObjTunnelDoor_Init-ObjTunnelDoor_Index
	dc.w	ObjTunnelDoor_Main-ObjTunnelDoor_Index
	dc.w	ObjTunnelDoor_Animate-ObjTunnelDoor_Index
	dc.w	ObjTunnelDoor_Reset-ObjTunnelDoor_Index
; ------------------------------------------------------------------------------

ObjTunnelDoor_ChkPlayer:
	tst.w	obj.y_speed(a1)
	bpl.s	.Solid
	bsr.w	ObjTunnelDoor_ChkCollision
	beq.s	.Solid
	move.b	#4,obj.routine(a0)
	tst.b	obj.subtype(a0)
	bne.s	.End
	jsr	FindObjSlot
	bne.s	.End
	move.b	#$B,obj.id(a1)
	move.w	obj.x(a0),obj.x(a1)
	move.w	obj.y(a0),obj.y(a1)
	subq.w	#4,obj.y(a1)
	move.w	#FM_A4,d0
	jmp	PlayFMSound

; ------------------------------------------------------------------------------

.End:
	rts

; ------------------------------------------------------------------------------

.Solid:
	move.w	obj.x(a0),d3
	move.w	obj.y(a0),d4
	jmp	TopSolidObject
; End of function ObjTunnelDoor_ChkPlayer

; ------------------------------------------------------------------------------

ObjTunnelDoor_Init:
	addq.b	#2,obj.routine(a0)
	move.l	#MapSpr_TunnelDoor,obj.sprites(a0)
	move.b	#1,obj.sprite_layer(a0)
	ori.b	#%00000100,obj.sprite_flags(a0)
	move.b	#$2C,obj.width(a0)
	cmpi.b	#2,obj.subtype(a0)
	bne.s	.NotNarrow
	move.b	#$18,obj.width(a0)

.NotNarrow:
	move.b	#8,obj.collide_height(a0)
	moveq	#$C,d0
	jsr	SetObjectTileID
; End of function ObjTunnelDoor_Init

; ------------------------------------------------------------------------------

ObjTunnelDoor_Main:
	lea	player_object,a1
	bsr.w	ObjTunnelDoor_ChkPlayer
	lea	player_2_object,a1
	bra.w	ObjTunnelDoor_ChkPlayer
; End of function ObjTunnelDoor_Main

; ------------------------------------------------------------------------------

ObjTunnelDoor_Animate:
	lea	Ani_TunnelDoor,a1
	bra.w	AnimateObject
; End of function ObjTunnelDoor_Animate

; ------------------------------------------------------------------------------

ObjTunnelDoor_Reset:
	move.b	#1,obj.prev_anim_id(a0)
	move.b	#0,obj.sprite_frame(a0)
	subq.b	#4,obj.routine(a0)
	rts
; End of function ObjTunnelDoor_Reset

; ------------------------------------------------------------------------------

ObjTunnelDoorSplashSet:
	; Scrapped object code

; ------------------------------------------------------------------------------

ObjTunnelDoor_ChkCollision:
	move.w	obj.x(a1),d0
	sub.w	obj.x(a0),d0
	moveq	#0,d1
	move.b	obj.width(a0),d1
	add.w	d1,d0
	bmi.s	.NoCollision
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollision
	move.w	obj.y(a1),d0
	sub.w	obj.y(a0),d0
	moveq	#0,d1
	move.b	obj.collide_height(a0),d1
	add.w	d1,d0
	bmi.s	.NoCollision
	add.w	d1,d1
	cmp.w	d1,d0
	bcc.s	.NoCollision
	moveq	#1,d0
	rts

; ------------------------------------------------------------------------------

.NoCollision:
	moveq	#0,d0
	rts

; ------------------------------------------------------------------------------
; Spin tunnel door splash object
; ------------------------------------------------------------------------------

ObjTunnelDoorSplash:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjTunnelDoorSplash_Index(pc,d0.w),d0
	jmp	ObjTunnelDoorSplash_Index(pc,d0.w)
; End of function ObjTunnelDoorSplash

; ------------------------------------------------------------------------------
ObjTunnelDoorSplash_Index:
	dc.w	ObjTunnelDoorSplash_Init-ObjTunnelDoorSplash_Index
	dc.w	ObjTunnelDoorSplash_Main-ObjTunnelDoorSplash_Index
	dc.w	ObjTunnelDoorSplash_Destroy-ObjTunnelDoorSplash_Index
; ------------------------------------------------------------------------------

ObjTunnelDoorSplash_Init:
	addq.b	#2,obj.routine(a0)
	move.b	#%00000100,obj.sprite_flags(a0)
	move.b	#1,obj.sprite_layer(a0)
	move.l	#MapSpr_TunnelDoorSplash,obj.sprites(a0)
	move.b	obj.subtype(a0),obj.anim_id(a0)
	moveq	#$D,d0
	jsr	SetObjectTileID
	move.w	#FM_A2,d0
	cmpi.b	#2,obj.subtype(a0)
	bcs.s	.PlaySound
	move.w	#FM_A1,d0

.PlaySound:
	jsr	PlayFMSound
; End of function ObjTunnelDoorSplash_Init

; ------------------------------------------------------------------------------

ObjTunnelDoorSplash_Main:
	lea	Ani_TunnelDoorSplash,a1
	bsr.w	AnimateObject
	jmp	DrawObject
; End of function ObjTunnelDoorSplash_Main

; ------------------------------------------------------------------------------

ObjTunnelDoorSplash_Destroy:
	jmp	DeleteObject

; ------------------------------------------------------------------------------
