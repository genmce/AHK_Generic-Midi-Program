; ++++++++++++++++++++++++ hotkeys here +++++++++++++++++++++++++=
/* 
  Generate midi messages from computer keyboard (mouse) events,
  METHOD 2 - Thanks JimF!
  
  Examples below
  
  What is going on here.
  A settimer (loop) is running every 70millisecond (timing is approximate as per the ahk manual on settimmer) called KeyboardCCs. 
  The loop below in the keyboardccs label detects if the var Vol is set to U, D or blank.
  The value of the var Vol is set by the hotkeys F11 and F12.
  The KeyboardCCs timer will do Send midi messages or not depending on the state of the Vol varible.
  VolVal is the value of the volume to send out.
  VolDelta is the amount of change of the VolVar each time the timer does 1 loop.
  The VolDelta var is set near the beginning of the generic_midi_program.
  As is VolVal and CCnum
  
*/



;*************************************************
;*          HOTKEY DEFINITIONS
;*************************************************

; here are a few examples of adding controller hotkeys.

=::Vol = U   ;    
= up::Vol = 
-::Vol = D   ; Mod wheel down 
- up::Vol = 

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

; =============== this is a section for volume control

If Vol = U ; increase volume up
  {
    VolVal := VolVal + VolDelta     ;see generic midi program05.ahk where vars defined. increase VolVal by VolDelta amount
    If VolVal > 127                 ; check for max value reached
    VolVal:= 127, Vol:=""           ; Don't go beyond the top
    midiOutShortMsg(h_midiout, (channel+175), CCnum, VolVal)    ;  ((channel+175) will make the correct statusbyte for cc message on midi chan1) CCnum var defined in autoexec section at top, VolVal is calculated three lines above.  
    byte1 = %ccnum%
    byte2 = %volVal%
	gosub, ShowMidiOutMessage       ; Show the midi message on the output monitor - needs revision - something weird here.
  }
If Vol = D ; decrease - volume down.
  {
    volVal := volVal- volDelta      ; decrease VolVal by VolDelta amount.
    If volVal < 0                   ; check min value reached. 
    VolVal:=0, Vol=""               ; if so set vol to blank and stop doing anything.
    midiOutShortMsg(h_midiout, (channel+175), CCnum, VolVal) 
     byte1 = %ccnum%
    byte2 = %volVal%
	gosub, ShowMidiOutMessage ; change the gui to a function
  }
if Vol = ; set the var to blank
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