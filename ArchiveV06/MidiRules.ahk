
;*************************************************
;*          RULES - MIDI FILTERS
;*************************************************

/* 
      The MidiRules section is for modifying midi input from some other source.
        *See hotkeys below if you wish to generate midi messages from hotkeys.
      
      Write your own MidiRules and put them in this section.
      Keep rules together under proper section, notes, cc, program change etc.
      Keep them after the statusbyte has been determined.
      Examples for each type of rule will be shown. 
      The example below is for note type message.
      
      Remember byte1 for a noteon/off is the note number, byte2 is the velocity of that note.
      example
      ifequal, byte1, 20 ; if the note number coming in is note # 20
        {
          byte1 := (do something in here) ; could be do something to the velocity(byte2)
          gosub, SendNote ; send the note out.
        }
  */

MidiRules: ; write your own rules in here, look for : ++++++ for where you might want to add
           ; stay away from !!!!!!!!!!

  ; =============== Is midi input a Note On or Note off message?  =============== 
  if statusbyte between 128 and 159 ; see range of values for notemsg var defined in autoexec section. "in" used because ranges of note on and note off
	{ ; beginning of note block
      
      if statusbyte between 144 and 159 ; detect if note message is "note on" 
        ;gosub, ShowMidiInMessage
		;GuiControl,14:, StatusByteIn,%statusbyte%
        ;GuiControl,14:, ChanIn,%chan%
        ;GuiControl,14:, Byte1In,%byte1%
        ;GuiControl,14:, Byte2In,%byte2% ; display noteOn message in gui
      
	  if statusbyte between 128 and 143 ; detect if note message is "note off"
        ;gosub, ShowMidiInMessage
		;GuiControl,12:, MidiMsOut, noteOff:%statusbyte% %chan% %byte1% %byte2%  ; display note off in gui
 
  ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! above  end of no edit
     
  ; =============== add your note MidiRules here ==; =============== 

  /* 
      Write your own note filters and put them in this section.
      Remember byte1 for a noteon/off is the note number, byte2 is the velocity of that note.
      example
      ifequal, byte1, 20 ; if the note number coming in is note # 20
        {
          byte1 := (do something in here) ; could be do something to the velocity(byte2)
          gosub, SendNote ; send the note out.
        }
  */
  ; ++++++++++++++++++++++++++++++++ examples of note rules ++++++++++ feel free to add more.
     
     ifequal, byte1, 20 ; if the note number coming in is note # 20
        {
          byte1 := (byte1 +1) ; transpose that note up 1 note number  
          gosub, SendNote ; send the note out.
        }
      
      ifequal, byte1, 30 ; if the note number coming in is note # 30
        {
          send , {NumLock} ; send a keypress when note number 20 is received.
        }
      
      ; a little more complex filter two notes
      if ((byte1 != 60) and (byte1 != 62)) ; if note message is not(!) 60 and not(!) 62 send the note out - ie - do nothing except statements above (note 20 and 30 have things to do) to it.
        {
            gosub, SendNote ; send it out the selected output midi port
            ;msgbox, ,straight note, note %byte1% message, 1 ; this messagebox for testing only.
        }

      IfEqual, byte1, 60 ; if the note number is middle C (60) (you can change this)  
        {
            byte1 := (byte1 + 5) ;transpost up 5 steps
            gosub, SendNote ;(h_midiout, note) ;send a note transposed up 5 notes.
            ;msgbox, ,transpose up 5, note on %byte1% message, 1 ; for testing only - show msgbox for 1 sec
        }
      
      IfEqual, byte1, 62 ; if note on is note number 62 (just another example of note detection)
        {
            byte1 := (byte1 -5) ;transpose down 5 steps
            gosub, SendNote
            ;msgbox, ,transpose down 5, note on %byte1% message, 1 ; for testing only, uncomment if you need it.
        }	
    ; ++++++++++++++++++++++++++++++++ End of examples of note rules  ++++++++++ 
    } ; end of note block
  
; =============== all cc detection ---- 
  ; is input cc?
  
  if statusbyte between 176 and 191 ; check status byte for cc 176-191 is the range for CC messages ; !!!!!!!! no edit this line, uykwyad
    ;gosub, sendcc
    
    {
    ; ++++++++++++++++++++++++++++++++ examples of CC rules ++++++++++ feel free to add more.  
        if byte1 in %cc_msg%
          {
            cc := (byte1 + 3) ; Will change all cc#'s up 3 for a different controller number
            ;gosub, ShowMidiOutMessage
			;GuiControl,12:, MidiMsOut, CC %statusbyte% %chan% %cc% %byte2% 
            ;midiOutShortMsg(h_midiout, statusbyte, cc, byte2)
            gosub, sendCC
          }
        else if byte1 not in %cc_msg% ; if the byte1 value is one of these...
          { 
            cc := byte1 ; pass them as is, no change.
            ;gosub, ShowMidiInMessage
			;GuiControl,12:, MidiMsOut, CC %statusbyte% %chan% %cc% %byte2% 
           gosub, ShowMidiOutMessage
            gosub, sendCC 
          }  
    ; ++++++++++++++++++++++++++++++++ examples of cc rules ends ++++++++++++ 
    }
  
  ; Is midi input a Program Change?
  if statusbyte between 192 and 208  ; check if message is in range of program change messages for byte1 values. ; !!!!!!!!!!!! no edit
    {
    ; ++++++++++++++++++++++++++++++++ examples of program change rules ++++++++++  
      ; Sorry I have not created anything for here nor for pitchbends....
      
      ;GuiControl,12:, MidiMsOut, ProgC:%statusbyte% %chan% %byte1% %byte2% 
          ;gosub, ShowMidiInMessage
		  gosub, sendPC
          ; need something for it to do here, could be converting to a cc or a note or changing the value of the pc
          ; however, at this point the only thing that happens is the gui change, not midi is output here.
          ; you may want to make a SendPc: label below
    ; ++++++++++++++++++++++++++++++++ examples of program change rules ++++++++++   
    }
  ;msgbox filter triggered
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  end of edit section
Return

;*************************************************
;*          MIDI OUTPUT LABELS TO CALL
;*************************************************

SendNote: ;(h_midiout,Note) ; send out note messages ; this should probably be a funciton but... eh.
  ;{
  
 
  ;GuiControl,12:, MidiMsOutSend, NoteOut:%statusbyte% %chan% %byte1% %byte2% 
    ;global chan, EventType, NoteVel
    ;MidiStatus := 143 + chan
    note = %byte1%                                      ; this var is added to allow transpostion of a note
    midiOutShortMsg(h_midiout, statusbyte, note, byte2) ; call the midi funcitons with these params.
     gosub, ShowMidiOutMessage
Return
  
SendCC: ; not sure i actually did anything changing cc's here but it is possible.

   
	;GuiControl,12:, MidiMsOutSend, CCOut:%statusbyte% %chan% %cc% %byte2%
    midiOutShortMsg(h_midiout, statusbyte, cc, byte2)
     
     ;MsgBox, 0, ,sendcc triggered , 1
 Return
 
SendPC:
    gosub, ShowMidiOutMessage
	;GuiControl,12:, MidiMsOutSend, ProgChOut:%statusbyte% %chan% %byte1% %byte2%
    midiOutShortMsg(h_midiout, statusbyte, pc, byte2)
 /* 
  COULD BE TRANSLATED TO SOME OTHER MIDI MESSAGE IF NEEDED.
 */
Return



