--[[ 
  ## Author: Bane from [V3X] Gaming discord.gg/XEU75MR | Credits: to Killer for assisting + name of addon: vB1OS (see "readme.txt" for more info)
]]

local MultiFollowFrame = CreateFrame("Frame")

-- Variables to track status
local isEnabled = true
local leaderOnly = false

-- Slash Commands Setup
SLASH_MULTIFOLLOW1 = "/mf"
SlashCmdList["MULTIFOLLOW"] = function(msg)
  local command = string.lower(msg or "")

  if command == "" then
    print("|cFFFFFF00Type in Party, Raid or Whisper Chat:|r")
    print("|cFFFFFFFFmf|r |cFFFFFF00(everyone with addon follows you)|r")
    print("|cFFFFFFFFmount|r |cFFFFFF00(everyone with addon will follow + mount) (type 2x)|r")
    print("|cFFFFFFFFmfstop|r |cFFFFFF00(everyone with addon stops following you)|r")
    print("|cFFFFFF00Type in-game /slash commands:|r")
    print("|cFFFFFFFF/mf|r |cFFFFFF00(prints this message and shows status)|r")
    print("|cFFFFFFFF/mf enable|r |cFFFFFF00(enables MultiFollow addon)|r")
    print("|cFFFFFFFF/mf disable|r |cFFFFFF00(disables MultiFollow addon)|r")
    print("|cFFFFFFFF/mf leader on|r |cFFFFFF00(only party or raid leader can command you)|r")
    print("|cFFFFFFFF/mf leader off|r |cFFFFFF00(anyone can command you)|r")
    print("|cFFFFFF00Current Status:|r")
    print("|cFFFFFF00Addon:|r |cFFFFFFFF" .. (isEnabled and "ENABLED" or "DISABLED") .. "|r")
    print("|cFFFFFF00Leader Only:|r |cFFFFFFFF" .. (leaderOnly and "ON" or "OFF") .. "|r")

  elseif command == "enable" then
    isEnabled = true
    print("|cFFFFFF00MultiFollow addon ENABLED.|r")

  elseif command == "disable" then
    isEnabled = false
    print("|cFFFFFF00MultiFollow addon DISABLED.|r")

  elseif command == "leader on" then
    leaderOnly = true
    print("|cFFFFFF00Leader-only mode ENABLED. Only raid/party leaders can command you.|r")

  elseif command == "leader off" then
    leaderOnly = false
    print("|cFFFFFF00Leader-only mode DISABLED. Anyone in party/raid/whisper can command you.|r")

  else
    print("|cFFFFFF00Unknown /mf command. Type /mf for help.|r")
  end
end

-- Helper: Get all group member names
local function GetGroupMemberNames()
  local groupMembers = {}
  local selfName = UnitName("player")

  if GetNumRaidMembers() > 0 then
    for i = 1, GetNumRaidMembers() do
      local unit = "raid" .. i
      local name = UnitName(unit)
      if name and name ~= "" then
        table.insert(groupMembers, name)
      end
    end
  else
    for i = 1, GetNumPartyMembers() do
      local unit = "party" .. i
      local name = UnitName(unit)
      if name and name ~= "" then
        table.insert(groupMembers, name)
      end
    end
    table.insert(groupMembers, selfName)
  end

  return groupMembers
end

-- Helper: Mount best available mount
local function MountBestAvailable()
  local numMounts = GetNumCompanions("MOUNT")
  local isFlyable = IsFlyableArea()

  for i = 1, numMounts do
    local creatureID, name, spellID, icon, isSummoned = GetCompanionInfo("MOUNT", i)
    if not isSummoned and isFlyable and (
      name:lower():find("gryphon") or name:lower():find("wind") or
      name:lower():find("nether") or name:lower():find("drake") or
      name:lower():find("ray") or name:lower():find("proto")) then
      CallCompanion("MOUNT", i)
      return
    end
  end

  for i = 1, numMounts do
    local creatureID, name, spellID, icon, isSummoned = GetCompanionInfo("MOUNT", i)
    if not isSummoned then
      CallCompanion("MOUNT", i)
      return
    end
  end
end

-- Helper: Check if sender is leader
local function IsSenderLeader(senderName)
  -- Check Party
  if GetNumPartyMembers() > 0 and GetNumRaidMembers() == 0 then
    for i = 1, GetNumPartyMembers() do
      local unit = "party" .. i
      if UnitName(unit) == senderName and UnitIsPartyLeader(unit) then
        return true
      end
    end
    if senderName == UnitName("player") and IsPartyLeader() then
      return true
    end
  end

  -- Check Raid
  if GetNumRaidMembers() > 0 then
    for i = 1, GetNumRaidMembers() do
      local unit = "raid" .. i
      if UnitName(unit) == senderName and UnitIsPartyLeader(unit) then
        return true
      end
    end
  end

  return false
end

-- Main chat message handler
local function handleChatMsg(msg, player)
  if not isEnabled then return end

  local msgUpper = string.upper(msg)
  local senderName = player
  local selfName = UnitName("player")

  -- Leader-only enforcement
  if leaderOnly then
    if not IsSenderLeader(senderName) then
      return
    end
  end

  if msgUpper == 'MF' and senderName ~= selfName then
    FollowUnit(senderName)

  elseif msgUpper == 'MFSTOP' and senderName ~= selfName then
    if IsMounted() then
      Dismount()
    end
    local groupMembers = GetGroupMemberNames()
    for _, name in ipairs(groupMembers) do
      if name ~= selfName and name ~= senderName then
        FollowUnit(name)
        break
      end
    end

  elseif msgUpper == 'MOUNT' then
    MountBestAvailable()
    if senderName ~= selfName then
      FollowUnit(senderName)
    end
  end
end

-- Event Handler
local function EventHandler(self, event, arg1, arg2)
  if event == 'CHAT_MSG_PARTY' or event == 'CHAT_MSG_PARTY_LEADER'
  or event == 'CHAT_MSG_RAID' or event == 'CHAT_MSG_RAID_LEADER'
  or event == 'CHAT_MSG_WHISPER' then
    handleChatMsg(arg1, arg2)
  end
end

-- Login Setup
local function LoginEvent(self, event)
  MultiFollowFrame:UnregisterEvent("PLAYER_LOGIN")
  MultiFollowFrame:SetScript("OnEvent", EventHandler)
  MultiFollowFrame:RegisterEvent("CHAT_MSG_PARTY")
  MultiFollowFrame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
  MultiFollowFrame:RegisterEvent("CHAT_MSG_RAID")
  MultiFollowFrame:RegisterEvent("CHAT_MSG_RAID_LEADER")
  MultiFollowFrame:RegisterEvent("CHAT_MSG_WHISPER")

  -- Pretty colored load message split across 2 lines
  print("|cFFFFFF00 ++++++++++++++++++|r |cFF3399FFMultiFollow:|r |cFFFFFF00++ Loaded ++|r |cFF3399FF/mf|r")
  print("|cFFFFFF00 ++++++++++++++++++|r |cFF3399FFDiscord.gg/|r|cFFFFFFFFXEU75MR|r |cFFFFFF00(Cap Sensitive)|r")
end

MultiFollowFrame:SetScript("OnEvent", LoginEvent)
MultiFollowFrame:RegisterEvent("PLAYER_LOGIN")
