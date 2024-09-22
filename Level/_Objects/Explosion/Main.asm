; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Explosion object
; ------------------------------------------------------------------------------

oExplodeBadnik	EQU	obj.routine_2		; Explosion from badnik flag
oExplodePoints	EQU	obj.var_3E		; Sprite ID for points object

; ------------------------------------------------------------------------------
; Create a points object from an explosion object
; ------------------------------------------------------------------------------

ObjExplosion_MakePoints:
	tst.b	oExplodeBadnik(a0)		; Was this explosion from a badnik?
	bne.s	.End				; If not, branch

	moveq	#0,d1				; Get points sprite to display
	move.w	oExplodePoints(a0),d1
	lsr.b	#1,d1
	ori.b	#$80,d1

	jsr	FindObjSlot			; Find a free object slot
	bne.s	.End				; If one was not found, branch

	move.b	#$1C,obj.id(a1)			; Load points object
	move.w	obj.x(a0),obj.x(a1)			; Set the points position to ours
	move.w	obj.y(a0),obj.y(a1)
	move.b	d1,obj.subtype(a1)		; Set points sprite frame ID

.End:
	rts

; ------------------------------------------------------------------------------
; Main explosion object code
; ------------------------------------------------------------------------------

ObjExplosion:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjExplosion_Init-.Index
	dc.w	ObjExplosion_Main-.Index
	dc.w	ObjExplosion_Done-.Index

; ------------------------------------------------------------------------------
; Initialization
; ------------------------------------------------------------------------------

ObjExplosion_Init:
	addq.b	#2,obj.routine(a0)			; Advance routine

	ori.b	#%00000100,obj.sprite_flags(a0)	; Set sprite flags
	move.b	#1,obj.sprite_layer(a0)		; Set priority
	move.w	#$8680,obj.sprite_tile(a0)		; Set base tile
	tst.b	obj.layer(a0)			; Are we on layer 2?
	beq.s	.HighPriority			; If not, branch
	andi.b	#$7F,obj.sprite_tile(a0)			; Set low priority

.HighPriority:
	move.l	#MapSpr_Explosion,obj.sprites(a0)	; Set mappings

	bsr.s	ObjExplosion_MakePoints		; Make points object if it should

	move.b	#0,obj.collide_type(a0)		; Disable collision
	move.b	#0,obj.anim_frame(a0)		; Initialize animation
	move.b	#0,obj.anim_time(a0)
	move.w	#0,obj.anim_id(a0)
	tst.b	obj.subtype(a0)			; Should we use the alternate animation?
	beq.s	ObjExplosion_Main		; If not, branch
	move.w	#$100,obj.anim_id(a0)			; If so, use it

; ------------------------------------------------------------------------------
; Main routine
; ------------------------------------------------------------------------------

ObjExplosion_Main:
	lea	Ani_Explosion,a1		; Animate sprite
	bsr.w	AnimateObject
	jmp	DrawObject			; Draw sprite

; ------------------------------------------------------------------------------
; Finished
; ------------------------------------------------------------------------------

ObjExplosion_Done:
	tst.b	oExplodeBadnik(a0)		; Was this explosion from a badnik?
	beq.s	.MakeFlower			; If so, branch
	jmp	DeleteObject			; If not, just delete ourselves

.MakeFlower:
	move.b	#$1F,obj.id(a0)			; Change into a flower object
	move.b	#0,obj.routine(a0)
	rts

; ------------------------------------------------------------------------------
