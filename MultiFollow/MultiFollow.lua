--[[ 
  MultiFollow addon was created by: Bane & Killer from [V3X] Community (discord.gg/XEU75MR), name given by vB1OS
  This has been tested to work with WoW version 3.3.5a but may work with others
  Important Info:  This will function fully ONLY with 3 or more players in party or raid
  Type Commands in:  Party, Raid or Whisper
  Available Commands:  
-  mf (everyone will follow in raid or party)
-  mount (will force everyone to mount and follow that target, must be standing still or it will follow first - then must send 'mount' command again)
-  mfstop (forces everyone following their target by targeting another random player in raid or party.  Blizzard in WoTLK broke the follow self or other commands that were used to stop someone from following, thus - this work around)
]]

local MultiFollowFrame = CreateFrame("Frame")

SLASH_MULTIFOLLOW1 = "/mf"
SlashCmdList["MULTIFOLLOW"] = function()
  print("MultiFollow loaded. Type 'mf' to follow, 'mount' to mount and follow, 'mfstop' to break follow and dismount. Works with 3 or more people in party or raid.")
end

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

local function MountBestAvailable()
  local numMounts = GetNumCompanions("MOUNT")
  local isFlyable = IsFlyableArea()

  -- Try to find a flying mount first based on name assumption
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

  -- Fallback: use first unsummoned mount
  for i = 1, numMounts do
    local creatureID, name, spellID, icon, isSummoned = GetCompanionInfo("MOUNT", i)
    if not isSummoned then
      CallCompanion("MOUNT", i)
      return
    end
  end
end

local function handleChatMsg(msg, player)
  local msgUpper = string.upper(msg)
  local senderName = player
  local selfName = UnitName("player")

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

local function EventHandler(self, event, arg1, arg2)
  if event == 'CHAT_MSG_PARTY' or event == 'CHAT_MSG_PARTY_LEADER'
  or event == 'CHAT_MSG_RAID' or event == 'CHAT_MSG_RAID_LEADER'
  or event == 'CHAT_MSG_WHISPER' then
    handleChatMsg(arg1, arg2)
  end
end

local function LoginEvent(self, event)
  MultiFollowFrame:UnregisterEvent("PLAYER_LOGIN")
  MultiFollowFrame:SetScript("OnEvent", EventHandler)
  MultiFollowFrame:RegisterEvent("CHAT_MSG_PARTY")
  MultiFollowFrame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
  MultiFollowFrame:RegisterEvent("CHAT_MSG_RAID")
  MultiFollowFrame:RegisterEvent("CHAT_MSG_RAID_LEADER")
  MultiFollowFrame:RegisterEvent("CHAT_MSG_WHISPER")
end

MultiFollowFrame:SetScript("OnEvent", LoginEvent)
MultiFollowFrame:RegisterEvent("PLAYER_LOGIN")
