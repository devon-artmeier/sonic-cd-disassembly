; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Scenery object
; ------------------------------------------------------------------------------

ObjScenery:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjScenery_Index(pc,d0.w),d0
	jsr	ObjScenery_Index(pc,d0.w)
	jsr	DrawObject
	jmp	CheckObjDespawn
; End of function ObjScenery

; ------------------------------------------------------------------------------
ObjScenery_Index:
	dc.w	ObjScenery_Init-ObjScenery_Index
	dc.w	ObjScenery_Main-ObjScenery_Index
; ------------------------------------------------------------------------------

ObjScenery_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.l	#MapSpr_Scenery,obj.sprites(a0)
	move.b	obj.subtype(a0),obj.sprite_frame(a0)
	move.b	#$10,obj.width(a0)
	move.b	#$18,obj.collide_height(a0)
	bsr.w	ObjScenery_SetBaseTile
; End of function ObjScenery_Init

; ------------------------------------------------------------------------------

ObjScenery_Main:
	rts
; End of function ObjScenery_Main

; ------------------------------------------------------------------------------

ObjScenery_SetBaseTile:
	moveq	#0,d0
	move.b	time_zone,d0
	andi.b	#$7F,d0
	cmpi.b	#2,d0
	bne.s	.NotFuture
	moveq	#1,d0
	add.b	good_future,d0

.NotFuture:
	add.w	d0,d0
	add.b	act,d0
	add.w	d0,d0
	move.w	ObjScenery_BaseTileList(pc,d0.w),obj.sprite_tile(a0)
	ori.w	#$4000,obj.sprite_tile(a0)
	rts
; End of function ObjScenery_SetBaseTile

; ------------------------------------------------------------------------------
ObjScenery_BaseTileList:
	dc.w	$3DB, $46E
	dc.w	$438, $39F
	dc.w	$438, $38F
MapSpr_Scenery:
	include	"Level/Palmtree Panic/Objects/Scenery/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
