; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"variables.inc"

	section code
	
	xref VBlankIrq, WaitSubCpuStart, GiveWordRamAccess, WaitSubCpuInit
	xref InitBuram, Unformatted, CartUnformatted, InitBuramParams
	xref SearchBuram, ReadBuram, BuramCorrupted, CallReadSaveData
	xref InitSaveData, WriteBuram, CallWriteSaveData, DeleteBuram
	xref BuramFull, Finish

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
