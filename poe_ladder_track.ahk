; Path of Exile Ladder Track
; Version 1 (2015/03/19)
;
; Written by Pete Waterman aka trackpete on reddit, pwx* in game
; email: pete@pwx.me  | personal website: whoispete.com
;
; The latest version of this can always be found here:
;
;   http://poe.pwx.me
;
; Author's Note: I'm not an AHK programmer, I learned everything on the fly. There is a
; good chance this code will look sloppy to experienced AHK programmers, if you have any
; advice or would like to re-write it, please feel free and let me know. 
;
; USAGE NOTE: This requires your Path of Exile to be in Windowed (or Windowed Full Screen) 
; to work properly, otherwise the popup will just show in the background and you won't
; see it.
;
; CONFIGURATION NOTE: You must configure the variables below! Look for the Variables
;   section and change them appropriately - especially LeagueName and CharName!
;
; ===================================================
; General Information on Data Returned:
;
; Grinding Gear Games makes ladder information for the top 15,000 players available via a
; horribly clumsy API here: http://www.pathofexile.com/developer/docs/api-resource-ladders
;
; It's ridiculous because you have to make a ton of requests and can't pull information on 
; a specific character. To help players with this, I download the main league ladders
; every 6-8 minutes on my server and make specific information available via a better API
; here: http://poe.pwx.me/api/ladder
;
; This macro simply loads a web page from my server that uses my API to show a simple
; summary of ladder information for the chosen character.
;
; NOTE: It reloads the page on my server every 60s, but my server only updates from GGG every
; 6-8 minutes. Thus, you will only see the data change every 6-8min in the UI. Anything closer
; to realtime is impossible with GGG's current API.
;
; WEIRD THINGS SOMETIMES HAPPEN IN HARDCORE IF YOU DIE AND MAKE A NEW CHARACTER WITH THE
; SAME NAME!! I do my best but GGG doesn't make this easy. If at all possible I try to only
; display information for characters that are ALIVE.
;
; FINAL NOTE: It makes the IE refresh sound whenever it refreshes. This is annoying, I realize.
; I can apparently turn it off by doing some registry stuff but didn't mess with it.
;
; == Startup Options ===========================================
#SingleInstance force
#NoEnv 
#Persistent ; Stay open in background
SendMode Input 
Menu, tray, Tip, Ladder Track POE.PWX.ME

; Hopefully exit if an old version is used. Note: use the ahkscript.org one!
If (A_AhkVersion <= "1.1.15") {
    msgbox, You need AutoHotkey v1.1.15 or later to run this script. `n`nPlease go to http://ahkscript.org/download and download a recent version.
    exit
}

; == Variables and Options and Stuff ===========================
; **************************************************************
; PLEASE MAKE SURE TO SET THESE!

LeagueName := "standard"       ; Change the value in quotes to the proper league, see http://api.exiletools.com/ladder for names
CharName := "pwxrf"           ; Change the value in quotes to your character's name
                              ; Hardcore players: It will only show ALIVE character data
							  ;
							  ; You can test this in your browser by going to:
							  ; http://poe.pwx.me/api/ladder/track?league=torment&char=pwxci
							  ; Change the league and char to what you are going to use
Global alwaysShow := 1        ; Always show the UI or not. 1 will always show it. Set it to 0 and it
                              ; will only show for 30s after an update.
Global showFor := 15000       ; Number of milliseconds to show the UI for if alwaysShow is 0, 15s by default
Global showOnStart := 1       ; Whether to show the overlay on macro start or not. 1 = show it, 0 = don't show it.
							  
Global winHeight := 150       ; Default window height. You shouldn't need to change this.
Global winWidth  := 300       ; Default window width. You shouldn't need to change this.
Global winPosX   := 1400      ; The X position of the window. CHANGE THIS. It determines where the window will be drawn.
                              ; On a 1080p display you might need to set it to 1400 or so, on a 4k display more like 3200, 
							  ; QHD seems like about 1600 is good.
Global winPosY   := 1         ; The Y position of the window. It defaults to the top of the screen but you can move it
                              ; wherever you want.

Global blinkTimes := 3        ; The number of times to blink the UI when a server side update is detected


; DO NOT CHANGE THESE! THANKS! :D		
Global winStatus := 0         ; This is for the toggle. Don't change this.
Global lastTitle              ; This needs to be global because I'm lazy.
Global updateCount := 0       ; This tells us how many times we got a server update.

delay := 30000     ; Refresh from my server every 30s. PLEASE don't hammer my server. The back-end
                   ; only updates every ~8min to avoid hammering GGG, setting this faster does NOTHING.
				   ; There is also a 5min sleep built in after a successful server side update.

; This is the URL to display. No point in messing with this, it will break things.				   
Global URL = "http://api.exiletools.com/ladder/track?updateCount=" . updateCount . "&league=" . LeagueName . "&char=" . CharName . ""
Global WB ; Just making sure this control is global

if (showOnStart > 0) {
  FunctionGuiControl()
}

; == The Hotkey ==============================================
; This defaults to CTRL+SHIFT+L to toggle showing/hiding the UI.  
^+l::
{
FunctionGuiControl()
return
}

; == The Ghetto Code==========================================
; Please don't mess with this stuff. :o

; Set up an activex event class to update the URL in the UI
class WB_events
{
    NavigateComplete2(wb, NewURL)
    {
        GuiControl,, URL, %URL%  ; Update the URL edit control.
    }
}  

; Function to show/hide the UI
FunctionGuiControl() {
  ; If it's disabled, then change status to enabled and enable it, otherwise vice-versa
  if (winStatus == 0) {
    winStatus := 1  
    Gui +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, Color, FFFFFF
    Gui, Margin, 0, 0
    Gui Add, ActiveX, w%winWidth% h%winHeight% x0 y0 vWB, %URL%  
    WinSet, TransColor, FFFFFF 140 ; If you want the UI to be more or less transparent you can change 140 to something else
    ComObjConnect(WB, WB_events)  ; Connect WB's events to the WB_events class object.
    Gui Show, x%winPosX% y%winPosY% NoActivate, LadderTrack
    WinSet AlwaysOnTop, On
    Gui, -Caption
    Gui, -Border
    Gosub, UpdateRank ; okay yeah, subroutines are ghetto, but hey it's AHK
  } else {
    winStatus := 0
	Gui, Destroy
	updateCount := 0
  }
}

; This sub loads the URL then sets a timer for the delay, 60s, please don't change it
UpdateRank:
  if (winStatus == 1) {
    WB.Navigate(URL)
	while wb.Busy
    Sleep, 100 ; Give it time to load the web page
	if (wb.Document.title <> lastTitle) {    ; if the timestamp in the title changed, blink that to let us know
	  WinShow LadderTrack
	  updateCount := updateCount + 1
      if (updateCount > 1) && (alwaysShow >0) {     ; Blink the GUI if AlwaysShow is on and this is our 2nd+ update
	    Loop %blinkTimes% {
  	      WinHide LadderTrack
          sleep, 75
          WinShow LadderTrack
        }
	  }
      sleep, %showFor% ; Show the UI for the specified time
      if (alwaysShow < 1) {
        WinHide LadderTrack
      }
	  if (updateCount > 1) { 
        sleep, 300000 ; Sleep for 5min so we're not spamming the server until it's closer to update time after the
		              ; first successful update
      }		
	}
    lastTitle := wb.Document.title
    SetTimer, UpdateRank , %delay%
  }
  return
  
