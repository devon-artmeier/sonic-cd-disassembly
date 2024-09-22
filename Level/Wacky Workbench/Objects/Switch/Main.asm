; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Switch object
; ------------------------------------------------------------------------------

oSwitchFlag	EQU	obj.var_3C
oSwitchPressPrv	EQU	obj.var_3E
oSwitchPress	EQU	obj.var_3F

; ------------------------------------------------------------------------------

ObjSwitch:
	tst.b	obj.routine(a0)
	bne.s	ObjSwitch_Main

; ------------------------------------------------------------------------------

ObjSwitch_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.b	#1,obj.sprite_layer(a0)
	move.b	#16,obj.collide_width(a0)
	move.b	#16,obj.width(a0)
	move.w	#$39A,obj.sprite_tile(a0)
	move.l	#MapSpr_Switch,obj.sprites(a0)
	move.b	#8,obj.collide_height(a0)

	lea	button_flags,a1
	moveq	#0,d0
	move.b	obj.subtype(a0),d0
	lea	(a1,d0.w),a1
	move.w	a1,oSwitchFlag(a0)

; ------------------------------------------------------------------------------

ObjSwitch_Main:
	move.b	oSwitchPress(a0),oSwitchPressPrv(a0)

	lea	player_object,a1
	jsr	SolidObject
	movea.w	oSwitchFlag(a0),a4
	sne	oSwitchPress(a0)
	bne.s	.Pressed

	bclr	#7,(a4)
	bra.s	.CheckPress

.Pressed:
	bset	#7,(a4)
	bset	#6,(a4)

.CheckPress:
	cmpi.w	#$00FF,oSwitchPressPrv(a0)
	bne.s	.CheckUnpress
	tst.b	obj.sprite_flags(a0)
	bpl.s	.PressedFrame
	move.w	#FM_BF,d0
	jsr	PlayFMSound

.PressedFrame:
	bchg	#5,(a4)
	addq.w	#8,obj.y(a1)
	addq.w	#4,obj.y(a0)
	addq.b	#1,obj.sprite_frame(a0)
	subq.b	#4,obj.collide_height(a0)

.CheckUnpress:
	cmpi.w	#$FF00,oSwitchPressPrv(a0)
	bne.s	.Draw
	subq.w	#8,obj.y(a1)
	subq.w	#4,obj.y(a0)
	subq.b	#1,obj.sprite_frame(a0)
	addq.b	#4,obj.collide_height(a0)

.Draw:
	jsr	DrawObject
	jmp	CheckObjDespawn

; ------------------------------------------------------------------------------

MapSpr_Switch:
	include	"Level/Wacky Workbench/Objects/Switch/Data/Mappings.asm"
	even

; ------------------------------------------------------------------------------
