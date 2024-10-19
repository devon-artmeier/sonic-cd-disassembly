; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"variables.inc"

	section code
	
	xref GraphicsIrq, WaitWordRamAccess, BuramCommand, GiveWordRamAccess

; ------------------------------------------------------------------------------
; Program start
; ------------------------------------------------------------------------------

Start:
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
	move.b	#MCDR_SUB_READ,MCD_CDC_DEVICE			; Set CDC device destination

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
