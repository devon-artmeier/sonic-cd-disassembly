; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Flags
; ------------------------------------------------------------------------------

MMD_SUB_BIT		equ 6					; Sub CPU Word RAM access flag
MMD_SUB			equ 1<<MMD_SUB_BIT			; Sub CPU Word RAM access flag mask

; ------------------------------------------------------------------------------
; MMD header structure
; ------------------------------------------------------------------------------

	rsreset
mmd.flags		rs.b 1					; Flags
			rs.b 1
mmd.origin		rs.l 1					; Origin address
mmd.size		rs.w 1					; Size of file data
mmd.entry		rs.l 1					; Entry address
mmd.hblank		rs.l 1					; H-BLANK interrupt address
mmd.vblank		rs.l 1					; V-BLANK interrupt address
			rs.b $100-__RS
mmd.file		rs.b 0					; Start of file data
mmd.struct_size		rs.b 0					; Size of structure

; ------------------------------------------------------------------------------
; MMD header
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - Flags
;	\2 - Origin address
;	\3 - Size of file data (if origin is not Word RAM)
;	\4 - Entry address
;	\5 - H-BLANK interrupt address
;	\6 - V-BLANK interrupt address
; ------------------------------------------------------------------------------

mmd macro
	dc.b	\1, 0
	ifeq (\2)-WORD_RAM_2M
		dc.l	0
		dc.w	0
	else
		dc.l	\2
		dc.w	(\3)/4-1
	endif
	dc.l	\4, \5, \6
	dcb.b 	mmd.struct_size-$14, 0
	endm

; ------------------------------------------------------------------------------
