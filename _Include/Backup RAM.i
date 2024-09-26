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
	rsset 1
BURAM_CMD_INIT		rs.b 1					; Initialize Backup RAM interaction
BURAM_CMD_STATUS	rs.b 1					; Get Backup RAM status
BURAM_CMD_SEARCH	rs.b 1					; Search Backup RAM
BURAM_CMD_READ		rs.b 1					; Read from Backup RAM
BURAM_CMD_WRITE		rs.b 1					; Write to Backup RAM
BURAM_CMD_DELETE	rs.b 1					; Delete Backup RAM
BURAM_CMD_FORMAT	rs.b 1					; Format Backup RAM
BURAM_CMD_DIRECTORY	rs.b 1					; Get Backup RAM directory
BURAM_CMD_VERIFY	rs.b 1					; Verify Backup RAM
BURAM_CMD_READ_SAVE	rs.b 1					; Read save data (Sub CPU)
BURAM_CMD_WRITE_SAVE	rs.b 1					; Write save data (Sub CPU)

; Backup RAM types
BURAM_TYPE_INTERNAL	equ 0					; Internal
BURAM_TYPE_CART		equ 1					; Cartridge

; Backup RAM file
BURAM_FILE_NAME_SIZE	equ 11					; File name length

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
buram_param.file_name	rs.b BURAM_FILE_NAME_SIZE		; File name
buram_param.misc	rs.b 0					; Misc. parameters start
buram_param.flag	rs.b 1					; Flag
buram_param.block_size	rs.w 1					; Block size
buram_param.struct_size	rs.b 0					; Size of structure

; ------------------------------------------------------------------------------
; Shared Word RAM variables
; ------------------------------------------------------------------------------

	rsset WORD_RAM_2M+$20
buram_command		rs.b 1					; Command ID
buram_status		rs.b 1					; Command status
buram_d0		rs.w 1					; Backup RAM function returned d0
buram_d1		rs.w 1					; Backup RAM function returned d1
buram_type		rs.b 1					; Backup RAM type
buram_cart_found	rs.b 1					; RAM cart found flag
buram_disabled		rs.b 1					; Backup RAM disabled flag
buram_write_flag	rs.b 1					; Backup RAM function write flag
buram_block_size	rs.w 1					; Backup RAM function block size
			rs.b 4
buram_params		rs.b buram_param.struct_size		; Backup RAM function parameters
			rs.b 2
buram_data		rs.b save.struct_size			; Backup RAM data

; ------------------------------------------------------------------------------
