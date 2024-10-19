; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Addresses
; ------------------------------------------------------------------------------

PcmDriver		equ PRG_RAM+$40000			; PCM driver location
PcmDriverOrigin		equ PcmDriver+$10			; PCM driver code origin
RunPcmDriver		equ PcmDriver+$10			; Run PCM driver
PcmSoundQueue		equ PcmDriver+$18+pcm.sound_queue	; PCM sound queue

; ------------------------------------------------------------------------------
