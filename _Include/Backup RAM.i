; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Shared Backup RAM management variables
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------

; Backup RAM command IDs
	rsset	1
BRCMD_INIT		rs.b 1			; Initialize Backup RAM interaction
BRCMD_STATUS		rs.b 1			; Get Backup RAM status
BRCMD_SEARCH		rs.b 1			; Search Backup RAM
BRCMD_READ		rs.b 1			; Read from Backup RAM
BRCMD_WRITE		rs.b 1			; Write to Backup RAM
BRCMD_DELETE		rs.b 1			; Delete Backup RAM
BRCMD_FORMAT		rs.b 1			; Format Backup RAM
BRCMD_DIR		rs.b 1			; Get Backup RAM directory
BRCMD_VERIFY		rs.b 1			; Verify Backup RAM
BRCMD_RDSAVE		rs.b 1			; Read save data (Sub CPU)
BRCMD_WRSAVE		rs.b 1			; Write save data (Sub CPU)

; Backup RAM types
BRTYPE_INT	EQU	0			; Internal Backup RAM
BRTYPE_CART	EQU	1			; RAM cartridge

; Backup RAM file
BRFILENAMESZ	EQU	$B			; File name length

; ------------------------------------------------------------------------------
; Save data
; ------------------------------------------------------------------------------

	rsreset
; Time attack save data
save.attack_times	rs.l (7*3*3)+(7*3)			; Time attack times
save.attack_names	rs.l (7*3*3)+(7*3)			; Time attack initials
save.attack_default	rs.l 1					; Time attack default initials
save.attack_struct_size	rs.b 0					; Size of time attack structure

; Main data save data
save.zone		rs.b 1					; Zone
save.attack_unlock	rs.b 1					; Last unlocked time attack zone
save.unknown		rs.b 1					; Unknown
save.good_futures	rs.b 1					; Good futures achieved flags
save.title_flags	rs.b 1					; Title screen flags
			rs.b 3
save.special_stage	rs.b 1					; Special stage ID
save.time_stones	rs.b 1					; Time stones retrieved flags
			rs.b $14
save.main_struct_size	equ __rs-save.attack_struct_size	; Main save data structure size

save.struct_size	rs.b 0					; Size of structure

; Save data in Backup RAM buffer
buram_attack_times	equ WORD_RAM_2M+save.attack_times
buram_attack_names	equ WORD_RAM_2M+save.attack_names
buram_attack_default	equ WORD_RAM_2M+save.attack_default
buram_zone		equ WORD_RAM_2M+save.zone
buram_attack_unlock	equ WORD_RAM_2M+save.attack_unlock
buram_unknown		equ WORD_RAM_2M+save.unknown
buram_good_futures	equ WORD_RAM_2M+save.good_futures
buram_title_flags	equ WORD_RAM_2M+save.title_flags
buram_special_stage	equ WORD_RAM_2M+save.special_stage
buram_time_stones	equ WORD_RAM_2M+save.time_stones

; ------------------------------------------------------------------------------
; Backup RAM function parameters
; ------------------------------------------------------------------------------

	rsreset
buramFile		rs.b BRFILENAMESZ		; File name
buramMisc		rs.b 0				; Misc. parameters start
buramFlag		rs.b 1				; Flag
buramBlkSz		rs.w 1				; Block size
BURAMPARAMSZ		rs.b 0				; Size of structure

; ------------------------------------------------------------------------------
; Shared Word RAM variables
; ------------------------------------------------------------------------------

	rsset	WORD_RAM_2M+$20
commandID		rs.b 1				; Command ID
cmdStatus		rs.b 1				; Command status
buramD0			rs.w 1				; Backup RAM function returned d0
buramD1			rs.w 1				; Backup RAM function returned d1
buramType		rs.b 1				; Backup RAM type
ramCartFound		rs.b 1				; RAM cart found flag
buramDisabled		rs.b 1				; Backup RAM disabled flag
writeFlag		rs.b 1				; Backup RAM function write flag
blockSize		rs.w 1				; Backup RAM function block size
			rs.b 4
buramParams		rs.b BURAMPARAMSZ		; Backup RAM function parameters
			rs.b 2
buramData		rs.b save.struct_size		; Backup RAM data

; ------------------------------------------------------------------------------
