; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; MMD format definitions
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
			rs.b $100-__rs
mmd.file		rs.b 0					; Start of file data
mmd.struct_size		rs.b 0					; Size of structure

; ------------------------------------------------------------------------------
; MMD header
; ------------------------------------------------------------------------------
; PARAMETERS:
;	flags  - Flags
;	origin - Origin address
;	size   - Size of file data (if origin is not Word RAM)
;	entry  - Entry address
;	hblank - H-BLANK interrupt address
;	vblank - V-BLANK interrupt address
; ------------------------------------------------------------------------------

MMD macro flags, origin, size, entry, hblank, vblank
	if (\origin)=WORD_RAM_2M
		org	WORD_RAM_2M
	else
		org	(\origin)-mmd.struct_size
	endif

	dc.b	\flags, 0
	if (\origin)=WORD_RAM_2M
		dc.l	0
		dc.w	0
	else
		dc.l	\origin
		dc.w	(\size)/4-1
	endif
	dc.l	\entry, \hblank, \vblank

	ALIGN 	mmd.struct_size
	endm

; ------------------------------------------------------------------------------
