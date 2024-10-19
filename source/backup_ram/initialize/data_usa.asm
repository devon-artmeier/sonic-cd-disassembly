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
	incbin	"source/backup_ram/initialize/data/message_english_art.nem"
	even

	xdef DataCorruptTilemap
DataCorruptTilemap:
	incbin	"source/backup_ram/initialize/data/data_corrupt_english_tilemap.eni"
	even

	xdef UnformattedTilemap
UnformattedTilemap:
	incbin	"source/backup_ram/initialize/data/unformatted_english_tilemap.eni"
	even

	xdef CartUnformattedTilemap
CartUnformattedTilemap:
	incbin	"source/backup_ram/initialize/data/cart_unformatted_english_tilemap.eni"
	even

	xdef BuramFullTilemap
BuramFullTilemap:
	incbin	"source/backup_ram/initialize/data/ram_full_english_tilemap.eni"
	even
	
	xdef MessageUsaArt
MessageUsaArt:
	incbin	"source/backup_ram/initialize/data/message_usa_art.nem"
	even

	xdef UnformattedUsaTilemap
UnformattedUsaTilemap:
	incbin	"source/backup_ram/initialize/data/unformatted_usa_tilemap.eni"
	even

; ------------------------------------------------------------------------------
