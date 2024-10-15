; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"

	section code
	
	xref IpxFile, SoundTestFile, McSonicFile, StageSelectFile
	xref WaitWordRamAccess, GiveWordRamAccess

; ------------------------------------------------------------------------------
; Load main program
; ------------------------------------------------------------------------------

	xdef LoadIpx
LoadIpx:
	lea	IpxFile(pc),a0					; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load sound test
; ------------------------------------------------------------------------------

	xdef LoadSoundTest
LoadSoundTest:
	lea	SoundTestFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load dummy file (unused)
; ------------------------------------------------------------------------------

	xdef LoadDummyFile1
LoadDummyFile1:
	lea	McSonicFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load dummy file (unused)
; ------------------------------------------------------------------------------

	xdef LoadDummyFile2
LoadDummyFile2:
	lea	McSonicFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load dummy file (unused)
; ------------------------------------------------------------------------------

	xdef LoadDummyFile3
LoadDummyFile3:
	lea	McSonicFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load dummy file (unused)
; ------------------------------------------------------------------------------

	xdef LoadDummyFile4
LoadDummyFile4:
	lea	McSonicFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load dummy file (unused)
; ------------------------------------------------------------------------------

	xdef LoadDummyFile5
LoadDummyFile5:
	lea	McSonicFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load stage select
; ------------------------------------------------------------------------------

	xdef LoadStageSelect
LoadStageSelect:
	lea	StageSelectFile(pc),a0				; Load file
	
; ------------------------------------------------------------------------------
; Load file into Word RAM
; ------------------------------------------------------------------------------
; PARAMETERS
;	a0.l - Pointer to file name
; ------------------------------------------------------------------------------

LoadFileIntoWordRam:
	bsr.w	WaitWordRamAccess				; Load file into Word RAM
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bra.w	GiveWordRamAccess

; ------------------------------------------------------------------------------
