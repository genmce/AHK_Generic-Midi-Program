
/* 
; 	Last edited 9/24/2010 6:21 PM by genmce

	1st method for generating CC's from keyboard push.

	All the code to generate the hotkey, besides the midioutshort function (located in midi_under_the_hood.ahk), is contained within each hotkey definition.	
	
	While this method is easy to use, and reproduce more controls with, 
	I think more flexibility as well as simultanous controls are possible with the second method (see other file hotkeyTOmidi_2.ahk)
	Choose yours and test out the merits yourself.
	
	Comments should be self explanitory

	The example below will generate volume cc#7, midi messages to the outport.
	
	; Last edited 9/19/2010 8:59 PM by genmce
*/

;*************************************************
;* 			HOTKEY TO MIDI GENERATION 
;*		1st method - easiest to replicate
;*************************************************

f7::	; hotkey taking value of cc down.
Loop	; loop to detect the state of the hotkey, held down.	
{
	if !GetKeyState("f7","P") 	; if key is not down, or, if key is released   
	  break						; break out of the loop and do nothing else.
    cc_num = 7 					; set the var to the volume cc, you could change this value in a different hotkey loop, do send a different cc# 
    CCIntVal := CCIntVal > 0 ? CCIntVal-1 : 0                 	; check min value of 0 is reached.
    midiOutShortMsg(h_midiout, (Channel+175), CC_num, CCIntVal) 	; Send midi output (h_midiout=port, (channel+CC statusbyte), CC_num=2lines up, CCIntVal) function located under the hood
		; =============== needed for output gui display only
		stb := "CC"
		statusbyte := 176
		chan = %channel%
		byte1 = %cc_num%			; set value of the byte1 to the above cc_num for display on the midi out window (only needed if you want to see output)	
		byte2 = %CCIntVal%			; see above for display of the value of the cc
		gosub, ShowMidiOutMessage   ; run the display label to show the midi output
		; =============== end 		
    sleep, 50         				; wait 50 ms to run next loop to see if key is up or down.
   
}
Return


f8:: 	; value up of cc
Loop 	; loop to detect the state of the hotkey, held down.
{
    if !GetKeyState("f8","P") 	; if key is not down, or, if key is released    
      break						; break out of the loop and do nothing else.	
    cc_num = 7 					; set the var to the volume cc, you could change this value in different hotkey loop. 
	CCIntVal := CCIntVal < 127 ? CCIntVal+1 : 127   ; check for max value 127, reached.
	midiOutShortMsg(h_midiout, (Channel+175), CCnum, CCIntVal)    ; midiport, cc = 176, CCmod is var above, CCIntVal in vars above
		; =============== needed for output gui display only
		stb := "CC"
		statusbyte := 176
		chan = %channel%
		byte1 = %cc_num%			; set value of the byte1 to the above cc_num for display on the midi out window (only needed if you want to see output)	
		byte2 = %CCIntVal%			; see above for display of the value of the cc
		gosub, ShowMidiOutMessage   ; run the display label to show the midi output
		; =============== end   
   Sleep, 50                                         
   
}
Return