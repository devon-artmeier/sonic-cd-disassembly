; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Main program
; ------------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Main CPU.i"
	include	"_Include/Main CPU Variables.i"
	include	"_Include/System.i"
	include	"_Include/System Commands.i"
	include	"_Include/Backup RAM.i"
	include	"_Include/Sound.i"
	include	"_Include/MMD.i"
	include	"Special Stage/_Global Variables.i"

; ------------------------------------------------------------------------------

	mmd 0, WORK_RAM, $1000, Start, 0, 0

; ------------------------------------------------------------------------------
; Program start
; ------------------------------------------------------------------------------

Start:
	move.l	#VBlankIrq,_LEVEL6+2				; Set V-BLANK interrupt address
	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM Access
	
	lea	global_variables,a0				; Clear variables
	move.w	#GLOBAL_VARIABLES_SIZE/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars

	moveq	#SCMD_MD_INIT,d0				; Run Mega Drive initialization
	bsr.w	RunMmd
	
	move.w	#SCMD_BURAM_INIT,d0				; Run Backup RAM initialization
	bsr.w	RunMmd
	
	tst.b	d0						; Was it a succes?
	beq.s	.GetSaveData					; If so, branch
	bset	#0,save_disabled				; If not, disable saving to Backup RAM

.GetSaveData:
	bsr.w	ReadSaveData					; Read save data

; ------------------------------------------------------------------------------

.GameLoop:
	move.w	#SCMD_SPECIAL_INIT,d0				; Initialize special stage flags
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

	moveq	#SCMD_TITLE,d0					; Run title screen
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
; Best staff times
; ------------------------------------------------------------------------------

BestStaffTimes:
	move.w	#SCMD_STAFF_TIMES,d0				; Run staff best times screen
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; Backup RAM manager
; ------------------------------------------------------------------------------

BuramManager:
	move.w	#SCMD_BURAM_MANAGER,d0				; Run Backup RAM manager
	bsr.w	RunMmd
	bsr.w	ReadSaveData					; Read save data
	rts

; ------------------------------------------------------------------------------
; Run Special Stage 1 demo
; ------------------------------------------------------------------------------

SpecStage1Demo:
	move.b	#1-1,special_stage_id_cmd			; Stage 1
	move.b	#0,time_stones_cmd				; Reset time stones retrieved for this stage
	bset	#0,special_stage_flags				; Temporary mode
	
	moveq	#SCMD_SPECIAL_STAGE,d0				; Run special stage
	bsr.w	RunMmd
	rts

; ------------------------------------------------------------------------------
; Run Special Stage 6 demo
; ------------------------------------------------------------------------------

SpecStage6Demo:
	move.b	#6-1,special_stage_id_cmd			; Stage 6
	move.b	#0,time_stones_cmd				; Reset time stones retrieved for this stage
	bset	#0,special_stage_flags				; Temporary mode
	
	moveq	#SCMD_SPECIAL_STAGE,d0				; Run special stage
	bsr.w	RunMmd
	rts

; ------------------------------------------------------------------------------
; Load game
; ------------------------------------------------------------------------------

LoadGame:
	bsr.w	ReadSaveData					; Read save data
	
	move.w	saved_stage,zone_act				; Get level from save data
	move.b	#3,lives					; Reset life count to 3
	move.b	#0,nemesis_queue_flags				; Reset Nemesis queue flags

	cmpi.b	#0,zone						; Are we in Palmtree Panic?
	beq.w	RunRound1					; If so, branch
	cmpi.b	#1,zone						; Are we in Collision Chaos?
	bls.w	RunRound3					; If so, branch
	cmpi.b	#2,zone						; Are we in Tidal Tempest?
	bls.w	RunRound4					; If so, branch
	cmpi.b	#3,zone						; Are we in Quartz Quadrant?
	bls.w	RunRound5					; If so, branch
	cmpi.b	#4,zone						; Are we in Wacky Workbench?
	bls.w	RunRound6					; If so, branch
	cmpi.b	#5,zone						; Are we in Stardust Speedway?
	bls.w	RunRound7					; If so, branch
	cmpi.b	#6,zone						; Are we in Metallic Madness?
	bls.w	RunRound8					; If so, branch

; ------------------------------------------------------------------------------
; New game
; ------------------------------------------------------------------------------

NewGame:
RunRound1:
	moveq	#0,d0
	move.b	d0,nemesis_queue_flags				; Reset Nemesis queue flags
	move.w	d0,zone						; Set stage to Palmtree Panic Act 1
	move.w	d0,saved_stage
	move.b	d0,good_future_zones				; Reset good futures achieved
	move.b	d0,current_special_stage			; Reset special stage ID
	move.b	d0,time_stones					; Reset time stones retrieved

	bsr.w	WriteSaveData					; Write save data
	
	bsr.w	RunRound11					; Run act 1
	bsr.w	RunRound12					; Run act 2
	bsr.w	RunRound13					; Run act 3

	moveq	#3*1,d0						; Unlock zone in time attack
	bsr.w	UnlockTimeAttackStage
	bset	#6,title_flags
	bset	#5,title_flags
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bclr	#0,good_future					; Was act 3 in the good future?
	beq.s	RunRound3					; If not, branch
	bset	#0,good_future_zones				; Mark good future as achieved

; ------------------------------------------------------------------------------

RunRound3:
	bsr.w	WriteSaveData					; Write save data
	
	move.b	#0,amy_captured					; Reset Amy captured flag
	bsr.w	RunRound31					; Run act 1
	move.b	#0,amy_captured					; Reset Amy captured flag
	bsr.w	RunRound32					; Run act 2
	bsr.w	RunRound33					; Run act 3

	moveq	#3*2,d0						; Unlock zone in time attack
	bsr.w	UnlockTimeAttackStage
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bclr	#0,good_future					; Was act 3 in the good future?
	beq.s	RunRound4					; If not, branch
	bset	#1,good_future_zones				; Mark good future as achieved

; ------------------------------------------------------------------------------

RunRound4:
	bsr.w	WriteSaveData					; Write save data
	
	bsr.w	RunRound41					; Run act 1
	bsr.w	RunRound42					; Run act 2
	bsr.w	RunRound43					; Run act 3

	moveq	#3*3,d0						; Unlock zone in time attack
	bsr.w	UnlockTimeAttackStage
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bclr	#0,good_future					; Was act 3 in the good future?
	beq.s	RunRound5					; If not, branch
	bset	#2,good_future_zones				; Mark good future as achieved

; ------------------------------------------------------------------------------

RunRound5:
	bsr.w	WriteSaveData					; Write save data
	
	bsr.w	RunRound51					; Run act 1
	bsr.w	RunRound52					; Run act 2
	bsr.w	RunRound53					; Run act 3

	moveq	#3*4,d0						; Unlock zone in time attack
	bsr.w	UnlockTimeAttackStage
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bclr	#0,good_future					; Was act 3 in the good future?
	beq.s	RunRound6					; If not, branch
	bset	#3,good_future_zones				; Mark good future as achieved

; ------------------------------------------------------------------------------

RunRound6:
	bsr.w	WriteSaveData					; Write save data
	
	bsr.w	RunRound61					; Run act 1
	bsr.w	RunRound62					; Run act 2
	bsr.w	RunRound63					; Run act 3

	moveq	#3*5,d0						; Unlock zone in time attack
	bsr.w	UnlockTimeAttackStage
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bclr	#0,good_future					; Was act 3 in the good future?
	beq.s	RunRound7					; If not, branch
	bset	#4,good_future_zones				; Mark good future as achieved

; ------------------------------------------------------------------------------

RunRound7:
	bsr.w	WriteSaveData					; Write save data
	
	bsr.w	RunRound71					; Run act 1
	bsr.w	RunRound72					; Run act 2
	bsr.w	RunRound73					; Run act 3

	moveq	#3*6,d0						; Unlock zone in time attack
	bsr.w	UnlockTimeAttackStage
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bclr	#0,good_future					; Was act 3 in the good future?
	beq.s	RunRound8					; If not, branch
	bset	#5,good_future_zones				; Mark good future as achieved

; ------------------------------------------------------------------------------

RunRound8:
	bsr.w	WriteSaveData					; Write save data
	
	bsr.w	RunRound81					; Run act 1
	bsr.w	RunRound82					; Run act 2
	bsr.w	RunRound83					; Run act 3

	moveq	#3*7,d0						; Unlock zone in time attack
	bsr.w	UnlockTimeAttackStage
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bclr	#0,good_future					; Was act 3 in the good future?
	beq.s	GameDone					; If not, branch
	bset	#6,good_future_zones				; Mark good future as achieved

; ------------------------------------------------------------------------------

GameDone:
	move.b	good_future_zones,good_future_zones_result	; Save good futures achieved
	move.b	time_stones,time_stones_result			; Save time stones retrieved

	bsr.w	WriteSaveData					; Write save data
	
	cmpi.b	#%01111111,good_future_zones_result		; Were all of the good futures achievd?
	beq.s	GoodEnding					; If so, branch
	cmpi.b	#%01111111,time_stones_result			; Were all of the time stones retrieved?
	beq.s	GoodEnding					; If so, branch

BadEnding:
	move.b	#0,ending_id					; Set ending ID to bad ending
	
	move.w	#SCMD_BAD_END,d0				; Run bad ending file
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	BadEnding					; If so, loop
	rts

GoodEnding:
	move.b	#$7F,ending_id					; Set ending ID to good ending
	
	move.w	#SCMD_GOOD_END,d0				; Run good ending file
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	GoodEnding					; If so, loop
	rts

; ------------------------------------------------------------------------------
; Game over
; ------------------------------------------------------------------------------

GameOver:
	move.b	#0,act						; Reset act
	move.w	zone_act,saved_stage				; Save zone and act ID
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	bclr	#0,good_future					; Reset good future flag
	rts

; ------------------------------------------------------------------------------
; Final game results data
; ------------------------------------------------------------------------------

good_future_zones_result:	
	dc.b	0						; Good futures achieved
time_stones_result:
	dc.b	0						; Time stones retrieved

; ------------------------------------------------------------------------------
; Run Palmtree Panic Act 1
; ------------------------------------------------------------------------------

RunRound11:
	lea	Round11Commands(pc),a0				; Run stage
	move.w	#$000,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Palmtree Panic Act 2
; ------------------------------------------------------------------------------

RunRound12:
	lea	Round12Commands(pc),a0				; Run stage
	move.w	#$001,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Palmtree Panic Act 3
; ------------------------------------------------------------------------------

RunRound13:
	lea	Round13Commands(pc),a0				; Run stage
	move.w	#$002,zone_act
	bra.w	RunBossStage

; ------------------------------------------------------------------------------
; Run Collision Chaos Act 1
; ------------------------------------------------------------------------------

RunRound31:
	lea	Round31Commands(pc),a0				; Run stage
	move.w	#$100,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Collision Chaos Act 2
; ------------------------------------------------------------------------------

RunRound32:
	lea	Round32Commands(pc),a0				; Run stage
	move.w	#$101,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Collision Chaos Act 3
; ------------------------------------------------------------------------------

RunRound33:
	lea	Round33Commands(pc),a0				; Run stage
	move.w	#$102,zone_act
	bra.w	RunBossStage

; ------------------------------------------------------------------------------
; Run Tidal Tempest Act 1
; ------------------------------------------------------------------------------

RunRound41:
	lea	Round41Commands(pc),a0				; Run stage
	move.w	#$200,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Tidal Tempest Act 2
; ------------------------------------------------------------------------------

RunRound42:
	lea	Round42Commands(pc),a0				; Run stage
	move.w	#$201,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Tidal Tempest Act 3
; ------------------------------------------------------------------------------

RunRound43:
	lea	Round43Commands(pc),a0				; Run stage
	move.w	#$202,zone_act
	bra.w	RunBossStage

; ------------------------------------------------------------------------------
; Run Quartz Quadrant Act 1
; ------------------------------------------------------------------------------

RunRound51:
	lea	Round51Commands(pc),a0				; Run stage
	move.w	#$300,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Quartz Quadrant Act 2
; ------------------------------------------------------------------------------

RunRound52:
	lea	Round52Commands(pc),a0				; Run stage
	move.w	#$301,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Quartz Quadrant Act 3
; ------------------------------------------------------------------------------

RunRound53:
	lea	Round53Commands(pc),a0				; Run stage
	move.w	#$302,zone_act
	bra.w	RunBossStage

; ------------------------------------------------------------------------------
; Run Wacky Workbench Act 1
; ------------------------------------------------------------------------------

RunRound61:
	lea	Round61Commands(pc),a0				; Run stage
	move.w	#$400,zone_act
	bra.s	RunStage

; ------------------------------------------------------------------------------
; Run Wacky Workbench Act 2
; ------------------------------------------------------------------------------

RunRound62:
	lea	Round62Commands(pc),a0				; Run stage
	move.w	#$401,zone_act
	bra.s	RunStage

; ------------------------------------------------------------------------------
; Run Wacky Workbench Act 3
; ------------------------------------------------------------------------------

RunRound63:
	lea	Round63Commands(pc),a0				; Run stage
	move.w	#$402,zone_act
	bra.w	RunBossStage

; ------------------------------------------------------------------------------
; Run Stardust Speedway Act 1
; ------------------------------------------------------------------------------

RunRound71:
	lea	Round71Commands(pc),a0				; Run stage
	move.w	#$500,zone_act
	bra.s	RunStage

; ------------------------------------------------------------------------------
; Run Stardust Speedway Act 2
; ------------------------------------------------------------------------------

RunRound72:
	lea	Round72Commands(pc),a0				; Run stage
	move.w	#$501,zone_act
	bra.s	RunStage

; ------------------------------------------------------------------------------
; Run Stardust Speedway Act 3
; ------------------------------------------------------------------------------

RunRound73:
	lea	Round73Commands(pc),a0				; Run stage
	move.w	#$502,zone_act
	bra.w	RunBossStage

; ------------------------------------------------------------------------------
; Run Metallic Madness Act 1
; ------------------------------------------------------------------------------

RunRound81:
	lea	Round81Commands(pc),a0				; Run stage
	move.w	#$600,zone_act
	bra.s	RunStage

; ------------------------------------------------------------------------------
; Run Metallic Madness Act 2
; ------------------------------------------------------------------------------

RunRound82:
	lea	Round82Commands(pc),a0				; Run stage
	move.w	#$601,zone_act
	bra.s	RunStage

; ------------------------------------------------------------------------------
; Run Metallic Madness Act 3
; ------------------------------------------------------------------------------

RunRound83:
	lea	Round83Commands(pc),a0				; Run stage
	move.w	#$602,zone_act
	bra.w	RunBossStage

; ------------------------------------------------------------------------------
; Run stage
; ------------------------------------------------------------------------------

RunStage:
	moveq	#0,d0						; Get present file load command
	move.b	0(a0),d0

.StageLoop:
	bsr.w	RunMmd						; Run stage file

	tst.b	lives						; Have we run out of lives?
	beq.s	.StageOver					; If so, branch
	btst	#7,time_zone					; Are we time warping?
	beq.s	.StageOver					; If not, branch

	moveq	#SCMD_WARP,d0					; Run warp sequence file
	bsr.w	RunMmd

	move.b	time_zone,d1					; Get new time zone

	moveq	#0,d0						; Get past file load command
	move.b	1(a0),d0
	andi.b	#$7F,d1						; Are we in the past?
	beq.s	.StageLoop					; If so, branch

	move.b	0(a0),d0					; Get present file load command
	subq.b	#1,d1						; Are we in the present?
	beq.s	.StageLoop					; If so, branch

	move.b	3(a0),d0					; Get bad future file load command
	tst.b	good_future					; Are we in the good future?
	beq.s	.StageLoop					; If not, branch
	
	move.b	2(a0),d0					; Get good future file load command
	bra.s	.StageLoop					; Loop

.StageOver:
	tst.b	lives						; Do we still have lives left?
	bne.s	.CheckSpecialStage				; If so, branch
	move.l	(sp)+,d0					; If not, exit
	bra.w	GameOver

.CheckSpecialStage:
	tst.b	special_stage					; Are we going into a special stage?
	bne.s	.SpecialStage					; If so, branch
	rts

.SpecialStage:
	move.b	current_special_stage,special_stage_id_cmd	; Set stage ID
	move.b	time_stones,time_stones_cmd			; Copy time stones retrieved flags
	bclr	#0,special_stage_flags				; Normal mode

	moveq	#SCMD_SPECIAL_STAGE,d0				; Run special stage
	bsr.w	RunMmd

	move.b	#1,palette_clear_flags				; Fade from white in next stage
	cmpi.b	#%01111111,time_stones				; Do we have all of the time stones now?
	bne.s	.End						; If not, branch
	move.b	#1,good_future					; If so, set good future flag

.End:
	rts

; ------------------------------------------------------------------------------
; Run boss stage
; ------------------------------------------------------------------------------

RunBossStage:
	moveq	#0,d0						; Get good future file load command
	move.b	0(a0),d0
	tst.b	good_future					; Are we in the good future?
	bne.s	.RunStage					; If so, branch
	move.b	1(a0),d0					; Get bad future file load command
	
.RunStage:
	bsr.w	RunMmd						; Run stage file

	tst.b	lives						; Do we still have lives left?
	bne.s	.NextStage					; If so, branch
	move.l	(sp)+,d0					; If not, exit
	bra.w	GameOver

.NextStage:
	addq.b	#1,saved_stage					; Next stage
	cmpi.b	#7,saved_stage					; Are we at the end of the game?
	bcs.s	.End						; If not, branch
	subq.b	#1,saved_stage					; Cap stage ID

.End:
	move.b	#0,checkpoint					; Reset checkpoint
	rts

; ------------------------------------------------------------------------------
; Unlock time attack zone
; ------------------------------------------------------------------------------
; PARAMETERS
;	d0.b - Stage ID
; ------------------------------------------------------------------------------

UnlockTimeAttackStage:
	cmp.b	time_attack_unlock,d0				; Is this stage already unlocked?
	bls.s	.End						; If so, branch
	move.b	d0,time_attack_unlock				; If not, unlock it

.End:
	rts

; ------------------------------------------------------------------------------
; Stage loading Sub CPU commands
; ------------------------------------------------------------------------------

; Palmtree Panic
Round11Commands:
	dc.b	SCMD_ROUND_11A, SCMD_ROUND_11B, SCMD_ROUND_11C, SCMD_ROUND_11D
Round12Commands:
	dc.b	SCMD_ROUND_12A, SCMD_ROUND_12B, SCMD_ROUND_12C, SCMD_ROUND_12D
Round13Commands:
	dc.b	SCMD_ROUND_13C, SCMD_ROUND_13D

; Collision Chaos
Round31Commands:
	dc.b	SCMD_ROUND_31A, SCMD_ROUND_31B, SCMD_ROUND_31C, SCMD_ROUND_31D
Round32Commands:
	dc.b	SCMD_ROUND_32A, SCMD_ROUND_32B, SCMD_ROUND_32C, SCMD_ROUND_32D
Round33Commands:
	dc.b	SCMD_ROUND_33C, SCMD_ROUND_33D

; Tidal Tempest
Round41Commands:
	dc.b	SCMD_ROUND_41A, SCMD_ROUND_41B, SCMD_ROUND_41C, SCMD_ROUND_41D
Round42Commands:
	dc.b	SCMD_ROUND_42A, SCMD_ROUND_42B, SCMD_ROUND_42C, SCMD_ROUND_42D
Round43Commands:
	dc.b	SCMD_ROUND_43C, SCMD_ROUND_43D

; Quartz Quadrant
Round51Commands:
	dc.b	SCMD_ROUND_51A, SCMD_ROUND_51B, SCMD_ROUND_51C, SCMD_ROUND_51D
Round52Commands:
	dc.b	SCMD_ROUND_52A, SCMD_ROUND_52B, SCMD_ROUND_52C, SCMD_ROUND_52D
Round53Commands:
	dc.b	SCMD_ROUND_53C, SCMD_ROUND_53D

; Wacky Workbench
Round61Commands:
	dc.b	SCMD_ROUND_61A, SCMD_ROUND_61B, SCMD_ROUND_61C, SCMD_ROUND_61D
Round62Commands:
	dc.b	SCMD_ROUND_62A, SCMD_ROUND_62B, SCMD_ROUND_62C, SCMD_ROUND_62D
Round63Commands:
	dc.b	SCMD_ROUND_63C, SCMD_ROUND_63D

; Stardust Speedway
Round71Commands:
	dc.b	SCMD_ROUND_71A, SCMD_ROUND_71B, SCMD_ROUND_71C, SCMD_ROUND_71D
Round72Commands:
	dc.b	SCMD_ROUND_72A, SCMD_ROUND_72B, SCMD_ROUND_72C, SCMD_ROUND_72D
Round73Commands:
	dc.b	SCMD_ROUND_73C, SCMD_ROUND_73D

; Metallic Madness
Round81Commands:
	dc.b	SCMD_ROUND_81A, SCMD_ROUND_81B, SCMD_ROUND_81C, SCMD_ROUND_81D
Round82Commands:
	dc.b	SCMD_ROUND_82A, SCMD_ROUND_82B, SCMD_ROUND_82C, SCMD_ROUND_82D
Round83Commands:
	dc.b	SCMD_ROUND_83C, SCMD_ROUND_83D

; ------------------------------------------------------------------------------
; Stage selection entry
; ------------------------------------------------------------------------------
; PARAMETERS:
;	id          - ID constant name
;	cmd         - Command ID
;	stage       - Stage ID
;	time_zone   - Time zone
;	good_future - Good Future flag
; ------------------------------------------------------------------------------

__stage_select_id: = 0
selectEntry macro id, cmd, stage, time_zone, good_future
	dc.w	\cmd, \stage
	dc.b	\time_zone, \good_future
	
	\id\: equ __stage_select_id
	__stage_select_id: = __stage_select_id+1
	endm

; ------------------------------------------------------------------------------
; Stage select
; ------------------------------------------------------------------------------

StageSelect:
	moveq	#SCMD_STAGE_SELECT,d0				; Run stage select file
	bsr.w	RunMmd

	mulu.w	#6,d0						; Get selected stage data
	move.w	StageSelections+2(pc,d0.w),zone_act		; Set stage
	move.b	StageSelections+4(pc,d0.w),time_zone		; Time zone
	move.b	StageSelections+5(pc,d0.w),good_future		; Good future flag
	move.w	StageSelections(pc,d0.w),d0			; File load command
	
	move.b	#0,projector_destroyed				; Reset projector destroyed flag

	cmpi.w	#SCMD_SPECIAL_STAGE,d0				; Have we selected the special stage?
	beq.w	SpecStage1Demo					; If so, branch
	
	bsr.w	RunMmd						; Run stage file
	rts

; ------------------------------------------------------------------------------

StageSelections:
	selectEntry SELECT_ROUND_11A,     SCMD_ROUND_11A,      $000, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_11B,     SCMD_ROUND_11B,      $000, TIME_PAST,    0
	selectEntry SELECT_ROUND_11C,     SCMD_ROUND_11C,      $000, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_11D,     SCMD_ROUND_11D,      $000, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_12A,     SCMD_ROUND_12A,      $001, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_12B,     SCMD_ROUND_12B,      $001, TIME_PAST,    0
	selectEntry SELECT_ROUND_12C,     SCMD_ROUND_12C,      $001, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_12D,     SCMD_ROUND_12D,      $001, TIME_FUTURE,  0
	selectEntry SELECT_WARP,          SCMD_WARP,           $000, TIME_PAST,    0
	selectEntry SELECT_OPENING,       SCMD_OPENING,        $000, TIME_PAST,    0
	selectEntry SELECT_COMIN_SOON,    SCMD_COMIN_SOON,     $000, TIME_PAST,    0
	selectEntry SELECT_ROUND_31A,     SCMD_ROUND_31A,      $100, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_31B,     SCMD_ROUND_31B,      $100, TIME_PAST,    0
	selectEntry SELECT_ROUND_31C,     SCMD_ROUND_31C,      $100, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_31D,     SCMD_ROUND_31D,      $100, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_32A,     SCMD_ROUND_32A,      $101, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_32B,     SCMD_ROUND_32B,      $101, TIME_PAST,    0
	selectEntry SELECT_ROUND_32C,     SCMD_ROUND_32C,      $101, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_32D,     SCMD_ROUND_32D,      $101, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_33C,     SCMD_ROUND_33C,      $102, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_33D,     SCMD_ROUND_33D,      $102, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_13C,     SCMD_ROUND_13C,      $002, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_13D,     SCMD_ROUND_13D,      $002, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_41A,     SCMD_ROUND_41A,      $200, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_41B,     SCMD_ROUND_41B,      $200, TIME_PAST,    0
	selectEntry SELECT_ROUND_41C,     SCMD_ROUND_41C,      $200, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_41D,     SCMD_ROUND_41D,      $200, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_42A,     SCMD_ROUND_42A,      $201, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_42B,     SCMD_ROUND_42B,      $201, TIME_PAST,    0
	selectEntry SELECT_ROUND_42C,     SCMD_ROUND_42C,      $201, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_42D,     SCMD_ROUND_42D,      $201, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_43C,     SCMD_ROUND_43C,      $202, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_43D,     SCMD_ROUND_43D,      $202, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_51A,     SCMD_ROUND_51A,      $300, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_51B,     SCMD_ROUND_51B,      $300, TIME_PAST,    0
	selectEntry SELECT_ROUND_51C,     SCMD_ROUND_51C,      $300, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_51D,     SCMD_ROUND_51D,      $300, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_52A,     SCMD_ROUND_52A,      $301, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_52B,     SCMD_ROUND_52B,      $301, TIME_PAST,    0
	selectEntry SELECT_ROUND_52C,     SCMD_ROUND_52C,      $301, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_52D,     SCMD_ROUND_52D,      $301, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_53C,     SCMD_ROUND_53C,      $302, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_53D,     SCMD_ROUND_53D,      $302, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_61A,     SCMD_ROUND_61A,      $400, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_61B,     SCMD_ROUND_61B,      $400, TIME_PAST,    0
	selectEntry SELECT_ROUND_61C,     SCMD_ROUND_61C,      $400, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_61D,     SCMD_ROUND_61D,      $400, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_62A,     SCMD_ROUND_62A,      $401, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_62B,     SCMD_ROUND_62B,      $401, TIME_PAST,    0
	selectEntry SELECT_ROUND_62C,     SCMD_ROUND_62C,      $401, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_62D,     SCMD_ROUND_62D,      $401, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_63C,     SCMD_ROUND_63C,      $402, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_63D,     SCMD_ROUND_63D,      $402, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_71A,     SCMD_ROUND_71A,      $500, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_71B,     SCMD_ROUND_71B,      $500, TIME_PAST,    0
	selectEntry SELECT_ROUND_71C,     SCMD_ROUND_71C,      $500, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_71D,     SCMD_ROUND_71D,      $500, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_72A,     SCMD_ROUND_72A,      $501, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_72B,     SCMD_ROUND_72B,      $501, TIME_PAST,    0
	selectEntry SELECT_ROUND_72C,     SCMD_ROUND_72C,      $501, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_72D,     SCMD_ROUND_72D,      $501, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_73C,     SCMD_ROUND_73C,      $502, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_73D,     SCMD_ROUND_73D,      $502, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_81A,     SCMD_ROUND_81A,      $600, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_81B,     SCMD_ROUND_81B,      $600, TIME_PAST,    0
	selectEntry SELECT_ROUND_81C,     SCMD_ROUND_81C,      $600, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_81D,     SCMD_ROUND_81D,      $600, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_82A,     SCMD_ROUND_82A,      $601, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_82B,     SCMD_ROUND_82B,      $601, TIME_PAST,    0
	selectEntry SELECT_ROUND_82C,     SCMD_ROUND_82C,      $601, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_82D,     SCMD_ROUND_82D,      $601, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_83C,     SCMD_ROUND_83C,      $602, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_83D,     SCMD_ROUND_83D,      $602, TIME_FUTURE,  0
	selectEntry SELECT_SPECIAL_STAGE, SCMD_SPECIAL_STAGE,  $000, TIME_PAST,    0
	selectEntry SELECT_UNUSED_1,      SCMD_ROUND_11A,      $000, TIME_PRESENT, 0
	selectEntry SELECT_UNUSED_2,      SCMD_ROUND_11A,      $000, TIME_PRESENT, 0
	selectEntry SELECT_UNUSED_3,      SCMD_ROUND_11A,      $000, TIME_PRESENT, 0
	selectEntry SELECT_UNUSED_4,      SCMD_ROUND_11A,      $000, TIME_PRESENT, 0

; ------------------------------------------------------------------------------
; Demo mode
; ------------------------------------------------------------------------------

Demo:
	moveq	#(.DemosEnd-.Demos)/2-1,d1			; Maximum demo ID
	
	lea	demo_id,a6					; Get current demo ID
	moveq	#0,d0
	move.b	(a6),d0

	addq.b	#1,(a6)						; Advance demo ID
	cmp.b	(a6),d1						; Are we past the max ID?
	bcc.s	.RunDemo					; If not, branch
	move.b	#0,(a6)						; Wrap demo ID

.RunDemo:
	add.w	d0,d0						; Run demo
	move.w	.Demos(pc,d0.w),d0
	jmp	.Demos(pc,d0.w)

; ------------------------------------------------------------------------------

.Demos:
	dc.w	RunOpeningDemo-.Demos
	dc.w	RunDemo11A-.Demos
	dc.w	RunSpecialDemo1-.Demos
	dc.w	RunDemo43C-.Demos
	dc.w	RunSpecialDemo6-.Demos
	dc.w	RunDemo82A-.Demos
.DemosEnd:

; ------------------------------------------------------------------------------
; Palmtree Panic Act 1 Present demo
; ------------------------------------------------------------------------------

RunDemo11A:
	move.b	#0,nemesis_queue_flags				; Reset Nemesis queue flags
	move.w	#$000,zone_act					; Set stage to Palmtree Panic Act 1
	move.b	#TIME_PRESENT,time_zone				; Set time zone to present
	move.b	#0,good_future					; Reset good future flag
	
	move.w	#SCMD_DEMO_11A,d0				; Run demo file
	bsr.w	RunMmd
	move.w	#0,demo_mode					; Reset demo mode flag
	rts

; ------------------------------------------------------------------------------
; Tidal Tempest Act 3 Good Future
; ------------------------------------------------------------------------------

RunDemo43C:
	move.b	#0,nemesis_queue_flags				; Reset Nemesis queue flags
	move.w	#$202,zone_act					; Set stage to Tidal Tempest Act 3
	move.b	#TIME_FUTURE,time_zone				; Set time zone to present
	move.b	#1,good_future					; Set good future flag
	
	move.w	#SCMD_DEMO_43C,d0				; Run demo file
	bsr.w	RunMmd
	move.w	#0,demo_mode					; Reset demo mode flag
	rts

; ------------------------------------------------------------------------------
; Metallic Madness Act 2 Present
; ------------------------------------------------------------------------------

RunDemo82A:
	move.b	#0,nemesis_queue_flags				; Reset Nemesis queue flags
	move.w	#$601,zone_act					; Set stage to Metallic Madness Act 2
	move.b	#TIME_PRESENT,time_zone				; Set time zone to present
	move.b	#0,good_future					; Reset good future flag
	
	move.w	#SCMD_DEMO_82A,d0				; Run demo file
	bsr.w	RunMmd
	move.w	#0,demo_mode					; Reset demo mode flag
	rts

; ------------------------------------------------------------------------------
; Special Stage 1 demo
; ------------------------------------------------------------------------------

RunSpecialDemo1:
	move.w	#SCMD_SPECIAL_RESET,d0				; Reset special stage flags
	bsr.w	SubCpuCommand
	bra.w	SpecStage1Demo					; Run demo file

; ------------------------------------------------------------------------------
; Special Stage 6 demo
; ------------------------------------------------------------------------------

RunSpecialDemo6:
	move.w	#SCMD_SPECIAL_RESET,d0				; Reset special stage flags
	bsr.w	SubCpuCommand
	bra.w	SpecStage6Demo					; Run demo file

; ------------------------------------------------------------------------------
; Opening FMV
; ------------------------------------------------------------------------------

RunOpeningDemo:
	move.w	#SCMD_OPENING,d0				; Run opening FMV
	bsr.w	RunMmd

	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	RunOpeningDemo					; If so, loop
	rts

; ------------------------------------------------------------------------------
; Sound test
; ------------------------------------------------------------------------------

SoundTest:
	moveq	#SCMD_SOUND_TEST,d0				; Run sound test
	bsr.w	RunMmd

	add.w	d0,d0						; Exit sound test
	move.w	.Exits(pc,d0.w),d0
	jmp	.Exits(pc,d0.w)

; ------------------------------------------------------------------------------

.Exits:
	dc.w	ExitSoundTest-.Exits				; Exit sound test
	dc.w	RunSpecialStage8-.Exits				; Special Stage 8
	dc.w	RunFunIsInfinite-.Exits				; Fun is infinite
	dc.w	RunMcSonic-.Exits				; M.C. Sonic
	dc.w	RunTails-.Exits					; Tails
	dc.w	RunBatman-.Exits				; Batman Sonic
	dc.w	RunCuteSonic-.Exits				; Cute Sonic

; ------------------------------------------------------------------------------
; Exit sound test
; ------------------------------------------------------------------------------

ExitSoundTest:
	rts

; ------------------------------------------------------------------------------
; Special Stage 8
; ------------------------------------------------------------------------------

RunSpecialStage8:
	move.b	#8-1,special_stage_id_cmd			; Stage 8
	move.b	#0,time_stones_cmd				; Reset time stones retrieved
	bset	#0,special_stage_flags				; Temporary mode
	bset	#2,special_stage_flags				; Secret mode
	
	moveq	#SCMD_SPECIAL_STAGE,d0				; Run special stage
	bsr.w	RunMmd
	
	tst.b	special_stage_lost				; Was the stage beaten?
	bne.s	.End						; If not, branch
	
	move.w	#SCMD_SPECIAL_8_END,d0				; If so, run credits
	bsr.w	RunMmd

.End:
	rts

; ------------------------------------------------------------------------------
; "Fun is infinite" easter egg
; ------------------------------------------------------------------------------

RunFunIsInfinite:
	move.w	#SCMD_FUN_IS_INFINITE,d0			; Run easter egg
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; M.C. Sonic easter egg
; ------------------------------------------------------------------------------

RunMcSonic:
	move.w	#SCMD_MC_SONIC,d0				; Run easter egg
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; Tails easter egg
; ------------------------------------------------------------------------------

RunTails:
	move.w	#SCMD_TAILS,d0					; Run easter egg
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; Batman Sonic easter egg
; ------------------------------------------------------------------------------

RunBatman:
	move.w	#SCMD_BATMAN,d0					; Run easter egg
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; Cute Sonic easter egg
; ------------------------------------------------------------------------------

RunCuteSonic:
	move.w	#SCMD_CUTE_SONIC,d0				; Run easter egg
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; Visual Mode
; ------------------------------------------------------------------------------

VisualMode:
	move.w	#SCMD_VISUAL_MODE,d0				; Run Visual Mode
	bsr.w	RunMmd

	add.w	d0,d0						; Play FMV
	move.w	.FMVs(pc,d0.w),d0
	jmp	.FMVs(pc,d0.w)

; ------------------------------------------------------------------------------

.FMVs:
	dc.w	ExitVisualMode-.FMVs				; Exit Visual Mode
	dc.w	VisualModeOpening-.FMVs				; Opening
	dc.w	VisualModeGoodEnding-.FMVs			; Good ending
	dc.w	VisualModeBadEnding-.FMVs			; Bad ending
	dc.w	VisualModePencilTest-.FMVs			; Pencil test

; ------------------------------------------------------------------------------
; Play opening FMV
; ------------------------------------------------------------------------------

VisualModeOpening:
	move.w	#SCMD_OPENING,d0				; Run opening
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	VisualModeOpening				; If so, loop

	bra.s	VisualMode					; Go back to menu

; ------------------------------------------------------------------------------
; Exit Visual Mode
; ------------------------------------------------------------------------------

ExitVisualMode:
	rts

; ------------------------------------------------------------------------------
; Play pencil test FMV
; ------------------------------------------------------------------------------

VisualModePencilTest:
	move.w	#SCMD_PENCIL_TEST,d0				; Run pencil test
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	VisualModePencilTest				; If so, loop

	bra.s	VisualMode					; Go back to menu

; ------------------------------------------------------------------------------
; Play good ending FMV
; ------------------------------------------------------------------------------

VisualModeGoodEnding:
	move.b	#$7F,ending_id					; Set ending ID to good ending
	
	move.w	#SCMD_GOOD_END,d0				; Run good ending
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	VisualModeGoodEnding				; If so, loop
	
	move.w	#SCMD_THANKS,d0					; Run "Thank You" screen
	bsr.w	RunMmd

	bra.s	VisualMode					; Go back to menu

; ------------------------------------------------------------------------------
; Play bad ending FMV
; ------------------------------------------------------------------------------

VisualModeBadEnding:
	move.b	#0,ending_id					; Set ending ID to bad ending
	
	move.w	#SCMD_BAD_END,d0				; Run bad ending
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	VisualModeBadEnding				; If so, loop

	bra.s	VisualMode					; Go back to menu

; ------------------------------------------------------------------------------
; D.A. Garden
; ------------------------------------------------------------------------------

DaGarden:
	move.w	#SCMD_DA_GARDEN,d0				; Run D.A. Garden
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; Time Attack
; ------------------------------------------------------------------------------

TimeAttack:
	moveq	#SCMD_TIME_ATTACK,d0				; Run time attack menu file
	bsr.w	RunMmd
	
	move.w	d0,time_attack_stage				; Set stage
	beq.w	.End						; If we are exiting, branch

	move.b	.Selections(pc,d0.w),d0				; Get stage selection ID
	bmi.s	TimeAttackSpecialStage				; If we are entering a special stage, branch

	mulu.w	#6,d0						; Get selected stage data
	lea	StageSelections(pc),a6
	move.w	2(a6,d0.w),zone_act				; Set stage
	move.b	4(a6,d0.w),time_zone				; Time zone
	move.b	5(a6,d0.w),good_future				; Good future flag
	move.w	(a6,d0.w),d0					; File load command
	
	move.b	#1,time_attack_mode				; Set time attack mode flag
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bsr.w	RunMmd						; Run stage file
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.l	time,time_attack_time				; Save time attack time
	
	bra.s	TimeAttack					; Loop back to menu

.End:
	rts

; ------------------------------------------------------------------------------

.Selections:
	dc.b	SELECT_ROUND_11A

	dc.b	SELECT_ROUND_11A
	dc.b	SELECT_ROUND_12A
	dc.b	SELECT_ROUND_13D
	
	dc.b	SELECT_ROUND_31A
	dc.b	SELECT_ROUND_32A
	dc.b	SELECT_ROUND_33D
	
	dc.b	SELECT_ROUND_41A
	dc.b	SELECT_ROUND_42A
	dc.b	SELECT_ROUND_43D
	
	dc.b	SELECT_ROUND_51A
	dc.b	SELECT_ROUND_52A
	dc.b	SELECT_ROUND_53D
	
	dc.b	SELECT_ROUND_61A
	dc.b	SELECT_ROUND_62A
	dc.b	SELECT_ROUND_63D
	
	dc.b	SELECT_ROUND_71A
	dc.b	SELECT_ROUND_72A
	dc.b	SELECT_ROUND_73D
	
	dc.b	SELECT_ROUND_81A
	dc.b	SELECT_ROUND_82A
	dc.b	SELECT_ROUND_83D

	dc.b	-1
	dc.b	-2
	dc.b	-3
	dc.b	-4
	dc.b	-5
	dc.b	-6
	dc.b	-7
	even

; ------------------------------------------------------------------------------

TimeAttackSpecialStage:
	neg.b	d0						; Set special stage ID
	ext.w	d0
	subq.w	#1,d0
	move.b	d0,special_stage_id_cmd
	
	move.b	#0,time_stones_cmd				; Reset time stones retrieved for this stage
	bset	#1,special_stage_flags				; Time attack mode

	moveq	#SCMD_SPECIAL_STAGE,d0				; Run special stage
	bsr.w	RunMmd
	
	bra.w	TimeAttack					; Loop back to menu

; ------------------------------------------------------------------------------
; Run MMD file
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - File load command ID
; ------------------------------------------------------------------------------

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

	bsr.w	StopZ80						; Stop the Z80
	move.b	#FMC_STOP,FMDrvQueue2				; Stop FM sound
	bsr.w	StartZ80					; Start the Z80

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

screen_disabled:
	dc.b	0						; Screen disable flag
mmd_return_code:
	dc.b	0						; MMD return code

; ------------------------------------------------------------------------------
; V-BLANK interrupt handler
; ------------------------------------------------------------------------------

VBlankIrq:
	bset	#MCDR_IFL2_BIT,MCD_IRQ2				; Trigger IRQ2 on Sub CPU
	
	bclr	#0,ipx_vsync					; Clear VSync flag
	bclr	#0,screen_disabled				; Clear screen disable flag
	beq.s	HBlankIrq					; If it wasn't set branch
	
	move.w	#$8134,VDP_CTRL					; If it was set, disable the screen

HBlankIrq:
	rte

; ------------------------------------------------------------------------------
; Read save data
; ------------------------------------------------------------------------------

ReadSaveData:
	bsr.w	GetBuramData					; Get Backup RAM data

	move.w	buram_zone,saved_stage				; Read save data
	move.b	buram_good_futures,good_future_zones
	move.b	buram_title_flags,title_flags
	move.b	buram_attack_unlock,time_attack_unlock
	move.b	buram_unknown,unknown_buram_var
	move.b	buram_special_stage,current_special_stage
	move.b	buram_time_stones,time_stones

	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM access
	rts

; ------------------------------------------------------------------------------
; Get Backup RAM data
; ------------------------------------------------------------------------------

GetBuramData:
	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM access
	
	move.w	#SCMD_TEMP_READ,d0				; Read temporary save data
	btst	#0,save_disabled				; Is saving to Backup RAM disabled?
	bne.s	.Read						; If so, branch
	move.w	#SCMD_BURAM_READ,d0				; Read Backup RAM save data
	
.Read:
	bsr.w	SubCpuCommand					; Run command
	bra.w	WaitWordRamAccess				; Wait for Word RAM access

; ------------------------------------------------------------------------------
; Write save data
; ------------------------------------------------------------------------------

WriteSaveData:
	bsr.s	GetBuramData					; Get Backup RAM data

	move.w	saved_stage,buram_zone				; Write save data
	move.b	good_future_zones,buram_good_futures
	move.b	title_flags,buram_title_flags
	move.b	time_attack_unlock,buram_attack_unlock
	move.b	unknown_buram_var,buram_unknown
	move.b	current_special_stage,buram_special_stage
	move.b	time_stones,buram_time_stones

	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM access

	move.w	#SCMD_TEMP_WRITE,d0				; Write temporary save data
	btst	#0,save_disabled				; Is saving to Backup RAM disabled?
	bne.s	.Read						; If so, branch
	move.w	#SCMD_BURAM_WRITE,d0				; Write Backup RAM save data
	
.Read:
	bsr.w	SubCpuCommand					; Run command
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access
	bra.w	GiveWordRamAccess				; Give Sub CPU Word RAM access
	
; ------------------------------------------------------------------------------
; Send the Sub CPU a command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; ------------------------------------------------------------------------------

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

WaitWordRamAccess:
	btst	#MCDR_RET_BIT,MCD_MEM_MODE			; Do we have Word RAM access?
	beq.s	WaitWordRamAccess				; If not, wait
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
; Stop the Z80
; ------------------------------------------------------------------------------

StopZ80:
	move	sr,saved_sr					; Save status register
	move	#$2700,sr					; Disable interrupts
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
; VSync
; ------------------------------------------------------------------------------

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

	jmp	0						; Unreferenced
	align global_variables

; ------------------------------------------------------------------------------
