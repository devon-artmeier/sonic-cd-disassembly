; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Music
; ------------------------------------------------------------------------------

	rsset $81
PCM_SONG_START		rs.b 0					; Starting ID
PCM_SONG_PAST		rs.b 1					; Past song
			rs.b $E
PCM_SONG_END		equ __RS-1				; Ending ID

; ------------------------------------------------------------------------------
; Sound effects
; ------------------------------------------------------------------------------

	rsset $B0
PCM_SFX_START		rs.b 0					; Starting ID
PCM_SFX_SONG_LOOP	rs.b 1					; Song loop (unused)
PCM_SFX_FUTURE		rs.b 1					; "Future"
PCM_SFX_PAST		rs.b 1					; "Past"
PCM_SFX_ALRIGHT		rs.b 1					; "Alright"
PCM_SFX_OUTTA_HERE	rs.b 1					; "I'm outta here"
PCM_SFX_YES		rs.b 1					; "Yes"
PCM_SFX_YEAH		rs.b 1					; "Yeah"
PCM_SFX_AMY_GIGGLE	rs.b 1					; Amy giggle
PCM_SFX_AMY_YELP	rs.b 1					; Amy yelp
PCM_SFX_STOMP		rs.b 1					; Mech stomp
PCM_SFX_BUMPER		rs.b 1					; Bumper
PCM_SFX_BREAK		rs.b 1					; Glass break
			rs.b 4
PCMS_END		equ __RS-1				; Ending ID

; ------------------------------------------------------------------------------
; Commands
; ------------------------------------------------------------------------------

	rsset $E0
PCM_CMD_START		rs.b 0					; Starting ID
PCM_CMD_FADE_OUT	rs.b 1					; Fade out
PCM_CMD_STOP		rs.b 1					; Stop
PCM_CMD_PAUSE		rs.b 1					; Pause
PCM_CMD_UNPAUSE		rs.b 1					; Unpause
PCM_CMD_MUTE		rs.b 1					; Mute
PCM_CMD_END		equ __RS-1				; Ending ID

; ------------------------------------------------------------------------------
