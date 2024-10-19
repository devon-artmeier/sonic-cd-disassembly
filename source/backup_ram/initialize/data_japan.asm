; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"variables.inc"

	section data

; ------------------------------------------------------------------------------

	xdef EggmanArt
EggmanArt:
	incbin	"source/backup_ram/initialize/data/eggman_art.nem"
	even

	xdef EggmanTilemap
EggmanTilemap:
	incbin	"source/backup_ram/initialize/data/eggman_tilemap.eni"
	even
	
	xdef MessageArt
MessageArt:
	incbin	"source/backup_ram/initialize/data/message_japan_art.nem"
	even

	xdef DataCorruptTilemap
DataCorruptTilemap:
	incbin	"source/backup_ram/initialize/data/data_corrupt_japan_tilemap.eni"
	even
	
	xdef Unformatted
Unformatted:
	incbin	"source/backup_ram/initialize/data/unformatted_japan_tilemap.eni"
	even

	xdef CartUnformattedTilemap
CartUnformattedTilemap:
	incbin	"source/backup_ram/initialize/data/cart_unformatted_japan_tilemap.eni"
	even

	xdef BuramFullTilemap
BuramFullTilemap:
	incbin	"source/backup_ram/initialize/data/ram_full_japan_tilemap.eni"
	even

; ------------------------------------------------------------------------------
