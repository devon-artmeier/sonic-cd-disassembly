; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"

	section code

; ------------------------------------------------------------------------------
; Initialization
; ------------------------------------------------------------------------------

	xdef Initialize
Initialize:
	lea	MCD_SUB_COMMS,a0				; Clear communication registers
	moveq	#0,d0
	move.b	d0,MCD_SUB_FLAG-MCD_SUB_COMMS(a0)
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+

	lea	DriveInitParams(pc),a0				; Initialzie drive
	move.w	#DRVINIT,d0
	jsr	_CDBIOS

.WaitReady:
	move.w	#CDBSTAT,d0					; Is the BIOS ready?
	jsr	_CDBIOS
	andi.b	#BIOS_BUSY_MASK,_CDSTAT
	bne.s	.WaitReady					; If not, wait

	andi.b	#~(MCDR_RET|MCDR_MODE),MCD_MEM_MODE		; Set to 2M mode
	
	move.w	#FILE_INIT,d0					; Initialize file engine
	jsr	FileFunction

	xdef UserCall
UserCall:
	rts

; ------------------------------------------------------------------------------

DriveInitParams:
	dc.b	1, $FF

SpxFile:
	dc.b	"SPX___.BIN;1", 0
	even

; ------------------------------------------------------------------------------
; Main
; ------------------------------------------------------------------------------

	xdef Main
Main:
	move.w	#FILE_GET_FILES,d0				; Get files
	jsr	FileFunction

.Wait:
	jsr	_WAITVSYNC					; VSync

	move.w	#FILE_STATUS,d0					; Is the operation finished?
	jsr	FileFunction
	bcs.s	.Wait						; If not, wait

	cmpi.w	#FILE_STATUS_OK,d0				; Was the operation a success?
	bne.w	.Error						; If not, branch

	lea	SpxFile(pc),a0					; Load SPX file
	lea	Spx,a1
	jsr	LoadFile.w

	lea	PRG_RAM+$10000,sp				; Set stack pointer
	jmp	SpxStart					; Go to SPX

.Error:
	nop							; Loop here forever
	nop
	bra.s	.Error

; ------------------------------------------------------------------------------
