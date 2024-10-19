; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------

ZTRACK_COUNT		equ 6					; Number of tracks

; Track flags
	rsreset
ZTRACK_FM3_DETUNE	rs.b 1					; FM3 detune mode flag
ZTRACK_LEGATO		rs.b 1					; Legato flag
ZTRACK_MUTE		rs.b 1					; Mute flag
ZTRACK_RAW_FREQ		rs.b 1					; Raw frequency mode
ZTRACK_REST		rs.b 1					; Rest flag
ZTRACK_PORTAMENTO	rs.b 1					; Portamento flag
ZTRACK_VIBRATO_END	rs.b 1					; Vibrato envelope end flag
ZTRACK_PLAY		rs.b 1					; Play flag

; ------------------------------------------------------------------------------
; Track variables structure
; ------------------------------------------------------------------------------

	rsreset
ztrack.flags		rs.b 1					; Flags
ztrack.channel		rs.b 1					; Channel ID
ztrack.tick_multiply	rs.b 1					; Tick multiplier
ztrack.data		rs.w 1					; Data address
ztrack.transpose	rs.b 1					; Transposition
ztrack.volume		rs.b 1					; Volume
ztrack.vibrato_mode	rs.b 1					; Vibrato mode
ztrack.instrument	rs.b 1					; Instrument ID
ztrack.call_stack	rs.b 1					; Call stack address
ztrack.pan_ams_fms	rs.b 1					; Panning/AMS/FMS
ztrack.duration_timer	rs.b 1					; Note duration timer
ztrack.duration		rs.b 1					; Note duration
ztrack.frequency	rs.w 1					; Frequency
			rs.b 1
ztrack.porta_speed	rs.b 1					; Portamento speed
			rs.b 6
ztrack.env_counter	rs.b 1					; Envelope counter
ztrack.ssg_eg_mode	rs.b 1					; SSG-EG mode
ztrack.ssg_eg_params	rs.w 1					; SSG-EG parameter address
ztrack.algo_feedback	rs.b 1					; FM feedback/algorithm
ztrack.tl_values	rs.w 1					; FM TL data address
ztrack.staccato_timer	rs.b 1					; Staccato timer
ztrack.staccato		rs.b 1					; Staccato
ztrack.vibrato_params	rs.w 1					; Vibrato parameters address
ztrack.vibrato		rs.w 1					; Vibrato value
ztrack.vibrato_wait	rs.b 1					; Vibrato wait
ztrack.vibrato_speed	rs.b 1					; Vibrato speed
ztrack.vibrato_delta	rs.b 1					; Vibrato delta
ztrack.vibrato_steps	rs.b 1					; Vibrato steps
ztrack.loop_counters	rs.b 2					; Loop counters
ztrack.instruments	rs.w 1					; Instruments address
			rs.b 4					; Call stack
ztrack.call_stack_base	rs.b 0					; Call stack base
ztrack.struct_size	rs.b 0					; Size of structure

; ------------------------------------------------------------------------------
