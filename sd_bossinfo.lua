local SD_BOSSINFO_LOADED = false

local SD_BOSSINFO_ENABLED = false

local SD_BOSSINFO_NPCMAP = nil

function SD_BOSSINFO_ON_INIT(addon, frame)
  addon:RegisterOpenOnlyMsg('FPS_UPDATE', 'SD_BOSSINFO_PING');
  
  SD_BOSSINFO_NPCMAP = {}
  
  if SD_BOSSINFO_ENABLED then
    ui.OpenFrame('sd_bossinfo');
  end
  
  if SD_BOSSINFO_LOADED then
    return
  end
  
  _G['SD_BOSSINFO_ON_CHAT_OLD'] = ui.Chat
  
  ui.Chat = SD_BOSSINFO_ON_CHAT
  
  ui.SysMsg('-> sd_bossinfo');
  
  SD_BOSSINFO_LOADED = true
end

function SD_BOSSINFO_ON_CHAT(args)
  SD_BOSSINFO_ON_CHAT_OLD(args)
  
  args = args:gsub('^/[rwpysg] ', '')
  
  if string.sub(args, 1, 9) == '/bossinfo' then
    args = args:gsub('/bossinfo', '');
    
    if args == ' on' then
      SD_BOSSINFO_ENABLE();
    elseif args == ' off' then
      SD_BOSSINFO_DISABLE();
    else
      SD_BOSSINFO_STATUS();
    end
  end
  
  local f = GET_CHATFRAME();
  f:GetChild('mainchat'):ShowWindow(0);
  f:ShowWindow(0);
end

function SD_BOSSINFO_ENABLE()
  ui.OpenFrame('sd_bossinfo');
  SD_BOSSINFO_ENABLED = true;
  CHAT_SYSTEM('sd_bossinfo is {#00A550}{ol}enabled{/}{/}');
end

function SD_BOSSINFO_DISABLE()
  ui.CloseFrame('sd_bossinfo');
  SD_BOSSINFO_ENABLED = false;
  CHAT_SYSTEM('sd_bossinfo is {#C41E3A}{ol}disabled{/}{/}');
end

function SD_BOSSINFO_STATUS()
  if SD_BOSSINFO_ENABLED then
    CHAT_SYSTEM('sd_bossinfo is currently {#00A550}{ol}enabled{/}{/}');
  else
    CHAT_SYSTEM('sd_bossinfo is currently {#C41E3A}{ol}disabled{/}{/}');
  end
  
  CHAT_SYSTEM('Usage: /bossinfo on|off');
end

function SD_BOSSINFO_PONG(npc)
  if SD_BOSSINFO_NPCMAP[npc.ClassID] then
    return
  end
  
  SD_BOSSINFO_NPCMAP[npc.ClassID] = true;
  
  local objHandle = GetHandle(npc);
  local actor = world.GetActor(objHandle);
  local pos = actor:GetPos();
  local mapClsID = session.GetCurrentMapProp().type;
  local mapCls = GetClassByType('Map', mapClsID)
  local fmt = '%s {a SLM %d#%d#%d}{#0000FF}{img link_map 24 24}%s{/}{/}{/}';
  local str = string.format(fmt, npc.Name, mapClsID, pos.x, pos.z, mapCls.Name);
  
  local in_party = session.party.GetPartyInfo(PARTY_NORMAL) ~= nil;
  local in_guild = session.party.GetPartyInfo(PARTY_GUILD) ~= nil;
  
  if in_party then
    ui.Chat('/p ' .. str);
  end
  
  if in_guild then
    ui.Chat('/g ' .. str);
  end
  
  if not in_party and not in_guild then
    CHAT_SYSTEM(str);
  end
  
  imcSound.PlaySoundEvent('sys_quest_message');
end

function SD_BOSSINFO_PING()
  local objs, count = SelectObject(GetMyPCObject(), 10000, 'ENEMY');
  
  for i = 1, count do
    local obj = objs[i];
    
    if obj.MonRank == 'Boss' and (string.find(obj.ClassName, 'F_') == 1 or string.find(obj.ClassName, 'FD_') == 1) then
      SD_BOSSINFO_PONG(obj);
    end
  end
end
