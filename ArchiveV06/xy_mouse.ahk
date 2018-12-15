; Last edited 11/18/2010 1:34 AM by genmce
/*
Most of this is with help from Learningone and JimVF as well as temp01 finding a code reference on ahk site. http://www.autohotkey.com/forum/topic7450.html by Serenity to detect mouse movement.

It uses JimVF's edit of the general midi functions (Lazslo and TomB).

capsLock is currently used for triggering

* this currently works toggling the capslock key.

* Fixed recenter issues.
* y axis will recenter on release of hotkey
* x axis will be remember for next time.

Consider a larger movement lane or a different hotkey for modwheel so they don't happen at the same time.

GPL

*/

; set a toggle to turn mouse on or off on preferences.

go_xymouse:

;This gui is only for reference and testing, I don't think it will be needed, but perhaps it will....
CustomColor = C0C0C0 ;00FFFF ;EEAA99  ; Can be any RGB Color (it will be made Transparent below).
Gui,3: +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar Button and an alt-tab Menu item.
Gui,3: Color, %CustomColor%
Gui,3: Font, s15 ; Set a large font size (32-point).
Gui,3: Add, Text, w300 gXYMouse vMyText cblue,  ; XX & YY serve to auto-size the window.
WinSet, TransColor, %CustomColor% 150

CoordMode, Mouse, Screen
CenterX := A_ScreenWidth/2, CenterY := A_ScreenHeight/2 ; find the Center of the Screen
XmidiCalc := Centerx/64                         ; set the value of Mouse movement to midi cc Range
YmidiCalc := CenterY/8192                        ; set to midi pitch bend Range
SetFormat, Float, 0


channel := 1   ; midi channel to Send on
CCmod := 33   ; Fine Mod Wheel, ccmod = 33 ; probably leave it as fine mod wheel.... not sure about this.
pb := 8192   ; set pb to center
moveit = ""   ; moveit to prevent repeating the mousemove to center multiple times.
modwheelPos := 0
;consider a var for speed of pitchbend or shorten the range to not get all the way out... not sure, have not tried it yet.

;*************************************************
;* 			run timer to convert mouse to xy midi
;*************************************************

SetTimer, XYMouse, 75            ; Run the timer below to
count =   1
Return

;capslock ?

;*************************************************
;* 			mouse wheel routine
;*	     midi output not created yet 
;*************************************************

$Wheeldown:: ; when wheel is moved down.
	If GetKeyState("Capslock", "T") ; test state of capslock of on
		{
			gosub, countdown
		}
	else ; off just send the wheel down on.
		{
			SendInput, {WheelDown}
		}
	return

$wheelup:: ; when wheel is moved up
	If GetKeyState("Capslock", "T")
		{
			gosub, countup
		}
	else
		{
			SendInput, {Wheelup}
		}
return

countup: ; chanage this to do midi work next.
	count := ++Count
	MsgBox, 0, , %count%, .35 ; just a message box to show what is happening

Return
	
countdown:
	count := --count
	MsgBox, 0, , %count%, .35
Return


;*************************************************
;* 	xy mouse by movement  pitchbend and mod wheel
;*************************************************

XYmouse: ; run the xy mouse sub

; =============== trigger the xymouse ======================
/* 
	CONSIDER RIGHT MOUSE BUTTON as the trigger.
	
*/

If GetKeyState("Capslock", "T")
	{
		xyRun := 1 ; set var = 1 to show active and will Send midi      ;Activate - hold key down like esc - this will need to change, I was thinking perhaps on f12, make a Toggle of the var. the display might help user know that they are active...
	   PBCenter := 1 ; not sure where I was going with that
	   IfEqual, moveit, ""
		  loop, 1
			 {
				MouseMove,  ModWheelPos, CenterY, 0
				reset := 1
				moveit := 1  ; mouse move is done.
			 }   
	   IfEqual, moveit, 1
		  {
			 ; do nothing, MouseMove already completed   
		  }
	;Return


		IfEqual, xyRun, 1 ; hotkey is held down so do the stuff below
		  {
			 MouseGetPos, sx, sy                   ; Get starting mouse postion    
			 Gui,3: Show, xCenter y5  AutoSize NoActivate  ; NoActivate avoids deactivating the currently active window. ;ONLY SHOW GUI WHILE capslock HELD DOWN.
			 Sleep, 100 ; not sure this is needed?  Some kind of interval needed between MouseGetPos, hate to use a sleep
			 MouseGetPos, cx, cy
			 If (cx != sx or cy != sy)
				{
				   ; mouse has moved by more than 10 px - might need higher amount
				   If (cx > (sx+10) or cx < (sx-10)) ; mouse moved more than 10 px on x axis
					  {
						 XMidival := cx/XmidiCalc
						 midiOutShortMsg(h_midiout, Channel + 175, CCmod, xmidival)
					  }
				   If (cy > (sy+10) or cy < (sy-10)) ; Mouse moved more than 10 px on y axis
					  {
						 PB := (CenterY - cy)/YmidiCalc + 8192
						 midiOutShortMsg(h_midiout, (channel+ 223), (PB&0x7F), (PB>>7))
					  }
				}
			 GuiControl,3:, MyText, ModWheel %XmidiVal%, PitchBend %pb% ; only to update the Gui
		  }

	}

else ;capslock up:: ;

   ;IfEqual, xyRun, 0
   
    {
       if reset  ; if reset is valid
			{ ; ======== stop the xy mouse ====================

			   moveit = ""             ; set mouse move var back to blank
			   xyRun := 0               ; set xy run to 0 so the timmer won't do anything
			   MouseGetPos, ModWheelPos ,    ; get last mouse x axis postion - remember x axis position
			   pb := 8192               ; set pb to center (no Bend)
			   midiOutShortMsg(h_midiout, (channel+ 223), (PB&0x7F), (PB>>7))   ; send midi pitch bend to center out midi port
			   Gui,3: hide
				reset = 	
			 GuiControl,3:, MyText, ModWheel %XmidiVal%, PitchBend %pb% ; only to update the Gui
			Return
			}
		else ; if it is not do nothing
			{
			}
	}


Return


; =============== end ====================================