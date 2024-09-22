; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Scroll flag set functions
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Set scroll flags for the background while scrolling the position
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - X scroll offset
;	d5.w - Y scroll offset
; ------------------------------------------------------------------------------

SetScrollFlagsBG:
	move.l	camera_bg_x,d2			; Scroll horizontally
	move.l	d2,d0
	add.l	d4,d0
	move.l	d0,camera_bg_x

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	map_block_cross_bg_x,d3
	eor.b	d3,d1
	bne.s	.ChkY
	eori.b	#$10,map_block_cross_bg_x
	sub.l	d2,d0
	bpl.s	.MoveRight
	bset	#2,scroll_flags_bg
	bra.s	.ChkY

.MoveRight:
	bset	#3,scroll_flags_bg

; ------------------------------------------------------------------------------

.ChkY:
	move.l	camera_bg_y,d3			; Scroll vertically
	move.l	d3,d0
	add.l	d5,d0
	move.l	d0,camera_bg_y

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	map_block_cross_bg_y,d2
	eor.b	d2,d1
	bne.s	.End
	eori.b	#$10,map_block_cross_bg_y
	sub.l	d3,d0
	bpl.s	.MoveDown
	bset	#0,scroll_flags_bg
	rts

.MoveDown:
	bset	#1,scroll_flags_bg

.End:
	rts

; ------------------------------------------------------------------------------
; Set vertical scroll flags for the background camera while scrolling the
; position
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d5.w - Y scroll offset
; ------------------------------------------------------------------------------

SetVertiScrollFlagsBG:
	move.l	camera_bg_y,d3			; Scroll vertically
	move.l	d3,d0
	add.l	d5,d0
	move.l	d0,camera_bg_y

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	map_block_cross_bg_y,d2
	eor.b	d2,d1
	bne.s	.End
	eori.b	#$10,map_block_cross_bg_y
	sub.l	d3,d0
	bpl.s	.MoveDown
	bset	#4,scroll_flags_bg
	rts

.MoveDown:
	bset	#5,scroll_flags_bg

.End:
	rts

; ------------------------------------------------------------------------------
; Set vertical scroll flags for the background camera while setting the
; position directly
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - New Y position
; ------------------------------------------------------------------------------

SetVertiScrollFlagsBG2:
	move.w	camera_bg_y,d3			; Set new position
	move.w	d0,camera_bg_y

	move.w	d0,d1				; Check if a block has been crossed and set flags accordingly
	andi.w	#$10,d1
	move.b	map_block_cross_bg_y,d2
	eor.b	d2,d1
	bne.s	.End
	eori.b	#$10,map_block_cross_bg_y
	sub.w	d3,d0
	bpl.s	.MoveDown
	bset	#0,scroll_flags_bg
	rts

.MoveDown:
	bset	#1,scroll_flags_bg

.End:
	rts

; ------------------------------------------------------------------------------
; Set horizontal scroll flags for the background camera while
; scrolling the position
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - X scroll offset
;	d6.b - Base scroll flag bit
; ------------------------------------------------------------------------------

SetHorizScrollFlagsBG:
	move.l	camera_bg_x,d2			; Scroll horizontally
	move.l	d2,d0
	add.l	d4,d0
	move.l	d0,camera_bg_x

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	map_block_cross_bg_x,d3
	eor.b	d3,d1
	bne.s	.End
	eori.b	#$10,map_block_cross_bg_x
	sub.l	d2,d0
	bpl.s	.MoveRight
	bset	d6,scroll_flags_bg
	bra.s	.End

.MoveRight:
	addq.b	#1,d6
	bset	d6,scroll_flags_bg

.End:
	rts

; ------------------------------------------------------------------------------
; Set horizontal scroll flags for the background camera #2 while
; scrolling the position
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - X scroll offset
;	d6.b - Base scroll flag bit
; ------------------------------------------------------------------------------

SetHorizScrollFlagsBG2:
	move.l	camera_bg2_x,d2			; Scroll horizontally
	move.l	d2,d0
	add.l	d4,d0
	move.l	d0,camera_bg2_x

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	map_block_cross_bg2_x,d3
	eor.b	d3,d1
	bne.s	.End
	eori.b	#$10,map_block_cross_bg2_x
	sub.l	d2,d0
	bpl.s	.MoveRight
	bset	d6,scroll_flags_bg2
	bra.s	.End


.MoveRight:
	addq.b	#1,d6
	bset	d6,scroll_flags_bg2

.End:
	rts

; ------------------------------------------------------------------------------
; Set horizontal scroll flags for the background camera #3 while
; scrolling the position
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d4.w - X scroll offset
;	d6.b - Base scroll flag bit
; ------------------------------------------------------------------------------

SetHorizScrollFlagsBG3:
	move.l	camera_bg3_x,d2			; Scroll horizontally
	move.l	d2,d0
	add.l	d4,d0
	move.l	d0,camera_bg3_x

	move.l	d0,d1				; Check if a block has been crossed and set flags accordingly
	swap	d1
	andi.w	#$10,d1
	move.b	map_block_cross_bg3_x,d3
	eor.b	d3,d1
	bne.s	.End
	eori.b	#$10,map_block_cross_bg3_x
	sub.l	d2,d0
	bpl.s	.MoveRight
	bset	d6,scroll_flags_bg3
	bra.s	.End

.MoveRight:
	addq.b	#1,d6
	bset	d6,scroll_flags_bg3

.End:
	rts

; ------------------------------------------------------------------------------
