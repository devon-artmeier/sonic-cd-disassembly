; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"
	include	"special_stage.inc"

	section code
	
	xref SpecialStageMainFile, WaitWordRamAccess, SpecialStageSubFile, GiveWordRamAccess
	xref ResetCddaVolume, SpecialStageSong, ResultsSong

; ------------------------------------------------------------------------------
; Load special stage
; ------------------------------------------------------------------------------

	xdef LoadSpecialStage
LoadSpecialStage:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	move.b	special_stage_id_cmd,special_stage_id		; Set stage ID
	move.b	time_stones_cmd,time_stones_sub			; Set time stones retrieved
	move.b	special_stage_flags,spec_stage_flags_copy	; Copy flags

	lea	SpecialStageMainFile(pc),a0			; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	lea	SpecialStageSubFile(pc),a0			; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	moveq	#0,d0						; Copy stage data into Word RAM
	move.b	special_stage_id,d0
	mulu.w	#6,d0
	lea	SpecialStageData,a0
	move.w	4(a0,d0.w),d7
	movea.l	(a0,d0.w),a0
	lea	WORD_RAM_2M+SpecialStageDataCopy,a1

.CopyData:
	move.b	(a0)+,(a1)+
	dbf	d7,.CopyData

	bsr.w	GiveWordRamAccess				; Give Main CPU Word RAM access

	bsr.w	ResetCddaVolume					; Play special stage music
	lea	SpecialStageSong(pc),a0
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	
	btst	#1,spec_stage_flags_copy			; Were we in time attack mode?
	bne.s	.NoResultsSong					; If so, branch
	
	bsr.w	ResetCddaVolume					; If not, play results music
	lea	ResultsSong(pc),a0
	move.w	#MSCPLAY1,d0
	jsr	_CDBIOS

.NoResultsSong:
	move.b	#0,spec_stage_flags_copy			; Clear special stage flags copy
	move.l	#0,cur_pcm_driver				; Reset current PCM driver
	rts

; ------------------------------------------------------------------------------
