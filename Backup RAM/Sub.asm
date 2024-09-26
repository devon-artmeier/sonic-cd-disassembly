; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Sub CPU Backup RAM management functions
; ------------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/System.i"
	include	"_Include/Backup RAM.i"

; ------------------------------------------------------------------------------
; Variables
; ------------------------------------------------------------------------------

	rsset	PRG_RAM+$16000
VARIABLES		rs.b 0					; Start of variables
			rs.b $800
irq1_flag		rs.b 1					; Graphics interrupt flag
			rs.b $17FF
VARIABLES_SIZE		equ __rs-VARIABLES			; Size of variables area

decomp_window		equ WORD_RAM_2M+$38000			; Decompression sliding window

; ------------------------------------------------------------------------------
; Program start
; ------------------------------------------------------------------------------

	org	$10000

	move.l	#GraphicsIrq,_LEVEL1+2				; Set IRQ1 handler
	move.b	#0,MCD_MEM_MODE					; Set to 2M mode

	moveq	#0,d0						; Clear communication statuses
	move.l	d0,MCD_SUB_COMM_0
	move.l	d0,MCD_SUB_COMM_4
	move.l	d0,MCD_SUB_COMM_8
	move.l	d0,MCD_SUB_COMM_12
	
	bset	#7,MCD_SUB_FLAG					; Mark as started
	bclr	#MCDR_IEN1_BIT,MCD_IRQ_MASK			; Disable graphics interrupt
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt
	move.b	#MCDR_CDC_SUB_READ,MCD_CDC_DEVICE		; Set CDC device destination

	lea	VARIABLES,a0					; Clear variables
	move.w	#VARIABLES_SIZE/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars

	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	lea	WORD_RAM_2M,a0					; Clear Word RAM
	move.w	#WORD_RAM_2M_SIZE/8-1,d7

.ClearWordRam:
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbf	d7,.ClearWordRam

	bset	#MCDR_IEN1_BIT,MCD_IRQ_MASK			; Enable graphics interrupt
	bclr	#7,MCD_SUB_FLAG					; Mark as initialized

; ------------------------------------------------------------------------------

MainLoop:
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access
	
	btst	#7,MCD_MAIN_FLAG				; Is the Main CPU finished?
	bne.s	.Done						; If so, branch
	
	bsr.w	BuramCommand					; Run Backup RAM command
	bsr.w	GiveWordRamAccess				; Give Main CPU Word RAM access
	
	bra.w	MainLoop					; Loop

.Done:
	bset	#7,MCD_SUB_FLAG					; Tell Main CPU that we are done

.WaitMainCpu:
	btst	#7,MCD_MAIN_FLAG				; Is the Main CPU done?
	bne.s	.WaitMainCpu					; If not, wait

	moveq	#0,d0						; Clear communication statuses
	move.l	d0,MCD_SUB_COMM_0
	move.l	d0,MCD_SUB_COMM_4
	move.l	d0,MCD_SUB_COMM_8
	move.l	d0,MCD_SUB_COMM_12
	move.b	d0,MCD_SUB_FLAG
	nop
	rts

; ------------------------------------------------------------------------------
; Unused function to get a command ID from the Main CPU
; ------------------------------------------------------------------------------
; RETURNS:
;	d0.w - Command ID
; ------------------------------------------------------------------------------

GetMainCpuCommand:
	move.w	MCD_MAIN_COMM_2,d0				; Get command ID from Main CPU
	beq.w	MainLoop					; If it's zero, exit out
	move.w	MCD_MAIN_COMM_2,MCD_SUB_COMM_2			; Acknowledge command

.WaitMainCpu:
	tst.w	MCD_MAIN_COMM_2					; Is the Main CPU ready to send more commands?
	bne.s	.WaitMainCpu					; If not, branch
	
	move.w	#0,MCD_SUB_COMM_2				; Mark as ready for another command
	rts

; ------------------------------------------------------------------------------
; Unknown graphics interrupt handler
; ------------------------------------------------------------------------------

GraphicsIrq:
	move.b	#0,irq1_flag					; Clear IRQ1 flag
	rte

; ------------------------------------------------------------------------------
; Unknown decompression routine
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to compressed data
;	a1.l - Pointer to destination buffer
; ------------------------------------------------------------------------------

UnkDecomp:
	movem.l	d0-a2,-(sp)					; Save registers

	lea	decomp_window,a2				; Decompression sliding window
	move.w	(a0)+,d7					; Get size of uncompressed data
	subq.w	#1,d7						; Subtract 1 for loop
	move.w	#(-$12)&$FFF,d2					; Set window position
	
	move.b	(a0)+,d1					; Get first description field
	move.w	#$FFF,d6					; Set window position mask
	moveq	#8,d0						; Number of bits in description field

.MainLoop:
	dbf	d0,.NextDescBit					; Loop until all flags have been scanned
	moveq	#8-1,d0						; Prepare next description field
	move.b	(a0)+,d1

.NextDescBit:
	lsr.b	#1,d1						; Get next description field bit
	bcc.s	.CopyFromWindow					; 0 | If we are copying from the window, branch

.CopyNextByte:
	move.b	(a0),(a1)+					; 1 | Copy next byte from archive
	move.b	(a0)+,(a2,d2.w)					; Store in window
	addq.w	#1,d2						; Advance window position
	and.w	d6,d2
	dbf	d7,.MainLoop					; Loop until all of the data is decompressed
	bra.s	.End						; Exit out

.CopyFromWindow:
	moveq	#0,d3
	move.b	(a0)+,d3					; Get low byte of window position
	move.b	(a0)+,d4					; Get high bits of window position and length
	
	move.w	d4,d5						; Combine window position bits
	andi.w	#$F0,d5
	lsl.w	#4,d5
	or.w	d5,d3

	andi.w	#$F,d4						; Isolate length
	addq.w	#3-1,d4						; Copy at least 3 bytes from window

.CopyWindowLoop:
	move.b	(a2,d3.w),d5					; Get byte from window
	move.b	d5,(a1)+					; Store in decompressed data buffer
	subq.w	#1,d7						; Decrement bytes left to decompress
	move.b	d5,(a2,d2.w)					; Store in window
	
	addq.w	#1,d3						; Advance copy position
	and.w	d6,d3
	addq.w	#1,d2						; Advance window position
	and.w	d6,d2

	dbf	d4,.CopyWindowLoop				; Loop until all bytes are copied
	tst.w	d7						; Are there any bytes left to decompress?
	bpl.s	.MainLoop					; If so, branch

.End:
	movem.l	(sp)+,d0-a2					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Mass copy
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - Pointer to destination buffer
; ------------------------------------------------------------------------------

Copy128:
	move.l	(a1)+,(a2)+
Copy124:
	move.l	(a1)+,(a2)+
Copy120:
	move.l	(a1)+,(a2)+
Copy116:
	move.l	(a1)+,(a2)+
Copy112:
	move.l	(a1)+,(a2)+
Copy108:
	move.l	(a1)+,(a2)+
Copy104:
	move.l	(a1)+,(a2)+
Copy100:
	move.l	(a1)+,(a2)+
Copy96:
	move.l	(a1)+,(a2)+
Copy92:
	move.l	(a1)+,(a2)+
Copy88:
	move.l	(a1)+,(a2)+
Copy84:
	move.l	(a1)+,(a2)+
Copy80:
	move.l	(a1)+,(a2)+
Copy76:
	move.l	(a1)+,(a2)+
Copy72:
	move.l	(a1)+,(a2)+
Copy68:
	move.l	(a1)+,(a2)+
Copy64:
	move.l	(a1)+,(a2)+
Copy60:
	move.l	(a1)+,(a2)+
Copy56:
	move.l	(a1)+,(a2)+
Copy52:
	move.l	(a1)+,(a2)+
Copy48:
	move.l	(a1)+,(a2)+
Copy44:
	move.l	(a1)+,(a2)+
Copy40:
	move.l	(a1)+,(a2)+
Copy36:
	move.l	(a1)+,(a2)+
Copy32:
	move.l	(a1)+,(a2)+
Copy28:
	move.l	(a1)+,(a2)+
Copy24:
	move.l	(a1)+,(a2)+
Copy20:
	move.l	(a1)+,(a2)+
Copy16:
	move.l	(a1)+,(a2)+
Copy12:
	move.l	(a1)+,(a2)+
Copy8:
	move.l	(a1)+,(a2)+
Copy4:
	move.l	(a1)+,(a2)+
	rts

; ------------------------------------------------------------------------------
; Wait for the graphics interrupt handler to run
; ------------------------------------------------------------------------------

WaitGraphicsIrq:
	move.b	#1,irq1_flag					; Set IRQ1 flag
	move	#$2000,sr					; Enable interrupts

.Wait:
	tst.b	irq1_flag					; Has the interrupt handler been run?
	bne.s	.Wait						; If not, wait
	rts

; ------------------------------------------------------------------------------
; Sync with Main CPU
; ------------------------------------------------------------------------------

SyncWithMainCpu:
	tst.w	MCD_MAIN_COMM_2					; Are we synced with the Main CPU?
	bne.s	SyncWithMainCpu					; If not, wait
	rts

; ------------------------------------------------------------------------------
; Give Main CPU Word RAM access
; ------------------------------------------------------------------------------

GiveWordRamAccess:
	bset	#MCDR_RET_BIT,MCD_MEM_MODE			; Give Main CPU Word RAM access
	btst	#MCDR_RET_BIT,MCD_MEM_MODE			; Has it been given?
	beq.s	GiveWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
; Wait for Word RAM access
; ------------------------------------------------------------------------------

WaitWordRamAccess:
	btst	#MCDR_DMNA_BIT,MCD_MEM_MODE			; Do we have Word RAM access?
	beq.s	WaitWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
; Load source image map
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - Pointer to destination buffer
;	d1.w - Width (minus 1)
;	d2.w - Height (minus 1)
; ------------------------------------------------------------------------------

LoadSourceImageMap:
	move.l	#$100,d4					; Stride

.SetupRow:
	movea.l	d0,a2						; Set row pointer
	move.w	d1,d3						; Set row width

.RowLoop:
	move.w	(a1)+,d5					; Get data
	lsl.w	#2,d5
	move.w	d5,(a2)+					; Store it
	dbf	d3,.RowLoop					; Loop until row is written
	add.l	d4,d0						; Next row
	dbf	d2,.SetupRow					; Loop until all data is written
	rts

; ------------------------------------------------------------------------------
; Run Backup RAM command
; ------------------------------------------------------------------------------

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
