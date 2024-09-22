; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Dust object (special stage)
; ------------------------------------------------------------------------------

dust.x_speed		equ obj.var_3C		; X velocity

; ------------------------------------------------------------------------------
; Dust object
; ------------------------------------------------------------------------------

ObjDust:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	bsr.w	DrawObject			; Draw sprite
	rts

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjDust_Init-.Index
	dc.w	ObjDust_Main-.Index

; ------------------------------------------------------------------------------

ObjDust_Init:
	move.w	#$87AE,obj.sprite_tile(a0)	; Base tile ID
	move.l	#MapSpr_Dust,obj.sprites(a0)	; Mappings
	move.w	#112+128,obj.sprite_x(a0)	; Set sprite position
	move.w	#212+128,obj.sprite_y(a0)
	moveq	#0,d0				; Set animation
	bsr.w	SetObjAnim
	move.w	#6,obj.timer(a0)		; Set timer
	addq.b	#1,obj.routine(a0)		; Set to main routine
	
	bsr.w	Random				; Add random offset to sprite position
	move.w	d0,d1
	andi.w	#$1F,d0
	add.w	d0,obj.sprite_x(a0)
	andi.w	#7,d0
	add.w	d0,obj.sprite_y(a0)
	
	move.w	#3,dust.x_speed(a0)		; Move right
	btst	#2,player_ctrl_hold		; Is the player moving left?
	bne.s	ObjDust_Main			; If so, branch
	move.w	#-3,dust.x_speed(a0)		; If not, move left
	btst	#3,player_ctrl_hold		; Is the player moving right?
	bne.s	ObjDust_Main			; If so, branch
	move.w	#0,dust.x_speed(a0)		; If not, don't move horizontally

; ------------------------------------------------------------------------------

ObjDust_Main:
	subq.w	#1,obj.timer(a0)		; Decrement timer
	bne.s	.Move				; If it hasn't run out, branch
	bset	#0,obj.flags(a0)		; If it has, delete object

.Move:
	move.l	dust.x_speed(a0),d0		; Move
	add.l	d0,obj.sprite_x(a0)
	subq.w	#1,obj.sprite_y(a0)
	rts

; ------------------------------------------------------------------------------

MapSpr_Dust:
	include	"Special Stage/Objects/Dust/Data/Mappings.asm"
	even
	
; ------------------------------------------------------------------------------
