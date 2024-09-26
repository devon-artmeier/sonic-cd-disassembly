; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; System program extension
; ------------------------------------------------------------------------------

	include	"_Include/Common.i"
	include	"_Include/Sub CPU.i"
	include	"_Include/System.i"
	include	"_Include/Backup RAM.i"
	include	"_Include/Sound.i"
	include	"Sound Drivers/PCM/_Variables.i"
	include	"Special Stage/_Global Variables.i"
	include	"DA Garden/Track Title Labels.i"
	
; ------------------------------------------------------------------------------
; Define a file name
; ------------------------------------------------------------------------------
; PARAMETERS:
;	id   - ID constant name
;	name - File name
; ------------------------------------------------------------------------------

__file_id = 0
fileName macro id, name
	dc.b	\name, 0
	; Hack to get the constant name listed in the symbol file
	obj __file_id
\id\: 
	__file_id: = __file_id+1
	objend
	endm

; ------------------------------------------------------------------------------
; Define a command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	id   - ID constant name
;	name - Command name
; ------------------------------------------------------------------------------

__command_id = 1
command macro id, name
	dc.w	(\name)-Commands
	; Hack to get the constant name listed in the symbol file
	obj __command_id
\id\: 
	__command_id: = __command_id+1
	objend
	endm

; ------------------------------------------------------------------------------
; File name table
; ------------------------------------------------------------------------------

	org Spx
Round11AFile:		fileName FILE_ROUND_11A,        "R11A__.MMD;1"
Round11BFile:		fileName FILE_ROUND_11B,        "R11B__.MMD;1"
Round11CFile:		fileName FILE_ROUND_11C,        "R11C__.MMD;1"
Round11DFile:		fileName FILE_ROUND_11D,        "R11D__.MMD;1"
MdInitFile:		fileName FILE_MD_INIT,          "MDINIT.MMD;1"
SoundTestFile:		fileName FILE_SOUND_TEST,       "SOSEL_.MMD;1"
StageSelectFile:	fileName FILE_STAGE_SELECT,     "STSEL_.MMD;1"
Round12AFile:		fileName FILE_ROUND_12A,        "R12A__.MMD;1"
Round12BFile:		fileName FILE_ROUND_12B,        "R12B__.MMD;1"
Round12CFile:		fileName FILE_ROUND_12C,        "R12C__.MMD;1"
Round12DFile:		fileName FILE_ROUND_12D,        "R12D__.MMD;1"
TitleMainFile:		fileName FILE_TITLE_MAIN,       "TITLEM.MMD;1"
TitleSubFile:		fileName FILE_TITLE_SUB,        "TITLES.BIN;1"
WarpFile:		fileName FILE_WARP,             "WARP__.MMD;1"
TimeAttackMainFile:	fileName FILE_TIME_ATTACK_MAIN, "ATTACK.MMD;1"
TimeAttackSubFile:	fileName FILE_TIME_ATTACK_SUB,  "ATTACK.BIN;1"
IpxFile:		fileName FILE_IPX,              "IPX___.MMD;1"
PencilStmFile:		fileName FILE_PENCIL_STM,       "PTEST.STM;1 "
OpeningStmFile:		fileName FILE_OPENING_STM,      "OPN.STM;1   "
BadEndingStmFile:	fileName FILE_BAD_END_STM,      "BADEND.STM;1"
GoodEndingStmFile:	fileName FILE_GOOD_END_STM,     "GOODEND.STM;1"
OpeningMainFile:	fileName FILE_OPENING_MAIN,     "OPEN_M.MMD;1"
OpeningSubFile:		fileName FILE_OPENING_SUB,      "OPEN_S.BIN;1"
CominSoonFile:		fileName FILE_COMIN_SOON,       "COME__.MMD;1"
DaGardenMainFile:	fileName FILE_DA_GARDEN_MAIN,   "PLANET_M.MMD;1"
DaGardenSubFile:	fileName FILE_DA_GARDEN_SUB,    "PLANET_S.BIN;1"
Round31AFile:		fileName FILE_ROUND_31A,        "R31A__.MMD;1"
Round31BFile:		fileName FILE_ROUND_31B,        "R31B__.MMD;1"
Round31CFile:		fileName FILE_ROUND_31C,        "R31C__.MMD;1"
Round31DFile:		fileName FILE_ROUND_31D,        "R31D__.MMD;1"
Round32AFile:		fileName FILE_ROUND_32A,        "R32A__.MMD;1"
Round32BFile:		fileName FILE_ROUND_32B,        "R32B__.MMD;1"
Round32CFile:		fileName FILE_ROUND_32C,        "R32C__.MMD;1"
Round32DFile:		fileName FILE_ROUND_32D,        "R32D__.MMD;1"
Round33CFile:		fileName FILE_ROUND_33C,        "R33C__.MMD;1"
Round33DFile:		fileName FILE_ROUND_33D,        "R33D__.MMD;1"
Round13CFile:		fileName FILE_ROUND_13C,        "R13C__.MMD;1"
Round13DFile:		fileName FILE_ROUND_13D,        "R13D__.MMD;1"
Round41AFile:		fileName FILE_ROUND_41A,        "R41A__.MMD;1"
Round41BFile:		fileName FILE_ROUND_41B,        "R41B__.MMD;1"
Round41CFile:		fileName FILE_ROUND_41C,        "R41C__.MMD;1"
Round41DFile:		fileName FILE_ROUND_41D,        "R41D__.MMD;1"
Round42AFile:		fileName FILE_ROUND_42A,        "R42A__.MMD;1"
Round42BFile:		fileName FILE_ROUND_42B,        "R42B__.MMD;1"
Round42CFile:		fileName FILE_ROUND_42C,        "R42C__.MMD;1"
Round42DFile:		fileName FILE_ROUND_42D,        "R42D__.MMD;1"
Round43CFile:		fileName FILE_ROUND_43C,        "R43C__.MMD;1"
Round43DFile:		fileName FILE_ROUND_43D,        "R43D__.MMD;1"
Round51AFile:		fileName FILE_ROUND_51A,        "R51A__.MMD;1"
Round51BFile:		fileName FILE_ROUND_51B,        "R51B__.MMD;1"
Round51CFile:		fileName FILE_ROUND_51C,        "R51C__.MMD;1"
Round51DFile:		fileName FILE_ROUND_51D,        "R51D__.MMD;1"
Round52AFile:		fileName FILE_ROUND_52A,        "R52A__.MMD;1"
Round52BFile:		fileName FILE_ROUND_52B,        "R52B__.MMD;1"
Round52CFile:		fileName FILE_ROUND_52C,        "R52C__.MMD;1"
Round52DFile:		fileName FILE_ROUND_52D,        "R52D__.MMD;1"
Round53CFile:		fileName FILE_ROUND_53C,        "R53C__.MMD;1"
Round53DFile:		fileName FILE_ROUND_53D,        "R53D__.MMD;1"
Round61AFile:		fileName FILE_ROUND_61A,        "R61A__.MMD;1"
Round61BFile:		fileName FILE_ROUND_61B,        "R61B__.MMD;1"
Round61CFile:		fileName FILE_ROUND_61C,        "R61C__.MMD;1"
Round61DFile:		fileName FILE_ROUND_61D,        "R61D__.MMD;1"
Round62AFile:		fileName FILE_ROUND_62A,        "R62A__.MMD;1"
Round62BFile:		fileName FILE_ROUND_62B,        "R62B__.MMD;1"
Round62CFile:		fileName FILE_ROUND_62C,        "R62C__.MMD;1"
Round62DFile:		fileName FILE_ROUND_62D,        "R62D__.MMD;1"
Round63CFile:		fileName FILE_ROUND_63C,        "R63C__.MMD;1"
Round63DFile:		fileName FILE_ROUND_63D,        "R63D__.MMD;1"
Round71AFile:		fileName FILE_ROUND_71A,        "R71A__.MMD;1"
Round71BFile:		fileName FILE_ROUND_71B,        "R71B__.MMD;1"
Round71CFile:		fileName FILE_ROUND_71C,        "R71C__.MMD;1"
Round71DFile:		fileName FILE_ROUND_71D,        "R71D__.MMD;1"
Round72AFile:		fileName FILE_ROUND_72A,        "R72A__.MMD;1"
Round72BFile:		fileName FILE_ROUND_72B,        "R72B__.MMD;1"
Round72CFile:		fileName FILE_ROUND_72C,        "R72C__.MMD;1"
Round72DFile:		fileName FILE_ROUND_72D,        "R72D__.MMD;1"
Round73CFile:		fileName FILE_ROUND_73C,        "R73C__.MMD;1"
Round73DFile:		fileName FILE_ROUND_73D,        "R73D__.MMD;1"
Round81AFile:		fileName FILE_ROUND_81A,        "R81A__.MMD;1"
Round81BFile:		fileName FILE_ROUND_81B,        "R81B__.MMD;1"
Round81CFile:		fileName FILE_ROUND_81C,        "R81C__.MMD;1"
Round81DFile:		fileName FILE_ROUND_81D,        "R81D__.MMD;1"
Round82AFile:		fileName FILE_ROUND_82A,        "R82A__.MMD;1"
Round82BFile:		fileName FILE_ROUND_82B,        "R82B__.MMD;1"
Round82CFile:		fileName FILE_ROUND_82C,        "R82C__.MMD;1"
Round82DFile:		fileName FILE_ROUND_82D,        "R82D__.MMD;1"
Round83CFile:		fileName FILE_ROUND_83C,        "R83C__.MMD;1"
Round83DFile:		fileName FILE_ROUND_83D,        "R83D__.MMD;1"
SpecialStageMainFile:	fileName FILE_SPECIAL_MAIN,     "SPMM__.MMD;1"
SpecialStageSubFile:	fileName FILE_SPECIAL_SUB,      "SPSS__.BIN;1"
PcmDriverR1BFile:	fileName FILE_PCM_1B,           "SNCBNK1B.BIN;1"
PcmDriverR3BFile:	fileName FILE_PCM_3B,           "SNCBNK3B.BIN;1"
PcmDriverR4BFile:	fileName FILE_PCM_4B,           "SNCBNK4B.BIN;1"
PcmDriverR5BFile:	fileName FILE_PCM_5B,           "SNCBNK5B.BIN;1"
PcmDriverR6BFile:	fileName FILE_PCM_6B,           "SNCBNK6B.BIN;1"
PcmDriverR7BFile:	fileName FILE_PCM_7B,           "SNCBNK7B.BIN;1"
PcmDriverR8BFile:	fileName FILE_PCM_8B,           "SNCBNK8B.BIN;1"
PcmDriverBoss:		fileName FILE_PCM_BOSS,         "SNCBNKB1.BIN;1"
PcmDriverFinal:		fileName FILE_PCM_FINAL,        "SNCBNKB2.BIN;1"
DaGardenDataFile:	fileName FILE_PLANET_DATA,      "PLANET_D.BIN;1"
Demo11AFile:		fileName FILE_DEMO_11A,         "DEMO11A.MMD;1"
VisualModeFile:		fileName FILE_VISUAL_MODE,      "VM____.MMD;1"
BuramInitFile:		fileName FILE_BURAM_INIT,       "BRAMINIT.MMD;1"
BuramSubFile:		fileName FILE_BURAM_SUB,        "BRAMSUB.BIN;1"
BuramMainFile:		fileName FILE_BURAM_MAIN,       "BRAMMAIN.MMD;1"
ThankYouMainFile:	fileName FILE_THANKS_MAIN,      "THANKS_M.MMD;1"
ThankYouSubFile:	fileName FILE_THANKS_SUB,       "THANKS_S.BIN;1"
ThankYouDataFile:	fileName FILE_THANKS_DATA,      "THANKS_D.BIN;1"
EndingMainFile:		fileName FILE_ENDING_MAIN,      "ENDING.MMD;1"
BadEndingSubFile:	fileName FILE_BAD_END_SUB,      "GOODEND.BIN;1" 
GoodEndingSubFile:	fileName FILE_GOOD_END_SUB,     "BADEND.BIN;1" 
FunIsInfiniteFile:	fileName FILE_FUN_IS_INFINITE,  "NISI.MMD;1"
Special8EndFile:	fileName FILE_SPECIAL_8_END,    "SPEEND.MMD;1"
McSonicFile:		fileName FILE_MC_SONIC,         "DUMMY0.MMD;1"
TailsFile:		fileName FILE_TAILS,            "DUMMY1.MMD;1"
BatmanSonicFile:	fileName FILE_BATMAN,           "DUMMY2.MMD;1"
CuteSonicFile:		fileName FILE_CUTE_SONIC,       "DUMMY3.MMD;1"
BestStaffTimesFile:	fileName FILE_STAFF_TIMES,      "DUMMY4.MMD;1"
DummyFile5:		fileName FILE_DUMMY_5,          "DUMMY5.MMD;1"
DummyFile6:		fileName FILE_DUMMY_6,          "DUMMY6.MMD;1"
DummyFile7:		fileName FILE_DUMMY_7,          "DUMMY7.MMD;1"
DummyFile8:		fileName FILE_DUMMY_8,          "DUMMY8.MMD;1"
DummyFile9:		fileName FILE_DUMMY_9,          "DUMMY9.MMD;1"
PencilTestMainFile:	fileName FILE_PENCIL_MAIN,      "PTEST.MMD;1"
PencilTestSubFile:	fileName FILE_PENCIL_SUB,       "PTEST.BIN;1"
Demo43CFile:		fileName FILE_DEMO_43C,         "DEMO43C.MMD;1"
Demo82AFile:		fileName FILE_DEMO_82A,         "DEMO82A.MMD;1"
	even

; ------------------------------------------------------------------------------
; Backup RAM read parameters
; ------------------------------------------------------------------------------

BuramReadParams:
	dc.b	"SONICCD____"
	even

; ------------------------------------------------------------------------------
; Backup RAM write parameters
; ------------------------------------------------------------------------------

BuramWriteParams:
	dc.b	"SONICCD____"
	dc.b	0
	dc.w	$B

; ------------------------------------------------------------------------------
; System program extension start
; ------------------------------------------------------------------------------

	align SpxStart
	lea	SpVariables,a0					; Clear variables
	move.w	#SP_VARIABLES_SIZE/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars

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
	command SCMD_ROUND_11A,        LoadStage
	command SCMD_ROUND_11B,        LoadStage
	command SCMD_ROUND_11C,        LoadStage
	command SCMD_ROUND_11D,        LoadStage
	command SCMD_MD_INIT,          LoadMegaDriveInit,      
	command SCMD_STAGE_SELECT,     LoadStageSelect
	command SCMD_ROUND_12A,        LoadStage
	command SCMD_ROUND_12B,        LoadStage
	command SCMD_ROUND_12C,        LoadStage
	command SCMD_ROUND_12D,        LoadStage
	command SCMD_TITLE,            LoadTitleScreen
	command SCMD_WARP,             LoadWarp,               
	command SCMD_TIME_ATTACK,      LoadTimeAttack
	command SCMD_FADE_CDDA,        FadeOutCdda
	command SCMD_SONG_1A,          PlayRound1ASong
	command SCMD_SONG_1C,          PlayRound1BSong
	command SCMD_SONG_1D,          PlayRound1DSong
	command SCMD_SONG_3A,          PlayRound3ASong
	command SCMD_SONG_3C,          PlayRound3CSong
	command SCMD_SONG_3D,          PlayRound3DSong
	command SCMD_SONG_4A,          PlayRound4ASong
	command SCMD_SONG_4C,          PlayRound4CSong
	command SCMD_SONG_4D,          PlayRound4DSong
	command SCMD_SONG_5A,          PlayRound5ASong
	command SCMD_SONG_5C,          PlayRound5CSong
	command SCMD_SONG_5D,          PlayRound5DSong
	command SCMD_SONG_6A,          PlayRound6ASong
	command SCMD_SONG_6C,          PlayRound6CSong
	command SCMD_SONG_6D,          PlayRound6DSong
	command SCMD_SONG_7A,          PlayRound7ASong
	command SCMD_SONG_7C,          PlayRound7CSong
	command SCMD_SONG_7D,          PlayRound7DSong
	command SCMD_SONG_8A,          PlayRound8ASong
	command SCMD_SONG_8C,          PlayRound8CSong
	command SCMD_IPX,              LoadIpx,                
	command SCMD_DEMO_43C,         LoadStage
	command SCMD_DEMO_82A,         LoadStage
	command SCMD_SOUND_TEST,       LoadSoundTest
	command SCMD_INVALID,          LoadStage
	command SCMD_ROUND_31A,        LoadStage
	command SCMD_ROUND_31B,        LoadStage
	command SCMD_ROUND_31C,        LoadStage
	command SCMD_ROUND_31D,        LoadStage
	command SCMD_ROUND_32A,        LoadStage
	command SCMD_ROUND_32B,        LoadStage
	command SCMD_ROUND_32C,        LoadStage
	command SCMD_ROUND_32D,        LoadStage
	command SCMD_ROUND_33C,        LoadStage
	command SCMD_ROUND_33D,        LoadStage
	command SCMD_ROUND_13C,        LoadStage
	command SCMD_ROUND_13D,        LoadStage
	command SCMD_ROUND_41A,        LoadStage
	command SCMD_ROUND_41B,        LoadStage
	command SCMD_ROUND_41C,        LoadStage
	command SCMD_ROUND_41D,        LoadStage
	command SCMD_ROUND_42A,        LoadStage
	command SCMD_ROUND_42B,        LoadStage
	command SCMD_ROUND_42C,        LoadStage
	command SCMD_ROUND_42D,        LoadStage
	command SCMD_ROUND_43C,        LoadStage
	command SCMD_ROUND_43D,        LoadStage
	command SCMD_ROUND_51A,        LoadStage
	command SCMD_ROUND_51B,        LoadStage
	command SCMD_ROUND_51C,        LoadStage
	command SCMD_ROUND_51D,        LoadStage
	command SCMD_ROUND_52A,        LoadStage
	command SCMD_ROUND_52B,        LoadStage
	command SCMD_ROUND_52C,        LoadStage
	command SCMD_ROUND_52D,        LoadStage
	command SCMD_ROUND_53C,        LoadStage
	command SCMD_ROUND_53D,        LoadStage
	command SCMD_ROUND_61A,        LoadStage
	command SCMD_ROUND_61B,        LoadStage
	command SCMD_ROUND_61C,        LoadStage
	command SCMD_ROUND_61D,        LoadStage
	command SCMD_ROUND_62A,        LoadStage
	command SCMD_ROUND_62B,        LoadStage
	command SCMD_ROUND_62C,        LoadStage
	command SCMD_ROUND_62D,        LoadStage
	command SCMD_ROUND_63C,        LoadStage
	command SCMD_ROUND_63D,        LoadStage
	command SCMD_ROUND_71A,        LoadStage
	command SCMD_ROUND_71B,        LoadStage
	command SCMD_ROUND_71C,        LoadStage
	command SCMD_ROUND_71D,        LoadStage
	command SCMD_ROUND_72A,        LoadStage
	command SCMD_ROUND_72B,        LoadStage
	command SCMD_ROUND_72C,        LoadStage
	command SCMD_ROUND_72D,        LoadStage
	command SCMD_ROUND_73C,        LoadStage
	command SCMD_ROUND_73D,        LoadStage
	command SCMD_ROUND_81A,        LoadStage
	command SCMD_ROUND_81B,        LoadStage
	command SCMD_ROUND_81C,        LoadStage
	command SCMD_ROUND_81D,        LoadStage
	command SCMD_ROUND_82A,        LoadStage
	command SCMD_ROUND_82B,        LoadStage
	command SCMD_ROUND_82C,        LoadStage
	command SCMD_ROUND_82D,        LoadStage
	command SCMD_ROUND_83C,        LoadStage
	command SCMD_ROUND_83D,        LoadStage
	command SCMD_SONG_8D,          PlayRound8DSong
	command SCMD_SONG_BOSS,        PlayBossSong
	command SCMD_SONG_FINAL,       PlayFinalBossSong,      
	command SCMD_SONG_TITLE,       PlayTitleSong
	command SCMD_SONG_TIME_ATTACK, PlayTimeAttackSong
	command SCMD_SONG_RESULTS,     PlayResultsSong
	command SCMD_SONG_SPEED_SHOES, PlaySpeedShoesSong
	command SCMD_SONG_INVINCIBLE,  PlayInvincibleSong
	command SCMD_SONG_GAME_OVER,   PlayGameOverSong
	command SCMD_SONG_SPECIAL,     PlaySpecialStageSong
	command SCMD_SONG_DA_GARDEN,   PlayDaGardenSong
	command SCMD_SFX_PROTO_WARP,   PlayProtoWarpSound
	command SCMD_SONG_OPENING,     PlayOpeningSong
	command SCMD_SONG_ENDING,      PlayEndingSong
	command SCMD_CDDA_STOP,        StopCdda,               
	command SCMD_SPECIAL_STAGE,    LoadSpecialStage
	command SCMD_SFX_FUTURE,       PlayFutureVoiceSfx
	command SCMD_SFX_PAST,         PlayPastVoiceSfx
	command SCMD_SFX_ALRIGHT,      PlayAlrightSfx
	command SCMD_SFX_OUTTA_HERE,   PlayGiveUpSfx
	command SCMD_SFX_YES,          PlayYesSfx
	command SCMD_SFX_YEAH,         PlayYeahSfx
	command SCMD_SFX_AMY_GIGGLE,   PlayAmyGiggleSfx
	command SCMD_SFX_AMY_YELP,     PlayAmyYelpSfx
	command SCMD_SFX_STOMP,        PlayStompSfx
	command SCMD_SFX_BUMPER,       PlayBumperSfx
	command SCMD_SONG_PAST,        PlayPastSong
	command SCMD_DA_GARDEN,        LoadDaGarden
	command SCMD_PCM_FADE,         FadeOutPcm
	command SCMD_PCM_STOP,         StopPcm,                
	command SCMD_DEMO_11A,         LoadStage
	command SCMD_VISUAL_MODE,      LoadVisualMode
	command SCMD_SPECIAL_INIT,     InitSpecialStageFlags
	command SCMD_BURAM_READ,       ReadBuramSaveData,      
	command SCMD_BURAM_WRITE,      WriteBuramSaveData
	command SCMD_BURAM_INIT,       LoadBuramInit
	command SCMD_SPECIAL_RESET,    ResetSpecialStageFlags
	command SCMD_TEMP_READ,        ReadTempSaveData
	command SCMD_TEMP_WRITE,       WriteTempSaveData,      
	command SCMD_THANKS,           LoadThankYou
	command SCMD_BURAM_MANAGER,    LoadBuramManager
	command SCMD_VOLUME_RESET,     ResetCddaVolumeCmd
	command SCMD_PCM_PAUSE,        PausePcm,               
	command SCMD_PCM_UNPAUSE,      UnpausePcm
	command SCMD_SFX_BREAK,        PlayBreakSfx
	command SCMD_BAD_END,          LoadBadEnding
	command SCMD_GOOD_END,         LoadGoodEnding
	command SCMD_TEST_R1A,         TestRound1ASong
	command SCMD_TEST_R1C,         TestRound1CSong
	command SCMD_TEST_R1D,         TestRound1DSong
	command SCMD_TEST_R3A,         TestRound3ASong
	command SCMD_TEST_R3C,         TestRound3CSong
	command SCMD_TEST_R3D,         TestRound3DSong
	command SCMD_TEST_R4A,         TestRound4ASong
	command SCMD_TEST_R4C,         TestRound4CSong
	command SCMD_TEST_R4D,         TestRound4DSong
	command SCMD_TEST_R5A,         TestRound5ASong
	command SCMD_TEST_R5C,         TestRound5CSong
	command SCMD_TEST_R5D,         TestRound5DSong
	command SCMD_TEST_R6A,         TestRound6ASong
	command SCMD_TEST_R6C,         TestRound6CSong
	command SCMD_TEST_R6D,         TestRound6DSong
	command SCMD_TEST_R7A,         TestRound7ASong
	command SCMD_TEST_R7C,         TestRound7CSong
	command SCMD_TEST_R7D,         TestRound7DSong
	command SCMD_TEST_R8A,         TestRound8ASong
	command SCMD_TEST_R8C,         TestRound8CSong
	command SCMD_TEST_R8D,         TestRound8DSong
	command SCMD_TEST_BOSS,        TestBossSong
	command SCMD_TEST_FINAL,       TestFinalSong
	command SCMD_TEST_TITLE,       TestTitleSong
	command SCMD_TEST_TIME_ATTACK, TestTimeAttackSong
	command SCMD_TEST_RESULTS,     TestResultsSong
	command SCMD_TEST_SPEED_SHOES, TestSpeedShoesSong
	command SCMD_TEST_INVINCIBLE,  TestInvincibleSong
	command SCMD_TEST_GAME_OVER,   TestGameOverSong
	command SCMD_TEST_SPECIAL,     TestSpecialStageSong
	command SCMD_TEST_DA_GARDEN,   TestDaGardenSong
	command SCMD_TEST_PROTO_WARP,  TestProtoWarpSound
	command SCMD_TEST_OPENING,     TestOpeningSong
	command SCMD_TEST_ENDING,      TestEndingSong
	command SCMD_TEST_FUTURE,      TestFutureVoiceSfx
	command SCMD_TEST_PAST,        TestPastVoiceSfx
	command SCMD_TEST_ALRIGHT,     TestAlrightSfx
	command SCMD_TEST_OUTTA_HERE,  TestGiveUpSfx
	command SCMD_TEST_YES,         TestYesSfx
	command SCMD_TEST_YEAH,        TestYeahSfx
	command SCMD_TEST_AMY_GIGGLE,  TestAmyGiggleSfx
	command SCMD_TEST_AMY_YELP,    TestAmyYelpSfx
	command SCMD_TEST_STOMP,       TestStompSfx
	command SCMD_TEST_BUMPER,      TestBumperSfx
	command SCMD_TEST_R1B,         TestRound1BSong
	command SCMD_TEST_R3B,         TestRound3BSong
	command SCMD_TEST_R4B,         TestRound4BSong
	command SCMD_TEST_R5B,         TestRound5BSong
	command SCMD_TEST_R6B,         TestRound6BSong
	command SCMD_TEST_R7B,         TestRound7BSong
	command SCMD_TEST_R8B,         TestRound8BSong
	command SCMD_FUN_IS_INFINITE,  LoadFunIsInfinite,      
	command SCMD_SPECIAL_8_END,    LoadSpecialStage8End
	command SCMD_MC_SONIC,         LoadMcSonic
	command SCMD_TAILS,            LoadTails
	command SCMD_BATMAN,           LoadBatman
	command SCMD_CUTE_SONIC,       LoadCuteSonic
	command SCMD_STAFF_TIMES,      LoadBestStaffTimes
	command SCMD_DUMMY_1,          LoadDummyFile1
	command SCMD_DUMMY_2,          LoadDummyFile2
	command SCMD_DUMMY_3,          LoadDummyFile3
	command SCMD_DUMMY_4,          LoadDummyFile4
	command SCMD_DUMMY_5,          LoadDummyFile5
	command SCMD_PENCIL_TEST,      LoadPencilTest
	command SCMD_CDDA_PAUSE,       PauseCdda
	command SCMD_CDDA_UNPAUSE,     UnpauseCdda
	command SCMD_OPENING,          LoadOpening
	command SCMD_COMIN_SOON,       LoadCominSoon
CommandsEnd:

; ------------------------------------------------------------------------------
; Load pencil test FMV
; ------------------------------------------------------------------------------

LoadPencilTest:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	lea	PencilTestMainFile(pc),a0			; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	PencilTestSubFile(pc),a0			; Load Sub CPU file
	lea	PRG_RAM+$30000,a1
	jsr	LoadFile

	jsr	PRG_RAM+$30000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	andi.b	#~(MCDR_RET|MCDR_MODE),MCD_MEM_MODE		; Set to 2M mode
	move.b	#MCDR_CDC_SUB_READ,MCD_CDC_DEVICE		; Set CDC device to "Sub CPU"
	move.l	#0,cur_pcm_driver				; Reset current PCM driver
	rts

; ------------------------------------------------------------------------------
; Load Backup RAM manager
; ------------------------------------------------------------------------------

LoadBuramManager:
	lea	BuramMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	BuramSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	rts

; ------------------------------------------------------------------------------
; Load "Thank You" screen
; ------------------------------------------------------------------------------

LoadThankYou:
	bsr.w	WaitWordRamAccess				; Load Main CPU file
	lea	ThankYouMainFile(pc),a0
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	lea	ThankYouDataFile(pc),a0				; Load data file
	lea	WORD_RAM_2M+$10000,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	ThankYouSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	rts

; ------------------------------------------------------------------------------
; Reset special stage flags
; ------------------------------------------------------------------------------

ResetSpecialStageFlags:
	moveq	#0,d0
	move.b	d0,time_stones_sub				; Reset time stones retrieved
	move.b	d0,special_stage_id				; Reset stage ID
	move.l	d0,special_stage_timer				; Reset timer
	move.w	d0,special_stage_rings				; Reset rings
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Reset special stage flags
; ------------------------------------------------------------------------------

InitSpecialStageFlags:
	moveq	#0,d0
	move.b	d0,time_stones_sub				; Reset time stones retrieved
	move.b	d0,special_stage_id				; Reset stage ID
	move.l	d0,special_stage_timer				; Reset timer
	move.w	d0,special_stage_rings				; Reset rings
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Load Backup RAM initialization
; ------------------------------------------------------------------------------

LoadBuramInit:
	lea	BuramInitFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	BuramSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	rts

; ------------------------------------------------------------------------------
; Read save data
; ------------------------------------------------------------------------------

ReadBuramSaveData:
	lea	BuramScratch(pc),a0				; Initialize Backup RAM interaction
	lea	BuramStrings(pc),a1
	move.w	#BRMINIT,d0
	jsr	_BURAM

.ReadData:
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	lea	BuramReadParams(pc),a0				; Load save data
	lea	WORD_RAM_2M,a1
	move.w	#BRMREAD,d0
	jsr	_BURAM
	bcs.s	.ReadData					; If it failed, try again

	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
; Write save data
; ------------------------------------------------------------------------------

WriteBuramSaveData:
	lea	BuramScratch(pc),a0				; Initialize Backup RAM interaction
	lea	BuramStrings(pc),a1
	move.w	#BRMINIT,d0
	jsr	_BURAM

.WriteData:
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	lea	BuramWriteParams(pc),a0				; Write save data
	lea	WORD_RAM_2M,a1
	move.w	#BRMWRITE,d0
	moveq	#0,d1
	jsr	_BURAM
	bcs.s	.WriteData					; If it failed, try again
	
	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
; Read temporary save data
; ------------------------------------------------------------------------------

ReadTempSaveData:
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	lea	TempSaveData,a0					; Copy from temporary save data buffer
	lea	WORD_RAM_2M,a1
	move.w	#save.struct_size/4-1,d7

.Read:
	move.l	(a0)+,(a1)+
	dbf	d7,.Read

	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
; Write temporary save data
; ------------------------------------------------------------------------------

WriteTempSaveData:
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	lea	TempSaveData,a0					; Copy to temporary save data buffer
	lea	WORD_RAM_2M,a1
	move.w	#save.struct_size/4-1,d7

.Write:
	move.l	(a1)+,(a0)+
	dbf	d7,.Write

	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
; Load stage
; ------------------------------------------------------------------------------

LoadStage:
	add.w	d1,d1						; Get stage file based on command ID
	lea	.StageFiles(pc),a1
	move.w	(a1,d1.w),d2
	lea	(a1,d2.w),a0
	move.l	d1,-(sp)

	bsr.w	WaitWordRamAccess				; Load stage file
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	bsr.w	ResetCddaVolume					; Reset CD audio volume
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	move.l	(sp)+,d1					; Get PCM driver file based on command ID
	add.w	d1,d1
	lea	.PcmDrivers(pc),a1
	move.l	cur_pcm_driver,d0
	cmp.l	(a1,d1.w),d0					; Is this PCM driver already loaded?
	beq.s	.Done						; If so, branch

	movea.l	(a1,d1.w),a0					; If not, load it
	move.l	a0,cur_pcm_driver
	lea	PcmDriver,a1
	jsr	LoadFile

.Done:
	bset	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Enable timer interrupt
	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
; Stage files
; ------------------------------------------------------------------------------

.StageFiles:
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Palmtree Panic Act 1 Present
	dc.w	Round11BFile-.StageFiles			; Palmtree Panic Act 1 Past
	dc.w	Round11CFile-.StageFiles			; Palmtree Panic Act 1 Good Future
	dc.w	Round11DFile-.StageFiles			; Palmtree Panic Act 1 Bad Future
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	Round12AFile-.StageFiles			; Palmtree Panic Act 2 Present
	dc.w	Round12BFile-.StageFiles			; Palmtree Panic Act 2 Past
	dc.w	Round12CFile-.StageFiles			; Palmtree Panic Act 2 Good Future
	dc.w	Round12DFile-.StageFiles			; Palmtree Panic Act 2 Bad Future
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	Demo43CFile-.StageFiles				; Tidal Tempest Act 3 Good Future demo
	dc.w	Demo82AFile-.StageFiles				; Metallic Madness Act 2 Present demo
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	Round31AFile-.StageFiles			; Collision Chaos Act 1 Present
	dc.w	Round31BFile-.StageFiles			; Collision Chaos Act 1 Past
	dc.w	Round31CFile-.StageFiles			; Collision Chaos Act 1 Good Future
	dc.w	Round31DFile-.StageFiles			; Collision Chaos Act 1 Bad Future
	dc.w	Round32AFile-.StageFiles			; Collision Chaos Act 2 Present 
	dc.w	Round32BFile-.StageFiles			; Collision Chaos Act 2 Past 
	dc.w	Round32CFile-.StageFiles			; Collision Chaos Act 2 Good Future 
	dc.w	Round32DFile-.StageFiles			; Collision Chaos Act 2 Bad Future 
	dc.w	Round33CFile-.StageFiles			; Collision Chaos Act 3 Good Future 
	dc.w	Round33DFile-.StageFiles			; Collision Chaos Act 3 Bad Future 
	dc.w	Round13CFile-.StageFiles			; Palmtree Panic Act 3 Good Future
	dc.w	Round13DFile-.StageFiles			; Palmtree Panic Act 3 Bad Future 
	dc.w	Round41AFile-.StageFiles			; Tidal Tempest Act 1 Present
	dc.w	Round41BFile-.StageFiles			; Tidal Tempest Act 1 Past
	dc.w	Round41CFile-.StageFiles			; Tidal Tempest Act 1 Good Future
	dc.w	Round41DFile-.StageFiles			; Tidal Tempest Act 1 Bad Future
	dc.w	Round42AFile-.StageFiles			; Tidal Tempest Act 2 Present 
	dc.w	Round42BFile-.StageFiles			; Tidal Tempest Act 2 Past 
	dc.w	Round42CFile-.StageFiles			; Tidal Tempest Act 2 Good Future 
	dc.w	Round42DFile-.StageFiles			; Tidal Tempest Act 2 Bad Future 
	dc.w	Round43CFile-.StageFiles			; Tidal Tempest Act 3 Good Future 
	dc.w	Round43DFile-.StageFiles			; Tidal Tempest Act 3 Bad Future 
	dc.w	Round51AFile-.StageFiles			; Quartz Quadrant Act 1 Present
	dc.w	Round51BFile-.StageFiles			; Quartz Quadrant Act 1 Past
	dc.w	Round51CFile-.StageFiles			; Quartz Quadrant Act 1 Good Future
	dc.w	Round51DFile-.StageFiles			; Quartz Quadrant Act 1 Bad Future
	dc.w	Round52AFile-.StageFiles			; Quartz Quadrant Act 2 Present 
	dc.w	Round52BFile-.StageFiles			; Quartz Quadrant Act 2 Past 
	dc.w	Round52CFile-.StageFiles			; Quartz Quadrant Act 2 Good Future 
	dc.w	Round52DFile-.StageFiles			; Quartz Quadrant Act 2 Bad Future 
	dc.w	Round53CFile-.StageFiles			; Quartz Quadrant Act 3 Good Future 
	dc.w	Round53DFile-.StageFiles			; Quartz Quadrant Act 3 Bad Future 
	dc.w	Round61AFile-.StageFiles			; Wacky Workbench Act 1 Present
	dc.w	Round61BFile-.StageFiles			; Wacky Workbench Act 1 Past
	dc.w	Round61CFile-.StageFiles			; Wacky Workbench Act 1 Good Future
	dc.w	Round61DFile-.StageFiles			; Wacky Workbench Act 1 Bad Future
	dc.w	Round62AFile-.StageFiles			; Wacky Workbench Act 2 Present 
	dc.w	Round62BFile-.StageFiles			; Wacky Workbench Act 2 Past 
	dc.w	Round62CFile-.StageFiles			; Wacky Workbench Act 2 Good Future 
	dc.w	Round62DFile-.StageFiles			; Wacky Workbench Act 2 Bad Future 
	dc.w	Round63CFile-.StageFiles			; Wacky Workbench Act 3 Good Future 
	dc.w	Round63DFile-.StageFiles			; Wacky Workbench Act 3 Bad Future 
	dc.w	Round71AFile-.StageFiles			; Stardust Speedway Act 1 Present
	dc.w	Round71BFile-.StageFiles			; Stardust Speedway Act 1 Past
	dc.w	Round71CFile-.StageFiles			; Stardust Speedway Act 1 Good Future
	dc.w	Round71DFile-.StageFiles			; Stardust Speedway Act 1 Bad Future
	dc.w	Round72AFile-.StageFiles			; Stardust Speedway Act 2 Present 
	dc.w	Round72BFile-.StageFiles			; Stardust Speedway Act 2 Past 
	dc.w	Round72CFile-.StageFiles			; Stardust Speedway Act 2 Good Future 
	dc.w	Round72DFile-.StageFiles			; Stardust Speedway Act 2 Bad Future 
	dc.w	Round73CFile-.StageFiles			; Stardust Speedway Act 3 Good Future 
	dc.w	Round73DFile-.StageFiles			; Stardust Speedway Act 3 Bad Future 
	dc.w	Round81AFile-.StageFiles			; Metallic Madness Act 1 Present
	dc.w	Round81BFile-.StageFiles			; Metallic Madness Act 1 Past
	dc.w	Round81CFile-.StageFiles			; Metallic Madness Act 1 Good Future
	dc.w	Round81DFile-.StageFiles			; Metallic Madness Act 1 Bad Future
	dc.w	Round82AFile-.StageFiles			; Metallic Madness Act 2 Present 
	dc.w	Round82BFile-.StageFiles			; Metallic Madness Act 2 Past 
	dc.w	Round82CFile-.StageFiles			; Metallic Madness Act 2 Good Future 
	dc.w	Round82DFile-.StageFiles			; Metallic Madness Act 2 Bad Future 
	dc.w	Round83CFile-.StageFiles			; Metallic Madness Act 3 Good Future 
	dc.w	Round83DFile-.StageFiles			; Metallic Madness Act 3 Bad Future 
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	Demo11AFile-.StageFiles				; Palmtree Panic Act 1 Present demo
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid
	dc.w	SpxFileNameTable-.StageFiles			; Invalid

; ------------------------------------------------------------------------------
; PCM drivers
; ------------------------------------------------------------------------------

.PcmDrivers:
	dc.l	SpxFileNameTable				; Invalid
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 1 Present
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 1 Past
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 1 Good Future
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 1 Bad Future
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 2 Present
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 2 Past
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 2 Good Future
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 2 Bad Future
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	PcmDriverBoss					; Tidal Tempest Act 3 Good Future demo
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 2 Present demo
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 1 Present
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 1 Past
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 1 Good Future
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 1 Bad Future
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 2 Present 
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 2 Past 
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 2 Good Future 
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 2 Bad Future 
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 3 Good Future 
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 3 Bad Future 
	dc.l	PcmDriverBoss					; Palmtree Panic Act 3 Good Future
	dc.l	PcmDriverBoss					; Palmtree Panic Act 3 Bad Future 
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 1 Present
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 1 Past
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 1 Good Future
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 1 Bad Future
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 2 Present 
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 2 Past 
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 2 Good Future 
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 2 Bad Future 
	dc.l	PcmDriverBoss					; Tidal Tempest Act 3 Good Future 
	dc.l	PcmDriverBoss					; Tidal Tempest Act 3 Bad Future 
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 1 Present
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 1 Past
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 1 Good Future
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 1 Bad Future
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 2 Present 
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 2 Past 
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 2 Good Future 
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 2 Bad Future 
	dc.l	PcmDriverBoss					; Quartz Quadrant Act 3 Good Future 
	dc.l	PcmDriverBoss					; Quartz Quadrant Act 3 Bad Future 
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 1 Present
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 1 Past
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 1 Good Future
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 1 Bad Future
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 2 Present 
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 2 Past 
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 2 Good Future 
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 2 Bad Future 
	dc.l	PcmDriverBoss					; Wacky Workbench Act 3 Good Future 
	dc.l	PcmDriverBoss					; Wacky Workbench Act 3 Bad Future 
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 1 Present
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 1 Past
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 1 Good Future
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 1 Bad Future
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 2 Present 
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 2 Past 
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 2 Good Future 
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 2 Bad Future 
	dc.l	PcmDriverBoss					; Stardust Speedway Act 3 Good Future 
	dc.l	PcmDriverBoss					; Stardust Speedway Act 3 Bad Future 
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 1 Present
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 1 Past
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 1 Good Future
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 1 Bad Future
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 2 Present 
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 2 Past 
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 2 Good Future 
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 2 Bad Future 
	dc.l	PcmDriverBoss					; Metallic Madness Act 3 Good Future 
	dc.l	PcmDriverBoss					; Metallic Madness Act 3 Bad Future 
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 1 Present demo
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid
	dc.l	SpxFileNameTable				; Invalid

; ------------------------------------------------------------------------------
; Load Mega Drive initialization
; ------------------------------------------------------------------------------

LoadMegaDriveInit:
	lea	MdInitFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bra.w	GiveWordRamAccess

; ------------------------------------------------------------------------------
; Load title screen
; ------------------------------------------------------------------------------

LoadTitleScreen:
	lea	TitleMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	lea	TitleSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	bsr.w	GiveWordRamAccess				; Give Main CPU Word RAM access

	bsr.w	ResetCddaVolume					; Play title screen music
	lea	TitleScreenSong(pc),a0
	move.w	#MSCPLAY1,d0
	jsr	_CDBIOS

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	rts

; ------------------------------------------------------------------------------
; Load "Comin' Soon" screen
; ------------------------------------------------------------------------------

LoadCominSoon:
	lea	CominSoonFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bsr.w	ResetCddaVolume					; Play invincibility music
	lea	InvincibleSong(pc),a0
	move.w	#MSCPLAYR,d0
	jmp	_CDBIOS

; ------------------------------------------------------------------------------
; Load special stage 8 credits
; ------------------------------------------------------------------------------

LoadSpecialStage8End:
	lea	Special8EndFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayEndingSong					; Play ending music

; ------------------------------------------------------------------------------
; Load "Fun is infinite" screen
; ------------------------------------------------------------------------------

LoadFunIsInfinite:
	lea	FunIsInfiniteFile(pc),a0			; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayBossSong					; Play boss music

; ------------------------------------------------------------------------------
; Load M.C. Sonic screen
; ------------------------------------------------------------------------------

LoadMcSonic:
	lea	McSonicFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayRound8ASong					; Play Metallic Madness Present music

; ------------------------------------------------------------------------------
; Load Tails screen
; ------------------------------------------------------------------------------

LoadTails:
	lea	TailsFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayDaGardenSong				; Play D.A. Garden music

; ------------------------------------------------------------------------------
; Load Batman Sonic screen
; ------------------------------------------------------------------------------

LoadBatman:
	lea	BatmanSonicFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayFinalBossSong				; Play final boss music

; ------------------------------------------------------------------------------
; Load cute Sonic screen
; ------------------------------------------------------------------------------

LoadCuteSonic:
	lea	CuteSonicFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayRound1BSong					; Play Palmtree Panic Good Future music

; ------------------------------------------------------------------------------
; Load best staff times screen
; ------------------------------------------------------------------------------

LoadBestStaffTimes:
	lea	BestStaffTimesFile(pc),a0			; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	SpeedShoesSong(pc),a0				; Play speed shoes music
	bsr.w	ResetCddaVolume
	move.w	#MSCPLAYR,d0
	jmp	_CDBIOS

; ------------------------------------------------------------------------------
; Load main program
; ------------------------------------------------------------------------------

LoadIpx:
	lea	IpxFile(pc),a0					; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load sound test
; ------------------------------------------------------------------------------

LoadSoundTest:
	lea	SoundTestFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load dummy file (unused)
; ------------------------------------------------------------------------------

LoadDummyFile1:
	lea	McSonicFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load dummy file (unused)
; ------------------------------------------------------------------------------

LoadDummyFile2:
	lea	McSonicFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load dummy file (unused)
; ------------------------------------------------------------------------------

LoadDummyFile3:
	lea	McSonicFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load dummy file (unused)
; ------------------------------------------------------------------------------

LoadDummyFile4:
	lea	McSonicFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load dummy file (unused)
; ------------------------------------------------------------------------------

LoadDummyFile5:
	lea	McSonicFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load stage select
; ------------------------------------------------------------------------------

LoadStageSelect:
	lea	StageSelectFile(pc),a0				; Load file
	
; ------------------------------------------------------------------------------
; Load file into Word RAM
; ------------------------------------------------------------------------------
; PARAMETERS
;	a0.l - Pointer to file name
; ------------------------------------------------------------------------------

LoadFileIntoWordRam:
	bsr.w	WaitWordRamAccess				; Load file into Word RAM
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bra.w	GiveWordRamAccess

; ------------------------------------------------------------------------------
; Load Visual Mode menu
; ------------------------------------------------------------------------------

LoadVisualMode:
	lea	VisualModeFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	bsr.w	ResetCddaVolume					; Play title screen music
	lea	TitleScreenSong(pc),a0
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS

	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
; Load time warp cutscene
; ------------------------------------------------------------------------------

LoadWarp:
	lea	WarpFile(pc),a0					; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bra.w	GiveWordRamAccess

; ------------------------------------------------------------------------------
; Load time attack menu
; ------------------------------------------------------------------------------

LoadTimeAttack:
	lea	TimeAttackMainFile(pc),a0			; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bsr.w	ResetCddaVolume					; Play time attack music
	if REGION=USA
		lea	DaGardenSong(pc),a0
	else
		lea	TimeAttackSong(pc),a0
	endif
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS
	rts

; ------------------------------------------------------------------------------
; Load D.A. Garden
; ------------------------------------------------------------------------------

LoadDaGarden:
	lea	DaGardenMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	lea	DaGardenDataFile(pc),a0				; Load data file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M+DAGrdnTrkTitles,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	DaGardenSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	bsr.w	ResetCddaVolume					; Play D.A. Garden music
	lea	DaGardenSong(pc),a0
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	rts

; ------------------------------------------------------------------------------
; Load opening FMV
; ------------------------------------------------------------------------------

LoadOpening:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	lea	OpeningMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	OpeningSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$30000,a1
	jsr	LoadFile

	jsr	PRG_RAM+$30000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	andi.b	#~(MCDR_RET|MCDR_MODE),MCD_MEM_MODE		; Set to 2M mode
	move.b	#MCDR_CDC_SUB_READ,MCD_CDC_DEVICE		; Set CDC device to "Sub CPU"
	move.l	#0,cur_pcm_driver				; Reset current PCM driver
	rts

; ------------------------------------------------------------------------------
; Load bad ending FMV
; ------------------------------------------------------------------------------

LoadBadEnding:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	lea	EndingMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	BadEndingSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$30000,a1				; GOODEND.BIN loads BADEND.STM. Seriously.
	jsr	LoadFile

	jsr	PRG_RAM+$30000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	andi.b	#~(MCDR_RET|MCDR_MODE),MCD_MEM_MODE		; Set to 2M mode
	move.b	#MCDR_IEN3_BIT,MCD_CDC_DEVICE			; Set CDC device to "Sub CPU"
	move.l	#0,cur_pcm_driver				; Reset current PCM driver
	rts

; ------------------------------------------------------------------------------
; Load good ending FMV
; ------------------------------------------------------------------------------

LoadGoodEnding:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	lea	EndingMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	GoodEndingSubFile(pc),a0			; Load Sub CPU file
	lea	PRG_RAM+$30000,a1				; BADEND.BIN loads GOODEND.STM. Seriously.
	jsr	LoadFile

	jsr	PRG_RAM+$30000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	andi.b	#~(MCDR_RET|MCDR_MODE),MCD_MEM_MODE		; Set to 2M mode
	move.b	#MCDR_IEN3_BIT,MCD_CDC_DEVICE			; Set CDC device to "Sub CPU"
	move.l	#0,cur_pcm_driver				; Reset current PCM driver
	rts

; ------------------------------------------------------------------------------
; Load special stage
; ------------------------------------------------------------------------------

LoadSpecialStage:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	move.b	special_stage_id_cmd,special_stage_id		; Set stage ID
	move.b	time_stones_cmd,time_stones_sub			; Set time stones retrieved
	move.b	special_stage_flags,spec_stage_flags_copy	; Copy flags

	lea	SpecialStageMainFile(pc),a0			; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	lea	SpecialStageSubFile(pc),a0			; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	moveq	#0,d0						; Copy stage data into Word RAM
	move.b	special_stage_id,d0
	mulu.w	#6,d0
	lea	SpecStageData,a0
	move.w	4(a0,d0.w),d7
	movea.l	(a0,d0.w),a0
	lea	WORD_RAM_2M+SpecStgDataCopy,a1

.CopyData:
	move.b	(a0)+,(a1)+
	dbf	d7,.CopyData

	bsr.w	GiveWordRamAccess				; Give Main CPU Word RAM access

	bsr.w	ResetCddaVolume					; Play special stage music
	lea	SpecialStageSong(pc),a0
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	
	btst	#1,spec_stage_flags_copy			; Were we in time attack mode?
	bne.s	.NoResultsSong					; If so, branch
	
	bsr.w	ResetCddaVolume					; If not, play results music
	lea	ResultsSong(pc),a0
	move.w	#MSCPLAY1,d0
	jsr	_CDBIOS

.NoResultsSong:
	move.b	#0,spec_stage_flags_copy			; Clear special stage flags copy
	move.l	#0,cur_pcm_driver				; Reset current PCM driver
	rts

; ------------------------------------------------------------------------------
; Play "Future" voice clip
; ------------------------------------------------------------------------------

PlayFutureVoiceSfx:
	move.b	#PCMS_FUTURE,PCMDrvQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Past" voice clip
; ------------------------------------------------------------------------------

PlayPastVoiceSfx:
	move.b	#PCMS_PAST,PCMDrvQueue				; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Alright" voice clip
; ------------------------------------------------------------------------------

PlayAlrightSfx:
	move.b	#PCMS_ALRIGHT,PCMDrvQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "I'm outta here" voice clip
; ------------------------------------------------------------------------------

PlayGiveUpSfx:
	move.b	#PCMS_GIVEUP,PCMDrvQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Yes" voice clip
; ------------------------------------------------------------------------------

PlayYesSfx:
	move.b	#PCMS_YES,PCMDrvQueue				; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Yeah" voice clip
; ------------------------------------------------------------------------------

PlayYeahSfx:
	move.b	#PCMS_YEAH,PCMDrvQueue				; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Amy giggle voice clip
; ------------------------------------------------------------------------------

PlayAmyGiggleSfx:
	move.b	#PCMS_GIGGLE,PCMDrvQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Amy yelp voice clip
; ------------------------------------------------------------------------------

PlayAmyYelpSfx:
	move.b	#PCMS_AMYYELP,PCMDrvQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play mech stomp sound
; ------------------------------------------------------------------------------

PlayStompSfx:
	move.b	#PCMS_STOMP,PCMDrvQueue				; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play bumper sound
; ------------------------------------------------------------------------------

PlayBumperSfx:
	move.b	#PCMS_BUMPER,PCMDrvQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play glass break sound
; ------------------------------------------------------------------------------

PlayBreakSfx:
	move.b	#PCMS_BREAK,PCMDrvQueue				; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play past music
; ------------------------------------------------------------------------------

PlayPastSong:
	move.b	#PCMM_PAST,PCMDrvQueue				; Play music
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Fade out PCM
; ------------------------------------------------------------------------------

FadeOutPcm:
	move.b	#PCMC_FADEOUT,PCMDrvQueue			; Fade out PCM
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Stop PCM
; ------------------------------------------------------------------------------

StopPcm:
	move.b	#PCMC_STOP,PCMDrvQueue				; Stop PCM
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Pause PCM
; ------------------------------------------------------------------------------

PausePcm:
	move.b	#PCMC_PAUSE,PCMDrvQueue				; Pause PCM
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Unpause PCM
; ------------------------------------------------------------------------------

UnpausePcm:
	move.b	#PCMC_UNPAUSE,PCMDrvQueue			; Unpause PCM
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Reset CD audio volume
; ------------------------------------------------------------------------------

ResetCddaVolumeCmd:
	bsr.w	ResetCddaVolume					; Reset CD audio volume
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Fade out CD audio
; ------------------------------------------------------------------------------

FadeOutCdda:
	move.w	#FDRCHG,d0					; Fade out CD audio
	moveq	#$20,d1
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Stop CD audio
; ------------------------------------------------------------------------------

StopCdda:
	move.w	#MSCSTOP,d0					; Stop CD audio
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Pause CD audio
; ------------------------------------------------------------------------------

PauseCdda:
	move.w	#MSCPAUSEON,d0					; Pause CD audio
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Unpause CD audio
; ------------------------------------------------------------------------------

UnpauseCdda:
	move.w	#MSCPAUSEOFF,d0					; Unpause CD audio
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Reset CD audio volume
; ------------------------------------------------------------------------------

ResetCddaVolume:
	move.l	a0,-(sp)					; Save registers
	
	move.w	#FDRSET,d0					; Set CD audio volume
	move.w	#$380,d1
	jsr	_CDBIOS

	move.w	#FDRSET,d0					; Set CD audio master volume
	move.w	#$8380,d1
	jsr	_CDBIOS

	movea.l	(sp)+,a0					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Play Palmtree Panic Present music
; ------------------------------------------------------------------------------

PlayRound1ASong:
	lea	Round1ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Palmtree Panic Good Future music
; ------------------------------------------------------------------------------

PlayRound1BSong:
	lea	Round1CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Palmtree Panic Bad Future music
; ------------------------------------------------------------------------------

PlayRound1DSong:
	lea	Round1DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Present music
; ------------------------------------------------------------------------------

PlayRound3ASong:
	lea	Round3ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Good Future music
; ------------------------------------------------------------------------------

PlayRound3CSong:
	lea	Round3CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Bad Future music
; ------------------------------------------------------------------------------

PlayRound3DSong:
	lea	Round3DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Present music
; ------------------------------------------------------------------------------

PlayRound4ASong:
	lea	Round4ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Good Future music
; ------------------------------------------------------------------------------

PlayRound4CSong:
	lea	Round4CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Bad Future music
; ------------------------------------------------------------------------------

PlayRound4DSong:
	lea	Round4DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Present music
; ------------------------------------------------------------------------------

PlayRound5ASong:
	lea	Round5ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Good Future music
; ------------------------------------------------------------------------------

PlayRound5CSong:
	lea	Round5CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Bad Future music
; ------------------------------------------------------------------------------

PlayRound5DSong:
	lea	Round5DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Present music
; ------------------------------------------------------------------------------

PlayRound6ASong:
	lea	Round6ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Good Future music
; ------------------------------------------------------------------------------

PlayRound6CSong:
	lea	Round6CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Bad Future music
; ------------------------------------------------------------------------------

PlayRound6DSong:
	lea	Round6DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Present music
; ------------------------------------------------------------------------------

PlayRound7ASong:
	lea	Round7ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Good Future music
; ------------------------------------------------------------------------------

PlayRound7CSong:
	lea	Round7CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Bad Future music
; ------------------------------------------------------------------------------

PlayRound7DSong:
	lea	Round7DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Metallic Madness Present music
; ------------------------------------------------------------------------------

PlayRound8ASong:
	lea	Round8ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Metallic Madness Good Future music
; ------------------------------------------------------------------------------

PlayRound8CSong:
	lea	Round8CSong(pc),a0				; Play music

; ------------------------------------------------------------------------------
; Loop CD audio
; ------------------------------------------------------------------------------
; PARAMETERS
;	a0.l - Pointer to music ID
; ------------------------------------------------------------------------------

LoopCdda:
	bsr.w	ResetCddaVolume					; Reset CD audio volume
	move.w	#MSCPLAYR,d0					; Play track on loop
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Metallic Madness Bad Future music
; ------------------------------------------------------------------------------

PlayRound8DSong:
	lea	Round8DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play boss music
; ------------------------------------------------------------------------------

PlayBossSong:
	lea	BossSong(pc),a0					; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play final boss music
; ------------------------------------------------------------------------------

PlayFinalBossSong:
	lea	FinalBossSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play time attack menu music
; ------------------------------------------------------------------------------

PlayTimeAttackSong:
	lea	TimeAttackSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play special stage music
; ------------------------------------------------------------------------------

PlaySpecialStageSong:
	lea	SpecialStageSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play D.A. Garden music
; ------------------------------------------------------------------------------

PlayDaGardenSong:
	lea	DaGardenSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play prototype time warp sound
; ------------------------------------------------------------------------------

PlayProtoWarpSound:
	lea	ProtoWarpSound(pc),a0				; Play sound
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play opening music
; ------------------------------------------------------------------------------

PlayOpeningSong:
	lea	OpeningSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play ending music
; ------------------------------------------------------------------------------

PlayEndingSong:
	lea	EndingSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play title screen music
; ------------------------------------------------------------------------------

PlayTitleSong:
	lea	TitleScreenSong(pc),a0				; Play music
	bra.s	PlayCdda

; ------------------------------------------------------------------------------
; Play results music
; ------------------------------------------------------------------------------

PlayResultsSong:
	lea	ResultsSong(pc),a0				; Play music
	bra.s	PlayCdda

; ------------------------------------------------------------------------------
; Play speed shoes music
; ------------------------------------------------------------------------------

PlaySpeedShoesSong:
	lea	SpeedShoesSong(pc),a0				; Play music
	bra.s	PlayCdda

; ------------------------------------------------------------------------------
; Play invincibility music
; ------------------------------------------------------------------------------

PlayInvincibleSong:
	lea	InvincibleSong(pc),a0				; Play music
	bra.s	PlayCdda

; ------------------------------------------------------------------------------
; Play game over music
; ------------------------------------------------------------------------------

PlayGameOverSong:
	lea	GameOverSong(pc),a0				; Play music

; ------------------------------------------------------------------------------
; Play CD audio
; ------------------------------------------------------------------------------
; PARAMETERS
;	a0.l - Pointer to music ID
; ------------------------------------------------------------------------------

PlayCdda:
	bsr.w	ResetCddaVolume					; Reset CD audio volume
	move.w	#MSCPLAY1,d0					; Play track once
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Palmtree Panic Present music (sound test)
; ------------------------------------------------------------------------------

TestRound1ASong:
	lea	Round1ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Palmtree Panic Good Future music (sound test)
; ------------------------------------------------------------------------------

TestRound1CSong:
	lea	Round1CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Palmtree Panic Bad Future music (sound test)
; ------------------------------------------------------------------------------

TestRound1DSong:
	lea	Round1DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Present music (sound test)
; ------------------------------------------------------------------------------

TestRound3ASong:
	lea	Round3ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Good Future music (sound test)
; ------------------------------------------------------------------------------

TestRound3CSong:
	lea	Round3CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Bad Future music (sound test)
; ------------------------------------------------------------------------------

TestRound3DSong:
	lea	Round3DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Present music (sound test)
; ------------------------------------------------------------------------------

TestRound4ASong:
	lea	Round4ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Good Future music (sound test)
; ------------------------------------------------------------------------------

TestRound4CSong:
	lea	Round4CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Bad Future music (sound test)
; ------------------------------------------------------------------------------

TestRound4DSong:
	lea	Round4DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Present music (sound test)
; ------------------------------------------------------------------------------

TestRound5ASong:
	lea	Round5ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Good Future music (sound test)
; ------------------------------------------------------------------------------

TestRound5CSong:
	lea	Round5CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Bad Future music (sound test)
; ------------------------------------------------------------------------------

TestRound5DSong:
	lea	Round5DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Present music (sound test)
; ------------------------------------------------------------------------------

TestRound6ASong:
	lea	Round6ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Good Future music (sound test)
; ------------------------------------------------------------------------------

TestRound6CSong:
	lea	Round6CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Bad Future music (sound test)
; ------------------------------------------------------------------------------

TestRound6DSong:
	lea	Round6DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Present music (sound test)
; ------------------------------------------------------------------------------

TestRound7ASong:
	lea	Round7ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Good Future music (sound test)
; ------------------------------------------------------------------------------

TestRound7CSong:
	lea	Round7CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Bad Future music (sound test)
; ------------------------------------------------------------------------------

TestRound7DSong:
	lea	Round7DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Metallic Madness Present music (sound test)
; ------------------------------------------------------------------------------

TestRound8ASong:
	lea	Round8ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Metallic Madness Good Future music (sound test)
; ------------------------------------------------------------------------------

TestRound8CSong:
	lea	Round8CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Metallic Madness Bad Future music (sound test)
; ------------------------------------------------------------------------------

TestRound8DSong:
	lea	Round8DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play boss music (sound test)
; ------------------------------------------------------------------------------

TestBossSong:
	lea	BossSong(pc),a0					; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play final boss music (sound test)
; ------------------------------------------------------------------------------

TestFinalSong:
	lea	FinalBossSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play title screen music (sound test)
; ------------------------------------------------------------------------------

TestTitleSong:
	lea	TitleScreenSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play time attack menu music (sound test)
; ------------------------------------------------------------------------------

TestTimeAttackSong:
	lea	TimeAttackSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play results music (sound test)
; ------------------------------------------------------------------------------

TestResultsSong:
	lea	ResultsSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play speed shoes music (sound test)
; ------------------------------------------------------------------------------

TestSpeedShoesSong:
	lea	SpeedShoesSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play invincibility music (sound test)
; ------------------------------------------------------------------------------

TestInvincibleSong:
	lea	InvincibleSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play game over music (sound test)
; ------------------------------------------------------------------------------

TestGameOverSong:
	lea	GameOverSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play special stage music (sound test)
; ------------------------------------------------------------------------------

TestSpecialStageSong:
	lea	SpecialStageSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play D.A. Garden music (sound test)
; ------------------------------------------------------------------------------

TestDaGardenSong:
	lea	DaGardenSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play prototype warp sound (sound test)
; ------------------------------------------------------------------------------

TestProtoWarpSound:
	lea	ProtoWarpSound(pc),a0				; Play sound
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play opening music (sound test)
; ------------------------------------------------------------------------------

TestOpeningSong:
	lea	OpeningSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play ending music (sound test)
; ------------------------------------------------------------------------------

TestEndingSong:
	lea	EndingSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play "Future" voice clip (sound test)
; ------------------------------------------------------------------------------

TestFutureVoiceSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMS_FUTURE,PCMDrvQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Past" voice clip (sound test)
; ------------------------------------------------------------------------------

TestPastVoiceSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMS_PAST,PCMDrvQueue				; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Alright" voice clip (sound test)
; ------------------------------------------------------------------------------

TestAlrightSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMS_ALRIGHT,PCMDrvQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "I'm outta here" voice clip (sound test)
; ------------------------------------------------------------------------------

TestGiveUpSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMS_GIVEUP,PCMDrvQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Yes" voice clip (sound test)
; ------------------------------------------------------------------------------

TestYesSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMS_YES,PCMDrvQueue				; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Yeah" voice clip (sound test)
; ------------------------------------------------------------------------------

TestYeahSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMS_YEAH,PCMDrvQueue				; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Amy giggle voice clip (sound test)
; ------------------------------------------------------------------------------

TestAmyGiggleSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMS_GIGGLE,PCMDrvQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Amy yelp voice clip (sound test)
; ------------------------------------------------------------------------------

TestAmyYelpSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMS_AMYYELP,PCMDrvQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play mech stomp sound (sound test)
; ------------------------------------------------------------------------------

TestStompSfx:
	lea	PcmDriverR3BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMS_STOMP,PCMDrvQueue				; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play bumper sound (sound test)
; ------------------------------------------------------------------------------

TestBumperSfx:
	lea	PcmDriverR3BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMS_BUMPER,PCMDrvQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Palmtree Panic past music (sound test)
; ------------------------------------------------------------------------------

TestRound1BSong:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMM_PAST,PCMDrvQueue				; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Collision Chaos past music (sound test)
; ------------------------------------------------------------------------------

TestRound3BSong:
	lea	PcmDriverR3BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMM_PAST,PCMDrvQueue				; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Tidal Tempest past music (sound test)
; ------------------------------------------------------------------------------

TestRound4BSong:
	lea	PcmDriverR4BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMM_PAST,PCMDrvQueue				; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Quartz Quadrant past music (sound test)
; ------------------------------------------------------------------------------

TestRound5BSong:
	lea	PcmDriverR5BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMM_PAST,PCMDrvQueue				; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Wacky Workbench past music (sound test)
; ------------------------------------------------------------------------------

TestRound6BSong:
	lea	PcmDriverR6BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMM_PAST,PCMDrvQueue				; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Stardust Speedway past music (sound test)
; ------------------------------------------------------------------------------

TestRound7BSong:
	lea	PcmDriverR7BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMM_PAST,PCMDrvQueue				; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Metallic Madness past music (sound test)
; ------------------------------------------------------------------------------

TestRound8BSong:
	lea	PcmDriverR8BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCMM_PAST,PCMDrvQueue				; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Load PCM driver for sound test
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to file name
; ------------------------------------------------------------------------------

LoadPcmDriver:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	move.l	cur_pcm_driver,d0				; Is this driver already loaded?
	move.l	a0,cur_pcm_driver
	cmp.l	a0,d0
	beq.s	.End						; If so, branch
	
	lea	PcmDriver,a1					; Load driver
	jsr	LoadFile

.End:
	bset	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Enable timer interrupt
	rts

; ------------------------------------------------------------------------------
; Null graphics interrupt
; ------------------------------------------------------------------------------

NullGraphicsIrq:
	rte

; ------------------------------------------------------------------------------
; Run PCM driver (timer interrupt)
; ------------------------------------------------------------------------------

TimerIrq:
	bchg	#0,pcm_driver_flags				; Should we run the driver on this interrupt?
	beq.s	.End						; If not, branch

	movem.l	d0-a6,-(sp)					; Run the driver
	jsr	PCMDrvRun
	movem.l	(sp)+,d0-a6

.End:
	rte

; ------------------------------------------------------------------------------
; Give Word RAM access to the Main CPU (and finish off command)
; ------------------------------------------------------------------------------

GiveWordRamAccess:
	bset	#MCDR_RET_BIT,MCD_MEM_MODE			; Give Word RAM access to Main CPU
	btst	#MCDR_RET_BIT,MCD_MEM_MODE			; Has it been given?
	beq.s	GiveWordRamAccess				; If not, wait

; ------------------------------------------------------------------------------
; Finish off command
; ------------------------------------------------------------------------------

FinishCommand:
	move.w	MCD_MAIN_COMM_0,MCD_SUB_COMM_0			; Acknowledge command

.WaitMain:
	move.w	MCD_MAIN_COMM_0,d0				; Is the Main CPU ready?
	bne.s	.WaitMain					; If not, wait
	move.w	MCD_MAIN_COMM_0,d0
	bne.s	.WaitMain					; If not, wait

	move.w	#0,MCD_SUB_COMM_0				; Mark as ready for another command
	rts

; ------------------------------------------------------------------------------
; Wait for Word RAM access
; ------------------------------------------------------------------------------

WaitWordRamAccess:
	btst	#MCDR_DMNA_BIT,MCD_MEM_MODE			; Do we have Word RAM access?
	beq.s	WaitWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
; Song IDs
; ------------------------------------------------------------------------------

ProtoWarpSound:
	dc.w	CDDA_PROTO_WARP
Round1ASong:
	dc.w	CDDA_ROUND_1A
Round1CSong:
	dc.w	CDDA_ROUND_1C
Round1DSong:
	dc.w	CDDA_ROUND_1D
Round3ASong:
	dc.w	CDDA_ROUND_3A
Round3CSong:
	dc.w	CDDA_ROUND_3C
Round3DSong:
	dc.w	CDDA_ROUND_3D
Round4ASong:
	dc.w	CDDA_ROUND_4A
Round4CSong:
	dc.w	CDDA_ROUND_4C
Round4DSong:
	dc.w	CDDA_ROUND_4D
Round5ASong:
	dc.w	CDDA_ROUND_5A
Round5CSong:
	dc.w	CDDA_ROUND_5C
Round5DSong:
	dc.w	CDDA_ROUND_5D
Round6ASong:
	dc.w	CDDA_ROUND_6A
Round6CSong:
	dc.w	CDDA_ROUND_6C
Round6DSong:
	dc.w	CDDA_ROUND_6D
Round7ASong:
	dc.w	CDDA_ROUND_7A
Round7CSong:
	dc.w	CDDA_ROUND_7C
Round7DSong:
	dc.w	CDDA_ROUND_7D
Round8ASong:
	dc.w	CDDA_ROUND_8A
Round8CSong:
	dc.w	CDDA_ROUND_8C
Round8DSong:
	dc.w	CDDA_ROUND_8D
BossSong:
	dc.w	CDDA_BOSS
FinalBossSong:
	dc.w	CDDA_FINAL
TitleScreenSong:
	dc.w	CDDA_TITLE
TimeAttackSong:
	dc.w	CDDA_TIME_ATTACK
ResultsSong:
	dc.w	CDDA_RESULTS
SpeedShoesSong:
	dc.w	CDDA_SPEED_SHOES
InvincibleSong:
	dc.w	CDDA_INVINCIBILE
GameOverSong:
	dc.w	CDDA_GAME_OVER
SpecialStageSong:
	dc.w	CDDA_SPECIAL_STAGE
DaGardenSong:
	dc.w	CDDA_DA_GARDEN
OpeningSong:
	dc.w	CDDA_OPENING
EndingSong:
	dc.w	CDDA_ENDING

; ------------------------------------------------------------------------------
; Backup RAM data
; ------------------------------------------------------------------------------

BuramScratch:
	dcb.b	$640, 0						; Scratch RAM

BuramStrings:	
	dcb.b	$C, 0						; Display strings

; ------------------------------------------------------------------------------

	align $FC00

; ------------------------------------------------------------------------------
