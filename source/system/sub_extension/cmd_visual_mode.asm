; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"

	section code
	
	xref VisualModeFile, WaitWordRamAccess, ResetCddaVolume, TitleScreenSong
	xref GiveWordRamAccess

; ------------------------------------------------------------------------------
; Load Visual Mode menu
; ------------------------------------------------------------------------------

	xdef LoadVisualMode
LoadVisualMode:
	lea	VisualModeFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	bsr.w	ResetCddaVolume					; Play title screen music
	lea	TitleScreenSong(pc),a0
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS

	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
