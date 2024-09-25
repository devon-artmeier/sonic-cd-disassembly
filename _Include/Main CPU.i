; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Main CPU definitions
; ------------------------------------------------------------------------------

MAIN_CPU		equ 1					; Main CPU

; ------------------------------------------------------------------------------
; Memory map
; ------------------------------------------------------------------------------

; Expansion
EXPANSION		equ 0					; Expansion memory start
EXPANSION_SIZE		equ $400000				; Expansion memory end
EXPANSION_END		equ EXPANSION+EXPANSION_SIZE		; Expansion memory size

; Mega CD BIOS ROM
CD_BIOS			equ EXPANSION				; BIOS start
CD_BIOS_SIZE		equ $20000				; BIOS size
CD_BIOS_END		equ CD_BIOS+CD_BIOS_SIZE		; BIOS end

; BIOS functions
BiosSetVdpRegs		equ CD_BIOS+$2B0			; Set up VDP registers
BiosDma68k		equ CD_BIOS+$2D4			; DMA 68000 data to VDP memory

; Mega CD PRG-RAM
PRG_RAM_BANK		equ EXPANSION+$20000			; Program RAM bank start
PRG_RAM_BANK_SIZE	equ $40000				; Program RAM bank size
PRG_RAM_BANK_END	equ PRG_RAM_BANK+PRG_RAM_BANK_SIZE	; Program RAM bank end

; Mega CD Word RAM
WORD_RAM_1M		equ EXPANSION+$200000			; Word RAM start (1M/1M)
WORD_RAM_1M_SIZE	equ $20000				; Word RAM size (1M/1M)
WORD_RAM_1M_END		equ WORD_RAM_1M+WORD_RAM_1M_SIZE	; Word RAM end (1M/1M)
WORD_RAM_2M		equ EXPANSION+$200000			; Word RAM start (2M)
WORD_RAM_2M_SIZE	equ $40000				; Word RAM size (2M)
WORD_RAM_2M_END		equ WORD_RAM_2M+WORD_RAM_2M_SIZE	; Word RAM end (2M)
WORD_RAM_IMAGE		equ EXPANSION+$220000			; Word RAM image start (1M/1M)
WORD_RAM_IMAGE_SIZE	equ $20000				; Word RAM image size (1M/1M)
WORD_RAM_IMAGE_END	equ WORD_RAM_IMAGE+WORD_RAM_IMAGE_SIZE	; Word RAM image size (1M/1M)

; Cartridge
CARTRIDGE		equ $400000				; Cartridge start
CARTRIDGE_SIZE		equ $400000				; Cartridge size
CARTRIDGE_END		equ CARTRIDGE+CARTRIDGE_SIZE		; Cartridge end

; RAM cartridge
RAM_CART_ID		equ CARTRIDGE+1				; RAM cartridge ID
RAM_CART_DATA		equ CARTRIDGE+$200001			; RAM cartridge data
RAM_CART_DATA_SIZE	equ $80000				; RAM cartridge data size
RAM_CART_DATA_END	equ RAM_CART_DATA+RAM_CART_DATA_SIZE	; RAM cartridge data end
RAM_CART_PROTECT	equ CARTRIDGE+$3FFFFF			; RAM cartridge memory protection flag

; Special cartridge
SPECIAL_CART_ID		equ CARTRIDGE+$10			; Special cartridge ID
SPECIAL_CART_START	equ CARTRIDGE+$20			; Special cartridge entry point

; Z80 RAM
Z80_RAM			equ $A00000				; Z80 RAM start
Z80_RAM_SIZE		equ $2000				; Z80 RAM size
Z80_RAM_END		equ Z80_RAM+Z80_RAM_SIZE		; Z80 RAM end

; YM2612
YM_ADDR_0		equ $A04000				; YM2612 address port 0
YM_DATA_0		equ $A04001				; YM2612 data port 0
YM_ADDR_1		equ $A04002				; YM2612 address port 1
YM_DATA_1		equ $A04003				; YM2612 data port 1

; I/O
IO_REGS			equ $A10000				; I/O registers base
VERSION			equ $A10001				; Hardware version
IO_DATA_1		equ $A10003				; I/O port 1 data
IO_DATA_2		equ $A10005				; I/O port 2 data
IO_DATA_3		equ $A10007				; I/O port 3 data
IO_CTRL_1		equ $A10009				; I/O port 1 control
IO_CTRL_2		equ $A1000B				; I/O port 2 control
IO_CTRL_3		equ $A1000D				; I/O port 3 control

; Z80 bus
Z80_BUS			equ $A11100				; Z80 bus request
Z80_RESET		equ $A11200				; Z80 reset

; Mega CD registers
MCD_REGS		equ $A12000				; Mega CD registers base
MCD_IRQ2		equ $A12000				; IRQ2 request
MCD_RESET		equ $A12001				; Reset
MCD_PROTECT		equ $A12002				; Program RAM write protection
MCD_MEM_MODE		equ $A12003				; Memory mode
MCD_CDC_MODE		equ $A12004				; CDC mode/Device destination
MCD_USER_HBLANK		equ $A12006				; User H-BLANK interrupt address
MCD_CDC_HOST		equ $A12008				; CDC data
MCD_STOPWATCH		equ $A1200C				; Stopwatch
MCD_COMM_FLAGS		equ $A1200E				; Communication flags
MCD_MAIN_FLAG		equ $A1200E				; Main CPU communication flag
MCD_SUB_FLAG		equ $A1200F				; Sub CPU communication flag
MCD_MAIN_COMMS		equ $A12010				; Main CPU communication registers
MCD_MAIN_COMM_0		equ $A12010				; Main CPU communication register 0
MCD_MAIN_COMM_1		equ $A12011				; Main CPU communication register 1
MCD_MAIN_COMM_2		equ $A12012				; Main CPU communication register 2
MCD_MAIN_COMM_3		equ $A12013				; Main CPU communication register 3
MCD_MAIN_COMM_4		equ $A12014				; Main CPU communication register 4
MCD_MAIN_COMM_5		equ $A12015				; Main CPU communication register 5
MCD_MAIN_COMM_6		equ $A12016				; Main CPU communication register 6
MCD_MAIN_COMM_7		equ $A12017				; Main CPU communication register 7
MCD_MAIN_COMM_8		equ $A12018				; Main CPU communication register 8
MCD_MAIN_COMM_9		equ $A12019				; Main CPU communication register 9
MCD_MAIN_COMM_10	equ $A1201A				; Main CPU communication register 10
MCD_MAIN_COMM_11	equ $A1201B				; Main CPU communication register 11
MCD_MAIN_COMM_12	equ $A1201C				; Main CPU communication register 12
MCD_MAIN_COMM_13	equ $A1201D				; Main CPU communication register 13
MCD_MAIN_COMM_14	equ $A1201E				; Main CPU communication register 14
MCD_MAIN_COMM_15	equ $A1201F				; Main CPU communication register 15
MCD_SUB_COMMS		equ $A12020				; Sub CPU communication registers
MCD_SUB_COMM_0		equ $A12020				; Sub CPU communication register 0
MCD_SUB_COMM_1		equ $A12021				; Sub CPU communication register 1
MCD_SUB_COMM_2		equ $A12022				; Sub CPU communication register 2
MCD_SUB_COMM_3		equ $A12023				; Sub CPU communication register 3
MCD_SUB_COMM_4		equ $A12024				; Sub CPU communication register 4
MCD_SUB_COMM_5		equ $A12025				; Sub CPU communication register 5
MCD_SUB_COMM_6		equ $A12026				; Sub CPU communication register 6
MCD_SUB_COMM_7		equ $A12027				; Sub CPU communication register 7
MCD_SUB_COMM_8		equ $A12028				; Sub CPU communication register 8
MCD_SUB_COMM_9		equ $A12029				; Sub CPU communication register 9
MCD_SUB_COMM_10		equ $A1202A				; Sub CPU communication register 10
MCD_SUB_COMM_11		equ $A1202B				; Sub CPU communication register 11
MCD_SUB_COMM_12		equ $A1202C				; Sub CPU communication register 12
MCD_SUB_COMM_13		equ $A1202D				; Sub CPU communication register 13
MCD_SUB_COMM_14		equ $A1202E				; Sub CPU communication register 14
MCD_SUB_COMM_15		equ $A1202F				; Sub CPU communication register 15

; TMSS
TMSS_SEGA		equ $A14000				; TMSS write register

; VDP/PSG
VDP_DATA		equ $C00000				; VDP data port
VDP_CTRL		equ $C00004				; VDP control port
VDP_HV			equ $C00008				; VDP H/V counter
PSG_CTRL		equ $C00011				; PSG control port

; Work RAM
WORK_RAM		equ $FF0000				; Work RAM start
WORK_RAM_SIZE		equ $10000				; Work RAM size
WORK_RAM_END		equ WORK_RAM+WORK_RAM_SIZE		; Work RAM end

; CD Work RAM assignments
_EXCPT			equ $FFFFFD00				; Exception
_LEVEL6			equ $FFFFFD06				; V-BLANK interrupt
_LEVEL4			equ $FFFFFD0C				; H-BLANK interrupt
_LEVEL2			equ $FFFFFD12				; External interrupt
_TRAP00			equ $FFFFFD18				; TRAP #00
_TRAP01			equ $FFFFFD1E				; TRAP #01
_TRAP02			equ $FFFFFD24				; TRAP #02
_TRAP03			equ $FFFFFD2A				; TRAP #03
_TRAP04			equ $FFFFFD30				; TRAP #04
_TRAP05			equ $FFFFFD36				; TRAP #05
_TRAP06			equ $FFFFFD3C				; TRAP #06
_TRAP07			equ $FFFFFD42				; TRAP #07
_TRAP08			equ $FFFFFD48				; TRAP #08
_TRAP09			equ $FFFFFD4E				; TRAP #09
_TRAP10			equ $FFFFFD54				; TRAP #10
_TRAP11			equ $FFFFFD5A				; TRAP #11
_TRAP12			equ $FFFFFD60				; TRAP #12
_TRAP13			equ $FFFFFD66				; TRAP #13
_TRAP14			equ $FFFFFD6C				; TRAP #14
_TRAP15			equ $FFFFFD72				; TRAP #15
_CHKERR			equ $FFFFFD78				; CHK exception
_ADRERR			equ $FFFFFD7E				; Address error
_CODERR			equ $FFFFFD7E				; Illegal instruction
_DIVERR			equ $FFFFFD84				; Division by zero
_TRPERR			equ $FFFFFD8A				; TRAPV exception
_NOCOD0			equ $FFFFFD90				; Line A emulator
_NOCOD1			equ $FFFFFD96				; Line F emulator
_SPVERR			equ $FFFFFD9C				; Privilege violation
_TRACE			equ $FFFFFDA2				; TRACE exception
_BURAM			equ $FFFFFDAE				; Cartridge Backup RAM handler

; ------------------------------------------------------------------------------
; BIOS function codes
; ------------------------------------------------------------------------------

BRMINIT			equ $00					; Backup RAM initialization
BRMSTAT			equ $01					; Backup RAM status
BRMSERCH		equ $02					; Backup RAM searchh
BRMREAD			equ $03					; Backup RAM read
BRMWRITE		equ $04					; Backup RAM write
BRMDEL			equ $05					; Backup RAM delete
BRMFORMAT		equ $06					; Backup RAM format
BRMDIR			equ $07					; Backup RAM directory
BRMVERIFY		equ $08					; Backup RAM verify

; ------------------------------------------------------------------------------
; Reqeust Z80 bus access
; ------------------------------------------------------------------------------
; PARAMETERS:
;	reg - Z80 control port (optional)
; ------------------------------------------------------------------------------

requestZ80 macro reg
	if narg>0
		move.w	#$100,\reg
	else
		move.w	#$100,Z80_BUS
	endif
	endm

; ------------------------------------------------------------------------------
; Wait for Z80 bus acknowledgement
; ------------------------------------------------------------------------------
; PARAMETERS:
;	reg - Z80 control port (optional)
; ------------------------------------------------------------------------------

waitZ80 macro reg
.Wait\@:
	if narg>0
		btst	#0,\reg
	else
		btst	#0,Z80_BUS
	endif
	bne.s	.Wait\@
	endm

; ------------------------------------------------------------------------------
; Stop the Z80 and get bus access
; ------------------------------------------------------------------------------
; PARAMETERS:
;	reg - Z80 control port (optional)
; ------------------------------------------------------------------------------

stopZ80 macro reg
	if narg>0
		requestZ80 \reg
		waitZ80 \reg
	else
		requestZ80
		waitZ80
	endif
	endm

; ------------------------------------------------------------------------------
; Start the Z80 and release bus access
; ------------------------------------------------------------------------------
; PARAMETERS:
;	reg - Z80 bus port (optional)
; ------------------------------------------------------------------------------

startZ80 macro reg
	if narg>0
		move.w	#0,\reg
	else
		move.w	#0,Z80_BUS
	endif
	endm

; ------------------------------------------------------------------------------
; Start Z80 reset
; ------------------------------------------------------------------------------
; PARAMETERS:
;	reg - Z80 reset port (optional)
; ------------------------------------------------------------------------------

resetZ80On macro reg
	if narg>0
		move.w	#0,\reg
	else
		move.w	#0,Z80_RESET
	endif
	ror.b	#8,d0
	endm

; ------------------------------------------------------------------------------
; Stop Z80 reset
; ------------------------------------------------------------------------------
; PARAMETERS:
;	reg - Z80 reset port (optional)
; ------------------------------------------------------------------------------

resetZ80Off macro reg
	if narg>0
		move.w	#$100,\reg
	else
		move.w	#$100,Z80_RESET
	endif
	endm

; ------------------------------------------------------------------------------
; Wait for a VDP DMA to finish
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ctrl - VDP control port (optional)
; ------------------------------------------------------------------------------

waitDma macro ctrl
.Wait\@:
	if narg>0
		btst	#1,\reg
	else
		move.w	VDP_CTRL,d0
		btst	#1,d0
	endif
	bne.s	.Wait\@
	endm

; ------------------------------------------------------------------------------
; VDP command instruction
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ins  - Instruction
;	addr - Address in VDP memory
;	type - Type of VDP memory
;	rwd  - VDP command
;	dest - Destination (optional)
; ------------------------------------------------------------------------------

VRAM_WRITE_CMD		equ $40000000				; VRAM write
CRAM_WRITE_CMD		equ $C0000000				; CRAM write
VSRAM_WRITE_CMD		equ $40000010				; VSRAM write
VRAM_READ_CMD		equ $00000000				; VRAM read
CRAM_READ_CMD		equ $00000020				; CRAM read
VSRAM_READ_CMD		equ $00000010				; VSRAM read
VRAM_DMA_CMD		equ $40000080				; VRAM DMA
CRAM_DMA_CMD		equ $C0000080				; CRAM DMA
VSRAM_DMA_CMD		equ $40000090				; VSRAM DMA
VRAM_COPY_CMD		equ $000000C0				; VRAM DMA copy

; ------------------------------------------------------------------------------

vdpCmd macro ins, addr, type, rwd, dest
	local cmd
	cmd: = (\type\_\rwd\_CMD)|(((\addr)&$3FFF)<<16)|((\addr)/$4000)
	if narg=5
		\ins	#\#cmd,\dest
	else
		\ins	cmd
	endif
	endm

; ------------------------------------------------------------------------------
; VDP command instruction (low word)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ins  - Instruction
;	addr - Address in VDP memory
;	type - Type of VDP memory
;	rwd  - VDP command
;	dest - Destination (optional)
; ------------------------------------------------------------------------------

vdpCmdLo macro ins, addr, type, rwd, dest
	local cmd
	cmd: = ((\type\_\rwd\_CMD)&$FFFF)|((\addr)/$4000)
	if narg=5
		\ins	#\#cmd,\dest
	else
		\ins	cmd
	endif
	endm

; ------------------------------------------------------------------------------
; VDP command instruction (high word)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ins  - Instruction
;	addr - Address in VDP memory
;	type - Type of VDP memory
;	rwd  - VDP command
;	dest - Destination (optional)
; ------------------------------------------------------------------------------

vdpCmdHi macro ins, addr, type, rwd, dest
	local cmd
	cmd: = ((\type\_\rwd\_CMD)>>16)|((\addr)&$3FFF)
	if narg=5
		\ins	#\#cmd,\dest
	else
		\ins	cmd
	endif
	endm

; ------------------------------------------------------------------------------
; VDP DMA from 68000 memory to VDP memory
; ------------------------------------------------------------------------------
; PARAMETERS:
;	src  - Source address in 68000 memory
;	dest - Destination address in VDP memory
;	size - Size of data in bytes
;	type - Type of VDP memory
;	a6.l - VDP control port
; ------------------------------------------------------------------------------

dma68k2 macro src, dest, size, type
	move.l	#$93009400|((((\size)/2)&$FF00)>>8)|((((\size)/2)&$FF)<<16),(a6)
	move.l	#$95009600|((((\src)/2)&$FF00)>>8)|((((\src)/2)&$FF)<<16),(a6)
	move.w	#$9700|(((\src)>>17)&$7F),(a6)
	vdpCmdHi move.w,\dest,\type,DMA,(a6)
	vdpCmdLo move.w,\dest,\type,DMA,-(sp)
	move.w	(sp)+,(a6)

	vdpCmd move.l,\dest,\type,WRITE,(a6)
	move.w	\src,VDP_DATA
	endm

; ------------------------------------------------------------------------------
; VDP DMA from 68000 memory to VDP memory
; (Automatically sets VDP control port in a6)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	src  - Source address in 68000 memory
;	dest - Destination address in VDP memory
;	size - Size of data in bytes
;	type - Type of VDP memory
; ------------------------------------------------------------------------------

dma68k macro src, dest, size, type
	lea	VDP_CTRL,a6
	dma68k2 \src,\dest,\size,\type
	endm

; ------------------------------------------------------------------------------
; Fill VRAM with byte
; ------------------------------------------------------------------------------
; PARAMETERS:
;	addr - Address in VRAM
;	size - Size of fill in bytes
;	byte - Byte to fill VRAM with
; ------------------------------------------------------------------------------

vramFill macro addr, size, byte, ctrl, data
	lea	VDP_CTRL,a6
	move.w	#$8F01,(a6)
	move.l	#$93009400|((((\size)-1)&$FF00)>>8)|((((\size)-1)&$FF)<<16),(a6)
	move.w	#$9780,(a6)
	vdpCmd move.l,\addr,VRAM,DMA,(a6)
	move.w	#(\byte)<<8,VDP_DATA
	waitDma 1(a6)

	vdpCmd move.l,\addr,VRAM,WRITE,(a6)
	move.w	#((\byte)<<8)|(\byte),VDP_DATA
	move.w	#$8F02,(a6)
	endm

; ------------------------------------------------------------------------------
; Copy a region of VRAM to a location in VRAM
; (Auto-increment should be set to 1 beforehand)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	src  - Source address in VRAM
;	dest - Destination address in VRAM
;	size - Size of copy in bytes
; ------------------------------------------------------------------------------

vramCopy macro src, dest, size, ctrl
	lea	VDP_CTRL,a6
	move.w	#$8F01,(a6)
	move.l	#$93009400|((((\size)-1)&$FF00)>>8)|((((\size)-1)&$FF)<<16),(a6)
	move.l	#$95009600|(((\src)&$FF00)>>8)|(((\src)&$FF)<<16),(a6)
	move.w	#$97C0,(a6)
	vdpCmd move.l,\dest,VRAM,COPY,(a6)
	waitDma 1(a6)
	move.w	#$8F02,(a6)
	endm

; ------------------------------------------------------------------------------
; Copy image buffer to VRAM
; ------------------------------------------------------------------------------
; PARAMETERS:
;	src  - Source address
;	buf  - Buffer ID
;	part - Buffer part ID
; ------------------------------------------------------------------------------

copyImg macro src, buf, part
	local off, size, vadr
	
	if (\part)=0
		off: = 0
		len: = IMGV1LEN
	else
		off: = IMGV1LEN
		len: = IMGLENGTH-IMGV1LEN
	endif
	
	vadr: = IMGVRAM+((\buf)*IMGLENGTH)
	if (\part)<>0
		vadr: = vadr+IMGV1LEN
	endif

	DMA68K	(\src)+off,vadr,\#len,VRAM
	endm

; ------------------------------------------------------------------------------
