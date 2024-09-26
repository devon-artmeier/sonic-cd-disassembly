; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Backup RAM initialization
; ------------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/Main CPU Variables.i"
	include	"_Include/Backup RAM.i"
	include	"_Include/Sound.i"
	include	"_Include/MMD.i"

; ------------------------------------------------------------------------------
; Variables
; ------------------------------------------------------------------------------

	rsset WORK_RAM+$FF00A000
VARIABLES		rs.b 0					; Start of variables
nem_code_table		rs.b 0					; Nemesis code table
decomp_buffer		rs.b $2D00				; Decompression buffer
vsync_flag		rs.b 1					; VSync flag
			rs.b 1
vblank_routine		rs.w 1					; V-BLANK routine ID
timer			rs.w 1					; Timer
frame_count		rs.w 1					; Frame count
saved_sr		rs.w 1					; Saved status register
lag_count		rs.l 1					; Lag frame count
rng_seed		rs.l 1					; Random number generator seed
			rs.b $2EEE
VARIABLES_SIZE		equ __rs-VARIABLES			; Size of variables area

fm_queue_1		equ WORK_RAM+$FF00F00B			; Sound queue 1
fm_queue_2		equ WORK_RAM+$FF00F00C			; Sound queue 2

ctrl_data		equ MCD_MAIN_COMM_14			; Controller data
ctrl_hold		equ ctrl_data				; Controller held buttons data
ctrl_tap		equ ctrl_data+1				; Controller tapped buttons data

; ------------------------------------------------------------------------------
; MMD header
; ------------------------------------------------------------------------------

	mmd 0, work_ram_file, $3000, Start, 0, VBlankIrq

; ------------------------------------------------------------------------------
; Program start
; ------------------------------------------------------------------------------

Start:
	move.l	#VBlankIrq,_LEVEL6+2				; Set V-BLANK address

	moveq	#0,d0						; Clear communication registers
	move.l	d0,MCD_MAIN_COMM_0
	move.l	d0,MCD_MAIN_COMM_4
	move.l	d0,MCD_MAIN_COMM_8
	move.l	d0,MCD_MAIN_COMM_12

	bsr.w	WaitSubCpuStart					; Wait for the Sub CPU program to start
	bsr.w	GiveWordRamAccess				; Give Word RAM access
	bsr.w	WaitSubCpuInit					; Wait for the Sub CPU program to finish initializing
	
	lea	VARIABLES,a0					; Clear variables
	move.w	#VARIABLES_SIZE/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars

	move.w	#0,vblank_routine				; Reset V-BLANK routine ID
	
	bsr.w	InitBuram					; Initialize Backup RAM
	cmpi.w	#-1,d0						; Is internal Backup RAM unformatted?
	beq.w	Unformatted					; If so, branch
	cmpi.w	#-2,d0						; Is the Backup RAM cartridge unformatted?
	beq.w	CartUnformatted					; If so, branch

	bsr.w	InitBuramParams					; Set up Backup RAM parameters
	bsr.w	SearchBuram					; Check if there's already save data stored
	bne.s	.NotFound					; If not, branch

	bsr.w	ReadBuram					; Read save data from Backup RAM
	bne.w	BuramCorrupted					; If it failed to read, branch
	
	move.b	#0,save_disabled				; Enable Backup RAM saving
	bsr.w	CallReadSaveData				; Read save data
	bra.w	.Success					; Exit

.NotFound:
	bsr.w	InitSaveData					; Initialize save data
	bsr.w	WriteBuram					; Write it to Backup RAM
	beq.s	.WriteSave					; If it was successful, branch
	
	move.b	#1,save_disabled				; Disable Backup RAM saving
	bsr.w	CallWriteSaveData				; Write temporary save data
	bsr.w	DeleteBuram					; Delete save data from Backup RAM
	bra.w	BuramFull					; Display Backup RAM full message

.WriteSave:
	move.b	#0,save_disabled				; Enable Backup RAM saving
	bsr.w	CallWriteSaveData				; Write save data

.Success:
	bsr.w	Finish						; Finish operations
	moveq	#0,d0						; Mark as successful
	rts

; ------------------------------------------------------------------------------

	if REGION=USA
		include	"Backup RAM/Initialization/V-BLANK Interrupt.asm"
	endif

; ------------------------------------------------------------------------------
; Backup RAM corrupted error
; ------------------------------------------------------------------------------

BuramCorrupted:
	moveq	#0,d0						; Show message
	bsr.w	ShowMessage
	bra.w	ErrorLoop					; Enter infinite loop

; ------------------------------------------------------------------------------
; Unformatted internal Backup RAM error
; ------------------------------------------------------------------------------

Unformatted:
	moveq	#1,d0						; Show message
	bsr.w	ShowMessage
	bra.w	ErrorLoop					; Enter infinite loop

; ------------------------------------------------------------------------------
; Unformatted RAM cartridge error
; ------------------------------------------------------------------------------

CartUnformatted:
	moveq	#2,d0						; Show message
	bsr.w	ShowMessage
	bra.w	ErrorLoop					; Enter infinite loop

; ------------------------------------------------------------------------------
; Backup RAM full warning
; ------------------------------------------------------------------------------

BuramFull:
	moveq	#3,d0						; Show message
	bsr.w	ShowMessage

.WaitUser:
	move.b	ctrl_tap,d0					; Get tapped buttons
	andi.b	#$F0,ctrl_tap					; Were A, B, C, or start pressed?
	beq.s	.WaitUser					; If not, wait

	bsr.w	Finish						; Finish operations
	moveq	#1,d0						; Mark as failed
	rts

; ------------------------------------------------------------------------------
; Fatal error infinite loop
; ------------------------------------------------------------------------------

ErrorLoop:
	bra.w	*

; ------------------------------------------------------------------------------
; Show a message
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Message ID
;	       0 = Backup RAM corrupted
;	       1 = Internal Backup RAM unformatted
;	       2 = RAM cartridge unformatted
;	       3 = Backup RAM full
; ------------------------------------------------------------------------------

ShowMessage:
	move.l	d0,-(sp)					; Save message ID

	bsr.w	InitMD						; Initialize Mega Drive hardware
	bclr	#6,ipx_vdp_reg_81+1				; Disable display
	move.w	ipx_vdp_reg_81,VDP_CTRL

	vdpCmd move.l,$BC00,VRAM,WRITE,VDP_CTRL			; Disable sprites
	lea	VDP_DATA,a6
	moveq	#0,d0
	move.l	d0,(a6)
	move.l	d0,(a6)

	if REGION=USA						; Load art
		move.l	#$00010203,d0
	else
		move.l	#$00000102,d0
	endif
	jsr	LoadMessageArt

	move.l	(sp)+,d0					; Restore message ID
	add.w	d0,d0

	move.l	d0,-(sp)					; Draw first tilemap
	jsr	DrawMessageTilemap
	move.l	(sp)+,d0

	addq.w	#1,d0						; Draw second tilemap
	jsr	DrawMessageTilemap
	
	bset	#6,ipx_vdp_reg_81+1				; Enable display
	move.w	ipx_vdp_reg_81,VDP_CTRL
	rts

; ------------------------------------------------------------------------------
; Finish operations
; ------------------------------------------------------------------------------

Finish:
	nop							; Tell Sub CPU we are done
	bset	#7,MCD_MAIN_FLAG

.WaitSubCpu:
	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM access
	btst	#7,MCD_SUB_FLAG					; Is the Sub CPU done?
	beq.s	.WaitSubCpu

	moveq	#0,d0						; Clear communication registers
	move.l	d0,MCD_MAIN_COMM_0
	move.l	d0,MCD_MAIN_COMM_4
	move.l	d0,MCD_MAIN_COMM_8
	move.l	d0,MCD_MAIN_COMM_12
	move.b	d0,MCD_MAIN_FLAG
	rts

; ------------------------------------------------------------------------------

	if REGION<>USA
		include	"Backup RAM/Initialization/V-BLANK Interrupt.asm"
	endif

; ------------------------------------------------------------------------------
; Unused function to send a Backup RAM command to the Sub CPU
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; ------------------------------------------------------------------------------

SubBuramCmd:
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

GiveWordRamAccess:
	bset	#MCDR_DMNA_BIT,MCD_MEM_MODE			; Give Sub CPU Word RAM access
	btst	#MCDR_DMNA_BIT,MCD_MEM_MODE			; Has it been given?
	beq.s	GiveWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
; Wait for Word RAM access
; ------------------------------------------------------------------------------

WaitWordRamAccess:
	btst	#MCDR_RET_BIT,MCD_MEM_MODE			; Do we have Word RAM access?
	beq.s	WaitWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
; Wait for the Sub CPU program to start
; ------------------------------------------------------------------------------

WaitSubCpuStart:
	btst	#7,MCD_SUB_FLAG					; Has the Sub CPU program started?
	beq.s	WaitSubCpuStart					; If not, wait
	rts 

; ------------------------------------------------------------------------------
; Wait for the Sub CPU program to finish initializing
; ------------------------------------------------------------------------------

WaitSubCpuInit:
	btst	#7,MCD_SUB_FLAG					; Has the Sub CPU program initialized?
	bne.s	WaitSubCpuInit					; If not, wait
	rts

; ------------------------------------------------------------------------------
; Initialize Mega Drive hardware
; ------------------------------------------------------------------------------

InitMD:
	lea	.VDPRegs(pc),a0					; Set up VDP registers
	move.w	#$8000,d0
	moveq	#.VDPRegsEnd-.VDPRegs-1,d7

.SetVDPRegs:
	move.b	(a0)+,d0
	move.w	d0,VDP_CTRL
	addi.w	#$100,d0
	dbf	d7,.SetVDPRegs

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

.LoadPal:
	move.l	(a0)+,VDP_DATA
	dbf	d7,.LoadPal

	vdpCmd move.l,0,VSRAM,WRITE,VDP_CTRL			; Clear VSRAM
	moveq	#$50/4-1,d0

.ClearVSRAM:
	move.w	#0,VDP_DATA
	move.w	#0,VDP_DATA
	dbf	d0,.ClearVSRAM

	bsr.w	StartZ80					; Start the Z80
	move.w	#$8134,ipx_vdp_reg_81				; Reset IPX VDP register 1 cache
	rts

; ------------------------------------------------------------------------------

.Palette:
	incbin	"Backup RAM/Initialization/Data/Palette.bin"
.PaletteEnd:
	even

.VDPRegs:
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
.VDPRegsEnd:
	even

; ------------------------------------------------------------------------------
; Stop the Z80
; ------------------------------------------------------------------------------

StopZ80:
	move	sr,saved_sr					; Save status register
	getZ80Bus						; Get Z80 bus access
	rts

; ------------------------------------------------------------------------------
; Start the Z80
; ------------------------------------------------------------------------------

StartZ80:
	releaseZ80Bus						; Release Z80 bus
	move	saved_sr,sr					; Restore status register
	rts

; ------------------------------------------------------------------------------
; Read controller data
; ------------------------------------------------------------------------------

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

PlaySound:
	move.b	d0,fm_queue_1					; Play sound
	rts

; ------------------------------------------------------------------------------
; Play an FM sound in queue 3
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - FM sound ID
; ------------------------------------------------------------------------------

PlaySound2:
	move.b	d0,fm_queue_2					; Play sound
	rts

; ------------------------------------------------------------------------------
; Flush the sound queue
; ------------------------------------------------------------------------------

FlushSoundQueue:
	jsr	StopZ80						; Stop the Z80

.CheckQueue2:
	tst.b	fm_queue_1					; Is the 1st sound queue set?
	beq.s	.CheckQueue3					; If not, branch
	
	move.b	fm_queue_1,FMDrvQueue1				; Queue sound in driver
	move.b	#0,fm_queue_1					; Clear 1st sound queue
	bra.s	.End						; Exit

.CheckQueue3:
	tst.b	fm_queue_2					; Is the 2nd sound queue set?
	beq.s	.End						; If not, branch
	
	move.b	fm_queue_2,FMDrvQueue1				; Queue sound in driver
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

Fill128:
	move.l	d1,(a1)+
Fill124:
	move.l	d1,(a1)+
Fill120:
	move.l	d1,(a1)+
Fill116:
	move.l	d1,(a1)+
Fill112:
	move.l	d1,(a1)+
Fill108:
	move.l	d1,(a1)+
Fill104:
	move.l	d1,(a1)+
Fill100:
	move.l	d1,(a1)+
Fill96:
	move.l	d1,(a1)+
Fill92:
	move.l	d1,(a1)+
Fill88:
	move.l	d1,(a1)+
Fill84:
	move.l	d1,(a1)+
Fill80:
	move.l	d1,(a1)+
Fill76:
	move.l	d1,(a1)+
Fill72:
	move.l	d1,(a1)+
Fill68:
	move.l	d1,(a1)+
Fill64:
	move.l	d1,(a1)+
Fill60:
	move.l	d1,(a1)+
Fill56:
	move.l	d1,(a1)+
Fill52:
	move.l	d1,(a1)+
Fill48:
	move.l	d1,(a1)+
Fill44:
	move.l	d1,(a1)+
Fill40:
	move.l	d1,(a1)+
Fill36:
	move.l	d1,(a1)+
Fill32:
	move.l	d1,(a1)+
Fill28:
	move.l	d1,(a1)+
Fill24:
	move.l	d1,(a1)+
Fill20:
	move.l	d1,(a1)+
Fill16:
	move.l	d1,(a1)+
Fill12:
	move.l	d1,(a1)+
Fill8:
	move.l	d1,(a1)+
Fill4:
	move.l	d1,(a1)+
	rts

; ------------------------------------------------------------------------------
; Mass fill (VDP)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Value to fill with
;	a1.l - VDP control port
; ------------------------------------------------------------------------------

Fill128Vdp:
	move.l	d1,(a1)
Fill124Vdp:
	move.l	d1,(a1)
Fill120Vdp:
	move.l	d1,(a1)
Fill116Vdp:
	move.l	d1,(a1)
Fill112Vdp:
	move.l	d1,(a1)
Fill108Vdp:
	move.l	d1,(a1)
Fill104Vdp:
	move.l	d1,(a1)
Fill100Vdp:
	move.l	d1,(a1)
Fill96Vdp:
	move.l	d1,(a1)
Fill92Vdp:
	move.l	d1,(a1)
Fill88Vdp:
	move.l	d1,(a1)
Fill84Vdp:
	move.l	d1,(a1)
Fill80Vdp:
	move.l	d1,(a1)
Fill76Vdp:
	move.l	d1,(a1)
Fill72Vdp:
	move.l	d1,(a1)
Fill68Vdp:
	move.l	d1,(a1)
Fill64Vdp:
	move.l	d1,(a1)
Fill60Vdp:
	move.l	d1,(a1)
Fill56Vdp:
	move.l	d1,(a1)
Fill52Vdp:
	move.l	d1,(a1)
Fill48Vdp:
	move.l	d1,(a1)
Fill44Vdp:
	move.l	d1,(a1)
Fill40Vdp:
	move.l	d1,(a1)
Fill36Vdp:
	move.l	d1,(a1)
Fill32Vdp:
	move.l	d1,(a1)
Fill28Vdp:
	move.l	d1,(a1)
Fill24Vdp:
	move.l	d1,(a1)
Fill20Vdp:
	move.l	d1,(a1)
Fill16Vdp:
	move.l	d1,(a1)
Fill12Vdp:
	move.l	d1,(a1)
Fill8Vdp:
	move.l	d1,(a1)
Fill4Vdp:
	move.l	d1,(a1)
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
; Mass copy (VDP)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - VDP control port
; ------------------------------------------------------------------------------

Copy128Vdp:
	move.l	(a1)+,(a2)
Copy124Vdp:
	move.l	(a1)+,(a2)
Copy120Vdp:
	move.l	(a1)+,(a2)
Copy116Vdp:
	move.l	(a1)+,(a2)
Copy112Vdp:
	move.l	(a1)+,(a2)
Copy108Vdp:
	move.l	(a1)+,(a2)
Copy104Vdp:
	move.l	(a1)+,(a2)
Copy100Vdp:
	move.l	(a1)+,(a2)
Copy96Vdp:
	move.l	(a1)+,(a2)
Copy92Vdp:
	move.l	(a1)+,(a2)
Copy88Vdp:
	move.l	(a1)+,(a2)
Copy84Vdp:
	move.l	(a1)+,(a2)
Copy80Vdp:
	move.l	(a1)+,(a2)
Copy76Vdp:
	move.l	(a1)+,(a2)
Copy72Vdp:
	move.l	(a1)+,(a2)
Copy68Vdp:
	move.l	(a1)+,(a2)
Copy64Vdp:
	move.l	(a1)+,(a2)
Copy60Vdp:
	move.l	(a1)+,(a2)
Copy56Vdp:
	move.l	(a1)+,(a2)
Copy52Vdp:
	move.l	(a1)+,(a2)
Copy48Vdp:
	move.l	(a1)+,(a2)
Copy44Vdp:
	move.l	(a1)+,(a2)
Copy40Vdp:
	move.l	(a1)+,(a2)
Copy36Vdp:
	move.l	(a1)+,(a2)
Copy32Vdp:
	move.l	(a1)+,(a2)
Copy28Vdp:
	move.l	(a1)+,(a2)
Copy24Vdp:
	move.l	(a1)+,(a2)
Copy20Vdp:
	move.l	(a1)+,(a2)
Copy16Vdp:
	move.l	(a1)+,(a2)
Copy12Vdp:
	move.l	(a1)+,(a2)
Copy8Vdp:
	move.l	(a1)+,(a2)
Copy4Vdp:
	move.l	(a1)+,(a2)
	rts

; ------------------------------------------------------------------------------
; VSync
; ------------------------------------------------------------------------------

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

SetAllButtons:
	move.w	#$FF00,ctrl_data				; Press down all buttons
	rts

; ------------------------------------------------------------------------------
; Random number generator
; ------------------------------------------------------------------------------
; RETURNS:
;	d0.l - Random number
; ------------------------------------------------------------------------------

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

	include	"Backup RAM/Main CPU Functions.asm"

; ------------------------------------------------------------------------------
; Load message art
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Message art ID queue
; ------------------------------------------------------------------------------

LoadMessageArt:
	lea	VDP_CTRL,a5					; VDP control port
	moveq	#4-1,d2						; Number of IDs to check

.QueueLoop:
	moveq	#0,d1						; Get ID from queue
	move.b	d0,d1
	beq.s	.Next						; If it's blank, branch

	lsl.w	#3,d1						; Get art metadata
	lea	.MessageArt(pc),a0

	move.l	-8(a0,d1.w),(a5)				; VDP command
	movea.l	-4(a0,d1.w),a0					; Art data
	jsr	DecompressNemesisVdp(pc)			; Decompress and load art

.Next:
	ror.l	#8,d0						; Shift queue
	dbf	d2,.QueueLoop					; Loop until queue is scanned
	rts

; ------------------------------------------------------------------------------

.MessageArt:
	vdpCmd dc.l,$20,VRAM,WRITE				; Eggman art
	dc.l	EggmanArt
	vdpCmd dc.l,$340,VRAM,WRITE				; Message art
	dc.l	MessageArt
	if REGION=USA
		vdpCmd dc.l,$1C40,VRAM,WRITE			; Message art (extension)
		dc.l	MessageUsaArt
	endif

; ------------------------------------------------------------------------------
; Advance data bitstream
; ------------------------------------------------------------------------------
; PARAMETERS:
;	branch - Branch to take if no new byte is needed (optional)
; ------------------------------------------------------------------------------

advanceBitstream macro branch
	cmpi.w	#9,d6						; Does a new byte need to be read?
	if narg>0						; If not, branch
		bcc.s	\branch
	else
		bcc.s	.NoNewByte\@
	endif
	
	addq.w	#8,d6						; Read next byte from bitstream
	asl.w	#8,d5
	move.b	(a0)+,d5

.NoNewByte\@:
	endm

; ------------------------------------------------------------------------------
; Decompress Nemesis art into VRAM (Note: VDP write command must be
; set beforehand)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Nemesis art pointer
; ------------------------------------------------------------------------------

DecompressNemesisVdp:
	movem.l	d0-a1/a3-a5,-(sp)				; Save registers
	lea	WriteNemesisRowVdp,a3				; Write all data to the same location
	lea	VDP_DATA,a4					; VDP data port
	bra.s	DecompressNemesisMain

; ------------------------------------------------------------------------------
; Decompress Nemesis data into RAM
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Nemesis data pointer
;	a4.l - Destination buffer pointer
; ------------------------------------------------------------------------------

DecompressNemesis:
	movem.l	d0-a1/a3-a5,-(sp)				; Save registers
	lea	WriteNemesisRow,a3				; Advance to the next location after each write

; ------------------------------------------------------------------------------

DecompressNemesisMain:
	lea	nem_code_table,a1				; Prepare decompression buffer
	
	move.w	(a0)+,d2					; Get number of tiles
	lsl.w	#1,d2						; Should we use XOR mode?
	bcc.s	.GetRows					; If not, branch
	adda.w	#WriteNemesisRowVdpXor-WriteNemesisRowVdp,a3	; Use XOR mode

.GetRows:
	lsl.w	#2,d2						; Get number of rows
	movea.w	d2,a5
	moveq	#8,d3						; 8 pixels per row
	moveq	#0,d2						; XOR row buffer
	moveq	#0,d4						; Row buffer
	
	jsr	BuildNemesisCodeTable(pc)			; Build code table
	
	move.b	(a0)+,d5					; Get first word of compressed data
	asl.w	#8,d5
	move.b	(a0)+,d5
	move.w	#16,d6						; Set bitstream read data position
	
	bsr.s	GetNemesisCode					; Decompress data
	
	nop
	nop
	nop
	nop
	
	movem.l	(sp)+,d0-a1/a3-a5				; Restore registers
	rts

; ------------------------------------------------------------------------------

GetNemesisCode:
	move.w	d6,d7						; Peek 8 bits from bitstream
	subq.w	#8,d7
	move.w	d5,d1
	lsr.w	d7,d1
	cmpi.b	#%11111100,d1					; Should we read inline data?
	bcc.s	ReadInlineNemesisData				; If so, branch
	
	andi.w	#$FF,d1						; Get code length
	add.w	d1,d1
	move.b	(a1,d1.w),d0
	ext.w	d0
	
	sub.w	d0,d6						; Advance bitstream read data position
	advanceBitstream

	move.b	1(a1,d1.w),d1					; Get palette index
	move.w	d1,d0
	andi.w	#$F,d1
	andi.w	#$F0,d0						; Get repeat count

GetNemesisCodeLength:
	lsr.w	#4,d0						; Isolate repeat count

WriteNemesisPixel:
	lsl.l	#4,d4						; Shift up by a nibble
	or.b	d1,d4						; Write pixel
	subq.w	#1,d3						; Has an entire 8-pixel row been written?
	bne.s	NextNemesisPixel				; If not, loop
	jmp	(a3)						; Otherwise, write the row to its destination

; ------------------------------------------------------------------------------

ResetNemesisRow:
	moveq	#0,d4						; Reset row
	moveq	#8,d3						; Reset nibble counter

NextNemesisPixel:
	dbf	d0,WriteNemesisPixel				; Loop until finished
	bra.s	GetNemesisCode					; Read next code

; ------------------------------------------------------------------------------

ReadInlineNemesisData:
	subq.w	#6,d6						; Advance bitstream read data position
	advanceBitstream

	subq.w	#7,d6						; Read inline data
	move.w	d5,d1
	lsr.w	d6,d1
	move.w	d1,d0
	andi.w	#$F,d1						; Get palette index
	andi.w	#$70,d0						; Get repeat count
	
	advanceBitstream GetNemesisCodeLength			; Advance bitstream read data position
	bra.s	GetNemesisCodeLength

; ------------------------------------------------------------------------------

WriteNemesisRowVdp:
	move.l	d4,(a4)						; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

WriteNemesisRowVdpXor:
	eor.l	d4,d2						; XOR the previous row with the current row
	move.l	d2,(a4)						; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

WriteNemesisRow:
	move.l	d4,(a4)+					; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

WriteNemesisRowXor:
	eor.l	d4,d2						; XOR the previous row with the current row
	move.l	d2,(a4)+					; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

BuildNemesisCodeTable:
	move.b	(a0)+,d0					; Read first byte

.CheckEnd:
	cmpi.b	#$FF,d0						; Has the end of the code table been reached?
	bne.s	.NewPaletteIndex				; If not, branch
	rts

.NewPaletteIndex:
	move.w	d0,d7						; Set palette index

.Loop:
	move.b	(a0)+,d0					; Read next byte
	cmpi.b	#$80,d0						; Should we set a new palette index?
	bcc.s	.CheckEnd					; If so, branch

	move.b	d0,d1						; Copy repeat count
	andi.w	#$F,d7						; Get palette index
	andi.w	#$70,d1						; Get repeat count
	or.w	d1,d7						; Combine them
	
	andi.w	#$F,d0						; Get code length
	move.b	d0,d1
	lsl.w	#8,d1
	or.w	d1,d7						; Combine with palette index and repeat count
	
	moveq	#8,d1						; Is the code length 8 bits in size?
	sub.w	d0,d1
	bne.s	.ShortCode					; If not, branch
	
	move.b	(a0)+,d0					; Store code entry
	add.w	d0,d0
	move.w	d7,(a1,d0.w)
	bra.s	.Loop

.ShortCode:
	move.b	(a0)+,d0					; Get index
	lsl.w	d1,d0
	add.w	d0,d0
	
	moveq	#1,d5						; Get number of entries
	lsl.w	d1,d5
	subq.w	#1,d5

.ShortCode_Loop:
	move.w	d7,(a1,d0.w)					; Store code entry
	addq.w	#2,d0						; Increment index
	dbf	d5,.ShortCode_Loop				; Loop until finished
	bra.s	.Loop

; ------------------------------------------------------------------------------
; Draw message tilemap
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Tilemap ID
; ------------------------------------------------------------------------------

DrawMessageTilemap:
	andi.l	#$FFFF,d0					; Get mappings metadata
	mulu.w	#14,d0
	lea	.Tilemaps,a1
	adda.w	d0,a1

	movea.l	(a1)+,a0					; Mappings data
	move.w	(a1)+,d0					; Base tile attributes

	move.l	a1,-(sp)					; Decompress mappings
	lea	decomp_buffer,a1
	bsr.w	DecompressEnigma
	movea.l	(sp)+,a1

	move.w	(a1)+,d3					; Width
	move.w	(a1)+,d2					; Height
	move.l	(a1),d0						; VDP command
	
	lea	decomp_buffer,a0				; Load mappings into VRAM
	movea.l	#VDP_DATA,a1					; VDP data port

.Row:
	move.l	d0,VDP_CTRL					; Set VDP command
	move.w	d3,d1						; Get width

.Tile:
	move.w	(a0)+,(a1)					; Copy tile
	dbf	d1,.Tile					; Loop until row is copied
	addi.l	#$800000,d0					; Next row
	dbf	d2,.Row						; Loop until map is copied
	rts

; ------------------------------------------------------------------------------

.Tilemaps:
	; Backup RAM data corrupted
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	$A-1, 6-1
	vdpCmd dc.l,$C31E,VRAM,WRITE

	dc.l	DataCorruptTilemap
	dc.w	$201A
	if REGION=JAPAN
		dc.w	$24-1, 6-1
		vdpCmd dc.l,$E584,VRAM,WRITE
	else
		dc.w	$1D-1, 6-1
		vdpCmd dc.l,$E58A,VRAM,WRITE
	endif
	
	; Internal Backup RAM unformatted
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	$A-1, 6-1
	vdpCmd dc.l,$C31E,VRAM,WRITE

	if REGION=JAPAN
		dc.l	UnformattedTilemap
		dc.w	$201A
		dc.w	$24-1, 6-1
		vdpCmd dc.l,$E584,VRAM,WRITE
	elseif REGION=USA
		dc.l	UnformattedUsaTilemap
		dc.w	$20E2
		dc.w	$1D-1, 8-1
		vdpCmd dc.l,$E58A,VRAM,WRITE
	else
		dc.l	UnformattedTilemap
		dc.w	$201A
		dc.w	$1D-1, 6-1
		vdpCmd dc.l,$E58A,VRAM,WRITE
	endif
	
	; Cartridge Backup RAM unformatted
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	9, 5
	if REGION=JAPAN
		vdpCmd dc.l,$C21E,VRAM,WRITE
	else
		vdpCmd dc.l,$C29E,VRAM,WRITE
	endif

	dc.l	CartUnformattedTilemap
	dc.w	$201A
	if REGION=JAPAN
		dc.w	$24-1, $A-1
		vdpCmd dc.l,$E484,VRAM,WRITE
	else
		dc.w	$1D-1, 8-1
		vdpCmd dc.l,$E50A,VRAM,WRITE
	endif
	
	; Backup RAM full
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	9, 5
	if REGION=JAPAN
		vdpCmd dc.l,$C29E,VRAM,WRITE
	else
		vdpCmd dc.l,$C31E,VRAM,WRITE
	endif

	dc.l	BuramFullTilemap
	dc.w	$201A
	if REGION=JAPAN
		dc.w	$24-1, 8-1
		vdpCmd dc.l,$E504,VRAM,WRITE
	else
		dc.w	$1D-1, 6-1
		vdpCmd dc.l,$E58A,VRAM,WRITE
	endif

; ------------------------------------------------------------------------------
; Decompress Enigma tilemap data into RAM
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to Enigma data
;	a1.l - Pointer to destination buffer
;	d0.w - Base tile attributes
; ------------------------------------------------------------------------------

DecompressEnigma:
	movem.l	d0-d7/a1-a5,-(sp)				; Save registers
	
	movea.w	d0,a3						; Get base tile
	
	move.b	(a0)+,d0					; Get size of inline copy value
	ext.w	d0
	movea.w	d0,a5

	move.b	(a0)+,d4					; Get tile flags
	lsl.b	#3,d4

	movea.w	(a0)+,a2					; Get incremental copy word
	adda.w	a3,a2
	
	movea.w	(a0)+,a4					; Get static copy word
	adda.w	a3,a4

	move.b	(a0)+,d5					; Get read first word
	asl.w	#8,d5
	move.b	(a0)+,d5
	moveq	#16,d6						; Initial shift value

GetEnigmaCode:
	moveq	#7,d0						; Assume a code entry is 7 bits
	move.w	d6,d7
	sub.w	d0,d7
	
	move.w	d5,d1						; Get code entry
	lsr.w	d7,d1
	andi.w	#$7F,d1
	move.w	d1,d2

	cmpi.w	#$40,d1						; Is this code entry actually 6 bits long?
	bcc.s	.GotCode					; If not, branch
	
	moveq	#6,d0						; Code entry is actually 6 bits
	lsr.w	#1,d2

.GotCode:
	bsr.w	AdvanceEnigmaBitstream				; Advance bitstream
	
	andi.w	#$F,d2						; Handle code
	lsr.w	#4,d1
	add.w	d1,d1
	jmp	HandleEnigmaCode(pc,d1.w)

; ------------------------------------------------------------------------------

EnigmaCopyInc:
	move.w	a2,(a1)+					; Copy incremental copy word
	addq.w	#1,a2						; Increment it
	dbf	d2,EnigmaCopyInc				; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyStatic:
	move.w	a4,(a1)+					; Copy static copy word
	dbf	d2,EnigmaCopyStatic				; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInline:
	bsr.w	ReadInlineEnigmaData				; Read inline data	

.Loop:
	move.w	d1,(a1)+					; Copy inline value
	dbf	d2,.Loop					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInlineInc:
	bsr.w	ReadInlineEnigmaData				; Read inline data

.Loop:
	move.w	d1,(a1)+					; Copy inline value
	addq.w	#1,d1						; Increment it
	dbf	d2,.Loop					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInlineDec:
	bsr.w	ReadInlineEnigmaData				; Read inline data

.Loop:
	move.w	d1,(a1)+					; Copy inline value
	subq.w	#1,d1						; Decrement it
	dbf	d2,.Loop					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInlineMult:
	cmpi.w	#$F,d2						; Are we done?
	beq.s	EnigmaDone					; If so, branch

.Loop4:
	bsr.w	ReadInlineEnigmaData				; Read inline data
	move.w	d1,(a1)+					; Copy it
	dbf	d2,.Loop4					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

HandleEnigmaCode:
	bra.s	EnigmaCopyInc
	bra.s	EnigmaCopyInc
	bra.s	EnigmaCopyStatic
	bra.s	EnigmaCopyStatic
	bra.s	EnigmaCopyInline
	bra.s	EnigmaCopyInlineInc
	bra.s	EnigmaCopyInlineDec
	bra.s	EnigmaCopyInlineMult

; ------------------------------------------------------------------------------

EnigmaDone:
	subq.w	#1,a0						; Go back by one byte
	cmpi.w	#16,d6						; Were we going to start a completely new byte?
	bne.s	.NotNewByte					; If not, branch
	subq.w	#1,a0						; Go back another

.NotNewByte:
	move.w	a0,d0						; Are we on an odd byte?
	lsr.w	#1,d0
	bcc.s	.Even						; If not, branch
	addq.w	#1,a0						; Ensure we're on an even byte

.Even:
	movem.l	(sp)+,d0-d7/a1-a5				; Restore registers
	rts

; ------------------------------------------------------------------------------

ReadInlineEnigmaData:
	move.w	a3,d3						; Copy base tile
	move.b	d4,d1						; Copy tile flags
	
	add.b	d1,d1						; Is the priority bit set?
	bcc.s	.NoPriority					; If not, branch
	
	subq.w	#1,d6						; Is the priority bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoPriority					; If not, branch
	
	ori.w	#$8000,d3					; Set priority bit in the base tile

.NoPriority:
	add.b	d1,d1						; Is the high palette line bit set?
	bcc.s	.NoPal1						; If not, branch
	
	subq.w	#1,d6						; Is the high palette bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoPal1						; If not, branch
	
	addi.w	#$4000,d3					; Set high palette bit

.NoPal1:
	add.b	d1,d1						; Is the low palette line bit set?
	bcc.s	.NoPal0						; If not, branch
	
	subq.w	#1,d6						; Is the low palette bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoPal0						; If not, branch
	
	addi.w	#$2000,d3					; Set low palette bit

.NoPal0:
	add.b	d1,d1						; Is the Y flip bit set?
	bcc.s	.NoYFlip					; If not, branch
	
	subq.w	#1,d6						; Is the Y flip bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoYFlip					; If not, branch
	
	ori.w	#$1000,d3					; Set Y flip bit

.NoYFlip:
	add.b	d1,d1						; Is the X flip bit set?
	bcc.s	.NoXFlip					; If not, branch
	
	subq.w	#1,d6						; Is the X flip bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoXFlip					; If not, branch
	
	ori.w	#$800,d3					; Set X flip bit

.NoXFlip:
	move.w	d5,d1						; Prepare to advance bitstream to tile ID
	move.w	d6,d7
	sub.w	a5,d7
	bcc.s	.GotEnoughBits					; If we don't need a new word, branch
	
	move.w	d7,d6						; Make space for the rest of the tile ID
	addi.w	#16,d6
	neg.w	d7
	lsl.w	d7,d1
	
	move.b	(a0),d5						; Add in the rest of the tile ID
	rol.b	d7,d5
	add.w	d7,d7
	and.w	EnigmaInlineMasks-2(pc,d7.w),d5
	add.w	d5,d1

.CombineBits:
	move.w	a5,d0						; Mask out garbage
	add.w	d0,d0
	and.w	EnigmaInlineMasks-2(pc,d0.w),d1

	add.w	d3,d1						; Add base tile
	
	move.b	(a0)+,d5					; Read another word from the bitstream
	lsl.w	#8,d5
	move.b	(a0)+,d5
	rts

.GotEnoughBits:
	beq.s	.JustEnough					; If the word has been exactly exhausted, branch
	
	lsr.w	d7,d1						; Shift tile data down
	
	move.w	a5,d0						; Mask out garbage
	add.w	d0,d0
	and.w	EnigmaInlineMasks-2(pc,d0.w),d1	
	
	add.w	d3,d1						; Add base tile

	move.w	a5,d0						; Advance bitstream
	bra.s	AdvanceEnigmaBitstream

.JustEnough:
	moveq	#16,d6						; Reset shift value
	bra.s	.CombineBits

; ------------------------------------------------------------------------------

EnigmaInlineMasks:
	dc.w	%0000000000000001
	dc.w	%0000000000000011
	dc.w	%0000000000000111
	dc.w	%0000000000001111
	dc.w	%0000000000011111
	dc.w	%0000000000111111
	dc.w	%0000000001111111
	dc.w	%0000000011111111
	dc.w	%0000000111111111
	dc.w	%0000001111111111
	dc.w	%0000011111111111
	dc.w	%0000111111111111
	dc.w	%0001111111111111
	dc.w	%0011111111111111
	dc.w	%0111111111111111
	dc.w	%1111111111111111

; ------------------------------------------------------------------------------

AdvanceEnigmaBitstream:
	sub.w	d0,d6						; Advance bitstream
	advanceBitstream
	rts

; ------------------------------------------------------------------------------
; Data
; ------------------------------------------------------------------------------

EggmanArt:
	incbin	"Backup RAM/Initialization/Data/Eggman Art.nem"
	even

EggmanTilemap:
	incbin	"Backup RAM/Initialization/Data/Eggman Mappings.eni"
	even

; ------------------------------------------------------------------------------

	if REGION=JAPAN
	
MessageArt:
		incbin	"Backup RAM/Initialization/Data/Message Art (Japanese).nem"
		even

DataCorruptTilemap:
		incbin	"Backup RAM/Initialization/Data/Message (Data Corrupt, Japanese).eni"
		even
	
Unformatted:
		incbin	"Backup RAM/Initialization/Data/Message (Internal Unformatted, Japanese).eni"
		even

CartUnformattedTilemap:
		incbin	"Backup RAM/Initialization/Data/Message (Cart Unformatted, Japanese).eni"
		even

BuramFullTilemap:
		incbin	"Backup RAM/Initialization/Data/Message (RAM Full, Japanese).eni"
		even
		
; ------------------------------------------------------------------------------

	elseif REGION=USA
	
MessageArt:
		incbin	"Backup RAM/Initialization/Data/Message Art (English).nem"
		even

DataCorruptTilemap:
		incbin	"Backup RAM/Initialization/Data/Message (Data Corrupt, English).eni"
		even

UnformattedTilemap:
		incbin	"Backup RAM/Initialization/Data/Message (Internal Unformatted, English).eni"
		even

CartUnformattedTilemap:
		incbin	"Backup RAM/Initialization/Data/Message (Cart Unformatted, English).eni"
		even

BuramFullTilemap:
		incbin	"Backup RAM/Initialization/Data/Message (RAM Full, English).eni"
		even
	
MessageUsaArt:
		incbin	"Backup RAM/Initialization/Data/Message Art (USA).nem"
		even

UnformattedUsaTilemap:
		incbin	"Backup RAM/Initialization/Data/Message (Internal Unformatted, USA).eni"
		even

; ------------------------------------------------------------------------------

	else
	
MessageArt:
		incbin	"Backup RAM/Initialization/Data/Message Art (English).nem"
		even

DataCorruptTilemap:
		incbin	"Backup RAM/Initialization/Data/Message (Data Corrupt, English).eni"
		even
	
UnformattedTilemap:
		incbin	"Backup RAM/Initialization/Data/Message (Internal Unformatted, English).eni"
		even

CartUnformattedTilemap:
		incbin	"Backup RAM/Initialization/Data/Message (Cart Unformatted, English).eni"
		even

BuramFullTilemap:
		incbin	"Backup RAM/Initialization/Data/Message (RAM Full, English).eni"
		even
	
	endif

; ------------------------------------------------------------------------------

End:

; ------------------------------------------------------------------------------
