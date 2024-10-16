; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code
	
	xref GiveWordRamAccess, SubCpuCommand, WaitWordRamAccess
	
; ------------------------------------------------------------------------------
; Read save data
; ------------------------------------------------------------------------------

	xdef ReadSaveData
ReadSaveData:
	bsr.w	GetBuramData					; Get Backup RAM data

	move.w	buram_zone,saved_stage				; Read save data
	move.b	buram_good_futures,good_future_zones
	move.b	buram_title_flags,title_flags
	move.b	buram_attack_unlock,time_attack_unlock
	move.b	buram_unknown,unknown_buram_var
	move.b	buram_special_stage,current_special_stage
	move.b	buram_time_stones,time_stones

	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM access
	rts

; ------------------------------------------------------------------------------
; Get Backup RAM data
; ------------------------------------------------------------------------------

GetBuramData:
	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM access
	
	move.w	#SYS_TEMP_READ,d0				; Read temporary save data
	btst	#0,save_disabled				; Is saving to Backup RAM disabled?
	bne.s	.Read						; If so, branch
	move.w	#SYS_BURAM_READ,d0				; Read Backup RAM save data
	
.Read:
	bsr.w	SubCpuCommand					; Run command
	bra.w	WaitWordRamAccess				; Wait for Word RAM access

; ------------------------------------------------------------------------------
; Write save data
; ------------------------------------------------------------------------------

	xdef WriteSaveData
WriteSaveData:
	bsr.s	GetBuramData					; Get Backup RAM data

	move.w	saved_stage,buram_zone				; Write save data
	move.b	good_future_zones,buram_good_futures
	move.b	title_flags,buram_title_flags
	move.b	time_attack_unlock,buram_attack_unlock
	move.b	unknown_buram_var,buram_unknown
	move.b	current_special_stage,buram_special_stage
	move.b	time_stones,buram_time_stones

	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM access

	move.w	#SYS_TEMP_WRITE,d0				; Write temporary save data
	btst	#0,save_disabled				; Is saving to Backup RAM disabled?
	bne.s	.Read						; If so, branch
	move.w	#SYS_BURAM_WRITE,d0				; Write Backup RAM save data
	
.Read:
	bsr.w	SubCpuCommand					; Run command
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access
	bra.w	GiveWordRamAccess				; Give Sub CPU Word RAM access
	
; ------------------------------------------------------------------------------
