; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	section code

; ------------------------------------------------------------------------------
; Backup RAM scratch data
; ------------------------------------------------------------------------------

	xdef BuramScratch
BuramScratch:
	dcb.b	$640, 0						; Scratch RAM

	xdef BuramStrings
BuramStrings:	
	dcb.b	$C, 0						; Display strings

; ------------------------------------------------------------------------------
