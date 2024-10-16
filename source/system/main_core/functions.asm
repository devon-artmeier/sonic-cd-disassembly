; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code
	
; ------------------------------------------------------------------------------
; Send the Sub CPU a command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; ------------------------------------------------------------------------------

	xdef SubCpuCommand
SubCpuCommand:
	move.w	d0,MCD_MAIN_COMM_0				; Set command ID

.WaitSubCpu:
	move.w	MCD_SUB_COMM_0,d0				; Has the Sub CPU received the command?
	beq.s	.WaitSubCpu					; If not, wait
	cmp.w	MCD_SUB_COMM_0,d0
	bne.s	.WaitSubCpu					; If not, wait

	move.w	#0,MCD_MAIN_COMM_0				; Mark as ready to send commands again

.WaitSubCpuDone:
	move.w	MCD_SUB_COMM_0,d0				; Is the Sub CPU done processing the command?
	bne.s	.WaitSubCpuDone					; If not, wait
	move.w	MCD_SUB_COMM_0,d0
	bne.s	.WaitSubCpuDone					; If not, wait
	rts

; ------------------------------------------------------------------------------
; Wait for Word RAM access
; ------------------------------------------------------------------------------

	xdef WaitWordRamAccess
WaitWordRamAccess:
	btst	#MCDR_RET_BIT,MCD_MEM_MODE			; Do we have Word RAM access?
	beq.s	WaitWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
; Give Sub CPU Word RAM access
; ------------------------------------------------------------------------------

	xdef GiveWordRamAccess
GiveWordRamAccess:
	bset	#MCDR_DMNA_BIT,MCD_MEM_MODE			; Give Sub CPU Word RAM access
	btst	#MCDR_DMNA_BIT,MCD_MEM_MODE			; Has it been given?
	beq.s	GiveWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
; Stop the Z80
; ------------------------------------------------------------------------------

	xdef StopZ80
StopZ80:
	move	sr,saved_sr					; Save status register
	move	#$2700,sr					; Disable interrupts
	getZ80Bus						; Get Z80 bus access
	rts

; ------------------------------------------------------------------------------
; Start the Z80
; ------------------------------------------------------------------------------

	xdef StartZ80
StartZ80:
	releaseZ80Bus						; Release Z80 bus
	move	saved_sr,sr					; Restore status register
	rts

; ------------------------------------------------------------------------------
; VSync
; ------------------------------------------------------------------------------

	xdef VSync
VSync:
	bset	#0,ipx_vsync					; Set VSync flag
	move	#$2500,sr					; Enable V-BLANK interrupt

.Wait:
	btst	#0,ipx_vsync					; Has the V-BLANK handler run?
	bne.s	.Wait						; If not, wait
	rts

; ------------------------------------------------------------------------------
; Send the Sub CPU a command (copy)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; ------------------------------------------------------------------------------

	xdef SubCpuCommandCopy
SubCpuCommandCopy:
	move.w	d0,MCD_MAIN_COMM_0				; Send the command

.WaitSubCpu:
	move.w	MCD_SUB_COMM_0,d0				; Has the Sub CPU received the command?
	beq.s	.WaitSubCpu					; If not, wait
	cmp.w	MCD_SUB_COMM_0,d0
	bne.s	.WaitSubCpu					; If not, wait

	move.w	#0,MCD_MAIN_COMM_0				; Mark as ready to send commands again

.WaitSubCpuDone:
	move.w	MCD_SUB_COMM_0,d0				; Is the Sub CPU done processing the command?
	bne.s	.WaitSubCpuDone					; If not, wait
	move.w	MCD_SUB_COMM_0,d0
	bne.s	.WaitSubCpuDone					; If not, wait
	rts

; ------------------------------------------------------------------------------
; Saved status register
; ------------------------------------------------------------------------------

saved_sr:
	dc.w	0
	
; ------------------------------------------------------------------------------
; Unknown
; ------------------------------------------------------------------------------

	jmp	0
	
; ------------------------------------------------------------------------------
