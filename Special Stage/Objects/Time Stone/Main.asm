; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Time stone object (special stage)
; ------------------------------------------------------------------------------

ObjTimeStone:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	bsr.w	DrawObject			; Draw sprite
	rts

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjTimeStone_Init-.Index
	dc.w	ObjTimeStone_Wait-.Index
	dc.w	ObjTimeStone_Fall-.Index
	dc.w	ObjTimeStone_Wait2-.Index

; ------------------------------------------------------------------------------

ObjTimeStone_Init:
	move.w	#$E424,obj.sprite_tile(a0)	; Base tile ID
	move.l	#MapSpr_TimeStone,obj.sprites(a0)
	move.w	#129+128,obj.sprite_x(a0)	; Set sprite position
	move.w	#-16+128,obj.sprite_y(a0)
	moveq	#0,d0				; Set animation
	bsr.w	SetObjAnim
	move.w	#30,obj.timer(a0)		; Set wait timer
	addq.b	#1,obj.routine(a0)		; Start waiting

; ------------------------------------------------------------------------------

ObjTimeStone_Wait:
	subq.w	#1,obj.timer(a0)		; Decrement wait timer
	bne.s	.End				; If it hasn't run out, branch
	addq.b	#1,obj.routine(a0)		; Start falling

.End:
	rts

; ------------------------------------------------------------------------------

ObjTimeStone_Fall:
	addq.w	#4,obj.sprite_y(a0)		; Move downwards
	cmpi.w	#208+128,obj.sprite_y(a0)	; Have we landed in Sonic's hands?
	bcs.s	.End				; If not, branch
	
	addq.b	#1,obj.routine(a0)		; Stop falling
	bset	#0,sparkle_1_object+obj.flags	; Delete sparkles
	bset	#0,sparkle_2_object+obj.flags
	move.w	#60,obj.timer(a0)		; Set timer
	
	move.b	#$12,player_object+obj.routine	; Make Sonic hold the time stone
	
	move.b	#FM_D9,d0			; Play time stone sound
	bsr.w	PlayFMSound

.End:
	rts

; ------------------------------------------------------------------------------

ObjTimeStone_Wait2:
	subq.w	#1,obj.timer(a0)		; Decrement timer
	bne.s	.End				; If it hasn't run out, branch
	move.b	#1,got_time_stone		; Mark time stone as retrieved

.End:
	rts

; ------------------------------------------------------------------------------
; Time stone sparkle 1 object
; ------------------------------------------------------------------------------

ObjSparkle1:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	bsr.w	DrawObject			; Draw sprite
	rts

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjSparkle1_Init-.Index
	dc.w	ObjSparkle1_Main-.Index

; ------------------------------------------------------------------------------

ObjSparkle1_Init:
	move.w	#$E424,obj.sprite_tile(a0)		; Base tile ID
	move.l	#MapSpr_TimeStone,obj.sprites(a0)	; Mappings
	moveq	#1,d0					; Set animation
	bsr.w	SetObjAnim
	addq.b	#1,obj.routine(a0)			; Set routine to main

; ------------------------------------------------------------------------------

ObjSparkle1_Main:
	move.w	time_stone_object+obj.sprite_x,obj.sprite_x(a0)	; Move with time stone
	move.w	time_stone_object+obj.sprite_y,obj.sprite_y(a0)
	subi.w	#16,obj.sprite_y(a0)
	rts

; ------------------------------------------------------------------------------
; Time stone sparkle 2 object
; ------------------------------------------------------------------------------

ObjSparkle2:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	bsr.w	DrawObject			; Draw sprite
	rts

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjSparkle2_Init-.Index
	dc.w	ObjSparkle2_Main-.Index

; ------------------------------------------------------------------------------

ObjSparkle2_Init:
	move.w	#$E424,obj.sprite_tile(a0)		; Base tile ID
	move.l	#MapSpr_TimeStone,obj.sprites(a0)	; Mappings
	moveq	#2,d0					; Set animation
	bsr.w	SetObjAnim
	addq.b	#1,obj.routine(a0)			; Set routine to main

; ------------------------------------------------------------------------------

ObjSparkle2_Main:
	move.w	time_stone_object+obj.sprite_x,obj.sprite_x(a0)	; Move with time stone
	move.w	time_stone_object+obj.sprite_y,obj.sprite_y(a0)
	subi.w	#32,obj.sprite_y(a0)
	rts

; ------------------------------------------------------------------------------

MapSpr_TimeStone:
	include	"Special Stage/Objects/Time Stone/Data/Mappings.asm"
	even
	
; ------------------------------------------------------------------------------
