; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Vertical spin tunnel door object
; ------------------------------------------------------------------------------

ObjTunnelDoorV:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjTunnelDoorV_Index(pc,d0.w),d0
	jsr	ObjTunnelDoorV_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawn
; End of function ObjTunnelDoorV

; ------------------------------------------------------------------------------
ObjTunnelDoorV_Index:
	dc.w	ObjTunnelDoorV_Init-ObjTunnelDoorV_Index
	dc.w	ObjTunnelDoorV_Main-ObjTunnelDoorV_Index
	dc.w	ObjTunnelDoorV_Reset-ObjTunnelDoorV_Index

; ------------------------------------------------------------------------------
	lea	player_object,a1
; ------------------------------------------------------------------------------

ObjTunnelDoorV_SolidObj:
	move.w	obj.x(a0),d3
	move.w	obj.y(a0),d4
	jmp	SolidObject
; End of function ObjTunnelDoorV_SolidObj

; ------------------------------------------------------------------------------

ObjTunnelDoorV_Init:
	addq.b	#2,obj.routine(a0)
	move.l	#MapSpr_FlapDoorV,obj.sprites(a0)
	move.b	#1,obj.sprite_layer(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#4,obj.width(a0)
	move.b	#$18,obj.collide_height(a0)
	moveq	#$C,d0
	jsr	SetObjectTileID
; End of function ObjTunnelDoorV_Init

; ------------------------------------------------------------------------------

ObjTunnelDoorV_Main:
	lea	player_object,a1
	move.w	obj.y(a0),d0
	sub.w	obj.y(a1),d0
	bcc.s	.AbsDX
	neg.w	d0

.AbsDX:
	cmpi.w	#$20,d0
	bcc.s	.NotRange
	move.w	obj.x(a0),d0
	sub.w	obj.x(a1),d0
	bcs.s	.NotRange
	cmpi.w	#$30,d0
	bcc.s	.NotRange
	clr.w	obj.var_3A(a0)
	move.b	#4,obj.routine(a0)
	btst	#7,obj.sprite_flags(a0)
	beq.s	.NotRange
	move.w	#FM_A4,d0
	jsr	PlayFMSound
	move.b	#1,obj.sprite_frame(a0)

.NotRange:
	bra.w	ObjTunnelDoorV_SolidObj
; End of function ObjTunnelDoorV_Main

; ------------------------------------------------------------------------------

ObjTunnelDoorV_Reset:
	addq.b	#8,obj.var_3A(a0)
	bcc.s	.End
	subq.b	#2,obj.routine(a0)
	move.b	#0,obj.sprite_frame(a0)

.End:
	rts
; End of function ObjTunnelDoorV_Reset

; ------------------------------------------------------------------------------
Ani_FlapDoorV:
	include	"Level/Palmtree Panic/Objects/Tunnel Door/Data/Animations.asm"
	even
MapSpr_FlapDoorV:
	include	"Level/Palmtree Panic/Objects/Tunnel Door/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
