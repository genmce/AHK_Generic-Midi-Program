; Last edited 12/19/2018 11:01 AM by genmce
/* 
	Method 1 for generating CC's from keystroke.

	While this method is easy to use, and reproduce more controls with, 
	I think more flexibility as well as simultanous controls are possible with the second method (see other file hotkeyTOmidi_2.ahk)
	Choose yours and test the merits, of each, yourself.
	
	Usually your definitions will come in pairs - 
		One to decrease the value.
		One to increase the value.
	The example 1 below will generate volume cc#7  
	CC#7 will decrease when F7 key is pressed  until 0 is reached
	CC#7 will increase when F8 is pressed until 127 is reached

*/

;*************************************************
;* 		HOTKEY TO MIDI CC GENERATION 
;*************************************************

; =============== Example 1  - 2 key definitions ; =============== 

f7::																		; hotkey subtracting CC  (data byte 2) value.
Loop																	; loop to detect the state of the hotkey, held down.	
{
	if !GetKeyState("f7","P") 								; if key is not down, or, if key is released   
	  break															; break out of the loop and do nothing else.
    CC_num = 7 													; What CC (data data1) do you wish to send? EDIT THIS TO CHANGE CC_num
    CCIntVal := CCIntVal > 0 ? CCIntVal-1 : 0  	;Subtract 1 from byte 2 until min value of 0 is reached. * LEAVE THIS ALONE
  	gosub, SendCC 												; LABEL LOCATED IN GEN_MIDI_APP  LINE 111
	;sleep, 20       												   ; adjust this for speed 20ms is fast - NOT SURE WHAT HAPPENS WHEN THIS IS FASTER?
}
Return

f8:: 																		; hotkey adding CC (data byte 2 ) value 
Loop 																	; loop to detect the state of the hotkey, held down.
{
    if !GetKeyState("f8","P") 								; if key is not down, or, if key is released    
      break															; break out of the loop and do nothing else.
    CC_num = 7 													; What CC (data byte 1) do you wish to send?
	CCIntVal := CCIntVal < 127 ? CCIntVal+1 : 127   ; Add 1 to data byte 2 until  max value 127, reached.
	gosub, SendCC
	;Sleep, 20                                         
}
Return

; =============== Example 2 - one hotkey to increase, same hotkey with modifier to decrease ; =============== 

^f9::										;CTRL + F9			; hotkey subtracting CC  (data byte 2) value.
Loop																	; loop to detect the state of the hotkey, held down.	
{
	if !GetKeyState("f9","P") 								; if key is not down, or, if key is released   
	  break															; break out of the loop and do nothing else.
    CC_num = 9 													; What CC (data data1) do you wish to send? EDIT THIS TO CHANGE CC_num
    CCIntVal := CCIntVal > 0 ? CCIntVal-1 : 0  	;Subtract 1 from byte 2 until min value of 0 is reached. * LEAVE THIS ALONE
  	gosub, SendCC 												; LABEL LOCATED IN GEN_MIDI_APP  LINE 111
	;sleep, 20       												   ; adjust this for speed 20ms is fast - NOT SURE WHAT HAPPENS WHEN THIS IS FASTER?
}
Return

f9:: 																		; hotkey adding CC (data byte 2 ) value 
Loop 																	; loop to detect the state of the hotkey, held down.
{
    if !GetKeyState("f9","P") 								; if key is not down, or, if key is released    
      break															; break out of the loop and do nothing else.
    CC_num = 9 													; What CC (data byte 1) do you wish to send?
	CCIntVal := CCIntVal < 127 ? CCIntVal+1 : 127   ; Add 1 to data byte 2 until  max value 127, reached.
	gosub, SendCC
	;Sleep, 20                                         
}
Return

;*****************************************************************
;	HOTKEY TO PROGRAM CHANGE - MIDI OUT
;*****************************************************************

F10::
{
	PC = 3										; Program change number to send 
	gosub, SendPC
}
return

;*****************************************************************
;	HOTKEY TO NOTE ON/OFF - NOTE HELD - not tested yet
;*****************************************************************

F11::
{
	note = 60 								; MIDI NOTE NUMBER TO SEND OUT
	Vel = 100								; VELOCITY OF NOTE NUMBER TO SEND OUT
	statusbyte = Channel+144	; NOTE ON MESSAGE
	gosub, SendNote
}
return

; =============== OLD METHOD TO SEND MIDI  - STILL WORKS  ; ================ UNCOMMENT THE LINE BELOW OR USE IT IN YOUR KEY METHODS
;midiOutShortMsg(h_midiout, (Channel+175), CC_num, CCIntVal) 	; Send midi output (h_midiout=port, (channel+CC statusbyte), CC_num=2lines up, CCIntVal) function located in Midi_In_Out_Library.ahk  ;
