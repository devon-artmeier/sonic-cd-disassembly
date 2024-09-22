; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Game/Time Over object
; ------------------------------------------------------------------------------

oGmOverDestX	EQU	obj.var_2A			; Destination X position

; ------------------------------------------------------------------------------

ObjGameOver:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjGameOver_Init-.Index
	dc.w	ObjGameOver_Main-.Index
	
; ------------------------------------------------------------------------------
; Initialization
; ------------------------------------------------------------------------------

ObjGameOver_Init:
	move.w	#SCMD_FADEPCM,d0		; Fade out PCM
	jsr	SubCPUCmd
	
	addq.b	#2,obj.routine(a0)			; Next routine
	move.w	#96+128,obj.screen_y(a0)		; Set position
	move.w	#0+128,obj.x(a0)
	move.w	#160+128,oGmOverDestX(a0)	; Set destination X position
	move.w	#$8544,obj.sprite_tile(a0)		; Set base tile ID
	move.l	#MapSpr_GameOver,obj.sprites(a0)	; Set mappings
	
	move.b	#8,powerup			; Load "GAME OVER" art
	bclr	#0,time_over			; Was there a time over?
	beq.s	.NotTimeOver			; If not, branch
	tst.b	lives				; Are we out of lives?
	beq.s	.GameOver			; If so, branch
	move.l	#MapSpr_TimeOver,obj.sprites(a0)	; Set "TIME OVER" mappings
	addq.b	#2,powerup			; Load "TIME OVER" art
	bra.s	.GameOver

.NotTimeOver:
	tst.b	lives				; Are we out of lives?
	bne.s	.Destroy			; If not, branch

.GameOver:
	bset	#7,powerup			; Load the art
	jsr	FindObjSlot			; Spawn "OVER" text
	beq.s	.SpawnOverText

.Destroy:
	jmp	DeleteObject			; Delete ourselves

.SpawnOverText:
	move.b	#$3B,obj.id(a1)			; "OVER" text
	move.b	obj.routine(a0),obj.routine(a1)	; Set routine
	move.w	obj.sprite_tile(a0),obj.sprite_tile(a1)		; Set base tile ID
	move.l	obj.sprites(a0),obj.sprites(a1)		; Set mappings
	move.b	#1,obj.sprite_frame(a1)		; Set to "OVER" frame
	move.w	#128+96,obj.screen_y(a1)		; Set position
	move.w	#320+128,obj.x(a1)
	move.w	#160+128,oGmOverDestX(a1)	; Set destination X position
	
	tst.b	lives				; Are we out of lives?
	bne.s	ObjGameOver_Main		; If not, branch
	move.w	#SCMD_GMOVERMUS,d0		; Play game over music
	jmp	SubCPUCmd

; ------------------------------------------------------------------------------

ObjGameOver_Main:
	moveq	#8,d0				; Movement speed
	move.w	oGmOverDestX(a0),d1		; Are we at our destination?
	cmp.w	obj.x(a0),d1
	beq.s	.Draw				; If so, branch
	bge.s	.AddX				; If we're left of it, branch
	neg.w	d0				; If we're right of it, move left

.AddX:
	add.w	d0,obj.x(a0)			; Move

.Draw:
	jmp	DrawObject			; Draw sprite

; ------------------------------------------------------------------------------
; Data
; ------------------------------------------------------------------------------

	include	"Level/_Objects/Game Over/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
