; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Unused function to send a Backup RAM command to the Sub CPU
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; ------------------------------------------------------------------------------

	xdef SubBuramCommand
SubBuramCommand:
	move.w	#1,MCD_MAIN_COMM_2				; Send command

.WaitSubCpu:
	tst.w	MCD_SUB_COMM_2					; Has the Sub CPU acknowledged it?
	beq.s	.WaitSubCpu
	
	move.w	#0,MCD_MAIN_COMM_2				; Tell Sub CPU we are ready to send more commands

.WaitSubCpu2:
	tst.w	MCD_SUB_COMM_2					; Is the Sub CPU ready for more commands?
	bne.s	.WaitSubCpu2					; If not, wait
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
; Wait for Word RAM access
; ------------------------------------------------------------------------------

	xdef WaitWordRamAccess
WaitWordRamAccess:
	btst	#MCDR_RET_BIT,MCD_MEM_MODE			; Do we have Word RAM access?
	beq.s	WaitWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
; Wait for the Sub CPU program to start
; ------------------------------------------------------------------------------

	xdef WaitSubCpuStart
WaitSubCpuStart:
	btst	#7,MCD_SUB_FLAG					; Has the Sub CPU program started?
	beq.s	WaitSubCpuStart					; If not, wait
	rts 

; ------------------------------------------------------------------------------
; Wait for the Sub CPU program to finish initializing
; ------------------------------------------------------------------------------

	xdef WaitSubCpuInit
WaitSubCpuInit:
	btst	#7,MCD_SUB_FLAG					; Has the Sub CPU program initialized?
	bne.s	WaitSubCpuInit					; If not, wait
	rts

; ------------------------------------------------------------------------------
; Initialize Mega Drive hardware
; ------------------------------------------------------------------------------

	xdef InitMegaDrive
InitMegaDrive:
	lea	.VdpRegisters(pc),a0				; Set up VDP registers
	move.w	#$8000,d0
	moveq	#.VdpRegistersEnd-.VdpRegisters-1,d7

.SetVdpRegisters:
	move.b	(a0)+,d0
	move.w	d0,VDP_CTRL
	addi.w	#$100,d0
	dbf	d7,.SetVdpRegisters

	moveq	#$40,d0						; Set up controller ports
	move.b	d0,IO_CTRL_1
	move.b	d0,IO_CTRL_2
	move.b	d0,IO_CTRL_3
	move.b	#$C0,IO_DATA_1

	bsr.w	StopZ80						; Stop the Z80
	vramFill 0,$10000,0					; Clear VRAM

	vdpCmd move.l,$C000,VRAM,WRITE,VDP_CTRL			; Clear Plane A
	move.w	#$1000/2-1,d7

.ClearPlaneA:
	move.w	#0,VDP_DATA
	dbf	d7,.ClearPlaneA

	vdpCmd move.l,$E000,VRAM,WRITE,VDP_CTRL			; Clear Plane B
	move.w	#$1000/2-1,d7

.ClearPlaneB:
	move.w	#0,VDP_DATA
	dbf	d7,.ClearPlaneB

	vdpCmd move.l,0,CRAM,WRITE,VDP_CTRL			; Load palette
	lea	.Palette(pc),a0
	moveq	#(.PaletteEnd-.Palette)/4-1,d7

.LoadPalette:
	move.l	(a0)+,VDP_DATA
	dbf	d7,.LoadPalette

	vdpCmd move.l,0,VSRAM,WRITE,VDP_CTRL			; Clear VSRAM
	moveq	#$50/4-1,d0

.ClearVsram:
	move.w	#0,VDP_DATA
	move.w	#0,VDP_DATA
	dbf	d0,.ClearVsram

	bsr.w	StartZ80					; Start the Z80
	move.w	#$8134,ipx_vdp_reg_81				; Reset IPX VDP register 1 cache
	rts

; ------------------------------------------------------------------------------

.Palette:
	incbin	"source/backup_ram/initialize/data/palette.pal"
.PaletteEnd:
	even

.VdpRegisters:
	dc.b	%00000100					; No H-BLANK interrupt
	dc.b	%00110100					; V-BLANK interrupt, DMA, mode 5
	dc.b	$C000/$400					; Plane A location
	dc.b	0						; Window location
	dc.b	$E000/$2000					; Plane B location
	dc.b	$BC00/$200					; Sprite table location
	dc.b	0						; Reserved
	dc.b	0						; Background color line 0 color 0
	dc.b	0						; Reserved
	dc.b	0						; Reserved
	dc.b	0						; H-INT counter 0
	dc.b	%00000110					; Scroll by tile
	dc.b	%10000001					; H40
	dc.b	$D000/$400					; Horizontal scroll table lcation
	dc.b	0						; Reserved
	dc.b	2						; Auto increment by 2
	dc.b	%00000001					; 64x32 tile plane size
	dc.b	0						; Window horizontal position 0
	dc.b	0						; Window vertical position 0
.VdpRegistersEnd:
	even

; ------------------------------------------------------------------------------
; Stop the Z80
; ------------------------------------------------------------------------------

	xdef StopZ80
StopZ80:
	move	sr,saved_sr					; Save status register
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
; Read controller data
; ------------------------------------------------------------------------------

	xdef ReadController
ReadController:
	lea	ctrl_data,a0					; Controller data buffer
	lea	IO_DATA_1,a1					; Controller port 1
	
	move.b	#0,(a1)						; TH = 0
	tst.w	(a0)						; Delay
	move.b	(a1),d0						; Read start and A buttons
	lsl.b	#2,d0
	andi.b	#$C0,d0
	
	move.b	#$40,(a1)					; TH = 1
	tst.w	(a0)						; Delay
	move.b	(a1),d1						; Read B, C, and D-pad buttons
	andi.b	#$3F,d1

	or.b	d1,d0						; Combine button data
	not.b	d0						; Flip bits
	move.b	d0,d1						; Make copy

	move.b	(a0),d2						; Mask out tapped buttons
	eor.b	d2,d0
	move.b	d1,(a0)+					; Store pressed buttons
	and.b	d1,d0						; Store tapped buttons
	move.b	d0,(a0)+
	rts

; ------------------------------------------------------------------------------
; Initialize the Z80
; ------------------------------------------------------------------------------

	xdef InitZ80
InitZ80:
	resetZ80Off						; Set Z80 reset off
	jsr	StopZ80(pc)					; Stop the Z80

	lea	Z80_RAM,a1					; Load dummy Z80 code
	move.b	#$F3,(a1)+					; DI
	move.b	#$F3,(a1)+					; DI
	move.b	#$C3,(a1)+					; JP $0000
	move.b	#0,(a1)+
	move.b	#0,(a1)+

	resetZ80On						; Set Z80 reset on
	resetZ80Off						; Set Z80 reset off
	jmp	StartZ80(pc)					; Start the Z80
	rts

; ------------------------------------------------------------------------------
; Play an FM sound in queue 2
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - FM sound ID
; ------------------------------------------------------------------------------

	xdef PlaySound
PlaySound:
	move.b	d0,fm_queue_1					; Play sound
	rts

; ------------------------------------------------------------------------------
; Play an FM sound in queue 3
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - FM sound ID
; ------------------------------------------------------------------------------

	xdef PlaySound2
PlaySound2:
	move.b	d0,fm_queue_2					; Play sound
	rts

; ------------------------------------------------------------------------------
; Flush the sound queue
; ------------------------------------------------------------------------------

	xdef FlushSoundQueue
FlushSoundQueue:
	jsr	StopZ80						; Stop the Z80

.CheckQueue2:
	tst.b	fm_queue_1					; Is the 1st sound queue set?
	beq.s	.CheckQueue3					; If not, branch
	
	move.b	fm_queue_1,FmSoundQueue1			; Queue sound in driver
	move.b	#0,fm_queue_1					; Clear 1st sound queue
	bra.s	.End						; Exit

.CheckQueue3:
	tst.b	fm_queue_2					; Is the 2nd sound queue set?
	beq.s	.End						; If not, branch
	
	move.b	fm_queue_2,FmSoundQueue1			; Queue sound in driver
	move.b	#0,fm_queue_2					; Clear 2nd sound queue

.End:
	jmp	StartZ80					; Start the Z80

; ------------------------------------------------------------------------------
; Mass fill
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Value to fill with
;	a1.l - Pointer to destination buffer
; ------------------------------------------------------------------------------

	xdef Fill128
Fill128:
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	rts

; ------------------------------------------------------------------------------
; Mass fill (VDP)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Value to fill with
;	a1.l - VDP control port
; ------------------------------------------------------------------------------

	xdef Fill128Vdp
Fill128Vdp:
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	rts

; ------------------------------------------------------------------------------
; Mass copy
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - Pointer to destination buffer
; ------------------------------------------------------------------------------

	xdef Copy128
Copy128:
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	rts

; ------------------------------------------------------------------------------
; Mass copy (VDP)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - VDP control port
; ------------------------------------------------------------------------------

	xdef Copy128Vdp
Copy128Vdp:
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	rts

; ------------------------------------------------------------------------------
; VSync
; ------------------------------------------------------------------------------

	xdef VSync
VSync:
	move.b	#1,vsync_flag					; Set VSync flag
	move	#$2500,sr					; Enable interrupts

.Wait:
	tst.b	vsync_flag					; Has the V-BLANK handler run?
	bne.s	.Wait						; If not, wait
	rts

; ------------------------------------------------------------------------------
; Set all buttons
; ------------------------------------------------------------------------------

	xdef SetAllButtons
SetAllButtons:
	move.w	#$FF00,ctrl_data				; Press down all buttons
	rts

; ------------------------------------------------------------------------------
; Random number generator
; ------------------------------------------------------------------------------
; RETURNS:
;	d0.l - Random number
; ------------------------------------------------------------------------------

	xdef Random
Random:
	move.l	d1,-(sp)					; Save registers
	move.l	rng_seed,d1					; Get RNG seed
	bne.s	.GetRandom					; If it's set, branch
	move.l	#$2A6D365A,d1					; If not, initialize it

.GetRandom:
	move.l	d1,d0						; Perform various operations
	asl.l	#2,d1
	add.l	d0,d1
	asl.l	#3,d1
	add.l	d0,d1
	move.w	d1,d0
	swap	d1
	add.w	d1,d0
	move.w	d0,d1
	swap	d1

	move.l	d1,rng_seed					; Update RNG seed
	move.l	(sp)+,d1					; Restore registers
	rts

; ------------------------------------------------------------------------------
