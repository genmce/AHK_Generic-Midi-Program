
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! no edit below here, unless you know what you are doing. 

;*************************************************
;*          MIDI UNDER THE HOOD
;*  DO NOT EDIT IN HERE, unless you know what 
;*          what you are doing!
;*************************************************

;****************************************************************************************************************
;******************************************** midi "under the hood" *********************************************
/* 
    This part is meant to take care of the "under the hood" midi input and output selection and save selection to an ini file.
    Hopefully it simplifies usage for others out here trying to do things with midi and ahk.
    
    * use it as an include.
    
    The code here was taken/modified from the work by TomB/Lazslo on Midi Output
        http://www.autohotkey.com/forum/viewtopic.php?t=18711&highlight=midi+output
    
    Orbik's Midi input thread 
        http://www.autohotkey.com/forum/topic30715.html
        This method does NOT use the midi_in.dll, it makes direct calls to the winmm.dll
        
    Many different people took part in the creation of this file.
    
    ; Last edited 6/17/2010 11:30 AM by genmce

*/

;*************************************************
;*          GET PORTS LIST PARSE
;*************************************************
MidiPortRefresh: ; get the list of ports

 MIlist := MidiInsList(NumPorts) 
	Loop Parse, MIlist, | 
		{
		}
	TheChoice := MidiInDevice + 1

MOlist := MidiOutsList(NumPorts2) 
   Loop Parse, MOlist, | 
		{
		}
	TheChoice2 := MidiOutDevice + 1

return

;*************************************************
;*          LOAD UP SOME STUFF.
;*************************************************
;-----------------------------------------------------------------

ReadIni() ; also set up the tray Menu
  {
    Menu, tray, add, MidiSet            ; set midi ports tray item
    Menu, tray, add, ResetAll           ; Delete the ini file for testing --------------------------------
    menu, tray, add, MidiMon
    global MidiInDevice, MidiOutDevice, version ; version var is set at the beginning.
    IfExist, %version%.ini
      {
        IniRead, MidiInDevice, %version%.ini, Settings, MidiInDevice , %MidiInDevice%     ; read the midi In port from ini file
        IniRead, MidiOutDevice, %version%.ini, Settings, MidiOutDevice , %MidiOutDevice%  ; read the midi out port from ini file
      }
    Else ; no ini exists and this is either the first run or reset settings.
      {
        MsgBox, 1, No ini file found, Select midi ports?
        IfMsgBox, Cancel
          ExitApp
        IfMsgBox, yes
          gosub, midiset
        ;WriteIni()
      }
  }
;*************************************************
;*          WRITE TO INI FILE FUNCTION 
;*************************************************

;CALLED TO UPDATE INI WHENEVER SAVED PARAMETERS CHANGE
WriteIni()
  {
    global MidiInDevice, MidiOutDevice, version
   
    IfNotExist, %version%io.ini ; if no ini 
      FileAppend,, %version%io.ini ; make one with the following entries.
    IniWrite, %MidiInDevice%, %version%.ini, Settings, MidiInDevice
    IniWrite, %MidiOutDevice%, %version%.ini, Settings, MidiOutDevice
  }

;*************************************************
;*                 PORT TESTING
;*************************************************
;------------ port testing to make sure selected midi port is valid --------------------------------

port_test(numports,numports2) ; confirm selected ports exist ; CLEAN THIS UP STILL 

  {
    global midiInDevice, midiOutDevice, midiok
    
    ; ----- In port selection test based on numports
    If MidiInDevice not Between 0 and %numports% 
      {
        MidiIn := 0 ; this var is just to show if there is an error - set if the ports are valid = 1, invalid = 0
            ;MsgBox, 0, , midi in port Error ; (this is left only for testing)
        If (MidiInDevice = "")              ; if there is no midi in device 
            MidiInerr = Midi In Port EMPTY. ; set this var = error message
            ;MsgBox, 0, , midi in port EMPTY
        If (midiInDevice > %numports%)          ; if greater than the number of ports on the system.
            MidiInnerr = Midi In Port Invalid.  ; set this error message
            ;MsgBox, 0, , midi in port out of range
      }
    Else
      {
        MidiIn := 1 ; setting var to non-error state or valid
      }
    ; ----- out port selection test based on numports2
    If  MidiOutDevice not Between 0 and %numports2%
      {
        MidiOut := 0 ; set var to 0 as Error state.
        If (MidiOutDevice = "")                 ; if blank
            MidiOuterr = Midi Out Port EMPTY.   ; set this error message
            ;MsgBox, 0, , midi o port EMPTY
        If (midiOutDevice > %numports2%)             ; if greater than number of availble ports  
            MidiOuterr = Midi Out Port Out Invalid.  ; set this error message   
            ;MsgBox, 0, , midi out port out of range
      }
    Else
      {
        MidiOut := 1 ;set var to 1 as valid state.
      }
      ; ---- test to see if ports valid, if either invalid load the gui to select.
      ;midicheck(MCUin,MCUout)
    If (%MidiIn% = 0) Or (%MidiOut% = 0)
      {
        MsgBox, 49, Midi Port Error!,%MidiInerr%`n%MidiOuterr%`n`nLaunch Midi Port Selection!
        IfMsgBox, Cancel
          ExitApp
        midiok = 0 ; Not sure if this is really needed now....
        Gosub, MidiSet ;Gui, show Midi Port Selection
      }
    Else
      {
        midiok = 1
        Return ; DO NOTHING - PERHAPS DO THE NOT TEST INSTEAD ABOVE.
      }
  }
Return

;*************************************************
;*        		  MIDI SET GUI 
;*************************************************
; ------------------ end of port testing ---------------------------


MidiSet: ; midi port selection gui
 
 ; ------------- MIDI INPUT SELECTION -----------------------
  Gui, 6: Destroy
  Gui, 2: Destroy
  Gui, 3: Destroy
  Gui, 4: Destroy
  Gui, 4: +LastFound +AlwaysOnTop   +Caption +ToolWindow ;-SysMenu
  Gui, 4: Font, s12
  Gui, 4: add, text, x10 y10 w300 cmaroon, Select Midi Ports. ; Text title
  Gui, 4: Font, s8
  Gui, 4: Add, Text, x10 y+10 w175 Center , Midi In Port  ;Just text label
  Gui, 4: font, s8
  ; midi ins list box
  Gui, 4: Add, ListBox, x10 w200 h100  Choose%TheChoice% vMidiInPort gDoneInChange AltSubmit, %MiList% ; --- midi in listing of ports
    ;Gui,  Add, DropDownList, x10 w200 h120 Choose%TheChoice% vMidiInPort gDoneInChange altsubmit, %MiList%  ; ( you may prefer this style, may need tweak)

  ; --------------- MidiOutSet ---------------------
  Gui, 4: Add, TEXT,  x220 y40 w175 Center, Midi Out Port ; gDoneOutChange
  ; midi outlist box
  Gui, 4: Add, ListBox, x220 y62 w200 h100 Choose%TheChoice2% vMidiOutPort gDoneOutChange AltSubmit, %MoList% ; --- midi out listing
  ;Gui,  Add, DropDownList, x220 y97 w200 h120 Choose%TheChoice2% vMidiOutPort gDoneOutChange altsubmit , %MoList%
  Gui, 4: add, Button, x10 w205 gSet_Done, Done - Reload script.
  Gui, 4: add, Button, xp+205 w205 gCancel, Cancel
  ;gui, 4: add, checkbox, x10 y+10 vNotShown gDontShow, Do Not Show at startup.
  ;IfEqual, NotShown, 1
  ;guicontrol, 4:, NotShown, 1
  Gui, 4: show , , %version% Midi Port Selection ; main window title and command to show it.

Return

;-----------------gui done change stuff - see label in both gui listbox line




;44444444444444444444444444 NEED TO EDIT THIS TO REFLECT CHANGES IN GENMCE PRIOR TO SEND OUT

DoneInChange:
	gui +lastfound
	Gui, Submit, NoHide
	Gui, Flash
  Gui, 4: Submit, NoHide
  Gui, 4: Flash
  If %MidiInPort%
      UDPort:= MidiInPort - 1, MidiInDevice:= UDPort ; probably a much better way do this, I took this from JimF's qwmidi without out editing much.... it does work same with doneoutchange below.
  GuiControl, 4:, UDPort, %MidiIndevice%
  WriteIni()
  ;MsgBox, 32, , midi in device = %MidiInDevice%`nmidiinport = %MidiInPort%`nport = %port%`ndevice= %device% `n UDPort = %UDport% ; only for testing
Return

DoneOutChange:
  gui +lastfound
  Gui, Submit, NoHide
  Gui, Flash

  Gui, 4: Submit, NoHide
  Gui, 4: Flash
  If %MidiOutPort%
      UDPort2:= MidiOutPort - 1 , MidiOutDevice:= UDPort2
  GuiControl, 4: , UDPort2, %MidiOutdevice%
  WriteIni()
  ;Gui, Destroy
Return

;------------------------ end of the doneout change stuff.

Set_Done: ;  aka reload program, called from midi selection gui
  Gui, 3: Destroy
  Gui, 4: Destroy
   sleep, 100
  Reload
Return

Cancel:
  Gui, Destroy
  Gui, 2: Destroy
  Gui, 3: Destroy
  Gui, 4: Destroy
  Gui, 5: Destroy
Return

;*************************************************
;*          MIDI OUTPUT - UNDER THE HOOD
;*************************************************
; ********************** Midi output detection

MidiOut: ; Function to load new settings from midi out menu item
  OpenCloseMidiAPI()
  h_midiout := midiOutOpen(MidiOutDevice) ; OUTPUT PORT 1 SEE BELOW FOR PORT 2
return

ResetAll: ; for development only, leaving this in for a program reset if needed by user
  MsgBox, 33, %version% - Reset All?, This will delete ALL settings`, and restart this program!
  IfMsgBox, OK
    {
      FileDelete, %version%.ini   ; delete the ini file to reset ports, probably a better way to do this ...
      Reload                        ; restart the app.
    }
  IfMsgBox, Cancel
Return

GuiClose: ; on x exit app
  Suspend, Permit ; allow Exit to work Paused. I just added this yesterday 3.16.09 Can now quit when Paused.
 
  MsgBox, 4, Exit %version%, Exit %version% %ver%? ; 
  IfMsgBox No
      Return
  Else IfMsgBox Yes
      midiOutClose(h_midiout)
    
  Gui, 6: Destroy
  Gui, 2: Destroy
  Gui, 3: Destroy
  Gui, 4: Destroy
  Gui, 5: Destroy
  gui, 7: destroy
 ;gui, 
 Sleep 100
  ;winclose, Midi_in_2 ;close the midi in 2 ahk file
 ExitApp

;*************************************************
;*      MIDI INPUT / OUTPUT UNDER THE HOOD
;*************************************************

;############################################## MIDI LIB from orbik and lazslo#############
;-------- orbiks midi input code --------------
; Set up midi input and callback_window based on the ini file above.
; This code copied from ahk forum Orbik's post on midi input

; nothing below here to edit.

; =============== midi in =====================

Midiin_go:
DeviceID := MidiInDevice      ; midiindevice from IniRead above assigned to deviceid
CALLBACK_WINDOW := 0x10000    ; from orbiks code for midi input

Gui, +LastFound 	; set up the window for midi data to arrive.
hWnd := WinExist()	;MsgBox, 32, , line 176 - mcu-input  is := %MidiInDevice% , 3 ; this is just a test to show midi device selection

hMidiIn =
VarSetCapacity(hMidiIn, 4, 0)
  result := DllCall("winmm.dll\midiInOpen", UInt,&hMidiIn, UInt,DeviceID, UInt,hWnd, UInt,0, UInt,CALLBACK_WINDOW, "UInt")
    If result
      {
        MsgBox, Error, midiInOpen Returned %result%`n
        ;GoSub, sub_exit
      }

hMidiIn := NumGet(hMidiIn) ; because midiInOpen writes the value in 32 bit binary Number, AHK stores it as a string
  result := DllCall("winmm.dll\midiInStart", UInt,hMidiIn)
    If result
      {
        MsgBox, Error, midiInStart Returned %result%`nRight Click on the Tray Icon - Left click on MidiSet to select valid midi_in port.
        ;GoSub, sub_exit
      }

OpenCloseMidiAPI()
  
  ; ----- the OnMessage listeners ----

      ; #define MM_MIM_OPEN 0x3C1 /* MIDI input */
      ; #define MM_MIM_CLOSE 0x3C2
      ; #define MM_MIM_DATA 0x3C3
      ; #define MM_MIM_LONGDATA 0x3C4
      ; #define MM_MIM_ERROR 0x3C5
      ; #define MM_MIM_LONGERROR 0x3C6

    OnMessage(0x3C1, "MidiMsgDetect")  ; calling the function MidiMsgDetect in get_midi_in.ahk
    OnMessage(0x3C2, "MidiMsgDetect")  
    OnMessage(0x3C3, "MidiMsgDetect")
    OnMessage(0x3C4, "MidiMsgDetect")
    OnMessage(0x3C5, "MidiMsgDetect")
    OnMessage(0x3C6, "MidiMsgDetect")

Return

;*************************************************
;*          MIDI IN PORT HANDLING
;*************************************************

;--- MIDI INS LIST FUNCTIONS - port handling -----

MidiInsList(ByRef NumPorts)   ; should work for unicode now... untested
  { ; Returns a "|"-separated list of midi output devices
    local List, MidiInCaps, PortName, result, midisize
	(A_IsUnicode)? offsetWordStr := 64: offsetWordStr := 32
	midisize := offsetWordStr + 18
    VarSetCapacity(MidiInCaps, midisize, 0)
    VarSetCapacity(PortName, offsetWordStr)                       ; PortNameSize 32

    NumPorts := DllCall("winmm.dll\midiInGetNumDevs") ; #midi output devices on system, First device ID = 0

    Loop %NumPorts%
      {
        result := DllCall("winmm.dll\midiInGetDevCaps", "UInt",A_Index-1, "Ptr",&MidiInCaps, "UInt",midisize)
		
        If (result OR ErrorLevel) {
            List .= "|-Error-"
            Continue
          }
		PortName := StrGet(&MidiInCaps + 8, offsetWordStr)
        List .= "|" PortName
      }
    Return SubStr(List,2)
  }

/*  old code
{ ; Returns a "|"-separated list of midi output devices
    local List, MidiInCaps, PortName, result
    VarSetCapacity(MidiInCaps, 50, 0)
    VarSetCapacity(PortName, 32)                       ; PortNameSize 32

    NumPorts := DllCall("winmm.dll\midiInGetNumDevs") ; #midi output devices on system, First device ID = 0

    Loop %NumPorts%
      {
        result := DllCall("winmm.dll\midiInGetDevCapsA", UInt,A_Index-1, UInt,&MidiInCaps, UInt,50, UInt)
        If (result OR ErrorLevel) {
            List .= "|-Error-"
            Continue
          }
        DllCall("RtlMoveMemory", Str,PortName, UInt,&MidiInCaps+8, UInt,32) ; PortNameOffset 8, PortNameSize 32
        List .= "|" PortName
      }
    Return SubStr(List,2)
  }
*/
MidiInGetNumDevs() { ; Get number of midi output devices on system, first device has an ID of 0
    Return DllCall("winmm.dll\midiInGetNumDevs")
  }
MidiInNameGet(uDeviceID = 0) { ; Get name of a midiOut device for a given ID

    ;MIDIOUTCAPS struct
    ;    WORD      wMid;
    ;    WORD      wPid;
    ;    MMVERSION vDriverVersion;
    ;    CHAR      szPname[MAXPNAMELEN];
    ;    WORD      wTechnology;
    ;    WORD      wVoices;
    ;    WORD      wNotes;
    ;    WORD      wChannelMask;
    ;    DWORD     dwSupport;

    VarSetCapacity(MidiInCaps, 50, 0)  ; allows for szPname to be 32 bytes
    OffsettoPortName := 8, PortNameSize := 32
    result := DllCall("winmm.dll\midiInGetDevCapsA", UInt,uDeviceID, UInt,&MidiInCaps, UInt,50, UInt)

    If (result OR ErrorLevel) {
        MsgBox Error %result% (ErrorLevel = %ErrorLevel%) in retrieving the name of midi Input %uDeviceID%
        Return -1
      }

    VarSetCapacity(PortName, PortNameSize)
    DllCall("RtlMoveMemory", Str,PortName, Uint,&MidiInCaps+OffsettoPortName, Uint,PortNameSize)
    Return PortName
  }

MidiInsEnumerate() { ; Returns number of midi output devices, creates global array MidiOutPortName with their names
    local NumPorts, PortID
    MidiInPortName =
    NumPorts := MidiInGetNumDevs()

    Loop %NumPorts% {
        PortID := A_Index -1
        MidiInPortName%PortID% := MidiInNameGet(PortID)
      }
    Return NumPorts
  }

;*************************************************
;*    MIDI OUT LIBRARY FROM lASZLO/TOMB
;	Modified by JimF - removed long message
;	handling as well as combining status byte with ch 
; 	see commented out section below if you want to change it back
; unicode fix by Grass_HOPEr
;*************************************************
; =============== end of midi selection stuff


MidiOutsList(ByRef NumPorts)
  { ; Returns a "|"-separated list of midi output devices
    local List, MidiOutCaps, PortName, result, midisize
	(A_IsUnicode)? offsetWordStr := 64: offsetWordStr := 32
	midisize := offsetWordStr + 18
	VarSetCapacity(MidiOutCaps, midisize, 0)
    VarSetCapacity(PortName, offsetWordStr)                       ; PortNameSize 32

    NumPorts := DllCall("winmm.dll\midiOutGetNumDevs") ; #midi output devices on system, First device ID = 0

    Loop %NumPorts%
      {
        result := DllCall("winmm.dll\midiOutGetDevCaps", "Uint",A_Index - 1, "Ptr",&MidiOutCaps, "Uint",midisize)

        If (result) {
            List .= "|-Error-"
            Continue
          }
		PortName := StrGet(&MidiOutCaps + 8, offsetWordStr)
        List .= "|" PortName
      }
    Return SubStr(List,2)
  }


/*  old code - did not work with unicode
MidiOutsList(ByRef NumPorts)
  { ; Returns a "|"-separated list of midi output devices
    local List, MidiOutCaps, PortName, result
    VarSetCapacity(MidiOutCaps, 50, 0)
    VarSetCapacity(PortName, 32)                       ; PortNameSize 32

    NumPorts := DllCall("winmm.dll\midiOutGetNumDevs") ; #midi output devices on system, First device ID = 0

    Loop %NumPorts%
      {
        result := DllCall("winmm.dll\midiOutGetDevCapsA", UInt,A_Index-1, UInt,&MidiOutCaps, UInt,50, UInt)
        If (result OR ErrorLevel)
          {
            List .= "|-Error-"
            Continue
          }
        DllCall("RtlMoveMemory", Str,PortName, UInt,&MidiOutCaps+8, UInt,32) ; PortNameOffset 8, PortNameSize 32
        List .= "|" PortName
      }
    Return SubStr(List,2)
  }
  */
;---------------------midiOut from TomB and Lazslo and JimF --------------------------------

;THATS THE END OF MY STUFF (JimF) THE REST ID WHAT LASZLo AND PAXOPHONE WERE USING ALREADY
;AHK FUNCTIONS FOR MIDI OUTPUT - calling winmm.dll
;http://msdn.microsoft.com/library/default.asp?url=/library/en-us/multimed/htm/_win32_multimedia_functions.asp
;Derived from Midi.ahk dated 29 August 2008 - streaming support removed - (JimF)


OpenCloseMidiAPI() {  ; at the beginning to load, at the end to unload winmm.dll
    static hModule
    If hModule
        DllCall("FreeLibrary", UInt,hModule), hModule := ""
    If (0 = hModule := DllCall("LoadLibrary",Str,"winmm.dll")) {
        MsgBox Cannot load libray winmm.dll
        Exit
      }
  }

;FUNCTIONS FOR SENDING SHORT MESSAGES

midiOutOpen(uDeviceID = 0) { ; Open midi port for sending individual midi messages --> handle
    strh_midiout = 0000

    result := DllCall("winmm.dll\midiOutOpen", UInt,&strh_midiout, UInt,uDeviceID, UInt,0, UInt,0, UInt,0, UInt)
    If (result or ErrorLevel) {
        MsgBox There was an Error opening the midi port.`nError code %result%`nErrorLevel = %ErrorLevel%
        Return -1
      }
    Return UInt@(&strh_midiout)
  }

midiOutShortMsg(h_midiout, MidiStatus,  Param1, Param2) { ;Channel,
    ;h_midiout: handle to midi output device returned by midiOutOpen
    ;EventType, Channel combined -> MidiStatus byte: http://www.harmony-central.com/MIDI/Doc/table1.html
    ;Param3 should be 0 for PChange, ChanAT, or Wheel
    ;Wheel events: entire Wheel value in Param2 - the function splits it into two bytes
/*
    If (EventType = "NoteOn" OR EventType = "N1")
        MidiStatus := 143 + Channel
    Else If (EventType = "NoteOff" OR EventType = "N0")
        MidiStatus := 127 + Channel
    Else If (EventType = "CC")
        MidiStatus := 175 + Channel
    Else If (EventType = "PolyAT"  OR EventType = "PA")
        MidiStatus := 159 + Channel
    Else If (EventType = "ChanAT"  OR EventType = "AT")
        MidiStatus := 207 + Channel
    Else If (EventType = "PChange" OR EventType = "PC")
        MidiStatus := 191 + Channel
    Else If (EventType = "Wheel"   OR EventType = "W") {
        MidiStatus := 223 + Channel
        Param2 := Param1 >> 8      ; MSB of wheel value
        Param1 := Param1 & 0x00FF  ; strip MSB
      }
*/
    result := DllCall("winmm.dll\midiOutShortMsg", UInt,h_midiout, UInt, MidiStatus|(Param1<<8)|(Param2<<16), UInt)
    If (result or ErrorLevel)  {
        MsgBox There was an Error Sending the midi event: (%result%`, %ErrorLevel%)
        Return -1
      }
  }

midiOutClose(h_midiout) {  ; Close MidiOutput
    Loop 9 {
        result := DllCall("winmm.dll\midiOutClose", UInt,h_midiout)
        If !(result or ErrorLevel)
            Return
        Sleep 250
      }
    MsgBox Error in closing the midi output port. There may still be midi events being Processed.
    Return -1
  }

;UTILITY FUNCTIONS
MidiOutGetNumDevs() { ; Get number of midi output devices on system, first device has an ID of 0
    Return DllCall("winmm.dll\midiOutGetNumDevs")
  }

MidiOutNameGet(uDeviceID = 0) { ; Get name of a midiOut device for a given ID

    ;MIDIOUTCAPS struct
    ;    WORD      wMid;
    ;    WORD      wPid;
    ;    MMVERSION vDriverVersion;
    ;    CHAR      szPname[MAXPNAMELEN];
    ;    WORD      wTechnology;
    ;    WORD      wVoices;
    ;    WORD      wNotes;
    ;    WORD      wChannelMask;
    ;    DWORD     dwSupport;

    VarSetCapacity(MidiOutCaps, 50, 0)  ; allows for szPname to be 32 bytes
    OffsettoPortName := 8, PortNameSize := 32
    result := DllCall("winmm.dll\midiOutGetDevCapsA", UInt,uDeviceID, UInt,&MidiOutCaps, UInt,50, UInt)

    If (result OR ErrorLevel) {
        MsgBox Error %result% (ErrorLevel = %ErrorLevel%) in retrieving the name of midi output %uDeviceID%
        Return -1
      }

    VarSetCapacity(PortName, PortNameSize)
    DllCall("RtlMoveMemory", Str,PortName, Uint,&MidiOutCaps+OffsettoPortName, Uint,PortNameSize)
    Return PortName
  }

MidiOutsEnumerate() { ; Returns number of midi output devices, creates global array MidiOutPortName with their names
    local NumPorts, PortID
    MidiOutPortName =
    NumPorts := MidiOutGetNumDevs()

    Loop %NumPorts% {
        PortID := A_Index -1
        MidiOutPortName%PortID% := MidiOutNameGet(PortID)
      }
    Return NumPorts
  }

UInt@(ptr) {
Return *ptr | *(ptr+1) << 8 | *(ptr+2) << 16 | *(ptr+3) << 24
}

PokeInt(p_value, p_address) { ; Windows 2000 and later
    DllCall("ntdll\RtlFillMemoryUlong", UInt,p_address, UInt,4, UInt,p_value)
}
