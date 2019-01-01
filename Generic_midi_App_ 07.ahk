; Last edited 1/1/2019 5:03 PM by genmce
/* 
;*************************************************
;*             GENERIC MIDI APP V.0.7 
;*************************************************

THIS IS THE PROGRAM TO RUN! 
EDIT THE OTHER FILES 
#Include MidiRules.ahk              ; this file contains: Rules for transforming midi input.
#Include hotkeyTOmidi_1.ahk         ; this file contains: examples of HOTKEY generated midi messages to be output - the easy way!
#Include hotkeyTOmidi_2.ahk         ; this file contains: examples of HOTKEY generated midi messages to be output - the BEST way!

Midi messages: Here is a good reference https://stackoverflow.com/questions/29481090/explanation-of-midi-messages
Example message: 10010011 00011011 0111111
Where the first byte is the status byte, 2nd byte is the data1 byte, and 3rd byte is the data 2 byte
 status        data1        data2
10010011 00011011 0111111
Status is the type of message (note on/off, CC, program change... etc + the midi channel)
Data 1 - midi note# (for note messages), cc# (for CC messages)
Data 2 - midi note Velocity (for note on/off messages, CC value (for CC messages)

--------------- old readme below--------------
 
Generic Midi App - renamed from Generic Midi Program
  Basic structural framework for a midi program in ahk.
  The description of what this is for is contained in the first post on the topic Midi Input/Output Combined at the ahk forum.
  Please read it, if you want to know more.
  I have added a few more examples for different midi data types as well as more, meaningful (I hope), documentation to the script.
  You are strongly encouraged to visit http://www.midi.org/techspecs/midimessages.php (decimal values), to learn more 
  about midi data.  It will help you create your own midi rules.
  
  I have combined much of the work of others here.
  You will need to create your own midi rules; 
    By creating or modifying if statements in the section of the MidiRules.ahk file.
    By creating hotkeys that generate midi messages in the hotkeyTOmidi.ahk file.
  
  I don't claim to be an expert on this, just a guy who pulled disparate things together.
  I really need help from someone to add sysex functionality.
  
  * Notes - All midi in/out lib stuff is included in Midi_In_Out_Lib.ahk, besides winmm.dll (part of windows).
*/
#Persistent
#SingleInstance , force         	                                                    ; Only run one instance
SendMode Input                              	                                ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%       	                                ; Ensures a consistent starting directory.
if A_OSVersion in WIN_NT4,WIN_95,WIN_98,WIN_ME  ; If not Windows XP or greater, quit program
{   
   MsgBox This script requires Windows 2000/XP or later.
    ExitApp
}
;*************************************************
version = Generic_Midi_App_0.71  ; Version name and number
;*************************************************
readini()                                            ; Load values from the ini file, via the readini function - see Midi_In_Out_Lib.ahk file
gosub, MidiPortRefresh                  ; used to refresh the input and output port lists - see Midi_In_Out_Lib.ahk file
port_test(numports,numports2)   ; test the ports - check for valid ports? - see Midi_In_Out_Lib.ahk file
gosub, midiin_go                            ; opens the midi input port listening routine see Midi_In_Out_Lib.ahk file
gosub, midiout                               ; opens the midi out port see Midi_In_Out_Lib.ahk file 
gosub, midiMon                             ; see below - a monitor gui - see Midi_In_Out_Lib.ahk file  COMMENT THIS OUT IF YOU DON'T WANT DISPLAY

;*************************************************
;*         VARIBLES TO SET @ STARTUP
;*************************************************

; =============== varibles below are for keyboard cc 
channel = 1        ; default channel =1
CC_num = 7         ; CC 
CCIntVal = 0       ; Default zero for  CC  (data byte 2)
CCIntDelta = 1     ; Amount to change CC (data byte 2)

/* 
  yourVar = 0
  yourVarDelta = 3
  yourVarCCnum = 1 ; modwheel
*/

;*****************************************************************
;   SETTIMER BELOW - ONLY USED WITH HOTKEYTOMIDI_2 METHOD
;*****************************************************************
/* 
 TODO Make .ini entry for this label - for use with hotkey2midi_2 method only to write it might need a gui too????
*/
settimer, KeyboardCCs, 50 ; KeyBoardCCs is located in HotKeyTOMidi2.ahk > timer (loop of code) to run the KeyboardCCs at the 70ms interval
; settimer, MidiRules, 70 ; does not seem to work  not needed called during onmessage detect

;*****************************************************************
;   XYMOUSE AND JOYSTICK ROUTINES - NOT USED AT THIS TIME
;*****************************************************************
;gosub, go_xymouse   ; loads the xy mouse  - only use if needed.... maybe make a switch for this?

return ;  Ends autoexec section
;*************************************************
;*          END OF AUTOEXEC SECTION
;*************************************************

;*************************************************
;*          SEND MIDI OUTPUT BASED ON TYPE  
;*************************************************

/* 
  Questions here - leave these labels and methods or 
  have them be part of each rule created - have it send the message by the function call or call these labels 
  - make the gui a function call instead of a label and use the same vars that are passed to output function...
  
*/

;*****************************************************************
;   SEND OUT MIDI CONTIOUS CONTROLLERS - CC'S
;*****************************************************************

RelayCC: ; ===============THIS FOR RELAYING CC'S OR TRANSLATING MIDI CC'S
   stb := "CC"                                                                                               ; Only used in the midi display - has nothing to do with message output    
  MidiOutDisplay(stb, statusbyte, chan , CC_num, data2)                      ; update the midimonitor gui
   midiOutShortMsg(h_midiout, (Channel+175), CC_num, CCIntVal)   ; SEND OUT THE MESSAGE > function located in Midi_In_Out_Lib.ahk;MsgBox, 0, ,sendcc triggered , 1 ; for testing purposes only
 Return

SendCC: ; ===============use this for converting keypress into midi message
  midiOutShortMsg(h_midiout, (Channel+175), CC_num, CCIntVal) ; SEND OUT THE MESSAGE > function located in Midi_In_Out_Lib.ahk
  ; =============== set vars for display only ;  get these to be the same vars as midi send messages
  stb := "CC" 
  statusbyte := (Channel+174)
  data1 = %CC_num%			; set value of the data1 to the above cc_num for display on the midi out window (only needed if you want to see output)	
  data2 = %CCIntVal%	    
  MidiOutDisplay(stb, statusbyte, channel, data1, data2) ; ; update the midimonitor gui
  ;MsgBox, 0, ,sendcc triggered , 1 ; for testing purposes only
Return

RelayNote:   ;(h_midiout,Note) ; send out note messages ; this should probably be a funciton but... eh
  midiOutShortMsg(h_midiout, statusbyte, data1, data2) ; call the midi funcitons with these params.
  stb := "NoteOn"
  MidiOutDisplay(stb, statusbyte, chan, data1, data2)
Return

SendNote:   ;(h_midiout,Note) ; send out note messages ; this should probably be a funciton but... eh
  note = %data1%                                      ; this var is added to allow transpostion of a note
  vel = %data2%
  midiOutShortMsg(h_midiout, statusbyte, note, vel) ; call the midi funcitons with these params.
    stb := "NoteOn"
    statusbyte := 144
    chan 	= %channel%
    data1 = %Note%			; set value of the data1 to the above cc_num for display on the midi out window (only needed if you want to see output)	
    data2 = %Vel%	
    MidiOutDisplay(stb, statusbyte, chan, data1, data2)
Return

SendPC: ; Send a progam change message - data2 is ignored - I think...
    midiOutShortMsg(h_midiout, (Channel+191), pc, data2)
    stb := "PC"
    statusbyte := 192
    chan 	= %channel%
    data1 = %PC%			; set value of the data1 to the above cc_num for display on the midi out window (only needed if you want to see output)	
    data2 = 
    MidiOutDisplay(stb, statusbyte, chan, data1, data2)
Return

/* 
   Method could be developed for other midi messages like after touch...etc.
 */
;*************************************************
;*              INCLUDE FILES -
;*  these files need to be in the same folder
;*************************************************
#Include MidiRules.ahk              ; this file contains: Rules for manipulating midi input then sending modified midi output.
#Include hotkeyTOmidi_1.ahk         ; this file contains: examples of HOTKEY generated midi messages to be output - the easy way!
#Include hotkeyTOmidi_2.ahk         ; this file contains: examples of HOTKEY generated midi messages to be output - the BEST way!
;#include joystuff.ahk              ; this file contains: joystick stuff.   
;#include xy_mouse.ahk
#Include mio2.ahk       ; this file replaced the midi in out lib below - for now