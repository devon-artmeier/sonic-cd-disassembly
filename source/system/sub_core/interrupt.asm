; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"

	section code_md_irq
	
	xref FileFunction

; ------------------------------------------------------------------------------
; Load file
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to file name
;	a1.l - File read destination buffer
; ------------------------------------------------------------------------------

	xdef MegaDriveIrq
MegaDriveIrq:
	movem.l	d0-a6,-(sp)					; Save registers
	move.w	#FILE_OPERATION,d0				; Perform file engine operation
	jsr	FileFunction
	movem.l	(sp)+,d0-a6					; Restore registers
	rts

; ------------------------------------------------------------------------------
