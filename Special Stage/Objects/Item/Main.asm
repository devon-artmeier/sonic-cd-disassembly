; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Item objects (special stage)
; ------------------------------------------------------------------------------

item.x_speed		equ obj.var_3C		; X speed
item.y_speed		equ obj.var_40		; Y speed
item.spawn_type		equ obj.var_51		; Item type (on spawn)
item.type		equ obj.var_52		; Item type

; ------------------------------------------------------------------------------
; Lost ring object
; ------------------------------------------------------------------------------

ObjLostRing:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	bra.w	DrawObject			; Draw sprite

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjLostRing_Init-.Index
	dc.w	ObjLostRing_Main-.Index

; ------------------------------------------------------------------------------

ObjLostRing_Init:
	move.w	#$E78F,obj.sprite_tile(a0)	; Base tile ID
	move.l	#MapSpr_Item,obj.sprites(a0)	; Mappings

	moveq	#4,d0				; Set type and animation
	move.b	d0,item.type(a0)
	bsr.w	SetObjAnim

	move.w	player_object+obj.sprite_x,obj.sprite_x(a0)	; Spawn at Sonic's position
	move.w	player_object+obj.sprite_y,obj.sprite_y(a0)

	addq.b	#1,obj.routine(a0)		; Set to main routine
	move.b	#45,obj.timer(a0)		; Set timer

	bsr.w	Random				; Get X speed
	move.w	d0,d1
	andi.l	#$3F000,d1
	bchg	#0,lost_ring_x_dir		; Should this ring fly left?
	beq.s	.SetXVel			; If not, branch
	neg.l	d1				; If so, fly left

.SetXVel:
	move.l	d1,item.x_speed(a0)		; Set X velocity

	andi.w	#$F,d0				; Set Y velocity
	move.w	#-$A,item.y_speed(a0)
	sub.w	d0,item.y_speed(a0)

	move.b	#FM_RINGLOSS,d0			; Play ring loss sound
	bsr.w	PlayFMSound

; ------------------------------------------------------------------------------

ObjLostRing_Main:
	subq.b	#1,obj.timer(a0)		; Decrement timer
	bne.s	.Move				; If it hasn't run out yet, branch
	bset	#0,obj.flags(a0)		; Delete object

.Move:
	move.l	item.x_speed(a0),d0		; Move
	add.l	d0,obj.sprite_x(a0)
	move.l	item.y_speed(a0),d0
	add.l	d0,obj.sprite_y(a0)

	cmpi.w	#216+128,obj.sprite_y(a0)	; Is the ring at the bottom of the screen?
	bls.s	.Gravity			; If not, branch
	move.w	#216+128,obj.sprite_y(a0)	; Bounce off the bottom of the screen
	neg.l	item.y_speed(a0)
	rts
	
.Gravity:
	addi.l	#$20000,item.y_speed(a0)		; Apply gravity
	rts

; ------------------------------------------------------------------------------
; Item object
; ------------------------------------------------------------------------------

ObjItem:
	moveq	#0,d0				; Run routine
	move.b	obj.routine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jsr	.Index(pc,d0.w)

	bra.w	DrawObject			; Draw sprite

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjItem_Init-.Index
	dc.w	ObjItem_Main-.Index

; ------------------------------------------------------------------------------

ObjItem_Init:
	move.w	#$878F,obj.sprite_tile(a0)	; Base tile ID
	move.l	#MapSpr_Item,obj.sprites(a0)	; Mappings

	moveq	#0,d0				; Set type and animation
	move.b	item.spawn_type(a0),d0
	move.b	d0,item.type(a0)
	bsr.w	SetObjAnim

	addq.b	#1,obj.routine(a0)		; Set to main routine
	move.b	#$10,obj.timer(a0)		; Set timer
	move.w	#-$10,item.y_speed(a0)		; Move upwards

	move.b	#FM_RING,d0			; Play ring sound
	bsr.w	PlayFMSound

; ------------------------------------------------------------------------------

ObjItem_Main:
	subq.b	#1,obj.timer(a0)		; Decrement timer
	bne.s	.Move				; If it hasn't run out yet, branch
	bset	#0,obj.flags(a0)		; Delete object

.Move:
	move.l	item.y_speed(a0),d0		; Move
	add.l	d0,obj.sprite_y(a0)
	
	addi.l	#$20000,item.y_speed(a0)	; Decelerate
	rts

; ------------------------------------------------------------------------------

MapSpr_Item:
	include	"Special Stage/Objects/Item/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
