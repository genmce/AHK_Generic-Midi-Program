; Last edited 12/18/2018 3:03 PM by genmce
;*************************************************
;*          RULES - MIDI FILTERS - 
;       MIDI INPUT TO KEY PRESS
;*************************************************
/* 
This section will deal with transforming midi; NoteOns, NoteOffs, Continuous Controllers and Program Change messages
You can 
- Transform the midi input > computer keypress(s) like a macro.  
- Transform the midi input > to some other type of midi output.
Both are possible in the same script.
This script does NOT, currently, pass the original midi messsage out.

There are a few ways to handle transformations
1. Set up a filter to detect correct type and data1 val - then run commands or 
2. Set up filter after type filter (NoteOn, NoteOff, CC or PC) under that section below -      
(Keep rules together under proper section, notes, cc, program change etc.
Keep them after the statusbyte has been determined.
Examples for each type of rule will be shown. 
The example below is for note type message.)

Statusbyte between 128 and 159 ; see range of values for notemsg var defined in autoexec section. "in" used because ranges of note on and note off
{ ; beginning of note block

statusbyte between 128 and 143 ARE NOTE OFF'S
statusbyte between 144 and 159 ARE NOTE ON'S 
statusbyte between 176 and 191 ARE CONTINUOS CONTROLLERS
statusbyte between 192 and 208  ARE PROGRAM CHANGE for data1 values

Remember: 
NoteOn/Off data1 = note number, data2 = velocity of that note.
CC - data1 = cc #, data2 = cc value 
Program Change - data1 = pc #, data2 - ignored

ifequal, data1, 20 ; if the note number coming in is note # 20
{
  data1 := (do something in here) ; could be do something to the velocity(data2)
  gosub, SendNote ; send the note out.
}
*/
/* 
  WHAT DO YOU REALLY WANT TO DO?
  CONVERT MIDI TO KEYSTROKE?  Line 45 this file 
  MODIFY MIDI INPUT AND SEND IT BACK OUT?
*/

;*****************************************************************
;   Midi input is detected in Midi_In_Out_Lib  - 
;   it automatically runs the MidiRules label
;*****************************************************************


MidiRules: ; This label is where midi input is modified or converted to  keypress.



;*****************************************************************
;     EXAMPLE OF MIDI TO KEYPRESS - 
;*****************************************************************
;if  (stb = "NoteOn" And data1  = "36")  ; Example - if  msg is midi noteOn AND note# 36 - trigger msg box - could trigger keycommands  
  {
 ; MsgBox, 0, , Note %data1%, 1          ; show the msgbox with the note# for 1 sec


;msgbox,,,midirules %CC_num%,1


;UNCOMMENT LINE BELOW TO SEND A KEYPRESS WHEN NOTE 36 IS RECEIVED
  ;send , {NumLock} ; send a keypress when note number 20 is received.
;  }

;*****************************************************************
; Compare statusbyte of recieved midi msg to determine type of 
; You could write your methods under which ever type of  midi you want to convert

; RETHINK HOW THESE ARE ORGANIZED AND MAYBE TO IT BY LINE
;*****************************************************************

; =============== Is midi input a Note On or Note off message?  =============== 
 ; If statusbyte between 128 and 159 ; see range of values for notemsg var defined in autoexec section. "in" used because ranges of note on and note off
;	{ ; beginning of note block
 
if statusbyte between 144 and 159 ; detect if note message is "note on" 
 ;*****************************************************************
 ;    PUT ALL "NOTE ON" TRANSFORMATIONS HERE
 ;*****************************************************************
  ;ifequal, data1, 57  ;  if the note number coming in is note # 20
    {
    ;MsgBox, 64, Note on Note = %data1%, Note %data1%, 1
     ;data1 := (data1 +1) ; transpose that note up 1 note number  
     gosub, RelayNote ; send the note out.
    }
   
 ; =============== END OF NOTE ON MESSAGES ; ===============
      
  if statusbyte between 128 and 143 ; detect if note message is "note off"
    ;*****************************************************************
    ;   PUT ALL NOTE OFF TRANSFORMATIONS HERE
    ;*****************************************************************
    
        ;gosub, ShowMidiInMessage
		;GuiControl,12:, MidiMsOut, noteOff:%statusbyte% %chan% %data1% %data2%  ; display note off in gui
 
  ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! above  end of no edit
     
  ; =============== add your note MidiRules here ==; =============== 

{
  
}

  /* 
      Write your own note filters and put them in this section.
      Remember data1 for a noteon/off is the note number, data2 is the velocity of that note.
      example
      ifequal, data1, 20 ; if the note number coming in is note # 20
        {
          data1 := (do something in here) ; could be do something to the velocity(data2)
          gosub, SendNote ; send the note out.
        }
  */
  ; ++++++++++++++++++++++++++++++++ examples of note rules ++++++++++ feel free to add more.
     
    /*
      ;*****************************************************************
      ; ANOTHER MIDI TO KEYPRESS EXAMPLE
      ;*****************************************************************
      
      ifequal, data1, 30 ; if the note number coming in is note # 30
        {
          send , {NumLock} ; send a keypress when note number 20 is received.
        }
      
      ; a little more complex filter two notes
      if ((data1 != 60) and (data1 != 62)) ; if note message is not(!) 60 and not(!) 62 send the note out - ie - do nothing except statements above (note 20 and 30 have things to do) to it.
        {
            gosub, SendNote ; send it out the selected output midi port
            ;msgbox, ,straight note, note %data1% message, 1 ; this messagebox for testing only.
        }

      IfEqual, data1, 60 ; if the note number is middle C (60) (you can change this)  
        {
            data1 := (data1 + 5) ;transpost up 5 steps
            gosub, SendNote ;(h_midiout, note) ;send a note transposed up 5 notes.
            ;msgbox, ,transpose up 5, note on %data1% message, 1 ; for testing only - show msgbox for 1 sec
        }
      
      IfEqual, data1, 62 ; if note on is note number 62 (just another example of note detection)
        {
            data1 := (data1 -5) ;transpose down 5 steps
            gosub, SendNote
            ;msgbox, ,transpose down 5, note on %data1% message, 1 ; for testing only, uncomment if you need it.
        }	
    ; ++++++++++++++++++++++++++++++++ End of examples of note rules  ++++++++++ 
    ;} 
*/

; =============== IS INCOMING MIDI MESSAGE A CC?  ---- 
;*****************************************************************
;   IS INCOMING MSG IS A CC?
;*****************************************************************

  if statusbyte between 176 and 191 ; check status byte for cc 176-191 is the range for CC messages
   {
    
    ;MsgBox,,,,1
    ;*****************************************************************
    ;   PUT ALL CC TRANSFORMATIONS HERE 
    ;***************************************************************** 
    ;++++++++++++++++++++++++++++++++ examples of CC rules ++++++++++ feel free to add more.  
     IfEqual, data1, 7
      {
     ;  msgbox, ,,7,1
       CC_num := (data1 + 3) ; Will change all cc#'s up 3 for a different controller number
        ;CCintVal = data2
         gosub, RelayCC
      return   
      }
    ifEqual, data1, 20
    {
      CC_num := 60
    ;  MsgBox,,,20,1
       gosub, RelayCC 
       return
    }  
    Else
    {
    CC_num := data1
    gosub, RelayCC ; relay message unchanged 
   ; MsgBox,,,else %data1%,1
    return
    }

; ++++++++++++++++++++++++++++++++ examples of cc rules ends ++++++++++++ 
   }
  
  ;*****************************************************************
  ; IS INCOMING MSG A PROGRAM CHANGE MESSAGE?
  ;*****************************************************************
  if statusbyte between 192 and 208  ; check if message is in range of program change messages for data1 values. ; !!!!!!!!!!!! no edit
    {
      ;*****************************************************************
      ; PUT ALL PC TRANSFORMATIONS HERE
      ;*****************************************************************
      
    ; ++++++++++++++++++++++++++++++++ examples of program change rules ++++++++++  
      ; Sorry I have not created anything for here nor for pitchbends....
      
      ;GuiControl,12:, MidiMsOut, ProgC:%statusbyte% %chan% %data1% %data2% 
          ;gosub, ShowMidiInMessage
		  gosub, sendPC
          ; need something for it to do here, could be converting to a cc or a note or changing the value of the pc
          ; however, at this point the only thing that happens is the gui change, not midi is output here.
          ; you may want to make a SendPc: label below
    ; ++++++++++++++++++++++++++++++++ examples of program change rules ++++++++++   
    }
  ;msgbox filter triggered
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  end of edit section

}

Return









/* =============================

THIS SECTION MOVED

;*************************************************
;*          MIDI OUTPUT LABELS TO CALL
;*************************************************

SendNote:   ;(h_midiout,Note) ; send out note messages ; this should probably be a funciton but... eh.
  ;{
    ;GuiControl,12:, MidiMsOutSend, NoteOut:%statusbyte% %chan% %data1% %data2% 
    ;global chan, EventType, NoteVel
    ;MidiStatus := 143 + chan
    note = %data1%                                      ; this var is added to allow transpostion of a note
    midiOutShortMsg(h_midiout, statusbyte, note, data2) ; call the midi funcitons with these params.
     gosub, ShowMidiOutMessage
Return
  
SendCC: ; not sure i actually did anything changing cc's here but it is possible.

   
	;GuiControl,12:, MidiMsOutSend, CCOut:%statusbyte% %chan% %cc% %data2%
    midiOutShortMsg(h_midiout, statusbyte, cc, data2)
     
     ;MsgBox, 0, ,sendcc triggered , 1
 Return
 
SendPC:
    gosub, ShowMidiOutMessage
	;GuiControl,12:, MidiMsOutSend, ProgChOut:%statusbyte% %chan% %data1% %data2%
    midiOutShortMsg(h_midiout, statusbyte, pc, data2)

  ;COULD BE TRANSLATED TO SOME OTHER MIDI MESSAGE IF NEEDED.

Return
;==========================================
*/


