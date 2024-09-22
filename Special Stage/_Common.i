; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Common special stage definitions
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Graphics chip
; ------------------------------------------------------------------------------

TRACETBL		equ PRG_RAM+$1C800			; Trace table
IMGBUFFER		equ PRG_RAM+$1D000			; Image buffer
STAMPMAP		equ PRG_RAM+$20000			; Stamp map

IMGWIDTH		equ 256					; Image buffer width
IMGHEIGHT		equ 96					; Image buffer height
IMGWTILE		equ IMGWIDTH/8				; Image buffer width in tiles
IMGHTILE		equ IMGHEIGHT/8				; Image buffer height in tiles

IMGLENGTH		equ IMGWTILE*IMGHTILE*$20		; Image buffer length in bytes

; ------------------------------------------------------------------------------
; Communication
; ------------------------------------------------------------------------------

ctrl_data		equ MCD_MAIN_COMM_14			; Controller data
ctrl_hold		equ ctrl_data				; Controller held buttons data
ctrl_tap		equ ctrl_data+1				; Controller tapped buttons data
ufo_count		equ MCD_SUB_COMM_11			; UFO count

; ------------------------------------------------------------------------------
; Word RAM
; ------------------------------------------------------------------------------

	rsset WORD_RAM_2M+$1C000
sub_sprites		rs.b	$280				; Sprite buffer
sub_fm_sound_1		rs.b	1				; FM sound queue 1
sub_fm_sound_2		rs.b	1				; FM sound queue 2
sub_fm_sound_3		rs.b	1				; FM sound queue 3
			rs.b	1
sub_splash_load		rs.b	1				; Splash art load flag
sub_scroll_flags	rs.b	1				; Scroll flags
			rs.b	$7A
sub_player_art_buffer	rs.b	$300				; Player art buffer

; ------------------------------------------------------------------------------
