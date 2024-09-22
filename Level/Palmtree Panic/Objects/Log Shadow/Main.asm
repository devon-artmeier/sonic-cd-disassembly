; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Log shadow object
; ------------------------------------------------------------------------------

ObjLogShadow:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjLogShadow_Index(pc,d0.w),d0
	jsr	ObjLogShadow_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawn
; End of function ObjLogShadow

; ------------------------------------------------------------------------------
ObjLogShadow_Index:
	dc.w	ObjLogShadow_Init-ObjLogShadow_Index
	dc.w	ObjLogShadow_Main-ObjLogShadow_Index
; ------------------------------------------------------------------------------

ObjLogShadow_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#6,obj.sprite_layer(a0)
	move.l	#MapSpr_LogShadow,obj.sprites(a0)
	move.b	obj.subtype(a0),obj.sprite_frame(a0)
	move.b	#$10,obj.width(a0)
	move.b	#$10,obj.collide_height(a0)
	bsr.w	ObjLogShadow_SetBaseTile
; End of function ObjLogShadow_Init

; ------------------------------------------------------------------------------

ObjLogShadow_Main:
	rts
; End of function ObjLogShadow_Main

; ------------------------------------------------------------------------------

ObjLogShadow_SetBaseTile:
	moveq	#0,d0
	move.b	time_zone,d0
	andi.b	#$7F,d0
	cmpi.b	#2,d0
	bne.s	.NotFuture
	add.b	good_future,d0

.NotFuture:
	add.w	d0,d0
	add.b	act,d0
	add.w	d0,d0
	move.w	ObjLogShadow_BaseTileList(pc,d0.w),obj.sprite_tile(a0)
	ori.w	#$4000,obj.sprite_tile(a0)
	rts
; End of function ObjLogShadow_SetBaseTile

; ------------------------------------------------------------------------------

ObjLogShadow_BaseTileList:
	dc.w	$3CB, $45E
	dc.w	$418, $3F0
	dc.w	$428, $38F
	dc.w	$428, $37F

; ------------------------------------------------------------------------------

MapSpr_LogShadow:
	include	"Level/Palmtree Panic/Objects/Log Shadow/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
