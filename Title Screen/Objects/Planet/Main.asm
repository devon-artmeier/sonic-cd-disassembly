; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Planet object (title screen)
; ------------------------------------------------------------------------------

	rsset obj.vars
planet.offset		rs.b 1					; Offset
planet.delay		rs.b 1					; Delay counter
			rs.b 4
planet.y		rs.w 1					; Y position

; ------------------------------------------------------------------------------

ObjPlanet:
	bsr.w	BookmarkObject					; Set bookmark
	
	move.l	a0,-(sp)					; Load planet art	
	VDP_CMD move.l,$8040,VRAM,WRITE,VDP_CTRL
	lea	PlanetArt(pc),a0
	bsr.w	NemDec
	movea.l	(sp)+,a0
	
	move.l	#PlanetSprites,obj.sprites(a0)			; Set mappings
	move.w	#$6000|($8040/$20),obj.sprite_tile(a0)		; Set sprite tile ID
	move.b	#%1,obj.flags(a0)				; Set flags
	move.w	#226,obj.x(a0)					; Set X position
	move.w	#24,obj.y(a0)					; Set Y position
	move.w	obj.y(a0),planet.y(a0)

; ------------------------------------------------------------------------------

.Hover:
	addi.b	#$40,planet.delay(a0)				; Increment delay counter
	bcc.s	.Exit						; If it hasn't overflowed, branch

	moveq	#0,d0						; Get offset value
	move.b	planet.offset(a0),d0
	move.b	.Offsets(pc,d0.w),d0
	ext.w	d0
	add.w	d0,obj.y(a0)

	move.b	planet.offset(a0),d0				; Next offset
	addq.b	#1,d0
	andi.b	#$1F,d0
	move.b	d0,planet.offset(a0)

.Exit:
	jsr	BookmarkObject(pc)				; Set bookmark
	bra.s	.Hover						; Handle hovering

; ------------------------------------------------------------------------------

.Offsets:
	dc.b	0, 0, 0, -1
	dc.b	0, 0, 0, -1
	dc.b	0, 0, 0, -1
	dc.b	0, 0, 0, 0
	dc.b	0, 0, 0, 0
	dc.b	1, 0, 0, 0
	dc.b	1, 0, 0, 0
	dc.b	1, 0, 0, 0

; ------------------------------------------------------------------------------
; Planet sprites
; ------------------------------------------------------------------------------

PlanetSprites:
	include	"Title Screen/Objects/Planet/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
