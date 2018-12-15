/* 
  PARSE - LAST MIDI MESSAGE RECEIVED - 
  Midi monitor.
*/

;*************************************************
;*			MIDI INPUT PARSE FUNCTION
;*		
;*************************************************

; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! no edit below here ....

MidiMsgDetect(hInput, midiMsg, wMsg) ; Midi input section in "under the hood" calls this function each time a midi message is received. Then the midi message is broken up into parts for manipulation.  See http://www.midi.org/techspecs/midimessages.php (decimal values).
  {
    global statusbyte, chan, note, cc, byte1, byte2, stb
    
    statusbyte 	:=  midiMsg & 0xFF			; EXTRACT THE STATUS BYTE (WHAT KIND OF MIDI MESSAGE IS IT?)
    chan 		:= (statusbyte & 0x0f) + 1	; WHAT MIDI CHANNEL IS THE MESSAGE ON?
    byte1 		:= (midiMsg >> 8) & 0xFF	; THIS IS DATA1 VALUE = NOTE NUMBER OR CC NUMBER
    byte2 		:= (midiMsg >> 16) & 0xFF	; DATA2 VALUE IS NOTE VELEOCITY OR CC VALUE
    pitchb		:= (byte2 << 7) | byte1   	;(midiMsg >> 8) & 0x7F7F  masking to extract the pbs  
    
     	
	if statusbyte between 176 and 191 	; test for cc
		stb := "CC" 					; if so then set stp to cc
	if statusbyte between 144 and 159 
		stb := "NoteOn"
	if statusbyte between 128 and 143 
		stb := "NoteOff"
	if statusbyte between 224 and 239
		stb := "PitchB"
	gosub, ShowMidiInMessage ; show updated midi input message on midi monitor gui.
	gosub, MidiRules ; run the label in file MidiRules.ahk Edit that file.
    
  } 
; end of MidiMsgDetect funciton

Return

;*************************************************
;* 		SHOW MIDI INPUT ON GUI MONITOR
;*************************************************

ShowMidiInMessage: ; update the midimonitor gui
	
Gui,14:default
Gui,14:ListView, In1 ; see the first listview midi in monitor
	LV_Add("",stb,statusbyte,chan,byte1,byte2)
	LV_ModifyCol(1,"center")
	LV_ModifyCol(2,"center")
	LV_ModifyCol(3,"center")
	LV_ModifyCol(4,"center")
	LV_ModifyCol(5,"center")
	If (LV_GetCount() > 10)
		{
			LV_Delete(1)
		}
return

;*************************************************
;* 		SHOW MIDI OUTPUT ON GUI MONITOR
;*************************************************

ShowMidiOutMessage: ; update the midimonitor gui 

Gui,14:default
Gui,14:ListView, Out1 ; see the second listview midi out monitor
	LV_Add("",stb,statusbyte,chan,byte1,byte2)
	LV_ModifyCol(1,"center")
	LV_ModifyCol(2,"center")
	LV_ModifyCol(3,"center")
	LV_ModifyCol(4,"center")
	LV_ModifyCol(5,"center")
	If (LV_GetCount() > 10)
		{
			LV_Delete(1)
		}
return

;*************************************************
;* 			MIDI MONITOR GUI CODE
;*************************************************

midiMon: ; midi monitor gui with listviews
gui,14:destroy
gui,14:default
gui,14:add,text, x80 y5, Midi Input ; %TheChoice%
	Gui,14:Add, DropDownList, x40 y20 w140 Choose%TheChoice% vMidiInPort gDoneInChange altsubmit, %MiList%  ; (
gui,14:add,text, x305 y5, Midi Ouput ; %TheChoice2%
	Gui,14:Add, DropDownList, x270 y20 w140  Choose%TheChoice2% vMidiOutPort gDoneOutChange altsubmit , %MoList%
Gui,14:Add, ListView, x5 r11 w220 Backgroundblack caqua Count10 vIn1,  EventType|StatB|Ch|Byte1|Byte2| 
gui,14:Add, ListView, x+5 r11 w220 Backgroundblack cyellow Count10 vOut1,  EventType|StatB|Ch|Byte1|Byte2| 
gui,14:Show, autosize xcenter y5, MidiMonitor

Return