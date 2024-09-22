; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Spin tunnel waterfall splash object
; ------------------------------------------------------------------------------

ObjSpinSplash:
	moveq	#0,d0				; Run object routine
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjSpinSplash_Init-.Index	; Initialization
	dc.w	ObjSpinSplash_Main-.Index	; Main
	dc.w	ObjSpinSplash_Destroy-.Index	; Destruction

; ------------------------------------------------------------------------------
; Initialization
; ------------------------------------------------------------------------------

ObjSpinSplash_Init:
	addq.b	#2,obj.routine(a0)			; Advance routine

	ori.b	#%00000100,obj.sprite_flags(a0)		; Set sprite flags
	move.l	#MapSpr_TunnelWaterfall,obj.sprites(a0)	; Set mappings
	move.w	#$3E4,obj.sprite_tile(a0)		; Set base tile ID
	tst.b	time_zone
	bne.s	.NotPast
	move.w	#$39E,obj.sprite_tile(a0)

.NotPast:
	move.b	#1,obj.sprite_layer(a0)			; Set priority

; ------------------------------------------------------------------------------
; Main
; ------------------------------------------------------------------------------

ObjSpinSplash_Main:
	lea	Ani_TunnelWaterfall,a1		; Animate sprite
	bsr.w	AnimateObject
	jmp	DrawObject			; Draw sprite

; ------------------------------------------------------------------------------
; Waterfall splash object destruction routine
; ------------------------------------------------------------------------------

ObjSpinSplash_Destroy:
	jmp	DeleteObject			; Delete ourselves

; ------------------------------------------------------------------------------
