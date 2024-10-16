; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code
	
	xref VBlankIrq, GiveWordRamAccess, RunMmd, ReadSaveData
	xref SubCpuCommand, Demo, NewGame, LoadGame
	xref TimeAttack, BuramManager, DaGarden, VisualMode
	xref SoundTest, StageSelect, BestStaffTimes

; ------------------------------------------------------------------------------

	mmd 0, WORK_RAM, $1000, Start, 0, 0

; ------------------------------------------------------------------------------
; Program start
; ------------------------------------------------------------------------------

Start:
	move.l	#VBlankIrq,_LEVEL6+2				; Set V-BLANK interrupt address
	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM Access
	
	lea	game_variables,a0				; Clear game variables
	move.w	#GAME_VARIABLES_SIZE/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars

	moveq	#SYS_MD_INIT,d0					; Run Mega Drive initialization
	bsr.w	RunMmd
	
	move.w	#SYS_BURAM_INIT,d0				; Run Backup RAM initialization
	bsr.w	RunMmd
	
	tst.b	d0						; Was it a succes?
	beq.s	.GetSaveData					; If so, branch
	bset	#0,save_disabled				; If not, disable saving to Backup RAM

.GetSaveData:
	bsr.w	ReadSaveData					; Read save data

; ------------------------------------------------------------------------------

.GameLoop:
	move.w	#SYS_SPECIAL_INIT,d0				; Initialize special stage flags
	bsr.w	SubCpuCommand

	moveq	#0,d0
	move.l	d0,score					; Reset score
	move.b	d0,time_attack_mode				; Reset time attack mode flag
	move.b	d0,special_stage				; Reset special stage flag
	move.b	d0,checkpoint					; Reset checkpoint
	move.w	d0,rings					; Reset ring count
	move.l	d0,time						; Reset time
	move.b	d0,good_future					; Reset good future flag
	move.b	d0,projector_destroyed				; Reset projector destroyed flag
	move.b	#TIME_PRESENT,time_zone				; Set time zone to present

	moveq	#SYS_TITLE,d0					; Run title screen
	bsr.w	RunMmd

	ext.w	d1						; Run next scene
	add.w	d1,d1
	move.w	.Scenes(pc,d1.w),d1
	jsr	.Scenes(pc,d1.w)

	bra.s	.GameLoop					; Loop

; ------------------------------------------------------------------------------

.Scenes:
	dc.w	Demo-.Scenes					; Demo mode
	dc.w	NewGame-.Scenes					; New game
	dc.w	LoadGame-.Scenes				; Load game
	dc.w	TimeAttack-.Scenes				; Time attack
	dc.w	BuramManager-.Scenes				; Backup RAM manager
	dc.w	DaGarden-.Scenes				; D.A. Garden
	dc.w	VisualMode-.Scenes				; Visual mode
	dc.w	SoundTest-.Scenes				; Sound test
	dc.w	StageSelect-.Scenes				; Stage select
	dc.w	BestStaffTimes-.Scenes				; Best staff times

; ------------------------------------------------------------------------------
