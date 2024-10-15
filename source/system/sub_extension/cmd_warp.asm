; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"

	section code
	
	xref WarpFile, WaitWordRamAccess, GiveWordRamAccess
	
; ------------------------------------------------------------------------------
; Load time warp cutscene
; ------------------------------------------------------------------------------

	xdef LoadWarp
LoadWarp:
	lea	WarpFile(pc),a0					; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bra.w	GiveWordRamAccess

; ------------------------------------------------------------------------------
