; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Variables
; ------------------------------------------------------------------------------

	rsset WORK_RAM+$FF00A000
VARIABLES		rs.b 0					; Start of variables
nem_code_table		rs.b 0					; Nemesis code table
decomp_buffer		rs.b $2D00				; Decompression buffer
vsync_flag		rs.b 1					; VSync flag
			rs.b 1
vblank_routine		rs.w 1					; V-BLANK routine ID
timer			rs.w 1					; Timer
frame_count		rs.w 1					; Frame count
saved_sr		rs.w 1					; Saved status register
lag_count		rs.l 1					; Lag frame count
rng_seed		rs.l 1					; Random number generator seed
			rs.b $2EEE
VARIABLES_SIZE		equ __RS-VARIABLES			; Size of variables area

fm_queue_1		equ WORK_RAM+$FF00F00B			; Sound queue 1
fm_queue_2		equ WORK_RAM+$FF00F00C			; Sound queue 2

ctrl_data		equ MCD_MAIN_COMM_14			; Controller data
ctrl_hold		equ ctrl_data				; Controller held buttons data
ctrl_tap		equ ctrl_data+1				; Controller tapped buttons data

; ------------------------------------------------------------------------------
