; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Object tile ID set function
; ------------------------------------------------------------------------------

SetObjectTileID:
	lea	ObjectTileIDs,a1
	add.w	d0,d0
	move.w	ObjectTileIDs(pc,d0.w),d4
	lea	ObjectTileIDs(pc,d4.w),a2
	moveq	#0,d1
	move.b	obj.subtype_2(a0),d1
	add.w	d1,d1
	move.w	(a2,d1.w),d5
	move.w	d5,obj.sprite_tile(a0)
	rts

; ------------------------------------------------------------------------------
