; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	section data
	
; ------------------------------------------------------------------------------
; Define a file name
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - Label name
;	\2 - ID constant name
;	\3 - File name
; ------------------------------------------------------------------------------

__file_id set 0
fileName macro label, id, name
	xdef \1
\1:
	dc.b	\3, 0
	\2:		equ __file_id
	__file_id:	set __file_id+1
	endm

; ------------------------------------------------------------------------------
; File name table
; ------------------------------------------------------------------------------

	fileName Round11AFile,		FILE_ROUND_11A,        "R11A__.MMD;1"
	fileName Round11BFile,		FILE_ROUND_11B,        "R11B__.MMD;1"
	fileName Round11CFile,		FILE_ROUND_11C,        "R11C__.MMD;1"
	fileName Round11DFile,		FILE_ROUND_11D,        "R11D__.MMD;1"
	fileName MdInitFile,		FILE_MD_INIT,          "MDINIT.MMD;1"
	fileName SoundTestFile,		FILE_SOUND_TEST,       "SOSEL_.MMD;1"
	fileName StageSelectFile,	FILE_STAGE_SELECT,     "STSEL_.MMD;1"
	fileName Round12AFile,		FILE_ROUND_12A,        "R12A__.MMD;1"
	fileName Round12BFile,		FILE_ROUND_12B,        "R12B__.MMD;1"
	fileName Round12CFile,		FILE_ROUND_12C,        "R12C__.MMD;1"
	fileName Round12DFile,		FILE_ROUND_12D,        "R12D__.MMD;1"
	fileName TitleMainFile,		FILE_TITLE_MAIN,       "TITLEM.MMD;1"
	fileName TitleSubFile,		FILE_TITLE_SUB,        "TITLES.BIN;1"
	fileName WarpFile,		FILE_WARP,             "WARP__.MMD;1"
	fileName TimeAttackMainFile,	FILE_TIME_ATTACK_MAIN, "ATTACK.MMD;1"
	fileName TimeAttackSubFile,	FILE_TIME_ATTACK_SUB,  "ATTACK.BIN;1"
	fileName IpxFile,		FILE_IPX,              "IPX___.MMD;1"
	fileName PencilStmFile,		FILE_PENCIL_STM,       "PTEST.STM;1 "
	fileName OpeningStmFile,	FILE_OPENING_STM,      "OPN.STM;1   "
	fileName BadEndingStmFile,	FILE_BAD_END_STM,      "BADEND.STM;1"
	fileName GoodEndingStmFile,	FILE_GOOD_END_STM,     "GOODEND.STM;1"
	fileName OpeningMainFile,	FILE_OPENING_MAIN,     "OPEN_M.MMD;1"
	fileName OpeningSubFile,	FILE_OPENING_SUB,      "OPEN_S.BIN;1"
	fileName CominSoonFile,		FILE_COMIN_SOON,       "COME__.MMD;1"
	fileName DaGardenMainFile,	FILE_DA_GARDEN_MAIN,   "PLANET_M.MMD;1"
	fileName DaGardenSubFile,	FILE_DA_GARDEN_SUB,    "PLANET_S.BIN;1"
	fileName Round31AFile,		FILE_ROUND_31A,        "R31A__.MMD;1"
	fileName Round31BFile,		FILE_ROUND_31B,        "R31B__.MMD;1"
	fileName Round31CFile,		FILE_ROUND_31C,        "R31C__.MMD;1"
	fileName Round31DFile,		FILE_ROUND_31D,        "R31D__.MMD;1"
	fileName Round32AFile,		FILE_ROUND_32A,        "R32A__.MMD;1"
	fileName Round32BFile,		FILE_ROUND_32B,        "R32B__.MMD;1"
	fileName Round32CFile,		FILE_ROUND_32C,        "R32C__.MMD;1"
	fileName Round32DFile,		FILE_ROUND_32D,        "R32D__.MMD;1"
	fileName Round33CFile,		FILE_ROUND_33C,        "R33C__.MMD;1"
	fileName Round33DFile,		FILE_ROUND_33D,        "R33D__.MMD;1"
	fileName Round13CFile,		FILE_ROUND_13C,        "R13C__.MMD;1"
	fileName Round13DFile,		FILE_ROUND_13D,        "R13D__.MMD;1"
	fileName Round41AFile,		FILE_ROUND_41A,        "R41A__.MMD;1"
	fileName Round41BFile,		FILE_ROUND_41B,        "R41B__.MMD;1"
	fileName Round41CFile,		FILE_ROUND_41C,        "R41C__.MMD;1"
	fileName Round41DFile,		FILE_ROUND_41D,        "R41D__.MMD;1"
	fileName Round42AFile,		FILE_ROUND_42A,        "R42A__.MMD;1"
	fileName Round42BFile,		FILE_ROUND_42B,        "R42B__.MMD;1"
	fileName Round42CFile,		FILE_ROUND_42C,        "R42C__.MMD;1"
	fileName Round42DFile,		FILE_ROUND_42D,        "R42D__.MMD;1"
	fileName Round43CFile,		FILE_ROUND_43C,        "R43C__.MMD;1"
	fileName Round43DFile,		FILE_ROUND_43D,        "R43D__.MMD;1"
	fileName Round51AFile,		FILE_ROUND_51A,        "R51A__.MMD;1"
	fileName Round51BFile,		FILE_ROUND_51B,        "R51B__.MMD;1"
	fileName Round51CFile,		FILE_ROUND_51C,        "R51C__.MMD;1"
	fileName Round51DFile,		FILE_ROUND_51D,        "R51D__.MMD;1"
	fileName Round52AFile,		FILE_ROUND_52A,        "R52A__.MMD;1"
	fileName Round52BFile,		FILE_ROUND_52B,        "R52B__.MMD;1"
	fileName Round52CFile,		FILE_ROUND_52C,        "R52C__.MMD;1"
	fileName Round52DFile,		FILE_ROUND_52D,        "R52D__.MMD;1"
	fileName Round53CFile,		FILE_ROUND_53C,        "R53C__.MMD;1"
	fileName Round53DFile,		FILE_ROUND_53D,        "R53D__.MMD;1"
	fileName Round61AFile,		FILE_ROUND_61A,        "R61A__.MMD;1"
	fileName Round61BFile,		FILE_ROUND_61B,        "R61B__.MMD;1"
	fileName Round61CFile,		FILE_ROUND_61C,        "R61C__.MMD;1"
	fileName Round61DFile,		FILE_ROUND_61D,        "R61D__.MMD;1"
	fileName Round62AFile,		FILE_ROUND_62A,        "R62A__.MMD;1"
	fileName Round62BFile,		FILE_ROUND_62B,        "R62B__.MMD;1"
	fileName Round62CFile,		FILE_ROUND_62C,        "R62C__.MMD;1"
	fileName Round62DFile,		FILE_ROUND_62D,        "R62D__.MMD;1"
	fileName Round63CFile,		FILE_ROUND_63C,        "R63C__.MMD;1"
	fileName Round63DFile,		FILE_ROUND_63D,        "R63D__.MMD;1"
	fileName Round71AFile,		FILE_ROUND_71A,        "R71A__.MMD;1"
	fileName Round71BFile,		FILE_ROUND_71B,        "R71B__.MMD;1"
	fileName Round71CFile,		FILE_ROUND_71C,        "R71C__.MMD;1"
	fileName Round71DFile,		FILE_ROUND_71D,        "R71D__.MMD;1"
	fileName Round72AFile,		FILE_ROUND_72A,        "R72A__.MMD;1"
	fileName Round72BFile,		FILE_ROUND_72B,        "R72B__.MMD;1"
	fileName Round72CFile,		FILE_ROUND_72C,        "R72C__.MMD;1"
	fileName Round72DFile,		FILE_ROUND_72D,        "R72D__.MMD;1"
	fileName Round73CFile,		FILE_ROUND_73C,        "R73C__.MMD;1"
	fileName Round73DFile,		FILE_ROUND_73D,        "R73D__.MMD;1"
	fileName Round81AFile,		FILE_ROUND_81A,        "R81A__.MMD;1"
	fileName Round81BFile,		FILE_ROUND_81B,        "R81B__.MMD;1"
	fileName Round81CFile,		FILE_ROUND_81C,        "R81C__.MMD;1"
	fileName Round81DFile,		FILE_ROUND_81D,        "R81D__.MMD;1"
	fileName Round82AFile,		FILE_ROUND_82A,        "R82A__.MMD;1"
	fileName Round82BFile,		FILE_ROUND_82B,        "R82B__.MMD;1"
	fileName Round82CFile,		FILE_ROUND_82C,        "R82C__.MMD;1"
	fileName Round82DFile,		FILE_ROUND_82D,        "R82D__.MMD;1"
	fileName Round83CFile,		FILE_ROUND_83C,        "R83C__.MMD;1"
	fileName Round83DFile,		FILE_ROUND_83D,        "R83D__.MMD;1"
	fileName SpecialStageMainFile,	FILE_SPECIAL_MAIN,     "SPMM__.MMD;1"
	fileName SpecialStageSubFile,	FILE_SPECIAL_SUB,      "SPSS__.BIN;1"
	fileName PcmDriverR1BFile,	FILE_PCM_1B,           "SNCBNK1B.BIN;1"
	fileName PcmDriverR3BFile,	FILE_PCM_3B,           "SNCBNK3B.BIN;1"
	fileName PcmDriverR4BFile,	FILE_PCM_4B,           "SNCBNK4B.BIN;1"
	fileName PcmDriverR5BFile,	FILE_PCM_5B,           "SNCBNK5B.BIN;1"
	fileName PcmDriverR6BFile,	FILE_PCM_6B,           "SNCBNK6B.BIN;1"
	fileName PcmDriverR7BFile,	FILE_PCM_7B,           "SNCBNK7B.BIN;1"
	fileName PcmDriverR8BFile,	FILE_PCM_8B,           "SNCBNK8B.BIN;1"
	fileName PcmDriverBoss,		FILE_PCM_BOSS,         "SNCBNKB1.BIN;1"
	fileName PcmDriverFinal,	FILE_PCM_FINAL,        "SNCBNKB2.BIN;1"
	fileName DaGardenDataFile,	FILE_PLANET_DATA,      "PLANET_D.BIN;1"
	fileName Demo11AFile,		FILE_DEMO_11A,         "DEMO11A.MMD;1"
	fileName VisualModeFile,	FILE_VISUAL_MODE,      "VM____.MMD;1"
	fileName BuramInitFile,		FILE_BURAM_INIT,       "BRAMINIT.MMD;1"
	fileName BuramSubFile,		FILE_BURAM_SUB,        "BRAMSUB.BIN;1"
	fileName BuramMainFile,		FILE_BURAM_MAIN,       "BRAMMAIN.MMD;1"
	fileName ThankYouMainFile,	FILE_THANKS_MAIN,      "THANKS_M.MMD;1"
	fileName ThankYouSubFile,	FILE_THANKS_SUB,       "THANKS_S.BIN;1"
	fileName ThankYouDataFile,	FILE_THANKS_DATA,      "THANKS_D.BIN;1"
	fileName EndingMainFile,	FILE_ENDING_MAIN,      "ENDING.MMD;1"
	fileName BadEndingSubFile,	FILE_BAD_END_SUB,      "GOODEND.BIN;1" 
	fileName GoodEndingSubFile,	FILE_GOOD_END_SUB,     "BADEND.BIN;1" 
	fileName FunIsInfiniteFile,	FILE_FUN_IS_INFINITE,  "NISI.MMD;1"
	fileName Special8EndFile,	FILE_SPECIAL_8_END,    "SPEEND.MMD;1"
	fileName McSonicFile,		FILE_MC_SONIC,         "DUMMY0.MMD;1"
	fileName TailsFile,		FILE_TAILS,            "DUMMY1.MMD;1"
	fileName BatmanSonicFile,	FILE_BATMAN,           "DUMMY2.MMD;1"
	fileName CuteSonicFile,		FILE_CUTE_SONIC,       "DUMMY3.MMD;1"
	fileName BestStaffTimesFile,	FILE_STAFF_TIMES,      "DUMMY4.MMD;1"
	fileName DummyFile5,		FILE_DUMMY_5,          "DUMMY5.MMD;1"
	fileName DummyFile6,		FILE_DUMMY_6,          "DUMMY6.MMD;1"
	fileName DummyFile7,		FILE_DUMMY_7,          "DUMMY7.MMD;1"
	fileName DummyFile8,		FILE_DUMMY_8,          "DUMMY8.MMD;1"
	fileName DummyFile9,		FILE_DUMMY_9,          "DUMMY9.MMD;1"
	fileName PencilTestMainFile,	FILE_PENCIL_MAIN,      "PTEST.MMD;1"
	fileName PencilTestSubFile,	FILE_PENCIL_SUB,       "PTEST.BIN;1"
	fileName Demo43CFile,		FILE_DEMO_43C,         "DEMO43C.MMD;1"
	fileName Demo82AFile,		FILE_DEMO_82A,         "DEMO82A.MMD;1"

; ------------------------------------------------------------------------------
