## Interface: 30300
## Title: MultiFollow
## Version: 1.2
## Author: Bane from [V3X] Gaming discord.gg/XEU75MR | Credits to: Killer for assisting /w some code + name of addon: vB1OS
## Notes: Party, Raid group will follow, mount, stop follow with mf, mount, mfstop in chat. Type: /mf (for options)
# Features
#  - Automatically follow designated players through Party, Raid, or Whisper commands.
#  - Force mount + follow behaviors for multiboxing, boosting, friends afk or group travel.
#  - Quickly break follow or dismount across all players simultaneously.
#  - Slash commands allow enabling/disabling, leader-only control, /w flexible toggle on/off controls.
#  - This has been tested to work with WoW version 3.3.5a but may work with others
#  - Important Info: This will function fully ONLY with 3 or more players in party or raid
#  - Type Commands in: Party, Raid or Whisper
# Available Commands: (in party, raid or whisper chat)
#  - mf (everyone will follow in raid or party)
#  - mount (everyone will mount and follow the sender, must be standing still first or mount second time)
#  - mfstop (forces everyone to stop following by redirecting to another player)
# Available /slash commands in-game:
#  - /mf (prints this message and shows addon status)
#  - /mf enable (enables MultiFollow addon) {enabled by default}
#  - /mf disable (disables MultiFollow addon)
#  - /mf leader on (only party/raid leader can command you)
#  - /mf leader off (anyone can command you)
#  
#    NOTES + Install
# ---------------------
#   - Make sure file contents (MultiFollow.lua, MultiFollow.toc, Readme.txt) are in only one folder called: "MultiFollow"
#   - Drag + Drop folder into your WoW\Interface\Addons Folder
#
#    CHANGE LOG
# --------------------
# VERSION: 1.2 
#  - Added new /slash commands
#  - Added Highlighted text when game starts 
#  - Added on / off toggle for "leader only" listen for command
#  - Added on / off toggle to enable and disable addon in-game
#  - Added some organizational re-arrangement of text information
#  - Added updated information on Login chat ++Load++ messages
