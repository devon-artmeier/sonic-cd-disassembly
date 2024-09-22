; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Shadow objects (special stage)
; ------------------------------------------------------------------------------

shadow.sprite		equ obj.var_52		; Current sprite ID
shadow.parent		equ obj.var_54		; Parent object

; ------------------------------------------------------------------------------
; Sonic's shadow
; ------------------------------------------------------------------------------

ObjSonicShadow:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	bsr.w	DrawObject			; Draw sprite
	rts

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjSonicShadow_Init-.Index
	dc.w	ObjSonicShadow_Main-.Index

; ------------------------------------------------------------------------------

ObjSonicShadow_Init:
	move.w	#$E6DC,obj.sprite_tile(a0)	; Base tile ID
	move.l	#MapSpr_Shadow,obj.sprites(a0)	; Mappings
	moveq	#5,d0				; Set animation
	move.b	d0,shadow.sprite(a0)
	bsr.w	SetObjAnim
	addq.b	#1,obj.routine(a0)		; Set routine to main

; ------------------------------------------------------------------------------

ObjSonicShadow_Main:
	lea	player_object,a1		; Move along with Sonic
	move.w	obj.x(a1),obj.x(a0)
	move.w	obj.y(a1),obj.y(a0)
	move.w	player_object+obj.z,obj.z(a0)
	bra.w	Set3DSpritePos			; Set sprite position

; ------------------------------------------------------------------------------
; UFO shadow
; ------------------------------------------------------------------------------

ObjUFOShadow:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	bsr.w	ObjUFO_ChkOnScreen		; Check if on screen
	bsr.w	DrawObject			; Draw sprite
	rts

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjUFOShadow_Init-.Index
	dc.w	ObjUFOShadow_Main-.Index

; ------------------------------------------------------------------------------

ObjUFOShadow_Init:
	move.w	#$E6DC,obj.sprite_tile(a0)	; Base tile ID
	move.l	#MapSpr_Shadow,obj.sprites(a0)	; Mappings
	moveq	#0,d0				; Set animation
	move.b	d0,shadow.sprite(a0)
	bsr.w	SetObjAnim
	addq.b	#1,obj.routine(a0)		; Set routine to main

; ------------------------------------------------------------------------------

ObjUFOShadow_Main:
	movea.l	shadow.parent(a0),a1		; Move with UFO
	move.w	obj.x(a1),obj.x(a0)
	move.w	obj.y(a1),obj.y(a0)

	bset	#2,obj.flags(a1)		; Sync draw flag with UFO's
	btst	#2,obj.flags(a0)
	bne.s	.Draw
	bclr	#2,obj.flags(a1)

.Draw:
	move.w	player_object+obj.z,obj.z(a0)	; Shift Z position according to Sonic's Z position

	bsr.w	ObjUFO_Draw			; Draw sprite
	bsr.w	Set3DSpritePos			; Set sprite position
	rts

; ------------------------------------------------------------------------------
