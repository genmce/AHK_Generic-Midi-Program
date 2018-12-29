# AHK_Generic-Midi-Program
Progress happening - 
I think I have all working
Renamed midi lib to mio2.ahk



December 15, 2018
I have come back to work on this project again - I would love help on it.
License for this version changed - see license

I am fixing here  stay tuned  v.0.7 is not ready yet.

Goals - 
   - Create new version 0.7 (work in progress)
   - mouse and joystick have been removed for the moment
   - Clean up the code and comment better
   - Rename Midi Under the hood.ahk to  Midi_In_Out_Library.ahk
   - Document how to make hotkeys to midi with clear examples
   - Document how to make midi to keypress with clear examples
   - Develop a gui to create the hotkey to midi and midi to hotkey
   
   Questions - Does it need a midi monitor.....   



---------------------------old readme ----------------------------------------------------------------

Autohotkey midi manipulation, keystroke to midi + midi to keystroke, Mouse to Midi and joystick to midi.

Windows only, requires autohotkey (written for Ansi 32bit ahk version) to run or compile https://autohotkey.com/

Generic Midi Program (originally from 2010)  
  Basic structural framework for a midi program in ahk.
  The description of what this is for is contained in the first post on the topic Midi Input/Output Combined at the ahk forum.
  Please read it, if you want to know more.
  I have added a few more examples for different midi data types as well as more, meaningful (I hope), documentation to the script.
  You are strongly encouraged to visit http://www.midi.org/techspecs/midimessages.php (decimal values), to learn more 
  about midi data.  It will help you create your own midi rules.
  
  I have combined much of the work of others here.
  It is a working script, most of the heavy lifing has been done for you.
  You will need to create your own midi rules. 
  By creating or modifying if statements, in the section of the MidiRules.ahk file.
  By creating hotkeys that generate midi messages in the hotkeyTOmidi.ahk file.
  
  I don't claim to be an expert on this, just a guy who pulled disparate things together.
  
Version history 
  
   
 v. 0.6
    + Joystick to midi 
    + Mouse to midi
 
 v. 0.5
    + changing this to multiple files for better readability, hopefully, I did not make it more confusing??
    + will leave version 4 (sorry it's long gone) up on the site and add these versions with a download location for version 5
    + New midi monitor, little smaller, little cleaner, I hope.
	  + Does NOT detect when midi input = midi output so display will get stuck in midi loop - just change your midi ports.
    + Auto detect ini file, if it does not exist, one will be generated. 
    + ini file name is generated from script name, so if you change you script name, it will generate a new ini file. Don't worry, it will do that every time to change the main program file name.
  
    
 v. 0.4 (lost code...)
    + added an example of hotkey generating midi (volume controller)
    + added a second example for you create your own hotkey generated midi message.
    
    
  v. 0.3 changes (lost code...)
  + Adding text for how to add new rules.
  + Midi Rules, name used instead of filters, seems more appropriate.
  + Moved all rules outside the detector function, hoping to make it easier to understand and use.
  + abandoned the idea of dynamic code and a gui to create rules, omg, someone else do that, please!
  + Adding more examples for rules.
  + more to come, maybe...
  + removed that notemsg var - did not need it, not sure why i used it... nevermind
