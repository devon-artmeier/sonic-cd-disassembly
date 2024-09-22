; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Test badnik object
; ------------------------------------------------------------------------------

oUnusedBadX	EQU	obj.var_30		; X position copy

; ------------------------------------------------------------------------------

ObjTestBadnik:
	moveq	#0,d0				; Run object routine
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjTestBadnik_Init-.Index	; Initialization
	dc.w	ObjTestBadnik_Main-.Index	; Main

; ------------------------------------------------------------------------------
; Unused badnik initialization routine
; ------------------------------------------------------------------------------

ObjTestBadnik_Init:
	btst	#7,obj.flags(a0)			; Are we offscreen?
	bne.w	DeleteObject			; If so, delete ourselves

	addq.b	#2,obj.routine(a0)			; Advance routine

	move.b	#%00000100,obj.sprite_flags(a0)	; Set sprite flags
	move.b	#1,obj.sprite_layer(a0)		; Set priority
	move.l	#MapSpr_Powerup,obj.sprites(a0)	; Set mappings
	move.w	#$541,obj.sprite_tile(a0)			; Set base tile
	move.w	obj.x(a0),oUnusedBadX(a0)		; Copy X position
	move.b	#6,obj.collide_type(a0)			; Enable collision

; ------------------------------------------------------------------------------
; Main unused badnik routine
; ------------------------------------------------------------------------------

ObjTestBadnik_Main:
	move.w	oUnusedBadX(a0),d0		; Get the object's chunk position
	andi.w	#$FF80,d0
	move.w	camera_fg_x,d1			; Get the camera's chunk position
	subi.w	#$80,d1
	andi.w	#$FF80,d1

	sub.w	d1,d0				; Has the object gone offscreen?
	cmpi.w	#$80+(320+$40)+$80,d0
	bhi.w	DeleteObject			; If so, delete ourselves

	lea	Ani_Powerup,a1			; Animate sprite
	bsr.w	AnimateObject
	jmp	DrawObject			; Draw sprite

; ------------------------------------------------------------------------------
