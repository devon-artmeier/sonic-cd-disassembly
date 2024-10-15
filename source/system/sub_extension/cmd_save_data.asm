; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"
	include	"backup_ram.inc"

	section code
	
	xref BuramScratch, BuramStrings, WaitWordRamAccess, BuramReadParams
	xref GiveWordRamAccess, BuramWriteParams

; ------------------------------------------------------------------------------
; Read save data
; ------------------------------------------------------------------------------
	
	xdef ReadBuramSaveData
ReadBuramSaveData:
	lea	BuramScratch(pc),a0				; Initialize Backup RAM interaction
	lea	BuramStrings(pc),a1
	move.w	#BRMINIT,d0
	jsr	_BURAM

.ReadData:
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	lea	BuramReadParams(pc),a0				; Load save data
	lea	WORD_RAM_2M,a1
	move.w	#BRMREAD,d0
	jsr	_BURAM
	bcs.s	.ReadData					; If it failed, try again

	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
; Write save data
; ------------------------------------------------------------------------------

	xdef WriteBuramSaveData
WriteBuramSaveData:
	lea	BuramScratch(pc),a0				; Initialize Backup RAM interaction
	lea	BuramStrings(pc),a1
	move.w	#BRMINIT,d0
	jsr	_BURAM

.WriteData:
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	lea	BuramWriteParams(pc),a0				; Write save data
	lea	WORD_RAM_2M,a1
	move.w	#BRMWRITE,d0
	moveq	#0,d1
	jsr	_BURAM
	bcs.s	.WriteData					; If it failed, try again
	
	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
; Read temporary save data
; ------------------------------------------------------------------------------

	xdef ReadTempSaveData
ReadTempSaveData:
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	lea	TempSaveData,a0					; Copy from temporary save data buffer
	lea	WORD_RAM_2M,a1
	move.w	#save.struct_size/4-1,d7

.Read:
	move.l	(a0)+,(a1)+
	dbf	d7,.Read

	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
; Write temporary save data
; ------------------------------------------------------------------------------

	xdef WriteTempSaveData
WriteTempSaveData:
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	lea	TempSaveData,a0					; Copy to temporary save data buffer
	lea	WORD_RAM_2M,a1
	move.w	#save.struct_size/4-1,d7

.Write:
	move.l	(a1)+,(a0)+
	dbf	d7,.Write

	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
