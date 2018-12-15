
go_joystuff:

gosub,joydisplay

;*************************************************
;*         add this to autoexec section of main generic midi program this section all about joystick
;*************************************************
;gosub,joydisplay ; only if you want the joydisplay to show.
SetTimer, stick, 75  ; run the loop every 50 ms - much smoother than 100
joyX_last := -1 ; initialize
joyY_last := -1
joyZ_last := -1
joyR_last := -1
  IniRead, joyXnum, %version%io.ini, joystick, xaxis , %xaxis%     ; read the midi In port from ini file
  IniRead, joyYnum, %version%io.ini, joystick, yaxis , %yaxis%  ; read the midi out port from ini file
  IniRead, joyZnum, %version%io.ini, joystick, zaxis , %zaxis%     ; read the midi In port from ini file
  IniRead, joyRnum, %version%io.ini, joystick, raxis , %raxis%  ; read the midi out port from ini file
  guicontrol,2:,joyXnum, %JoyXnum%
;joyXnum := 7 ; midi output CC number for this axis
;JoyYnum := 1
;joyZnum := 10
;joyRnum := 11
;*************************************************
;*          end section to add to autoexec
;*************************************************
;*************************************************
;*          add #include joystuff.ahk to generic midi program file
;*************************************************
;*************************************************
;*          save below as joystuff.ahk put it in the same folder as generic midi
;*************************************************
return
joydisplay: ; for testging only.
  Gui,2: +LastFound +AlwaysOnTop +Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
  Gui,2: Color, %CustomColor%
  Gui,2: Font, s9 ; Set a large font size (32-point).
  Gui,2: Add, Text, vMyText w300, ; XX & YY serve to auto-size the window.
  gui,2:add,edit, vjoyXnum
  Gui,2: Show, AutoSize xcenter ycenter NoActivate  ; NoActivate avoids deactivating the currently active window.
  
return

stick: ; label for running joystick detection
  {
    GetKeyState, JoyX, JoyX  ; Get position of X axis.
    GetKeyState, JoyY, JoyY  ; Get position of Y axis.
    getkeystate, joyz, joyz  ; lever 3rd axis on my joystick - ms force feedback2 (picked it up at a yardsale for $1.
    getkeystate, joyr, joyr  ; twist stick rotation axis on my stick

    joyXval := round(joyx*1.27)             ; assumes Joyx 0-100 conversion to 0 -127
    joyYval := round((joyy/(-100)+1)*127)   ; inverted output joyY 100 - 0 conversion to 127 - 0 (thanks skylord5816 ahk chat)
    joyZval := round((joyZ/(-100)+1)*127)   ;  
    joyrval := round(joyr*1.27)             ;joy rotation

    GuiControl,2:, MyText, X%joyX% = ccX%joyXval% | Y%joyY% = ccY%joyYval% | R%joyR% = ccR%joyRval% | Z%joyz% = ccZ%joyzval% ; updates the joydisplay, active.

    If (joyXVal != joyx_last) ; if it has moved then send another message.
     {
       stb = CC
       statusbyte = 176 ; chan 1 + 175
       byte1 = %joyXnum%
       byte2 = %joyXval%
       midiOutShortMsg(h_midiout, statusbyte, byte1, byte2) ; commented out just to run stand alone - showing the settimer is working.
       gosub, ShowMidiOutMessage
       joyx_last := joyXval
      ;MsgBox joylast
      
     }
    if (joyYval != joyY_last)
     {
       stb = CC 
       statusbyte = 176 ; chan 1 + 175
       byte1 = %joyYnum%
       byte2 = %joyYval%
       midiOutShortMsg(h_midiout, statusbyte, byte1, byte2) 
       gosub, ShowMidiOutMessage
       joyY_last := joyYval
     
    }
    If (joyRVal != joyR_last)
     {
       stb = CC
       statusbyte = 176 ; chan 1 + 175
       byte1 = %joyRnum%
       byte2 = %joyRval%
       midiOutShortMsg(h_midiout, statusbyte, byte1, byte2) ; commented out just to run stand alone - showing the settimer is working.
       gosub, ShowMidiOutMessage
       joyR_last := joyRval
      ;MsgBox joylast
      
     }
    if (joyzval != joyZ_last)
     {
       stb = CC 
       statusbyte = 176 ; chan 1 + 175
       byte1 = %joyZnum%
       byte2 = %joyZval%
       midiOutShortMsg(h_midiout, statusbyte, byte1, byte2) ; commented out just to run stand alone - showing the settimer is working.
       gosub, ShowMidiOutMessage
       joyZ_last := joyZval
     
     }
    Else
     Return ; if none of them have moved, nothing to do.
  }
return
