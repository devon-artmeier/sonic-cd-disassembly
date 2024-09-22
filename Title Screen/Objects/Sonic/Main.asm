; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Sonic object (title screen)
; ------------------------------------------------------------------------------

	rsset obj.vars
sonic.delay		rs.b 1				; Animation delay

; ------------------------------------------------------------------------------

ObjSonic:
	move.l	#SonicSprites,obj.sprites(a0)		; Set mappings
	move.w	#$E000|($6D00/$20),obj.sprite_tile(a0)	; Set sprite tile ID
	move.b	#%11,obj.flags(a0)			; Set flags
	move.w	#91,obj.x(a0)				; Set X position
	move.w	#15,obj.y(a0)				; Set Y position

	move.b	#2,sonic.delay(a0)			; Set animation delay

; ------------------------------------------------------------------------------

.Frame0Delay:
	bsr.w	BookmarkObject				; Set bookmark
	subq.b	#1,sonic.delay(a0)			; Decrement delay timer
	bne.s	.Frame0Delay				; If it hasn't run out, branch

	addq.b	#1,obj.sprite_frame(a0)			; Set next sprite frame
	move.b	#3,sonic.delay(a0)			; Reset animation delay

; ------------------------------------------------------------------------------

.Frame1Delay:
	bsr.w	BookmarkObject				; Set bookmark
	subq.b	#1,sonic.delay(a0)			; Decrement delay timer
	bne.s	.Frame1Delay				; If it hasn't run out, branch

	move.l	a0,-(sp)				; Load background mountains art
	VDP_CMD move.l,$6000,VRAM,WRITE,VDP_CTRL
	lea	MountainsArt(pc),a0
	bsr.w	NemDec
	movea.l	(sp)+,a0

	addq.b	#1,obj.sprite_frame(a0)			; Set next sprite frame
	move.b	#2,sonic.delay(a0)			; Reset animation delay

; ------------------------------------------------------------------------------

.Frame2Delay:
	bsr.w	BookmarkObject				; Set bookmark
	subq.b	#1,sonic.delay(a0)			; Decrement delay timer
	bne.s	.Frame2Delay				; If it hasn't run out, branch

	move.l	a0,-(sp)				; Load background mountains art
	VDP_CMD move.l,$6B00,VRAM,WRITE,VDP_CTRL
	lea	WaterArt(pc),a0
	bsr.w	NemDec
	movea.l	(sp)+,a0

	addq.b	#1,obj.sprite_frame(a0)			; Set next sprite frame
	move.b	#1,sonic.delay(a0)			; Reset animation delay

; ------------------------------------------------------------------------------

.Frame3Delay:
	bsr.w	BookmarkObject				; Set bookmark
	subq.b	#1,sonic.delay(a0)			; Decrement delay timer
	bne.s	.Frame3Delay				; If it hasn't run out, branch

	bset	#7,title_mode				; Mark Sonic as turned around
	
	lea	ObjSonicArm(pc),a2			; Spawn Sonic's arm
	bsr.w	SpawnObject
	move.w	a0,arm.parent(a1)

	lea	ObjBanner,a2				; Spawn banner
	bsr.w	SpawnObject
	
	addq.b	#1,obj.sprite_frame(a0)			; Set next sprite frame
	move.b	#$14,sonic.delay(a0)			; Reset animation delay

; ------------------------------------------------------------------------------

.Frame4Delay:
	bsr.w	BookmarkObject				; Set bookmark
	subq.b	#1,sonic.delay(a0)			; Decrement delay timer
	bne.s	.Frame4Delay				; If it hasn't run out, branch
	
	addq.b	#1,obj.sprite_frame(a0)			; Set next sprite frame
	move.b	#4,sonic.delay(a0)			; Reset animation delay

; ------------------------------------------------------------------------------

.Frame5Delay:
	bsr.w	BookmarkObject				; Set bookmark
	subq.b	#1,sonic.delay(a0)			; Decrement delay timer
	bne.s	.Frame5Delay				; If it hasn't run out, branch
	
	move.b	#4,obj.sprite_frame(a0)			; Go back to frame 4

; ------------------------------------------------------------------------------

.Done:
	bsr.w	BookmarkObject				; Set bookmark
	bra.s	.Done					; Remain static

; ------------------------------------------------------------------------------
; Sonic mappings
; ------------------------------------------------------------------------------

SonicSprites:
	include	"Title Screen/Objects/Sonic/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
; Sonic's arm object
; ------------------------------------------------------------------------------

	rsset obj.vars
arm.delay		rs.b 1			; Delay counter
			rs.b 3			; Unused
arm.frame		rs.b 1			; Animatiom frame
			rs.b 3			; Unused
arm.parent		rs.w 1			; Parent object

; ------------------------------------------------------------------------------

ObjSonicArm:
	move.l	#SonicSprites,obj.sprites(a0)		; Set mappings
	move.w	#$E000|($6D00/$20),obj.sprite_tile(a0)	; Set sprite tile ID
	move.b	#%11,obj.flags(a0)			; Set flags
	move.w	#140,obj.x(a0)				; Set X position
	move.w	#104,obj.y(a0)				; Set Y position
	move.b	#9,obj.sprite_frame(a0)			; Set sprite frame

; ------------------------------------------------------------------------------

.Delay:
	bsr.w	BookmarkObject				; Set bookmark
	addi.b	#$12,arm.delay(a0)			; Increment delay counter
	bcc.s	.Delay					; If it hasn't overflowed, loop

; ------------------------------------------------------------------------------

.Animate:
	moveq	#0,d0					; Get animation frame
	move.b	arm.frame(a0),d0
	move.b	.Frames(pc,d0.w),obj.sprite_frame(a0)

	addq.b	#1,d0					; Increment animation frame ID
	cmpi.b	#.FramesEnd-.Frames,d0			; Are we at the end of the animation?
	bcc.s	.Done					; If so, branch
	move.b	d0,arm.frame(a0)			; Update animation frame ID
	
	bsr.w	BookmarkObject				; Set bookmark
	bra.s	.Animate				; Animate

; ------------------------------------------------------------------------------

.Done:
	bsr.w	BookmarkObject				; Set bookmark
	bra.s	.Done					; Remain static

; ------------------------------------------------------------------------------

.Frames:
	dc.b	9, 8, 7, 6, 6, 7, 8, 9
	dc.b	9, 8, 7, 6, 6, 7, 8, 9
.FramesEnd:

; ------------------------------------------------------------------------------
