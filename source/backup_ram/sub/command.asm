; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Run Backup RAM command
; ------------------------------------------------------------------------------

	xdef BuramCommand
BuramCommand:
	moveq	#0,d0						; Get command ID
	move.b	buram_command,d0
	beq.s	.End						; If it's zero, branch
	
	subq.w	#1,d0						; Make command ID zero based
	cmpi.w	#(.CommandsEnd-.Commands)/2,d0			; Is it too large?
	bcc.s	.Error						; If so, branch

	add.w	d0,d0						; Run command
	lea	.Commands,a0
	move.w	(a0,d0.w),d0
	moveq	#0,d1
	jsr	(a0,d0.w)
	bcs.s	.Error						; If an error occured, branch

	move.b	#0,buram_status					; Mark as a success
	bra.s	.GetReturnVals

.Error:
	move.b	#-1,buram_status				; Mark as a failure

.GetReturnVals:
	move.w	d0,buram_d0					; Store return values
	move.w	d1,buram_d1
	
	clr.b	buram_command					; Mark command as completed

.End:
	rts

; ------------------------------------------------------------------------------

.Commands:
	dc.w	InitBuram-.Commands
	dc.w	GetBuramStatus-.Commands
	dc.w	CartBuram-.Commands
	dc.w	ReadBuram-.Commands	
	dc.w	WriteBuram-.Commands
	dc.w	DeleteBuram-.Commands
	dc.w	FormatBuram-.Commands
	dc.w	GetBuramDirectory-.Commands
	dc.w	VerifyBuram-.Commands
	dc.w	ReadSaveData-.Commands
	dc.w	WriteSaveData-.Commands
.CommandsEnd:

; ------------------------------------------------------------------------------
; Initialize Backup RAM interaction
; ------------------------------------------------------------------------------

InitBuram:
	lea	BuramScratch,a0					; Initialize Backup RAM
	lea	BuramStrings,a1
	moveq	#BRMINIT,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Get Backup RAM status	
; ------------------------------------------------------------------------------

GetBuramStatus:
	moveq	#BRMSTAT,d0					; Get Backup RAM status
	movea.l	#BuramStrings,a1
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Search Backup RAM
; ------------------------------------------------------------------------------

CartBuram:
	movea.l	#buram_params,a0				; Search Backup RAM
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	moveq	#BRMSERCH,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Read from Backup RAM
; ------------------------------------------------------------------------------

ReadBuram:
	movea.l	#buram_params,a0				; Read Backup RAM
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	movea.l	#buram_data,a1
	moveq	#BRMREAD,d0
	jsr	_BURAM
	rts

; ------------------------------------------------------------------------------
; Read save data
; ------------------------------------------------------------------------------

ReadSaveData:
	tst.b	buram_disabled					; Is Backup RAM disabled?
	bne.s	.BuramDisabled					; If so, branch

	bsr.s	ReadBuram					; Read from Backup RAM
	bsr.w	WriteTempSaveData				; Write read data to temporary save data buffer
	
	move.w	#0,buram_d0
	move.w	#0,buram_d1
	rts

.BuramDisabled:
	bsr.w	ReadTempSaveData				; Read from temporary save data buffer
	move.w	#0,buram_d0
	move.w	#0,buram_d1
	rts

; ------------------------------------------------------------------------------
; Write to Backup RAM
; ------------------------------------------------------------------------------

WriteBuram:
	movea.l	#buram_params,a0				; Write Backup RAM
	move.b	buram_write_flag,buram_param.flag(a0)
	move.w	buram_block_size,buram_param.block_size(a0)
	movea.l	#buram_data,a1
	moveq	#BRMWRITE,d0
	jsr	_BURAM
	rts

; ------------------------------------------------------------------------------
; Write save data
; ------------------------------------------------------------------------------

WriteSaveData:
	tst.b	buram_disabled					; Is Backup RAM disabled?
	bne.s	.BuramDisabled					; If so, branch

	bsr.s	WriteBuram					; Write to Backup RAM
	bsr.w	WriteTempSaveData				; Write to temporary save data buffer
	move.w	#0,buram_d0
	move.w	#0,buram_d1
	rts

.BuramDisabled:
	bsr.w	WriteTempSaveData				; Write to temporary save data buffer
	move.w	#0,buram_d0
	move.w	#0,buram_d1
	rts

; ------------------------------------------------------------------------------
; Delete Backup RAM
; ------------------------------------------------------------------------------

DeleteBuram:
	movea.l	#buram_params,a0				; Delete Backup RAM
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	moveq	#BRMDEL,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Format Backup RAM
; ------------------------------------------------------------------------------

FormatBuram:
	moveq	#BRMFORMAT,d0					; Format Backup RAM
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Get Backup RAM directory
; ------------------------------------------------------------------------------

GetBuramDirectory:
	movea.l	#buram_params,a0				; Get Backup RAM directory
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	movea.l	#buram_data+4,a1
	move.l	buram_data,d1
	moveq	#BRMDIR,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Verify Backup RAM
; ------------------------------------------------------------------------------

VerifyBuram:
	movea.l	#buram_params,a0				; Verify Backup RAM
	move.b	buram_write_flag,buram_param.flag(a0)
	move.w	buram_block_size,buram_param.block_size(a0)
	movea.l	#buram_data,a1
	moveq	#BRMVERIFY,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Write to temporary save data buffer
; ------------------------------------------------------------------------------

WriteTempSaveData:
	movem.l	d0/a0-a1,-(sp)					; Save registers

	movea.l	#buram_data,a0					; Write to temporary save data buffer
	movea.l	#TempSaveData,a1
	move.w	#save.struct_size/4-1,d0

.Write:
	move.l	(a0)+,(a1)+
	dbf	d0,.Write

	movem.l	(sp)+,d0/a0-a1					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Read from temporary save data buffer
; ------------------------------------------------------------------------------

ReadTempSaveData:
	movem.l	d0/a0-a1,-(sp)					; Save registers

	movea.l	#TempSaveData,a0				; Read from temporary save data buffer
	movea.l	#buram_data,a1
	move.w	#save.struct_size/4-1,d0

.read:
	move.l	(a0)+,(a1)+
	dbf	d0,.read

	movem.l	(sp)+,d0/a0-a1					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Backup RAM data
; ------------------------------------------------------------------------------

BuramScratch:
	dcb.b	$640, 0						; Scratch RAM

BuramStrings:	
	dcb.b	$C, 0						; Display strings

; ------------------------------------------------------------------------------
