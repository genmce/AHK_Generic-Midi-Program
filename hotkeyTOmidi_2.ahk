; ++++++++++++++++++++++++ hotkeys here +++++++++++++++++++++++++=
/* 
  Generate midi messages from computer keyboard (mouse) events,
  METHOD 2 - Thanks JimF!
  
  Examples below
  
  What is going on here.
  A settimer (loop) is running every 70millisecond (timing is approximate as per the ahk manual on settimmer) called KeyboardCCs. 
  The loop below in the keyboardccs label detects if the var Vol is set to U, D or blank.
  The value of the var CC1 is set by the hotkeys  "- "and "=".
  The KeyboardCCs timer will do Send midi messages or not depending on the state of the CC1 varible.
  VolVal is the value of the volume to send out.
  VolDelta is the amount of change of the VolVar each time the timer does 1 loop.
  The VolDelta var is set near the beginning of the generic_midi_program.
  As is VolVal and CCnum
  
*/



;*************************************************
;*          HOTKEY DEFINITIONS
;*************************************************

; here are a few examples of adding controller hotkeys.

=::CC1 = U     ; Detects if key  "="  is pressed, if yes CC1 var is set to U for volume up  se below
= up::CC1 =   ; detects if  key is released 
-::CC1 = D      ;  
- up::CC1 = 

/* 
; here are two more examples you can add

  F10::yourVar = U   ; set yourVar to U for changing value up
  F10 UP::yourVar =  ; set yourVar blank to stop message generation
  F9::yourVar = D    ; set yourVar to D for changing value down
  f9::yourVar =      ; set yourVar to blank to stop message generation
*/
; ++++++++++++++++++++++++++++++ end hotkey defs ++++++++++++++++++++

; +++++++++++++++++++++++++++++ begin keyboardccs section +++++++++++

;*************************************************
;*      TIMER - (LOOP) TO RUN FOR CONVERSION
;*************************************************

  /* 
    Process Definitions for hotkey generated midi controllers.
    Unless you are good at arrays (I am not)
    You will need to add three statements like these, for each controller you wish to generate from a pair of hotkeys.
  */

KeyboardCCs:

;*****************************************************************
;   THIS SECTION CONVERTS KEY PRESS TO MIDI CC MSG
;*****************************************************************

; =============== this is a section for volume control

If CC1 = U ; increase volume up
  {
    ;CC_num = 7 				; What CC (data data1) do you wish to send?
    CCIntVal := CCIntVal + CCIntDelta     ;see generic midi program05.ahk where vars defined. increase VolVal by VolDelta amount
    If CCIntVal > 127                 ; check for max value reached
      CCIntVal:= 127, CC1:=""           ; Don't go beyond the top
    gosub, SendCC
    ;midiOutShortMsg(h_midiout, (channel+175), CC_num, VolVal)    ;  ((channel+175) will make the correct statusbyte for cc message on midi chan1) CCnum var defined in autoexec section at top, VolVal is calculated three lines above.  
   ;data1 = %CC_num%
   ;data2 = %volVal%
	;gosub, ShowMidiOutMessage       ; Show the midi message on the output monitor - needs revision - something weird here.
  }
If CC1= D ; decrease - volume down.
  {
    CC_num = 7 				; What CC (data data1) do you wish to send?
    ;CCIntVal := CCIntVal > 0 ? CCIntVal-1 : 0 
    CCIntVal := CCIntVal - CCIntDelta     ; decrease VolVal by VolDelta amount.
    If CCIntVal < 0                   ; check min value reached. 
  CCIntVal:=0, CC1 =""               ; if so set vol to blank and stop doing anything.
    gosub, SendCC
    ;midiOutShortMsg(h_midiout, (channel+175), CC_num, VolVal) 
     ;data1 = %CC_num%
    ;data2 = %volVal%
	;gosub, ShowMidiOutMessage ; change the gui to a function
  }
if CC1 = ; set the var to blank
  {
    ; do nothing.
  }
; =============== end of volume control

;++++++++++++++++++++++++++++++ edit below as needed to add new ccs

;*************************************************
;*          ADD NEW VARS AND METHOD HERE
;*************************************************
/*
; ********* remember you can't use yourVar, yourVarCCnum and yourVarDelta unless you define it somewhere, autoexec section makes sense. 
            ;(That is not true, you can define vars as you go... but until you get used to it, might be better to define them in autoexec first.)
            
            ;Define some hotkeys - I have done so just above the KeyboardCCs label.
            

; examples to be triggered by f9 and f10 defined above but commented out.
; **********

If yourVar = U
  {
    yourVarVal := yourVarVal + yourVarDelta ;see top where vars defined.
    If yourVarVal > 127   ; check for max value reached
    yourVarVal:= 127, yourVar:=""
    ;yourVarCCnum := 10 ; just an example the var can be defined here just as well, but you will probably need it in the other below too...
    midiOutShortMsg(h_midiout, (channel+175), yourVarCCnum, yourVarVal)    ;  yourVarCCnum is defined in autoexec section and yourVarVal is defined in the lines directly above.
  }
If yourVar = D
  {
    yourVarVal := yourVarVal- yourVarDelta 
    If yourVarVal < 0      ; check min value reached. 
    yourVarVal:=0, yourVar=""
    ;yourVarCCnum := 10 ; just an example the var can be defined here just as well, all places that need it will need it... that sounds dumb!... that is why defining in autoexec might be better....
    midiOutShortMsg(h_midiout, (channel+175), yourVarCCnum, yourVarVal) 
  }
if yourVar = ; set the var to blank
  {
    ; do nothing.
  }

*/
Return