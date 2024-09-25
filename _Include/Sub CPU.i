; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Sub CPU definitions
; ------------------------------------------------------------------------------

SUB_CPU			equ 1					; Sub CPU

; ------------------------------------------------------------------------------
; Addresses
; ------------------------------------------------------------------------------

; Program RAM
PRG_RAM			equ 0					; Program RAM start
PRG_RAM_SIZE		equ $80000				; Program RAM size
PRG_RAM_END		equ PRG_RAM+PRG_RAM_SIZE		; Program RAM end
SP_START		equ PRG_RAM+$6000			; System program start

; Word RAM
WORD_RAM_1M		equ $C0000				; Word RAM start (1M/1M)
WORD_RAM_1M_SIZE	equ $20000				; Word RAM size (1M/1M)
WORD_RAM_1M_END		equ WORD_RAM_1M+WORD_RAM_1M_SIZE	; Word RAM end (1M/1M)
WORD_RAM_2M		equ $80000				; Word RAM start (2M)
WORD_RAM_2M_SIZE	equ $40000				; Word RAM size (2M)
WORD_RAM_2M_END		equ WORD_RAM_2M+WORD_RAM_2M_SIZE	; Word RAM end (2M)
WORD_RAM_IMAGE		equ $80000				; Word RAM image start (1M/1M)
WORD_RAM_IMAGE_SIZE	equ $40000				; Word RAM image size (1M/1M)
WORD_RAM_IMAGE_END	equ WORD_RAM_IMAGE+WORD_RAM_IMAGE_SIZE	; Word RAM image size (1M/1M)

; PCM registers
PCM_REGS		equ $FF0000				; PCM registers base
PCM_VOLUME		equ $FF0001				; Volume
PCM_PAN			equ $FF0003				; Pan
PCM_FREQ_L		equ $FF0005				; Frequency (low)
PCM_FREQ_H		equ $FF0007				; Frequency (high)
PCM_LOOP_L		equ $FF0009				; Wave memory stop address (low)
PCM_LOOP_H		equ $FF000B				; Wave memory stop address (high)
PCM_START		equ $FF000D				; Wave memory start address
PCM_CTRL		equ $FF000F				; Control
PCM_ON_OFF		equ $FF0011				; On/Off
PCM_ADDR		equ $FF0021				; Wave address
PCM_ADDR_1L		equ $FF0021				; PCM1 wave address (low)
PCM_ADDR_1H		equ $FF0023				; PCM1 wave address (high)
PCM_ADDR_2L		equ $FF0025				; PCM2 wave address (low)
PCM_ADDR_2H		equ $FF0027				; PCM2 wave address (high)
PCM_ADDR_3L		equ $FF0029				; PCM3 wave address (low)
PCM_ADDR_3H		equ $FF002B				; PCM3 wave address (high)
PCM_ADDR_4L		equ $FF002D				; PCM4 wave address (low)
PCM_ADDR_4H		equ $FF002F				; PCM4 wave address (high)
PCM_ADDR_5L		equ $FF0031				; PCM5 wave address (low)
PCM_ADDR_5H		equ $FF0033				; PCM5 wave address (high)
PCM_ADDR_6L		equ $FF0035				; PCM6 wave address (low)
PCM_ADDR_6H		equ $FF0037				; PCM6 wave address (high)
PCM_ADDR_7L		equ $FF0039				; PCM7 wave address (low)
PCM_ADDR_7H		equ $FF003B				; PCM7 wave address (high)
PCM_ADDR_8L		equ $FF003D				; PCM8 wave address (low)
PCM_ADDR_8H		equ $FF003F				; PCM8 wave address (high)
PCM_WAVE_RAM		equ $FF2001				; Wave RAM

; Gate array
MCD_REGS		equ $FFFF8000				; Mega CD registers base
MCD_LED_CTRL		equ $FFFF8000				; LED control
	MCDR_LEDR_BIT:		equ 0				; Red LED on flag
	MCDR_LEDR:		equ 1<<MCDR_LEDR_BIT
	MCDR_LEDG_BIT:		equ 1				; Green LED on flag
	MCDR_LEDG:		equ 1<<MCDR_LEDG_BIT
MCD_RESET		equ $FFFF8001				; Periphery reset
	MCDR_RES0_BIT:		equ 0				; Reset flag
	MCDR_RES0:		equ 1<<MCDR_RES0_BIT
	MCDR_VER_BIT:		equ 4				; Version number
MCD_PROTECT		equ $FFFF8002				; Write protection
MCD_MEM_MODE		equ $FFFF8003				; Memory mode
	MCDR_RET_BIT:		equ 0				; Main CPU Word RAM access flag
	MCDR_RET:		equ 1<<MCDR_RET_BIT
	MCDR_DMNA_BIT:		equ 1				; Sub CPU Word RAM access flag
	MCDR_DMNA:		equ 1<<MCDR_DMNA_BIT
	MCDR_MODE_BIT:		equ 2				; Word RAM mode
	MCDR_MODE:		equ 1<<MCDR_MODE_BIT
	MCDR_PM_BIT:		equ 3				; Word RAM write priority mode
	MCDR_PM_OFF:		equ 0<<MCDR_PM_BIT		; Word RAM no priority mode
	MCDR_PM_UNDER:		equ 1<<MCDR_PM_BIT		; Word RAM underwrite mode
	MCDR_PM_OVER:		equ 2<<MCDR_PM_BIT		; Word RAM overwrite mode
MCD_CDC_DEVICE		equ $FFFF8004				; CDC device destination
	MCDR_CDC_MAIN_READ:	equ 2				; Main CPU read
	MCDR_CDC_SUB_READ:	equ 3				; Sub CPU read
	MCDR_CDC_PCM_DMA:	equ 4				; PCM wave RAM DMA
	MCDR_CDC_PRG_DMA:	equ 5				; Program RAM DMA
	MCDR_CDC_WORD_DMA:	equ 7				; Word RAM DMA
	MCDR_UBR_BIT:		equ 5				; Upper byte ready flag
	MCDR_UBR:		equ 1<<MCDR_UBR_BIT
	MCDR_DSR_BIT:		equ 6				; Data set ready flag
	MCDR_DSR:		equ 1<<MCDR_DSR_BIT
	MCDR_EDT_BIT:		equ 7				; End of data transfer flag
	MCDR_EDT:		equ 1<<MCDR_EDT_BIT
MCD_CDC_REG_ADDR	equ $FFFF8005				; CDC register address
MCD_CDC_REG_DATA	equ $FFFF8007				; CDC register data
MCD_CDC_HOST		equ $FFFF8008				; CDC data
MCD_CDC_DMA		equ $FFFF800A				; CDC DMA address
MCD_STOPWATCH		equ $FFFF800C				; Stopwatch
MCD_COMM_FLAGS		equ $FFFF800E				; Communication flags
MCD_MAIN_FLAG		equ $FFFF800E				; Main CPU communication flag
MCD_SUB_FLAG		equ $FFFF800F				; Sub CPU communication flag
MCD_MAIN_COMMS		equ $FFFF8010				; Main CPU communication registers
MCD_MAIN_COMM_0		equ $FFFF8010				; Main CPU communication register 0
MCD_MAIN_COMM_1		equ $FFFF8011				; Main CPU communication register 1
MCD_MAIN_COMM_2		equ $FFFF8012				; Main CPU communication register 2
MCD_MAIN_COMM_3		equ $FFFF8013				; Main CPU communication register 3
MCD_MAIN_COMM_4		equ $FFFF8014				; Main CPU communication register 4
MCD_MAIN_COMM_5		equ $FFFF8015				; Main CPU communication register 5
MCD_MAIN_COMM_6		equ $FFFF8016				; Main CPU communication register 6
MCD_MAIN_COMM_7		equ $FFFF8017				; Main CPU communication register 7
MCD_MAIN_COMM_8		equ $FFFF8018				; Main CPU communication register 8
MCD_MAIN_COMM_9		equ $FFFF8019				; Main CPU communication register 9
MCD_MAIN_COMM_10	equ $FFFF801A				; Main CPU communication register 10
MCD_MAIN_COMM_11	equ $FFFF801B				; Main CPU communication register 11
MCD_MAIN_COMM_12	equ $FFFF801C				; Main CPU communication register 12
MCD_MAIN_COMM_13	equ $FFFF801D				; Main CPU communication register 13
MCD_MAIN_COMM_14	equ $FFFF801E				; Main CPU communication register 14
MCD_MAIN_COMM_15	equ $FFFF801F				; Main CPU communication register 15
MCD_SUB_COMMS		equ $FFFF8020				; Sub CPU communication registers
MCD_SUB_COMM_0		equ $FFFF8020				; Sub CPU communication register 0
MCD_SUB_COMM_1		equ $FFFF8021				; Sub CPU communication register 1
MCD_SUB_COMM_2		equ $FFFF8022				; Sub CPU communication register 2
MCD_SUB_COMM_3		equ $FFFF8023				; Sub CPU communication register 3
MCD_SUB_COMM_4		equ $FFFF8024				; Sub CPU communication register 4
MCD_SUB_COMM_5		equ $FFFF8025				; Sub CPU communication register 5
MCD_SUB_COMM_6		equ $FFFF8026				; Sub CPU communication register 6
MCD_SUB_COMM_7		equ $FFFF8027				; Sub CPU communication register 7
MCD_SUB_COMM_8		equ $FFFF8028				; Sub CPU communication register 8
MCD_SUB_COMM_9		equ $FFFF8029				; Sub CPU communication register 9
MCD_SUB_COMM_10		equ $FFFF802A				; Sub CPU communication register 10
MCD_SUB_COMM_11		equ $FFFF802B				; Sub CPU communication register 11
MCD_SUB_COMM_12		equ $FFFF802C				; Sub CPU communication register 12
MCD_SUB_COMM_13		equ $FFFF802D				; Sub CPU communication register 13
MCD_SUB_COMM_14		equ $FFFF802E				; Sub CPU communication register 14
MCD_SUB_COMM_15		equ $FFFF802F				; Sub CPU communication register 15
MCD_IRQ3_TIME		equ $FFFF8031 				; Interrupt 3 timer
MCD_IRQ_MASK		equ $FFFF8033 				; Interrupt mask
	MCDR_IEN1_BIT:		equ 1				; Graphics interrupt enable flag
	MCDR_IEN1:		equ 1<<MCDR_IEN1_BIT
	MCDR_IEN2_BIT:		equ 1				; Mega Drive interrupt enable flag
	MCDR_IEN2:		equ 1<<MCDR_IEN2_BIT
	MCDR_IEN3_BIT:		equ 1				; Timer interrupt enable flag
	MCDR_IEN3:		equ 1<<MCDR_IEN3_BIT
	MCDR_IEN4_BIT:		equ 1				; CDD interrupt enable flag
	MCDR_IEN4:		equ 1<<MCDR_IEN4_BIT
	MCDR_IEN5_BIT:		equ 1				; CDC interrupt enable flag
	MCDR_IEN5:		equ 1<<MCDR_IEN5_BIT
	MCDR_IEN6_BIT:		equ 1				; Subcode interrupt enable flag
	MCDR_IEN6:		equ 1<<MCDR_IEN6_BIT
MCD_FADER		equ $FFFF8034 				; Fader control/Spindle speed
	MCDR_SSF_BIT:		equ 1				; Spindle speed flag (lower byte)
	MCDR_SSF:		equ 1<<MCDR_SSF_BIT
	MCDR_DEF_BIT:		equ 2				; De-emphasis flag (lower byte)
	MCDR_DEF:		equ 1<<MCDR_DEF_BIT
	MCDR_FD_BIT:		equ 4				; Fade volume data (lower byte)
	MCDR_FD:		equ 1<<MCDR_FD_BIT
	MCDR_EFDT_BIT:		equ 7				; End of fade data transfer (upper byte)
	MCDR_EFDT:		equ 1<<MCDR_EFDT_BIT
MCD_CDD_TYPE		equ $FFFF8036 				; CDD data type
	MCDR_DM_BIT:		equ 0				; CDD data type flag
	MCDR_DM:		equ 1<<MCDR_DM_BIT
MCD_CDD_CTRL		equ $FFFF8037 				; CDD control
	MCDR_DTS_BIT:		equ 0				; Data transfer status flag
	MCDR_DTS:		equ 1<<MCDR_DTS_BIT
	MCDR_DRS_BIT:		equ 1				; Data receive status
	MCDR_DRS:		equ 1<<MCDR_DRS_BIT
	MCDR_HOCK_BIT:		equ 2				; Host clock flag
	MCDR_HOCK:		equ 1<<MCDR_HOCK_BIT
MCD_CDD_STATUSES	equ $FFFF8038 				; CDD statuses
MCD_CDD_STATUS_0	equ $FFFF8038 				; CDD status 0
MCD_CDD_STATUS_1	equ $FFFF8039 				; CDD status 1
MCD_CDD_STATUS_2	equ $FFFF803A 				; CDD status 2
MCD_CDD_STATUS_3	equ $FFFF803B 				; CDD status 3
MCD_CDD_STATUS_4	equ $FFFF803C 				; CDD status 4
MCD_CDD_STATUS_5	equ $FFFF803D 				; CDD status 5
MCD_CDD_STATUS_6	equ $FFFF803E 				; CDD status 6
MCD_CDD_STATUS_7	equ $FFFF803F 				; CDD status 7
MCD_CDD_STATUS_8	equ $FFFF8040 				; CDD status 8
MCD_CDD_STATUS_9	equ $FFFF8041 				; CDD status 9
MCD_CDD_CMDS		equ $FFFF8038 				; CDD commands
MCD_CDD_CMD_0		equ $FFFF8042 				; CDD command 0
MCD_CDD_CMD_1		equ $FFFF8043 				; CDD command 1
MCD_CDD_CMD_2		equ $FFFF8044 				; CDD command 2
MCD_CDD_CMD_3		equ $FFFF8045 				; CDD command 3
MCD_CDD_CMD_4		equ $FFFF8046 				; CDD command 4
MCD_CDD_CMD_5		equ $FFFF8047 				; CDD command 5
MCD_CDD_CMD_6		equ $FFFF8048 				; CDD command 6
MCD_CDD_CMD_7		equ $FFFF8049 				; CDD command 7
MCD_CDD_CMD_8		equ $FFFF804A 				; CDD command 8
MCD_CDD_CMD_9		equ $FFFF804B 				; CDD command 9
MCD_1BPP_COLOR		equ $FFFF804C 				; 1BPP conversion color
MCD_1BPP_IN		equ $FFFF804E 				; 1BPP conversion input data
MCD_1BPP_OUT		equ $FFFF8050 				; 1BPP conversion output data
MCD_IMG_CTRL		equ $FFFF8058				; Image render control (2M)
	MCDR_RPT_BIT:		equ 0				; Image source map repeat flag (lower byte)
	MCDR_RPT:		equ 1<<MCDR_RPT_BIT
	MCDR_STS_BIT:		equ 1				; Image source stamp size flag (lower byte)
	MCDR_STS:		equ 1<<MCDR_STS_BIT
	MCDR_SMS_BIT:		equ 2				; Image source size flag (lower byte)
	MCDR_SMS:		equ 1<<MCDR_SMS_BIT
	MCDR_GRON_BIT:		equ 7				; Image rendering flag (upper byte)
	MCDR_GRON:		equ 1<<MCDR_GRON_BIT
MCD_IMG_SRC_MAP		equ $FFFF805A 				; Image source map address (2M)
MCD_IMG_STRIDE		equ $FFFF805C 				; Image buffer stride (2M)
MCD_IMG_START		equ $FFFF805E 				; Image buffer address (2M)
MCD_IMG_OFFSET		equ $FFFF8060 				; Image buffer pixel offset (2M)
	MCDR_DOT_BIT:		equ 0				; Image buffer pixel offset
	MCDR_LN_BIT:		equ 3				; Image buffer line offset
MCD_IMG_WIDTH		equ $FFFF8062 				; Image buffer width (2M)
MCD_IMG_HEIGHT		equ $FFFF8064 				; Image buffer height (2M)
MCD_IMG_TRACE		equ $FFFF8066 				; Trace table address (2M)
MCD_SUBCODE_ADDR	equ $FFFF8068 				; Subcode address
MCD_SUBCODE_DATA	equ $FFFF8100 				; Subcode data

; ------------------------------------------------------------------------------
; BIOS function codes
; ------------------------------------------------------------------------------

MSCSTOP			equ $02
MSCPAUSEON		equ $03
MSCPAUSEOFF		equ $04
MSCSCANFF		equ $05
MSCSCANFR		equ $06
MSCSCANOFF		equ $07

ROMPAUSEON		equ $08
ROMPAUSEOFF		equ $09

DRVOPEN			equ $0A
DRVINIT			equ $10

MSCPLAY			equ $11
MSCPLAY1		equ $12
MSCPLAYR		equ $13
MSCPLAYT		equ $14
MSCSEEK			equ $15
MSCSEEKT		equ $16

ROMREAD			equ $17
ROMSEEK			equ $18

MSCSEEK1		equ $19
TESTENTRY		equ $1E
TESTENTRYLOOP		equ $1F

ROMREADN		equ $20
ROMREADE		equ $21

CDBCHK			equ $80
CDBSTAT			equ $81
CDBTOCWRITE		equ $82
CDBTOCREAD		equ $83
CDBPAUSE		equ $84

FDRSET			equ $85
FDRCHG			equ $86

CDCSTART		equ $87
CDCSTARTP		equ $88
CDCSTOP			equ $89
CDCSTAT			equ $8A
CDCREAD			equ $8B
CDCTRN			equ $8C
CDCACK			equ $8D

SCDINIT			equ $8E
SCDSTART		equ $8F
SCDSTOP			equ $90
SCDSTAT			equ $91
SCDREAD			equ $92
SCDPQ			equ $93
SCDPQL			equ $94

LEDSET			equ $95

CDCSETMODE		equ $96

WONDERREQ		equ $97
WONDERCHK		equ $98

CBTINIT			equ $00
CBTINT			equ $01
CBTOPENDISC		equ $02
CBTOPENSTAT		equ $03
CBTCHKDISC		equ $04
CBTCHKSTAT		equ $05
CBTIPDISC		equ $06
CBTIPSTAT		equ $07
CBTSPDISC		equ $08
CBTSPSTAT		equ $09

BRMINIT			equ $00
BRMSTAT			equ $01
BRMSERCH		equ $02
BRMREAD			equ $03
BRMWRITE		equ $04
BRMDEL			equ $05
BRMFORMAT		equ $06
BRMDIR			equ $07
BRMVERIFY		equ $08

; ------------------------------------------------------------------------------
; BIOS entry points
; ------------------------------------------------------------------------------

_ADRERR			equ $005F40
_BOOTSTAT		equ $005EA0
_BURAM			equ $005F16
_CDBIOS			equ $005F22
_CDBOOT			equ $005F1C
_CDSTAT			equ $005E80
_CHKERR			equ $005F52
_CODERR			equ $005F46
_DEVERR			equ $005F4C
_LEVEL1			equ $005F76
_LEVEL2			equ $005F7C
_LEVEL3			equ $005F82
_LEVEL4			equ $005F88
_LEVEL5			equ $005F8E
_LEVEL6			equ $005F94
_LEVEL7			equ $005F9A
_NOCOD0			equ $005F6A
_NOCOD1			equ $005F70
_SETJMPTBL		equ $005F0A
_SPVERR			equ $005F5E
_TRACE			equ $005F64
_TRAP00			equ $005FA0
_TRAP01			equ $005FA6
_TRAP02			equ $005FAC
_TRAP03			equ $005FB2
_TRAP04			equ $005FB8
_TRAP05			equ $005FBE
_TRAP06			equ $005FC4
_TRAP07			equ $005FCA
_TRAP08			equ $005FD0
_TRAP09			equ $005FD6
_TRAP10			equ $005FDC
_TRAP11			equ $005FE2
_TRAP12			equ $005FE8
_TRAP13			equ $005FEE
_TRAP14			equ $005FF4
_TRAP15			equ $005FFA
_TRPERR			equ $005F58
_USERCALL0		equ $005F28
_USERCALL1		equ $005F2E
_USERCALL2		equ $005F34
_USERCALL3		equ $005F3A
_USERMODE		equ $005EA6
_WAITVSYNC		equ $005F10

; ------------------------------------------------------------------------------
; BIOS status flags
; ------------------------------------------------------------------------------

BIOS_NO_DISC_BIT	equ 12					; No disc flag
BIOS_NO_DISC		equ 1<<BIOS_NO_DISC_BIT
BIOS_TOC_READ_BIT	equ 13					; TOC read flag
BIOS_TOC_READ		equ 1<<BIOS_TOC_READ_BIT
BIOS_TRAY_OPEN_BIT	equ 14					; Tray open flag
BIOS_TRAY_OPEN		equ 1<<BIOS_TRAY_OPEN_BIT
BIOS_NOT_READY_BIT	equ 15					; Not ready flag
BIOS_NOT_READY		equ 1<<BIOS_NOT_READY_BIT
BIOS_BUSY_MASK		equ $F0

; ------------------------------------------------------------------------------
