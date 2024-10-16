; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code
	
	xref ReadSaveData, WriteSaveData, RunMmd
	xref mmd_return_code

; ------------------------------------------------------------------------------
; Load game
; ------------------------------------------------------------------------------

	xdef LoadGame
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

	xdef NewGame
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
	
	move.w	#SYS_BAD_END,d0					; Run bad ending file
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	BadEnding					; If so, loop
	rts

GoodEnding:
	move.b	#$7F,ending_id					; Set ending ID to good ending
	
	move.w	#SYS_GOOD_END,d0				; Run good ending file
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

	moveq	#SYS_WARP,d0					; Run warp sequence file
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

	moveq	#SYS_SPECIAL_STAGE,d0				; Run special stage
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
	dc.b	SYS_ROUND_11A, SYS_ROUND_11B, SYS_ROUND_11C, SYS_ROUND_11D
Round12Commands:
	dc.b	SYS_ROUND_12A, SYS_ROUND_12B, SYS_ROUND_12C, SYS_ROUND_12D
Round13Commands:
	dc.b	SYS_ROUND_13C, SYS_ROUND_13D

; Collision Chaos
Round31Commands:
	dc.b	SYS_ROUND_31A, SYS_ROUND_31B, SYS_ROUND_31C, SYS_ROUND_31D
Round32Commands:
	dc.b	SYS_ROUND_32A, SYS_ROUND_32B, SYS_ROUND_32C, SYS_ROUND_32D
Round33Commands:
	dc.b	SYS_ROUND_33C, SYS_ROUND_33D

; Tidal Tempest
Round41Commands:
	dc.b	SYS_ROUND_41A, SYS_ROUND_41B, SYS_ROUND_41C, SYS_ROUND_41D
Round42Commands:
	dc.b	SYS_ROUND_42A, SYS_ROUND_42B, SYS_ROUND_42C, SYS_ROUND_42D
Round43Commands:
	dc.b	SYS_ROUND_43C, SYS_ROUND_43D

; Quartz Quadrant
Round51Commands:
	dc.b	SYS_ROUND_51A, SYS_ROUND_51B, SYS_ROUND_51C, SYS_ROUND_51D
Round52Commands:
	dc.b	SYS_ROUND_52A, SYS_ROUND_52B, SYS_ROUND_52C, SYS_ROUND_52D
Round53Commands:
	dc.b	SYS_ROUND_53C, SYS_ROUND_53D

; Wacky Workbench
Round61Commands:
	dc.b	SYS_ROUND_61A, SYS_ROUND_61B, SYS_ROUND_61C, SYS_ROUND_61D
Round62Commands:
	dc.b	SYS_ROUND_62A, SYS_ROUND_62B, SYS_ROUND_62C, SYS_ROUND_62D
Round63Commands:
	dc.b	SYS_ROUND_63C, SYS_ROUND_63D

; Stardust Speedway
Round71Commands:
	dc.b	SYS_ROUND_71A, SYS_ROUND_71B, SYS_ROUND_71C, SYS_ROUND_71D
Round72Commands:
	dc.b	SYS_ROUND_72A, SYS_ROUND_72B, SYS_ROUND_72C, SYS_ROUND_72D
Round73Commands:
	dc.b	SYS_ROUND_73C, SYS_ROUND_73D

; Metallic Madness
Round81Commands:
	dc.b	SYS_ROUND_81A, SYS_ROUND_81B, SYS_ROUND_81C, SYS_ROUND_81D
Round82Commands:
	dc.b	SYS_ROUND_82A, SYS_ROUND_82B, SYS_ROUND_82C, SYS_ROUND_82D
Round83Commands:
	dc.b	SYS_ROUND_83C, SYS_ROUND_83D

; ------------------------------------------------------------------------------
