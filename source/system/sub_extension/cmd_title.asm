; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"

	section code
	
	xref TitleMainFile, WaitWordRamAccess, GiveWordRamAccess, TitleSubFile
	xref ResetCddaVolume, TitleScreenSong

; ------------------------------------------------------------------------------
; Load title screen
; ------------------------------------------------------------------------------

	xdef LoadTitleScreen
LoadTitleScreen:
	lea	TitleMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	lea	TitleSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	bsr.w	GiveWordRamAccess				; Give Main CPU Word RAM access

	bsr.w	ResetCddaVolume					; Play title screen music
	lea	TitleScreenSong(pc),a0
	move.w	#MSCPLAY1,d0
	jsr	_CDBIOS

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	rts

; ------------------------------------------------------------------------------
