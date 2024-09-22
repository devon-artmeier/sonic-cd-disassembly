; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Copyright text object (title screen)
; ------------------------------------------------------------------------------

ObjCopyright:
	move.l	#MapSpr_Copyright,obj.sprites(a0)	; Set mappings
	move.w	#$E000|($DE00/$20),obj.sprite_tile(a0)	; Set sprite tile ID
	move.b	#%1,obj.flags(a0)				; Set flags
	if REGION=USA
		move.w	#208,obj.y(a0)			; Set Y position
		move.w	#80,obj.x(a0)			; Set X position
		move.b	#1,obj.sprite_frame(a0)		; Display with trademark
	else
		move.w	#91,obj.x(a0)			; Set X position
		move.w	#208,obj.y(a0)			; Set Y position
	endif

; ------------------------------------------------------------------------------

.Done:
	bsr.w	BookmarkObject				; Set bookmark
	bra.s	.Done					; Remain static

; ------------------------------------------------------------------------------
; Copyright text mappings
; ------------------------------------------------------------------------------

MapSpr_Copyright:
	if REGION=USA
		include	"Title Screen/Objects/Copyright/Data/Mappings (Copyright, USA).asm"
	else
		include	"Title Screen/Objects/Copyright/Data/Mappings (Copyright, JPN and EUR).asm"
	endif
	even

; ------------------------------------------------------------------------------
; Trademark symbol object
; ------------------------------------------------------------------------------

ObjTM:
	move.l	#MapSpr_TM,obj.sprites(a0)		; Set mappings
	if REGION=USA					; Set sprite tile ID
		move.w	#$E000|($DFC0/$20),obj.sprite_tile(a0)
	else
		move.w	#$E000|($DF20/$20),obj.sprite_tile(a0)
	endif
	move.b	#%1,obj.flags(a0)			; Set flags
	move.w	#194,obj.x(a0)				; Set X position
	move.w	#131,obj.y(a0)				; Set Y position
	
; ------------------------------------------------------------------------------

.Done:
	bsr.w	BookmarkObject				; Set bookmark
	bra.s	.Done					; Remain static

; ------------------------------------------------------------------------------
; Trademark symbol mappings
; ------------------------------------------------------------------------------

MapSpr_TM:
	include	"Title Screen/Objects/Copyright/Data/Mappings (TM).asm"
	even

; ------------------------------------------------------------------------------
