; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Boulder object
; ------------------------------------------------------------------------------

ObjBoulder:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	jsr	DrawObject			; Draw sprite
	jmp	CheckObjDespawn			; Check despawn

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjBoulder_Init-.Index
	dc.w	ObjBoulder_Main-.Index
	
; ------------------------------------------------------------------------------
; Initialization
; ------------------------------------------------------------------------------

ObjBoulder_Init:
	addq.b	#2,obj.routine(a0)			; Next routine
	ori.b	#%00000100,obj.sprite_flags(a0)	; Set sprite flags
	move.b	#4,obj.sprite_layer(a0)		; Set priority
	move.l	#MapSpr_Boulder,obj.sprites(a0)	; Set mappings
	move.b	#$10,obj.width(a0)			; Set width
	move.b	#$10,obj.collide_height(a0)		; Set height
	move.b	#0,obj.sprite_frame(a0)		; Set sprite frame
	moveq	#$B,d0				; Set base tile ID
	jsr	SetObjectTileID

; ------------------------------------------------------------------------------
; Main routine
; ------------------------------------------------------------------------------

ObjBoulder_Main:
	tst.b	obj.sprite_flags(a0)			; Are we on screen?
	bpl.s	.End				; If not, branch
	
	lea	player_object,a1		; Handle solidity
	move.w	obj.x(a0),d3
	move.w	obj.y(a0),d4
	jmp	SolidObject

.End:
	rts

; ------------------------------------------------------------------------------
; Data
; ------------------------------------------------------------------------------

MapSpr_Boulder:
	include	"Level/_Objects/Boulder/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
