; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"

	section code
	
	xref TimerIrq, FinishCommand, NullGraphicsIrq

; ------------------------------------------------------------------------------
; Define a command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - ID constant name
;	\2 - Command name
; ------------------------------------------------------------------------------

__command_id set 1
command macro id, name
	xdef \1
	xref \2
	dc.w	(\2)-Commands
	\1:		equ __command_id
	__command_id:	set __command_id+1
	endm

; ------------------------------------------------------------------------------
; Command handler
; ------------------------------------------------------------------------------

CommandHandler:
	lea	SpVariables,a0					; Clear variables
	move.w	#SP_VARIABLES_SIZE/4-1,d7

.ClearVariables:
	move.l	#0,(a0)+
	dbf	d7,.ClearVariables

	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt
	move.l	#TimerIrq,_LEVEL3+2				; Set timer interrupt address
	move.b	#255,MCD_IRQ3_TIME				; Set timer interrupt interval

.WaitCommand:
	move.w	MCD_MAIN_COMM_0,d0				; Get command ID from Main CPU
	beq.s	.WaitCommand
	cmp.w	MCD_MAIN_COMM_0,d0
	bne.s	.WaitCommand
	cmpi.w	#(CommandsEnd-Commands)/2+1,d0			; Note: that "+1" shouldn't be there
	bcc.w	FinishCommand					; If it's an invalid ID, branch

	move.w	d0,d1						; Execute command
	add.w	d0,d0
	move.w	Commands(pc,d0.w),d0
	jsr	Commands(pc,d0.w)

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2 address
	bclr	#MCDR_IEN1_BIT,MCD_IRQ_MASK			; Disable graphics interrupt
	move.l	#NullGraphicsIrq,_LEVEL1+2			; Reset graphics interrupt address

	bra.s	.WaitCommand					; Loop

; ------------------------------------------------------------------------------

Commands:
	dc.w	0
	command SYS_ROUND_11A,        LoadStage
	command SYS_ROUND_11B,        LoadStage
	command SYS_ROUND_11C,        LoadStage
	command SYS_ROUND_11D,        LoadStage
	command SYS_MD_INIT,          LoadMegaDriveInit,      
	command SYS_STAGE_SELECT,     LoadStageSelect
	command SYS_ROUND_12A,        LoadStage
	command SYS_ROUND_12B,        LoadStage
	command SYS_ROUND_12C,        LoadStage
	command SYS_ROUND_12D,        LoadStage
	command SYS_TITLE,            LoadTitleScreen
	command SYS_WARP,             LoadWarp,               
	command SYS_TIME_ATTACK,      LoadTimeAttack
	command SYS_FADE_CDDA,        FadeOutCdda
	command SYS_SONG_1A,          PlayRound1ASong
	command SYS_SONG_1C,          PlayRound1CSong
	command SYS_SONG_1D,          PlayRound1DSong
	command SYS_SONG_3A,          PlayRound3ASong
	command SYS_SONG_3C,          PlayRound3CSong
	command SYS_SONG_3D,          PlayRound3DSong
	command SYS_SONG_4A,          PlayRound4ASong
	command SYS_SONG_4C,          PlayRound4CSong
	command SYS_SONG_4D,          PlayRound4DSong
	command SYS_SONG_5A,          PlayRound5ASong
	command SYS_SONG_5C,          PlayRound5CSong
	command SYS_SONG_5D,          PlayRound5DSong
	command SYS_SONG_6A,          PlayRound6ASong
	command SYS_SONG_6C,          PlayRound6CSong
	command SYS_SONG_6D,          PlayRound6DSong
	command SYS_SONG_7A,          PlayRound7ASong
	command SYS_SONG_7C,          PlayRound7CSong
	command SYS_SONG_7D,          PlayRound7DSong
	command SYS_SONG_8A,          PlayRound8ASong
	command SYS_SONG_8C,          PlayRound8CSong
	command SYS_IPX,              LoadIpx,                
	command SYS_DEMO_43C,         LoadStage
	command SYS_DEMO_82A,         LoadStage
	command SYS_SOUND_TEST,       LoadSoundTest
	command SYS_INVALID,          LoadStage
	command SYS_ROUND_31A,        LoadStage
	command SYS_ROUND_31B,        LoadStage
	command SYS_ROUND_31C,        LoadStage
	command SYS_ROUND_31D,        LoadStage
	command SYS_ROUND_32A,        LoadStage
	command SYS_ROUND_32B,        LoadStage
	command SYS_ROUND_32C,        LoadStage
	command SYS_ROUND_32D,        LoadStage
	command SYS_ROUND_33C,        LoadStage
	command SYS_ROUND_33D,        LoadStage
	command SYS_ROUND_13C,        LoadStage
	command SYS_ROUND_13D,        LoadStage
	command SYS_ROUND_41A,        LoadStage
	command SYS_ROUND_41B,        LoadStage
	command SYS_ROUND_41C,        LoadStage
	command SYS_ROUND_41D,        LoadStage
	command SYS_ROUND_42A,        LoadStage
	command SYS_ROUND_42B,        LoadStage
	command SYS_ROUND_42C,        LoadStage
	command SYS_ROUND_42D,        LoadStage
	command SYS_ROUND_43C,        LoadStage
	command SYS_ROUND_43D,        LoadStage
	command SYS_ROUND_51A,        LoadStage
	command SYS_ROUND_51B,        LoadStage
	command SYS_ROUND_51C,        LoadStage
	command SYS_ROUND_51D,        LoadStage
	command SYS_ROUND_52A,        LoadStage
	command SYS_ROUND_52B,        LoadStage
	command SYS_ROUND_52C,        LoadStage
	command SYS_ROUND_52D,        LoadStage
	command SYS_ROUND_53C,        LoadStage
	command SYS_ROUND_53D,        LoadStage
	command SYS_ROUND_61A,        LoadStage
	command SYS_ROUND_61B,        LoadStage
	command SYS_ROUND_61C,        LoadStage
	command SYS_ROUND_61D,        LoadStage
	command SYS_ROUND_62A,        LoadStage
	command SYS_ROUND_62B,        LoadStage
	command SYS_ROUND_62C,        LoadStage
	command SYS_ROUND_62D,        LoadStage
	command SYS_ROUND_63C,        LoadStage
	command SYS_ROUND_63D,        LoadStage
	command SYS_ROUND_71A,        LoadStage
	command SYS_ROUND_71B,        LoadStage
	command SYS_ROUND_71C,        LoadStage
	command SYS_ROUND_71D,        LoadStage
	command SYS_ROUND_72A,        LoadStage
	command SYS_ROUND_72B,        LoadStage
	command SYS_ROUND_72C,        LoadStage
	command SYS_ROUND_72D,        LoadStage
	command SYS_ROUND_73C,        LoadStage
	command SYS_ROUND_73D,        LoadStage
	command SYS_ROUND_81A,        LoadStage
	command SYS_ROUND_81B,        LoadStage
	command SYS_ROUND_81C,        LoadStage
	command SYS_ROUND_81D,        LoadStage
	command SYS_ROUND_82A,        LoadStage
	command SYS_ROUND_82B,        LoadStage
	command SYS_ROUND_82C,        LoadStage
	command SYS_ROUND_82D,        LoadStage
	command SYS_ROUND_83C,        LoadStage
	command SYS_ROUND_83D,        LoadStage
	command SYS_SONG_8D,          PlayRound8DSong
	command SYS_SONG_BOSS,        PlayBossSong
	command SYS_SONG_FINAL,       PlayFinalBossSong,      
	command SYS_SONG_TITLE,       PlayTitleSong
	command SYS_SONG_TIME_ATTACK, PlayTimeAttackSong
	command SYS_SONG_RESULTS,     PlayResultsSong
	command SYS_SONG_SPEED_SHOES, PlaySpeedShoesSong
	command SYS_SONG_INVINCIBLE,  PlayInvincibleSong
	command SYS_SONG_GAME_OVER,   PlayGameOverSong
	command SYS_SONG_SPECIAL,     PlaySpecialStageSong
	command SYS_SONG_DA_GARDEN,   PlayDaGardenSong
	command SYS_SFX_PROTO_WARP,   PlayProtoWarpSound
	command SYS_SONG_OPENING,     PlayOpeningSong
	command SYS_SONG_ENDING,      PlayEndingSong
	command SYS_CDDA_STOP,        StopCdda,               
	command SYS_SPECIAL_STAGE,    LoadSpecialStage
	command SYS_SFX_FUTURE,       PlayFutureVoiceSfx
	command SYS_SFX_PAST,         PlayPastVoiceSfx
	command SYS_SFX_ALRIGHT,      PlayAlrightSfx
	command SYS_SFX_OUTTA_HERE,   PlayOuttaHereSfx
	command SYS_SFX_YES,          PlayYesSfx
	command SYS_SFX_YEAH,         PlayYeahSfx
	command SYS_SFX_AMY_GIGGLE,   PlayAmyGiggleSfx
	command SYS_SFX_AMY_YELP,     PlayAmyYelpSfx
	command SYS_SFX_STOMP,        PlayStompSfx
	command SYS_SFX_BUMPER,       PlayBumperSfx
	command SYS_SONG_PAST,        PlayPastSong
	command SYS_DA_GARDEN,        LoadDaGarden
	command SYS_PCM_FADE,         FadeOutPcm
	command SYS_PCM_STOP,         StopPcm,                
	command SYS_DEMO_11A,         LoadStage
	command SYS_VISUAL_MODE,      LoadVisualMode
	command SYS_SPECIAL_INIT,     InitSpecialStageFlags
	command SYS_BURAM_READ,       ReadBuramSaveData,      
	command SYS_BURAM_WRITE,      WriteBuramSaveData
	command SYS_BURAM_INIT,       LoadBuramInit
	command SYS_SPECIAL_RESET,    ResetSpecialStageFlags
	command SYS_TEMP_READ,        ReadTempSaveData
	command SYS_TEMP_WRITE,       WriteTempSaveData,      
	command SYS_THANKS,           LoadThankYou
	command SYS_BURAM_MANAGER,    LoadBuramManager
	command SYS_VOLUME_RESET,     ResetCddaVolumeCmd
	command SYS_PCM_PAUSE,        PausePcm,               
	command SYS_PCM_UNPAUSE,      UnpausePcm
	command SYS_SFX_BREAK,        PlayBreakSfx
	command SYS_BAD_END,          LoadBadEnding
	command SYS_GOOD_END,         LoadGoodEnding
	command SYS_TEST_R1A,         TestRound1ASong
	command SYS_TEST_R1C,         TestRound1CSong
	command SYS_TEST_R1D,         TestRound1DSong
	command SYS_TEST_R3A,         TestRound3ASong
	command SYS_TEST_R3C,         TestRound3CSong
	command SYS_TEST_R3D,         TestRound3DSong
	command SYS_TEST_R4A,         TestRound4ASong
	command SYS_TEST_R4C,         TestRound4CSong
	command SYS_TEST_R4D,         TestRound4DSong
	command SYS_TEST_R5A,         TestRound5ASong
	command SYS_TEST_R5C,         TestRound5CSong
	command SYS_TEST_R5D,         TestRound5DSong
	command SYS_TEST_R6A,         TestRound6ASong
	command SYS_TEST_R6C,         TestRound6CSong
	command SYS_TEST_R6D,         TestRound6DSong
	command SYS_TEST_R7A,         TestRound7ASong
	command SYS_TEST_R7C,         TestRound7CSong
	command SYS_TEST_R7D,         TestRound7DSong
	command SYS_TEST_R8A,         TestRound8ASong
	command SYS_TEST_R8C,         TestRound8CSong
	command SYS_TEST_R8D,         TestRound8DSong
	command SYS_TEST_BOSS,        TestBossSong
	command SYS_TEST_FINAL,       TestFinalSong
	command SYS_TEST_TITLE,       TestTitleSong
	command SYS_TEST_TIME_ATTACK, TestTimeAttackSong
	command SYS_TEST_RESULTS,     TestResultsSong
	command SYS_TEST_SPEED_SHOES, TestSpeedShoesSong
	command SYS_TEST_INVINCIBLE,  TestInvincibleSong
	command SYS_TEST_GAME_OVER,   TestGameOverSong
	command SYS_TEST_SPECIAL,     TestSpecialStageSong
	command SYS_TEST_DA_GARDEN,   TestDaGardenSong
	command SYS_TEST_PROTO_WARP,  TestProtoWarpSound
	command SYS_TEST_OPENING,     TestOpeningSong
	command SYS_TEST_ENDING,      TestEndingSong
	command SYS_TEST_FUTURE,      TestFutureVoiceSfx
	command SYS_TEST_PAST,        TestPastVoiceSfx
	command SYS_TEST_ALRIGHT,     TestAlrightSfx
	command SYS_TEST_OUTTA_HERE,  TestOuttaHereSfx
	command SYS_TEST_YES,         TestYesSfx
	command SYS_TEST_YEAH,        TestYeahSfx
	command SYS_TEST_AMY_GIGGLE,  TestAmyGiggleSfx
	command SYS_TEST_AMY_YELP,    TestAmyYelpSfx
	command SYS_TEST_STOMP,       TestStompSfx
	command SYS_TEST_BUMPER,      TestBumperSfx
	command SYS_TEST_R1B,         TestRound1BSong
	command SYS_TEST_R3B,         TestRound3BSong
	command SYS_TEST_R4B,         TestRound4BSong
	command SYS_TEST_R5B,         TestRound5BSong
	command SYS_TEST_R6B,         TestRound6BSong
	command SYS_TEST_R7B,         TestRound7BSong
	command SYS_TEST_R8B,         TestRound8BSong
	command SYS_FUN_IS_INFINITE,  LoadFunIsInfinite,      
	command SYS_SPECIAL_8_END,    LoadSpecialStage8End
	command SYS_MC_SONIC,         LoadMcSonic
	command SYS_TAILS,            LoadTails
	command SYS_BATMAN,           LoadBatman
	command SYS_CUTE_SONIC,       LoadCuteSonic
	command SYS_STAFF_TIMES,      LoadBestStaffTimes
	command SYS_DUMMY_1,          LoadDummyFile1
	command SYS_DUMMY_2,          LoadDummyFile2
	command SYS_DUMMY_3,          LoadDummyFile3
	command SYS_DUMMY_4,          LoadDummyFile4
	command SYS_DUMMY_5,          LoadDummyFile5
	command SYS_PENCIL_TEST,      LoadPencilTest
	command SYS_CDDA_PAUSE,       PauseCdda
	command SYS_CDDA_UNPAUSE,     UnpauseCdda
	command SYS_OPENING,          LoadOpening
	command SYS_COMIN_SOON,       LoadCominSoon
CommandsEnd:

; ------------------------------------------------------------------------------
