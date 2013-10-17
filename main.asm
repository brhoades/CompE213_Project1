#include <reg932.inc>

cseg at 0
	ljmp main	
	
cseg at 0x0030	 
main:
	mov p0m1,#0		; set port 0 to bi-directional
	mov p1m1,#0		; set port 1 to bi-directional
	mov p2m1,#0		; set port 2 to bi-directional
	mov TMOD,#0x00		; sets TIMER 0 into mode 1 operation 
	mov TH0, #0		; presets a 16-bit value into TIMER 0 
	mov TL0, #0		; upper byte first and then lower byte

	;setb ET0		; enable TIMER 0 overflow interrupt
	;setb EA			; set global interrupt enable bit
	;setb TR0		; start TIMER 0 counting
	mov sp, #0x80		; initialize stack pointer to 0x80
	acall STARTUP	  	
mainloop:
	nop ; Insert code to call my functions from here.
	mov r7, #0 ; zero register r7 : Keeping count value here.
	jb p2.0, NPLUS ; Add 1 to counter
	jb p2.1, NMINUS ; Minus 1 from counter
	jb p2.7, NRESET ; Store(R6) R7 then set again to zero
	jb p2.2, NSUM ; Sum Store(R6) with Current(R7) and act on these results
	mov A, r5
	jnz NCHLIGHT ; If R5 = 1 then light needs to change, otherwise do nothing 
	sjmp mainloop

startup:
	acall startupsound
	acall hline	   ;horizontal line
	acall rhline   ;a line that goes back to led1
	acall vline	   ;vertical line
	acall rvline   ;vertical line that goes back to led1
	acall flashleds;flashes leds 5x
	mov R0, #0
	mov R1, #0
	mov R2, #0
	mov R3, #0
	mov R4, #0
	mov R5, #1 ; will make light turn on when mainloop starts up
	mov R6, #0
	mov R7, #0
	mov A, #0
	ret

NPLUS:
	ret ; need to write code here
	inc r7 ; increment the count holder register
	mov A, r7
	lcall NCHLIGHT ; call the function to change the lights
	jz NROLLOVER ; Jump to the rollover label if a rollover occoured
	; jz does not modify the SP, so I can use ret in NROLLOVER
	ret
NMINUS:
	mov A, r7
	dec r7
	lcall NCHLIGHT ; call the label to change the lights
	jz NROLLOVER ; Jump if r7 was zero when minus was called
	ret
	; jz does not modify the SP, so I can use ret in NROLLOVER
	; jz 
	; adding a new comment
NRESET:
	ret ; need to write code here
	mov 0x36, r7 ; store the value of the count at 36H
	mov r7, #0 ; clear the current count register
	lcall NBUTTONDELAY
	ret
NSUM:
	; need to write this piece of code
	ret
NCHLIGHT: ; this function changes the lights, called when R5 != 0
	
	mov r5, #0 ; reset the conditional
	; Note: r7 holds the value to be compared with
	mov A, r7 ; moved r7 -> A for use with CJNE
	cjne A, #15, NSW14 ; GoTo 14  only if this is not 15
	acall NFIFTEEN
	ret
NSW14:
	; Note: A should not change since there are no iterrupts running
	cjne A, #14, NSW13
	acall NFOURTEEN
	ret
NSW13:
	cjne A, #13, NSW12
	acall NTHIRTEEN
	ret
NSW12:
	cjne A, #12, NSW11
	acall NTWELVE
	ret
NSW11:
	cjne A, #11, NSW10
	acall NELEVEN
	ret
NSW10:
	cjne A, #10, NSW9
	acall NTEN
	ret
NSW9:
	cjne A, #9, NSW8
	acall NNINE
	ret
NSW8:
	cjne A, #8, NSW7
	acall NEIGHT
	ret
NSW7:
	cjne A, #7, NSW6
	acall NSEVEN
	ret
NSW6:
	cjne A, #6, NSW5
	acall NSIX
	ret
NSW5:
	cjne A, #5, NSW4
	acall NFIVE
	ret
NSW4:
	cjne A, #4, NSW3
	acall NFOUR
	ret
NSW3:
	cjne A, #3, NSW2
	acall NTHREE
	ret
NSW2:
	cjne A, #2, NSW1
	acall NTWO
	ret
NSW1:
	acall NONE
	ret
	; End of the number switching code
	
	ret ; 
NROLLOVER:
	; sound buzzer here
	mov R0, #0x7D
	mov R1, #0x00
	mov R2, #0x66
	mov R3, #0x0E
	acall sound
	lcall NBUTTONDELAY ; 
	ret ; return after this is called, because lcall is used for NBUTTONDELAY
	
NBUTTONDELAY:
	mov r0, #0xFE
	mov r1, #0x12
	acall lightinner ; delay after any button press
	ret
	
;Do a horizontal line of LEDS that turn themselves
;off when finished.
hline:
	acall led1w
	acall led2w
	acall led3w
	acall led4w
	acall led5w
	acall led6w
	acall led7w
	acall led8w
	acall led9w
	ret

;Do a horizontal line that turns around and goes backwards
rhline:
	acall led9w
	acall led8w
	acall led7w
	acall led6w
	acall led5w
	acall led4w
	acall led3w
	acall led2w
	acall led1w
	ret

;Do a vertical line starting at the top left and ending
;at the bottom right
vline:
	acall led1w
	acall led4w
	acall led7w
	acall led8w
	acall led5w
	acall led2w
	acall led3w
	acall led6w
	acall led9w
	ret

;Do a vertical line starting at bottom left and ending
;at top right
rvline:
	acall led9w
	acall led6w
	acall led3w
	acall led2w
	acall led5w
	acall led8w
	acall led7w
	acall led4w
	acall led1w
	ret

;Flash all LEDS	5x
flashleds:
	mov R2, #0x0A
flashloop:
	acall led1t
	acall led2t
	acall led3t
	acall led4t
	acall led5t
	acall led6t
	acall led7t
	acall led8t
	acall led9t
	acall lightdelay
	djnz R2, flashloop
	ret

;1000/1.085 =~ 921
;number of cycles in a millisecond
;about 10 cycles below so 92 cycles of this for a ms
;
lightdelay:
	mov R0, #0xB0
	mov R1, #0xB3
lightinner:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	djnz R0, lightinner
	mov R0, #0xFF
	djnz R1, lightinner
	ret

startupsound:
	;2000khz
	;500ms =~ 1000/1.085/167*500
	mov R0, #0xA7
	mov R1, #0x00
	mov R2, #0xC7
	mov R3, #0x0A
	acall led1t
	acall sound

	;1500 khz
	;500ms =~ 1000/1.085/208*500
	mov R0, #0xD0
	mov R1, #0x00
	mov R2, #0xA7
	mov R3, #0x08
	acall led2t
	acall sound


	;2250khz
	;500ms =~ 1000/1.085/185*500
	mov R0, #0xBC
	mov R1, #0x00
	mov R2, #0xBB
	mov R3, #0x09
	acall led3t
	acall sound

	;2500khz
	;500ms =~ 1000/1.085/125*500
	mov R0, #0x7D
	mov R1, #0x00
	mov R2, #0x66
	mov R3, #0x0E
	acall led4t
	acall led5t
	acall led6t
	acall led7t
	acall led8t
	acall led9t
	acall sound
	acall lightdelay
	acall lightdelay
	ret

;sound ~~ hz / 12 in r1.r0
;these control the pitch
;mov R0, #0xA7   this is about 2 khz
;mov R1, #0x00   ^^^
;these are somewhere near the length
;mov R2, #0xFE   this is a long time...
;mov R3, #0xB3	 usually have go guess this length
;But it's whatever you think it should be in
;multiples of r1.r0
sound:
	inc R0
	inc R1
	inc R2
	inc R3

	;These back stuff up
	mov A, R0
	mov R4, A
	mov A, R1
	mov R5, A

sound_inner:
	djnz R0, sound_inner
	mov R0, #0xFF
	djnz R1, sound_inner
	cpl p1.7
	mov A, R4
	mov R0, A
	mov A, R5
	mov R1, A
	djnz R2, sound_inner
	mov R2, #0xFF
	djnz R3, sound_inner
	ret

resetlights:
	setb p2.4
	setb p0.5
	setb p2.7
	setb p0.6
	setb p1.6
	setb p0.4
	setb p2.5
	setb p0.7
	setb p2.6
	ret

led1w:
	clr p2.4
	acall lightdelay
led1t:
	cpl p2.4
	ret

led2w:
	clr p0.5
	acall lightdelay
led2t:
	cpl p0.5
	ret

led3w:
	clr p2.7
	acall lightdelay
led3t:
	cpl p2.7
	ret

led4w:
	clr p0.6
	acall lightdelay
led4t:
	cpl p0.6
	ret

led5w:
	clr p1.6
	acall lightdelay
led5t:
	cpl p1.6
	ret

led6w:
	clr p0.4
	acall lightdelay
led6t:
	cpl p0.4
	ret

led7w:
	clr p2.5
	acall lightdelay
led7t:
	cpl p2.5
	ret

led8w:
	clr p0.7
	acall lightdelay
led8t:
	cpl p0.7
	ret

led9w:
	clr p2.6
	acall lightdelay
led9t:
	cpl p2.6
	ret
	
NZERO:
	; no light given when the variable is zero
	ret
NONE:
	cpl p2.4
	ret
NTWO:
	cpl p0.5
    ret
NTHREE:
	cpl p2.7
	ret
NFOUR:
	cpl p0.6
	ret
NFIVE:
	cpl p1.6
	ret
NSIX:
	cpl p0.4
	ret
NSEVEN:
	cpl p2.5
	ret
NEIGHT:
	cpl p0.7
	ret
NNINE:
	cpl p2.6
	ret
NTEN:
	cpl p2.6
	cpl p2.4
	ret
NELEVEN:
	cpl p2.6
    cpl p0.5
	ret
NTWELVE:
	cpl p2.6
	cpl p2.7
	ret
NTHIRTEEN:
	cpl p2.6
	cpl p0.6
	ret
NFOURTEEN:
	cpl p2.6
	cpl p1.6
	ret
NFIFTEEN:
	cpl p2.6
	cpl p0.4
	ret

end
