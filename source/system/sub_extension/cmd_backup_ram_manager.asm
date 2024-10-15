; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"

	section code
	
	xref BuramMainFile, WaitWordRamAccess, GiveWordRamAccess, BuramSubFile

; ------------------------------------------------------------------------------
; Load Backup RAM manager
; ------------------------------------------------------------------------------

	xdef LoadBuramManager
LoadBuramManager:
	lea	BuramMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	BuramSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	rts

; ------------------------------------------------------------------------------
