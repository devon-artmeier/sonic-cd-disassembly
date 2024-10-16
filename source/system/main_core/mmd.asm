; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code
	
	xref WaitWordRamAccess, GiveWordRamAccess, StopZ80, StartZ80
	xref HBlankIrq, VBlankIrq, VSync

; ------------------------------------------------------------------------------
; Run MMD file
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - File load command ID
; ------------------------------------------------------------------------------
	
	xdef RunMmd
RunMmd:
	move.l	a0,-(sp)					; Save registers
	move.w	d0,MCD_MAIN_COMM_0				; Set command ID

	lea	work_ram_file,a1				; Clear work RAM file buffer
	moveq	#0,d0
	move.w	#WORK_RAM_FILE_SIZE/16-1,d7

.ClearFileBuffer:
	rept	16/4
		move.l	d0,(a1)+
	endr
	dbf	d7,.ClearFileBuffer

	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	move.l	WORD_RAM_2M+mmd.entry,d0			; Get entry address
	beq.w	.End						; If it's not set, exit
	movea.l	d0,a0

	move.l	WORD_RAM_2M+mmd.origin,d0			; Get origin address
	beq.s	.GetHBlank					; If it's not set, branch
	
	movea.l	d0,a2						; Copy file to origin address
	lea	WORD_RAM_2M+mmd.file,a1
	move.w	WORD_RAM_2M+mmd.size,d7

.CopyFile:
	move.l	(a1)+,(a2)+
	dbf	d7,.CopyFile

.GetHBlank:
	move	sr,-(sp)					; Save status register

	move.l	WORD_RAM_2M+mmd.hblank,d0			; Get H-BLANK interrupt address
	beq.s	.GetVBlank					; If it's not set, branch
	move.l	d0,_LEVEL4+2					; Set H-BLANK interrupt address

.GetVBlank:
	move.l	WORD_RAM_2M+mmd.vblank,d0			; Get V-BLANK interrupt address
	beq.s	.CheckFlags					; If it's not set, branch
	move.l	d0,_LEVEL6+2					; Set V-BLANK interrupt address

.CheckFlags:
	btst	#MMD_SUB_BIT,WORD_RAM_2M+mmd.flags		; Should the Sub CPU have Word RAM access?
	beq.s	.NoSubWordRam					; If not, branch
	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM access

.NoSubWordRam:
	move	(sp)+,sr					; Restore status register

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

	jsr	(a0)						; Run file
	move.b	d0,mmd_return_code				; Set return code

	bsr.w	StopZ80						; Stop FM sound
	move.b	#FM_CMD_STOP,FmSoundQueue2
	bsr.w	StartZ80

	move.b	#0,ipx_vsync					; Clear VSync flag
	move.l	#HBlankIrq,_LEVEL4+2				; Reset H-BLANK interrupt address
	move.l	#VBlankIrq,_LEVEL6+2				; Reset V-BLANK interrupt address
	move.w	#$8134,ipx_vdp_reg_81				; Reset VDP register 1 cache
	
	bset	#0,screen_disabled				; Set screen disable flag
	bsr.w	VSync						; VSync
	
	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM access

.End:
	movea.l	(sp)+,a0					; Restore a0
	rts

; ------------------------------------------------------------------------------
; Variables
; ------------------------------------------------------------------------------

	xdef screen_disabled
screen_disabled:
	dc.b	0						; Screen disable flag
	
	xdef mmd_return_code
mmd_return_code:
	dc.b	0						; MMD return code
	
; ------------------------------------------------------------------------------
