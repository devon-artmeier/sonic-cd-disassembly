; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"cdda_ids.inc"

	section code

; ------------------------------------------------------------------------------
; Define a CDDA ID
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - Label name
;	\2 - ID constant name
; ------------------------------------------------------------------------------

cdda macro
	xdef \1
\1:
	dc.w	\2
	endm

; ------------------------------------------------------------------------------
; CDDA IDs
; ------------------------------------------------------------------------------

	cdda ProtoWarpSound,   CDDA_PROTO_WARP
	cdda Round1ASong,      CDDA_ROUND_1A
	cdda Round1CSong,      CDDA_ROUND_1C
	cdda Round1DSong,      CDDA_ROUND_1D
	cdda Round3ASong,      CDDA_ROUND_3A
	cdda Round3CSong,      CDDA_ROUND_3C
	cdda Round3DSong,      CDDA_ROUND_3D
	cdda Round4ASong,      CDDA_ROUND_4A
	cdda Round4CSong,      CDDA_ROUND_4C
	cdda Round4DSong,      CDDA_ROUND_4D
	cdda Round5ASong,      CDDA_ROUND_5A
	cdda Round5CSong,      CDDA_ROUND_5C
	cdda Round5DSong,      CDDA_ROUND_5D
	cdda Round6ASong,      CDDA_ROUND_6A
	cdda Round6CSong,      CDDA_ROUND_6C
	cdda Round6DSong,      CDDA_ROUND_6D
	cdda Round7ASong,      CDDA_ROUND_7A
	cdda Round7CSong,      CDDA_ROUND_7C
	cdda Round7DSong,      CDDA_ROUND_7D
	cdda Round8ASong,      CDDA_ROUND_8A
	cdda Round8CSong,      CDDA_ROUND_8C
	cdda Round8DSong,      CDDA_ROUND_8D
	cdda BossSong,	       CDDA_BOSS
	cdda FinalBossSong,    CDDA_FINAL
	cdda TitleScreenSong,  CDDA_TITLE
	cdda TimeAttackSong,   CDDA_TIME_ATTACK
	cdda ResultsSong,      CDDA_RESULTS
	cdda SpeedShoesSong,   CDDA_SPEED_SHOES
	cdda InvincibleSong,   CDDA_INVINCIBILE
	cdda GameOverSong,     CDDA_GAME_OVER
	cdda SpecialStageSong, CDDA_SPECIAL_STAGE
	cdda DaGardenSong,     CDDA_DA_GARDEN
	cdda OpeningSong,      CDDA_OPENING
	cdda EndingSong,       CDDA_ENDING

; ------------------------------------------------------------------------------
