; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"

	section code_get_file_name

; ------------------------------------------------------------------------------
; Get file name
; ------------------------------------------------------------------------------
; NOTE: This function is not reliable, because there are some file names
; whose size is shorter or longer than "FILE_NAME_SIZE" characters. This is only
; used by the FMVs for getting name of their associated data file, whose
; file names are stored in the "safe" part of the file name table.
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - File ID
; RETURNS:
;	a0.l - Pointer to file name
; ------------------------------------------------------------------------------

	xdef GetFileName
GetFileName:
	mulu.w	#FILE_NAME_SIZE+1,d0				; Get file name pointer
	lea	SpxFileNameTable,a0
	adda.w	d0,a0
	rts

; ------------------------------------------------------------------------------
