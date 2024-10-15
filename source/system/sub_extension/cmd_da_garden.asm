; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"
	include	"da_garden.inc"

	section code
	
	xref DaGardenMainFile, WaitWordRamAccess, DaGardenDataFile, GiveWordRamAccess
	xref DaGardenSubFile, ResetCddaVolume, DaGardenSong

; ------------------------------------------------------------------------------
; Load D.A. Garden
; ------------------------------------------------------------------------------

	xdef LoadDaGarden
LoadDaGarden:
	lea	DaGardenMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	lea	DaGardenDataFile(pc),a0				; Load data file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M+DaGardenTrackTitles,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	DaGardenSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	bsr.w	ResetCddaVolume					; Play D.A. Garden music
	lea	DaGardenSong(pc),a0
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	rts

; ------------------------------------------------------------------------------
