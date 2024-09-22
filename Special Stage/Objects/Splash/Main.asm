; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Splash object (special stage)
; ------------------------------------------------------------------------------

ObjSplash:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)
	
	bsr.w	DrawObject			; Draw sprite
	
	tst.b	time_stopped			; Is time stopped?
	beq.s	.End				; If not, branch
	bset	#0,obj.flags(a0)		; Delete object

.End:
	rts

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjSplash_Init-.Index
	dc.w	ObjSplash_Large-.Index
	dc.w	ObjSplash_Small-.Index

; ------------------------------------------------------------------------------

ObjSplash_Init:
	move.w	#$8582,obj.sprite_tile(a0)	; Base tile ID
	move.l	#MapSpr_Splash,obj.sprites(a0)	; Mappings
	move.w	#128+128,obj.sprite_x(a0)	; Set sprite position
	move.w	#216+128,obj.sprite_y(a0)
	moveq	#0,d0				; Set large splash animation
	bsr.w	SetObjAnim
	move.w	#14,obj.timer(a0)		; Set large splash timer
	addq.b	#1,obj.routine(a0)		; Set to large splash routine
	
	move.b	#FM_A2,d0			; Play splash sound
	bsr.w	PlayFMSound
	
	btst	#1,special_stage_flags		; Are we in time attack mode?
	bne.s	ObjSplash_Large			; If not, branch
	; NOTE: The timer speed-up lasts shorter than the large splash animation.
	; The timer will go back to normal speed for the last few frames of the animation.
	move.b	#10,timer_speed_up		; If so, set timer speed-up counter

; ------------------------------------------------------------------------------

ObjSplash_Large:
	subq.w	#1,obj.timer(a0)		; Decrement timer
	bne.s	.End				; If it hasn't run out yet, branch
	cmpi.b	#3,player_object+player.stamp_center	; Is Sonic on a water stamp?
	bne.s	ObjSplash_Delete		; If not, branch
	
	moveq	#1,d0				; Set small splash animation
	bsr.w	SetObjAnim
	
	move.b	#2,obj.routine(a0)		; Set to small splash routine

.End:
	rts

; ------------------------------------------------------------------------------

ObjSplash_Small:
	cmpi.b	#3,player_object+player.stamp_center	; Is Sonic on a water stamp?
	bne.s	ObjSplash_Delete		; If not, branch
	
	tst.b	obj.anim_frame(a0)		; Has the animation restarted?
	bne.s	.End				; If not, branch
	move.b	#2,timer_speed_up		; If so, reset timer speed-up counter

.End:
	rts

; ------------------------------------------------------------------------------

ObjSplash_Delete:
	bset	#0,obj.flags(a0)		; Delete object
	rts

; ------------------------------------------------------------------------------
; Delete splash object
; ------------------------------------------------------------------------------

DeleteSplash:
	tst.b	splash_object+obj.id		; Was the splash object spawned in?
	beq.s	.End				; If not, branch
	bset	#0,splash_object+obj.flags	; If so, delete it

.End:
	rts

; ------------------------------------------------------------------------------
