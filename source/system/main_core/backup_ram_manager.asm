; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code
	
	xref RunMmd, ReadSaveData

; ------------------------------------------------------------------------------
; Backup RAM manager
; ------------------------------------------------------------------------------

	xdef BuramManager
BuramManager:
	move.w	#SYS_BURAM_MANAGER,d0				; Run Backup RAM manager
	bsr.w	RunMmd
	bsr.w	ReadSaveData					; Read save data
	rts
	
; ------------------------------------------------------------------------------
