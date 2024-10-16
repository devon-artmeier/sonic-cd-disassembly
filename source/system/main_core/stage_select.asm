; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code
	
	xref RunMmd, SpecialStage1Demo

; ------------------------------------------------------------------------------
; Stage selection entry
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - ID constant name
;	\2 - Command ID
;	\3 - Stage ID
;	\4 - Time zone
;	\5 - Good Future flag
; ------------------------------------------------------------------------------

__stage_select_id set 0
selectEntry macro
	xdef \1
	dc.w	\2, \3
	dc.b	\4, \5
	\1:			equ __stage_select_id
	__stage_select_id:	set __stage_select_id+1
	endm

; ------------------------------------------------------------------------------
; Stage select
; ------------------------------------------------------------------------------

	xdef StageSelect
StageSelect:
	moveq	#SYS_STAGE_SELECT,d0				; Run stage select file
	bsr.w	RunMmd

	mulu.w	#6,d0						; Get selected stage data
	move.w	StageSelections+2(pc,d0.w),zone_act		; Set stage
	move.b	StageSelections+4(pc,d0.w),time_zone		; Time zone
	move.b	StageSelections+5(pc,d0.w),good_future		; Good future flag
	move.w	StageSelections(pc,d0.w),d0			; File load command
	
	move.b	#0,projector_destroyed				; Reset projector destroyed flag

	cmpi.w	#SYS_SPECIAL_STAGE,d0				; Have we selected the special stage?
	beq.w	SpecialStage1Demo				; If so, branch
	
	bsr.w	RunMmd						; Run stage file
	rts

; ------------------------------------------------------------------------------

	xdef StageSelections
StageSelections:
	selectEntry SELECT_ROUND_11A,     SYS_ROUND_11A,      $000, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_11B,     SYS_ROUND_11B,      $000, TIME_PAST,    0
	selectEntry SELECT_ROUND_11C,     SYS_ROUND_11C,      $000, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_11D,     SYS_ROUND_11D,      $000, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_12A,     SYS_ROUND_12A,      $001, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_12B,     SYS_ROUND_12B,      $001, TIME_PAST,    0
	selectEntry SELECT_ROUND_12C,     SYS_ROUND_12C,      $001, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_12D,     SYS_ROUND_12D,      $001, TIME_FUTURE,  0
	selectEntry SELECT_WARP,          SYS_WARP,           $000, TIME_PAST,    0
	selectEntry SELECT_OPENING,       SYS_OPENING,        $000, TIME_PAST,    0
	selectEntry SELECT_COMIN_SOON,    SYS_COMIN_SOON,     $000, TIME_PAST,    0
	selectEntry SELECT_ROUND_31A,     SYS_ROUND_31A,      $100, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_31B,     SYS_ROUND_31B,      $100, TIME_PAST,    0
	selectEntry SELECT_ROUND_31C,     SYS_ROUND_31C,      $100, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_31D,     SYS_ROUND_31D,      $100, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_32A,     SYS_ROUND_32A,      $101, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_32B,     SYS_ROUND_32B,      $101, TIME_PAST,    0
	selectEntry SELECT_ROUND_32C,     SYS_ROUND_32C,      $101, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_32D,     SYS_ROUND_32D,      $101, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_33C,     SYS_ROUND_33C,      $102, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_33D,     SYS_ROUND_33D,      $102, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_13C,     SYS_ROUND_13C,      $002, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_13D,     SYS_ROUND_13D,      $002, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_41A,     SYS_ROUND_41A,      $200, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_41B,     SYS_ROUND_41B,      $200, TIME_PAST,    0
	selectEntry SELECT_ROUND_41C,     SYS_ROUND_41C,      $200, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_41D,     SYS_ROUND_41D,      $200, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_42A,     SYS_ROUND_42A,      $201, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_42B,     SYS_ROUND_42B,      $201, TIME_PAST,    0
	selectEntry SELECT_ROUND_42C,     SYS_ROUND_42C,      $201, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_42D,     SYS_ROUND_42D,      $201, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_43C,     SYS_ROUND_43C,      $202, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_43D,     SYS_ROUND_43D,      $202, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_51A,     SYS_ROUND_51A,      $300, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_51B,     SYS_ROUND_51B,      $300, TIME_PAST,    0
	selectEntry SELECT_ROUND_51C,     SYS_ROUND_51C,      $300, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_51D,     SYS_ROUND_51D,      $300, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_52A,     SYS_ROUND_52A,      $301, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_52B,     SYS_ROUND_52B,      $301, TIME_PAST,    0
	selectEntry SELECT_ROUND_52C,     SYS_ROUND_52C,      $301, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_52D,     SYS_ROUND_52D,      $301, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_53C,     SYS_ROUND_53C,      $302, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_53D,     SYS_ROUND_53D,      $302, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_61A,     SYS_ROUND_61A,      $400, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_61B,     SYS_ROUND_61B,      $400, TIME_PAST,    0
	selectEntry SELECT_ROUND_61C,     SYS_ROUND_61C,      $400, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_61D,     SYS_ROUND_61D,      $400, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_62A,     SYS_ROUND_62A,      $401, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_62B,     SYS_ROUND_62B,      $401, TIME_PAST,    0
	selectEntry SELECT_ROUND_62C,     SYS_ROUND_62C,      $401, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_62D,     SYS_ROUND_62D,      $401, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_63C,     SYS_ROUND_63C,      $402, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_63D,     SYS_ROUND_63D,      $402, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_71A,     SYS_ROUND_71A,      $500, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_71B,     SYS_ROUND_71B,      $500, TIME_PAST,    0
	selectEntry SELECT_ROUND_71C,     SYS_ROUND_71C,      $500, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_71D,     SYS_ROUND_71D,      $500, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_72A,     SYS_ROUND_72A,      $501, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_72B,     SYS_ROUND_72B,      $501, TIME_PAST,    0
	selectEntry SELECT_ROUND_72C,     SYS_ROUND_72C,      $501, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_72D,     SYS_ROUND_72D,      $501, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_73C,     SYS_ROUND_73C,      $502, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_73D,     SYS_ROUND_73D,      $502, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_81A,     SYS_ROUND_81A,      $600, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_81B,     SYS_ROUND_81B,      $600, TIME_PAST,    0
	selectEntry SELECT_ROUND_81C,     SYS_ROUND_81C,      $600, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_81D,     SYS_ROUND_81D,      $600, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_82A,     SYS_ROUND_82A,      $601, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_82B,     SYS_ROUND_82B,      $601, TIME_PAST,    0
	selectEntry SELECT_ROUND_82C,     SYS_ROUND_82C,      $601, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_82D,     SYS_ROUND_82D,      $601, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_83C,     SYS_ROUND_83C,      $602, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_83D,     SYS_ROUND_83D,      $602, TIME_FUTURE,  0
	selectEntry SELECT_SPECIAL_STAGE, SYS_SPECIAL_STAGE,  $000, TIME_PAST,    0
	selectEntry SELECT_UNUSED_1,      SYS_ROUND_11A,      $000, TIME_PRESENT, 0
	selectEntry SELECT_UNUSED_2,      SYS_ROUND_11A,      $000, TIME_PRESENT, 0
	selectEntry SELECT_UNUSED_3,      SYS_ROUND_11A,      $000, TIME_PRESENT, 0
	selectEntry SELECT_UNUSED_4,      SYS_ROUND_11A,      $000, TIME_PRESENT, 0
	
; ------------------------------------------------------------------------------
