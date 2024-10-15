; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"

	section code_load_file
	
	xref FileFunction

; ------------------------------------------------------------------------------
; Load file
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to file name
;	a1.l - File read destination buffer
; ------------------------------------------------------------------------------

	xdef LoadFile
LoadFile:
	move.w	#FILE_LOAD_FILE,d0				; Start file loading
	jsr	FileFunction

.WaitFileLoad:
	jsr	_WAITVSYNC					; VSync
	
	move.w	#FILE_STATUS,d0					; Is the operation finished?
	jsr	FileFunction
	bcs.s	.WaitFileLoad					; If not, wait

	cmpi.w	#FILE_STATUS_OK,d0				; Was the operation a success?
	bne.w	LoadFile					; If not, try again
	rts

; ------------------------------------------------------------------------------
