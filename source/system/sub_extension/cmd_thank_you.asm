; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"

	section code
	
	xref WaitWordRamAccess, ThankYouMainFile, ThankYouDataFile, GiveWordRamAccess
	xref ThankYouSubFile

; ------------------------------------------------------------------------------
; Load "Thank You" screen
; ------------------------------------------------------------------------------

	xdef LoadThankYou
LoadThankYou:
	bsr.w	WaitWordRamAccess				; Load Main CPU file
	lea	ThankYouMainFile(pc),a0
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	lea	ThankYouDataFile(pc),a0				; Load data file
	lea	WORD_RAM_2M+$10000,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	ThankYouSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	rts

; ------------------------------------------------------------------------------
