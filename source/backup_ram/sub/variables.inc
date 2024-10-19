; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Variables
; ------------------------------------------------------------------------------

	rsset	PRG_RAM+$16000
VARIABLES		rs.b 0					; Start of variables
			rs.b $800
irq1_flag		rs.b 1					; Graphics interrupt flag
			rs.b $17FF
VARIABLES_SIZE		equ __RS-VARIABLES			; Size of variables area

decomp_window		equ WORD_RAM_2M+$38000			; Decompression sliding window

; ------------------------------------------------------------------------------
