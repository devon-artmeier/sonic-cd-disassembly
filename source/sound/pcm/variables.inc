; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------

; Counts
RHYTHM_TRACK_COUNT	equ 1					; Number of rhythm tracks
PCM_TRACK_COUNT		equ 8					; Number of PCM tracks

; Track flags
	rsreset
			rs.b 1
TRACK_REST		rs.b 1					; Rest flag
			rs.b 1
			rs.b 1
TRACK_LEGATO		rs.b 1					; Legato flag
			rs.b 1
			rs.b 1
TRACK_PLAY		rs.b 1					; Play flag

; ------------------------------------------------------------------------------
; Track variables structure
; ------------------------------------------------------------------------------

	rsreset
track.flags		rs.b 1					; Flags
track.channel		rs.b 1					; Channel ID
track.tick_multiply	rs.b 1					; Tick multiplier
track.panning		rs.b 1					; Panning
track.data_addr		rs.l 1					; Data address
track.transpose		rs.b 1					; Transposition
track.volume		rs.b 1					; Volume
track.call_stack_addr	rs.b 1					; Call stack pointer
track.duration_timer	rs.b 1					; Duration timer
track.duration		rs.b 1					; Duration
track.staccato_timer	rs.b 1					; Staccato timer
track.staccato		rs.b 1					; Staccato
track.Detune		rs.b 1					; Detune
track.Freq		rs.w 1					; Frequency
track.sample_bank	rs.b 1					; Sample RAM bank ID
track.sample_blocks	rs.b 1					; Sample stream block counter
track.prev_sample_pos	rs.w 1					; Previous sample playback position
track.sample_ram_offset	rs.w 1					; Sample RAM offset
track.sample_ram_addr	rs.l 1					; Sample RAM address
track.sample_size	rs.l 1					; Sample size
track.samples_remain	rs.l 1					; Sample bytes remaining
track.sample_addr	rs.l 1					; Sample data address
track.sample_start	rs.l 1					; Sample start address
track.sample_loop	rs.l 1					; Sample loop address
track.sample_staccato	rs.b 1					; Sample staccato
track.sample_stac_timer	rs.b 1					; Sample staccato timer
track.sample_mode	rs.b 1					; Sample mode
			rs.b $40-__RS
track.call_stack	rs.b 0					; Call stack
track.loop_counters	rs.b $40				; Loop counters
track.call_stack_base	rs.b 0					; Call stack base
track.struct_size	rs.b 0					; Size of structure

; ------------------------------------------------------------------------------
; Global driver variables structure
; ------------------------------------------------------------------------------

	rsreset
pcm.tempo		rs.b 1					; Tempo
pcm.tempo_timer		rs.b 1					; Tempo timer
pcm.on			rs.b 1					; Channels on/off array
pcm.sfx_priority	rs.b 1					; Saved SFX priority level
pcm.communication	rs.b 1					; Communication flag
pcm.cdda_loop		rs.b 1					; CDDA music loop flag
pcm.unk_counter		rs.b 1					; Unknown counter
			rs.b 2
pcm.sound_play		rs.b 1					; Sound play queue
pcm.sound_queue		rs.b 4					; Sound queue slots
pcm.sfx_mode		rs.b 1					; SFX mode
pcm.pause_mode		rs.b 1					; Pause mode
pcm.ptr_offset		rs.l 1					; Pointer offset
pcm.fade_steps		rs.b 1					; Fade out step count
pcm.fade_speed		rs.b 1					; Fade out speed
pcm.fade_delay		rs.b 1					; Fade out delay
pcm.fade_delay_timer	rs.b 1					; Fade out delay timer
pcm.unk_fade_volume	rs.b 1					; Unknown fade out volume
			rs.b $80-__RS
pcm.rhythm		rs.b track.struct_size			; Rhythm track (unused)
pcm.track_1		rs.b track.struct_size			; Music PCM1 track
pcm.track_2		rs.b track.struct_size			; Music PCM2 track
pcm.track_3		rs.b track.struct_size			; Music PCM3 track
pcm.track_4		rs.b track.struct_size			; Music PCM4 track
pcm.track_5		rs.b track.struct_size			; Music PCM5 track
pcm.track_6		rs.b track.struct_size			; Music PCM6 track
pcm.track_7		rs.b track.struct_size			; Music PCM7 track
pcm.track_8		rs.b track.struct_size			; Music PCM8 track
pcm.sfx_1		rs.b track.struct_size			; SFX PCM1 track
pcm.sfx_2		rs.b track.struct_size			; SFX PCM2 track
pcm.sfx_3		rs.b track.struct_size			; SFX PCM3 track
pcm.sfx_4		rs.b track.struct_size			; SFX PCM4 track
pcm.sfx_5		rs.b track.struct_size			; SFX PCM5 track
pcm.sfx_6		rs.b track.struct_size			; SFX PCM6 track
pcm.sfx_7		rs.b track.struct_size			; SFX PCM7 track
pcm.sfx_8		rs.b track.struct_size			; SFX PCM8 track
pcm.struct_size		rs.b 0					; Size of structure

; ------------------------------------------------------------------------------
; Sample data structure
; ------------------------------------------------------------------------------

	rsreset
sample.address		rs.l 1					; Sample address
sample.size		rs.l 1					; Sample size
sample.loop		rs.l 1					; Sample loop offset
sample.staccato		rs.b 1					; Sample staccato time
sample.mode		rs.b 1					; Sample mode
sample.dest_addr	rs.w 1					; Sample destination address
sample.struct_size	rs.b 0					; Size of structure

; ------------------------------------------------------------------------------
