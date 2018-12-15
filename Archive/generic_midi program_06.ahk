/* 
 ;*************************************************
 ;*             GENERIC MIDI APP V.0.6 
 ;*************************************************
; Last edited 12/16/2010 10:46 PM by genmce

 
 Spliting this program into multiple files for readability.
 
 
 
 I fear that adding so many different examples my make this more difficult to use.
 I may have to pull different parts, MidiRules into an include file the same goes for the hotkeys midi generation...
 Ah well...
 
 ****************************************************************
 Please post your revisions back to this forum post.
 Please post your derivative projects back to this page, so that others can learn from what you do.
 Please share, as I am sharing, so that others may learn and grow!
 ****************************************************************
 
Generic Midi Program
  Basic structural framework for a midi program in ahk.
  The description of what this is for is contained in the first post on the topic Midi Input/Output Combined at the ahk forum.
  Please read it, if you want to know more.
  I have added a few more examples for different midi data types as well as more, meaningful (I hope), documentation to the script.
  You are strongly encouraged to visit http://www.midi.org/techspecs/midimessages.php (decimal values), to learn more 
  about midi data.  It will help you create your own midi rules.
  
  I have combined much of the work of others here.
  It is a working script, most of the heavy lifing has been done for you.
  You will need to create your own midi rules. 
  By creating or modifying if statements in the section of the MidiRules.ahk file.
  By creating hotkeys that generate midi messages in the hotkeyTOmidi.ahk file.
  
  I don't claim to be an expert on this, just a guy who pulled disparate things together.
  I really need help from someone to add sysex functionality.
  
******  Sections with  !!!!!!!!!!!!!!!!!!!!!! - don't edit between these, unless you know what you are doing (uykwyad) !
  
******  Sections with ++++++++++++++++++++++ Edit between these marks. You won't break it, I don't think???

 v. 0.6
    + Joystick to midi 
    + Mouse to midi
 
 v. 0.5
    + changing this to multiple files for better readability, hopefully, I did not make it more confusing??
    + will leave version 4 up on the site and add these versions with a download location for version 5
    + New midi monitor, little smaller, little cleaner, I hope.
	+ Does NOT detect when midi input = midi output so display will get stuck in midi loop - just change your midi ports.
    + Auto detect ini file, if it does not exist, one will be generated. 
    + ini file name is generated from script name, so if you change you script name, it will generate a new ini file. Don't worry, it will do that every time to change the main program file name.
  
    
 v. 0.4
    + added an example of hotkey generating midi (volume controller)
    + added a second example for you create your own hotkey generated midi message.
    
    
  v. 0.3 changes
  + Adding text for how to add new rules.
  + Midi Rules, name used instead of filters, seems more appropriate.
  + Moved all rules outside the detector function, hoping to make it easier to understand and use.
  + abandoned the idea of dynamic code and a gui to create rules, omg, someone else do that, please!
  + Adding more examples for rules.
  + more to come, maybe...
  + removed that notemsg var - did not need it, not sure why i used it... nevermind
  
  
   TODO - 
  + add a way to echo all midi input that is not filtered or modified to the output. Like a gui switch (sometimes you want it all sometimes you don't)
  + make the midi monitor easier to use and read, also a toggle for it to be on or off.
      - midi monitor columnar with data columns to show statusbyte, byte1 and byte2 as well as midi chan.
        So need a heading grid for each ....
  + bring back sendnote() funtion instead of a gosub, same for each type of midi data.
  + Figure out how to do SYSEX with it, PLEASE HELP ME ON THIS!
 
 Generic midi program v. - 0.2 changes

  - fixed bad note off detection...
  - select input and output port
  - open and close selected midi ports
  - write ports to ini file
  - send receive midi data
  - modify received midi data, send it to output port
  - uses contributions by so many different people. See midi input and midi output forum posts. Links in midi under the hood section below
  - "under the hood" midi functions and subroutines at the end of this file 
  - post your creations back to this midi I/O thread - that way we can all build on it.
  
  Notes - All midi in/out lib stuff is included here, no external dlls, besides winmm.dll required.
  Use of this - you should only need to edit the input part - great way to practice you if else logic and midi manipulation.
  This does not do sysex. I really want to develop that, but not sure how to go about it.
  Perhaps one day.
 
*/
 
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! no edit here 
 
#Persistent
#SingleInstance
SendMode Input              ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

if A_OSVersion in WIN_NT4,WIN_95,WIN_98,WIN_ME  ; if not xp or 2000 quit
{
    MsgBox This script requires Windows 2000/XP or later.
    ExitApp
}

;*************************************************
version = Generic_Midi_App_0.6  ; Change this to suit you.          
;*************************************************

readini()                       ; load values from the ini file, via the readini function - see Midi_under_the_hood.ahk file
gosub, MidiPortRefresh          ; used to refresh the input and output port lists - see Midi_under_the_hood.ahk file
port_test(numports,numports2)   ; test the ports - check for valid ports? - see Midi_under_the_hood.ahk file
gosub, midiin_go                ; opens the midi input port listening routine see Midi_under_the_hood.ahk file
gosub, midiout                  ; opens the midi out port see Midi_under_the_hood.ahk file  
gosub, midiMon                  ; see below - a monitor gui - see Midi_In_and_GuiMonitor.ahk

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! end edit here 

;*************************************************
;*         VARIBLES TO SET @ STARTUP
;*************************************************

cc_msg = 73,74 ; ++++++++++++++++ you might want to add other vars that load in auto execute section
; varibles below are for keyboarcc 
channel = 1     ; default channel =1
ccnum = 7       ; 7 is volume
volVal = 0     ; Default zero for volume
volDelta = 1  ; Amount to change volume 
; end of vars for hotkey and keyboardcc

/* 
  yourVar = 0
  yourVarDelta = 3
  yourVarCCnum = 1 ; modwheel
*/

settimer, KeyboardCCs, 70 ; timer (loop of code) to run the KeyboardCCs at the 70 interval

gosub, go_xymouse

return ; !!!! no edit here, need this line to end the auto exec section.

;*************************************************
;*          END OF AUTOEXEC SECTION
;*************************************************

/* 
  The rest of the script has been broken out to other parts for readability, I hope!
*/

;*************************************************
;*              INCLUDE FILES -
;*  these files need to be in the same folder
;*************************************************
; include files below - you need each of these files in the same folder as this file for this to work.

#Include Midi_In_and_GuiMonitor.ahk ; this file contains: the function to parse midi message into parts we can work with and a midi monitor.
#Include MidiRules.ahk              ; this file contains: Rules for manipulating midi input then sending modified midi output.
#Include hotkeyTOmidi_1.ahk         ; this file contains: examples of HOTKEY generated midi messages to be output - the easy way!
#Include hotkeyTOmidi_2.ahk         ; this file contains: examples of HOTKEY generated midi messages to be output - the BEST way!
#include joystuff.ahk               ; this file contains: joystick stuff.   
#include xy_mouse.ahk

#Include Midi_under_the_hood.ahk    ; this file contains: (DO NOT EDIT THIS FILE) all the dialogs to set up midi ports and midi message handling.