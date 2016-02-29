# ExileTools Ladder Track UI Overlay

Ladder Track is a simple web page that shows a character's current Rank on the Official Ladder, updated every 8-10min. This macro will display this information in-game, automatically refreshing to keep you up to date.

*Note:* This will only work for Leagues, and does not work for Events/Races!

![Example](http://exiletools.com/img/example-ladder-track.jpg)
![Example](http://exiletools.com/img/example-ladder-track2.jpg)

*What it Does:* Grinding Gear Games makes some basic information about the top 15,000 players in every league available via a slightly clumsy API - it requires you to download the status of every player on the list to find a specific player. ExileTools provides a [Ladder API](http://api.exiletools.com/ladder) that automatically populates this data for access by third party tools. The Ladder Track web page uses this data, refreshed approximately every ten minutes, to show some statistics for characters on the ladder.

The simple Ladder Track page can be accessed at the following URL:

`http://api.exiletools.com/ladder/track?league=LeagueName&char=CharName`

*The Ladder Track Macro* is an AHK macro which will display this page in a very small customizable transparent and translucent window over your game client. For people really excited about tracking their progress, this is the way to do it! The macro automatically checks for updates from ExileTools and reloads the web page. It also has options to hide until there is an update and blinks when new data comes in.

# How to Install:

1. Download AutoHotKey 1.1.15+ from ahkscript.org (not autohotkey.com - that's different!).
2. Save the [Ladder Track Macro](https://raw.githubusercontent.com/trackpete/exiletools-ladder-track/master/poe_ladder_track.ahk) anywhere on your computer.
3. Open the `poe_ladder_track.ahk` file in an editor such as Wordpad (Notepad may have problems with the carriage returns)
4. Optional: Read through all the information in the script to learn about it and why it's wonky
5. Search for the `LeagueName` setting and change it to reflect the league your character is in (see below)
6. Search for the `CharName` setting and change it to reflect the league your character is in
7. Change the coordinates for the window so it appears where you want. More information on this is below.
8. Optional: Change other global variables if desired, such as alwaysShow, etc.
9. Save the file, then double click it to load it. Hit `CTRL+SHIFT+L` to show/hide the UI at any time.

*Please note:* You must play Path of Exile in Windowed Fullscreen or Windowed mode for the UI to show up!

**Check the [ExileTools Ladder API documentation](http://api.exiletools.com/ladder) for a list of Active Leagues!**

## Options Within the Macro:

* `Global winPosX := #####` Where to draw the popup horizontally. 1 is the left side of the screen, 1920 is the far right side on a 1080p screen. Some suggestions are in the script.
* `Global winPosY := ####` Where to draw the popup vertically. 1 is the top, 1080 would be the bottom on a 1080p screen, etc.
* `Global alwaysShow := [ 0 / 1 ]` If set to 0, the popup only shows for ~15s after a server update. If set to 1 it always shows.
* `Global blinkTimes := ##` If alwaysShow is enabled, the popup will blink this many times when a server update is loaded.
* `Global showFor := #####` The number of milliseconds to show the popup for if alwaysShow is set to 0. Defaults to 15s.
* `Global showOnStart := [ 0 / 1 ]` If set to 1, the UI will be spawned on macro start, if 0 you will need to ctrl-shift-L to start it.

# Using the Macro:

* `CTRL-SHIFT-L` : Create / Destroy the UI overlay. This will also reset update counts. The overlay should always be on top but sometimes something makes go behind POE (some alt tab combinations). If this happens, just hit CTRL-SHIFT-L to destroy/create it again.

# Known Issues

* The update time shown in the UI is based on your browser's timezone, in theory.
* The transparency might not always work depending on settings. Works for me though!
* The IE activex control makes that reload click sound when it reloads. You can disable this in your registry, google "disable IE refresh sound" for information!
* The update time shown in the UI is the time the server started a ladder update cycle. Sometimes this can be 2-3min earlier than the new data is rendered for your character.
