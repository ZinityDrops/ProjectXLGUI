
--// Settings 
local set = {
    enabled = false,
    itemenabled = false,
    clip = true,
    distance = 6,
    tool = false,
    quest = "",
    angle = "Below",
    itemselected = "",
    alwaysStand = true,
    instaKill = true,
    abs = {E=false,R=false,C=false,F=false,X=false}
}

--// Declaration Settings
local arrows = {"Requiem Arrow","Lucky Arrow"}
local target_races = {'Human (Hybrid)', 'Saiyan', 'Frieza Race', 'Uzumaki Clan', 'Fanalis', 'Jiren', 'Goblin', 'Namekian', 'Majin'}
local mentors = {'White Beard','Ace','Enel','Dabi'}
local spec = {'Haoshoku Haki','Kenbunshoku Haki','Hirenyaku','Danger Sense v2','Danger Sense v1','Doa Doa no mi v1'}
getgenv().armors = {
                    Level = 1000,
                    Enchantments = {
                        'Heroic',
                        'Reinforced',
                        'Flawless',
                        'Mythical',
                        'Mighty',
                        'Arcane',
                        'Conqueror\'s',
                        'Titanic',
                        'Firm',
                        '' -- 'Include this if you want to get any enchant'
                    }
                }


--// Imports
local imgui = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/1e17/UI-Libs/main/imgui_.lua'))()

--// Declarations 
local quests = {strings={},values={}}
local bosses = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/1e17/assets/main/projectXl_bosses.lua'))()
local toolCache = {}
local player = game.Players.LocalPlayer
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local live = workspace.Live  
local localQuests = player.Quests
local questRemote = game.ReplicatedStorage.RemoteEvents.ChangeQuestRemote -- :FireSever(questValue) 
local combatRemote = game.ReplicatedStorage.RemoteEvents.BladeCombatRemote -- :FireSever(bool,vec3,cf)
local clear = game.ReplicatedStorage.RemoteEvents.ClearInventoryRemote -- :FireServer()
local buy = game.ReplicatedStorage.RemoteEvents.BuyItemRemote -- :FireServer()
local use = game.ReplicatedStorage.RemoteEvents.ItemRemote -- FireServer()
local itemA = 'Arrow'
local itemM = 'Random Mentor'
local race = player.PlayerValues.Race

--// Old Data 
local lvl = player.PlayerValues.Level.Value
local gold = player.PlayerValues.Gold.Value

--// Storing Quests 
for i,v in pairs(game.ReplicatedStorage.Quests:GetChildren()) do 
    if v.Name:match('%d') then 
        --// Strings 
        table.insert(quests.strings,v.Name)

        --// Remote Value
        quests.values[v.Name] = v
    end
end 


--// Primary Loop 
coroutine.wrap(function()
    while wait(nil) do 

        if set.enabled then 
            --// Quest 
            local q = set.quest
            local boss = not localQuests:FindFirstChild(q)
            local allow = (#q>0 and (not boss and localQuests[q].Value or boss and #q>0))

            if not allow and not boss then 
                questRemote:FireServer(quests.values[q])
                allow = true 
            end 


            if allow then 
                --// Equip
                if not player.Character:FindFirstChildWhichIsA('Tool') then 
                    (not set.tool and player.Backpack:FindFirstChildWhichIsA('Tool') or set.tool and player.Backpack[set.tool]).Parent = player.Character
                end 
                --// Farm 
                for i,v in pairs(live:GetChildren()) do
                    if q:find(v.Name) then
                        --// Checks
                        local root = v:FindFirstChild('HumanoidRootPart')
                        local hum = v:FindFirstChild('Humanoid')
                        local origin = player.Character:FindFirstChild('HumanoidRootPart')
         
                        while (root and hum and origin and not v:FindFirstChild('ForceField')) and (hum.Health>0) and (game.RunService.Stepped:wait()) and (not boss and localQuests[q].Value or boss) do 
                            origin.CFrame = root.CFrame * CFrame.new(0,(set.angle == 'Above' and set.distance or set.angle == 'Below' and -set.distance or 0),(set.angle == 'Behind' and set.distance or 0)) * (((set.angle == 'Above' or set.angle == 'Below') and not set.alwaysStand) and CFrame.Angles(math.rad(set.angle == 'Above' and -90 or set.angle == 'Below' and 90),0,0) or (CFrame.new()))
                            if set.instaKill then 
                                combatRemote:FireServer(true,nil,nil)

                                if hum.Health < hum.MaxHealth then 
                                    hum.Health = 0 
                                end 
                            else 
                                combatRemote:FireServer(true,nil,nil)
                            end 
                        end

                    end 
                end 
                
            end 
        end 
    end 
end)()

-- Buy Menu loop
coroutine.wrap(function()
    while wait(nil) do 
        if set.itemenabled then
            local o = set.itemselected
            print(o)
            if o == "Arrow" then 
                if #player.Backpack:GetChildren() >= 20 then 
                    for i,v in pairs(player.Backpack:GetChildren()) do
                        if not table.find(arrows,v.Name) and v.Name:find(itemA) then 
                            v.Parent = player.Character
                            v:Destroy()
                        elseif v.Name:find(itemA) and table.find(arrows,v.Name) then
                            set.itemenabled = false
                        end 
                    end
                else 
                    buy:FireServer(itemA)
                end 
            end
                
            if o == "Mentor" then
                if #player.Backpack:GetChildren() >= 10 then 
                    for i,v in pairs(player.Backpack:GetChildren()) do
                        if not table.find(mentors,v.Name) and v:FindFirstChild('EggMesh') then 
                            v.Parent = player.Character
                            v:Destroy()
                        elseif v:FindFirstChild('EggMesh') and table.find(mentors,v.Name) then
                            set.itemenabled = false
                        end 
                    end
                else 
                    buy:FireServer(itemM)
                end 
            end
                
            if o == "Armor" then
                Buy:FireServer('Random Armor')
                
                for _, v in next, LocalPlayer.Backpack:GetChildren() do
                    if v.Name == 'Bag' then
                        repeat 
                            RunService.RenderStepped:Wait() 
                        until v:FindFirstChild('Level', true) and v:FindFirstChild('Enchantment', true)
                            
                        if v.BagPart.Overhead.Level.Text:find(tostring(armors.Level)) and table.find(armors.Enchantments, v.BagPart.Overhead.Enchantment.Text) then
                            set.itemenabled = false
                        else
                            v.Parent = LocalPlayer.Character
                            v:Destroy()
                        end
                end
                RunService.RenderStepped:Wait()
                end
            end
                
            if o == "Race" then
                local t = player.Backpack:FindFirstChild('Heart')
                if not table.find(target_races, race.Value) and t then 
                    t.Parent = player.Character 
                    use:FireServer()
                elseif not t then 
                    buy:FireServer('Heart')
                elseif table.find(target_races, race.Value) then 
                    set.itemenabled = false 
                end 
            end
                
            if o == "Specialization" then
                Buy:FireServer('Random Specialization')
    
                for _, v in next, LocalPlayer.Backpack:GetChildren() do
                    if v:FindFirstChild('Storable') then
                        if table.find(spec, v.Name) then
                            set.itemenabled = false
                        else
                            v.Parent = LocalPlayer.Character
                            v:Destroy()
                        end
                    end
                end
                RunService.RenderStepped:Wait()
            end
        end
    end
end)()

--// Render Loops 
game.RunService.Stepped:Connect(function()
    local hum = player.Character:FindFirstChild('Humanoid')
    if hum and set.clip and set.enabled then 
        hum:ChangeState(11)
    end 
    setsimulationradius(math.huge,math.huge) -- insta kill
end)

--// Anti afk 
for i,v in pairs(getconnections(player.Idled)) do 
    v:Disable()
end

--// UI
local win = imgui.AddWindow(nil,'ProjectXL - {}#1000',{main_color = Color3.fromRGB(40,40,40),min_size = Vector2.new(350,450),toggle_key = Enum.KeyCode.RightShift,can_resize = true})

--// Tabs
local primaryTab = win.AddTab(nil,'Farm') --[[]]
local secondTab = win.AddTab(nil,'Buy')

--//Folders
local setFolder = primaryTab.AddFolder(nil,'Settings')
local farmSetFolder = setFolder.AddFolder(nil,'Farm')
local abSetFolder = setFolder.AddFolder(nil,'Abilites')
local buyFolder = secondTab.AddFolder(nil,'Items')

--// Other Shit
farmSetFolder.AddSwitch(nil,'Insta-Kill',true,function(bool) set.instaKill = bool end)
farmSetFolder.AddSwitch(nil,'Clip',true,function(bool) set.clip = bool end)
farmSetFolder.AddSwitch(nil,'Always Stand',true,function(bool) set.alwaysStand = bool end)
local angleDropdown = farmSetFolder.AddDropdown(nil,'Angle',function(val) set.angle = val end)
for i,v in pairs({'Behind','Below','Above'}) do 
    angleDropdown:Add(v)
end 
local questDropdown = farmSetFolder.AddDropdown(nil,'Quest',function(val) set.quest = val end)
for _,v in pairs(quests.strings) do 
    questDropdown:Add(v)
end 
for _,v in pairs(bosses) do 
    questDropdown:Add(v)
end 
local itemDropdown = buyFolder.AddDropdown(nil,'ChooseAnItem',function(val) set.itemselected = val end)
for i,v in pairs({'Arrow','Mentor','Armor','Race','Specialization'}) do 
    itemDropdown:Add(v)
end 
farmSetFolder.AddSlider(nil,'Distance',function(val) set.distance = val end,{min=0,max=10,def=set.distance,readonly=false})
primaryTab.AddSwitch(nil,'Start',false,function(bool) set.enabled = bool end)

local toolDropdown = abSetFolder.AddDropdown(nil,'Select Ability',function(val) set.tool = val end)
for i,item in pairs(player.Backpack:GetChildren()) do 
    if item:IsA('Tool') then 
        toolCache[item.Name] = toolDropdown:Add(item.Name)
    end 
end
player.Backpack.ChildAdded:Connect(function(item)
    if not toolCache[item.Name] then 
        toolCache[item.Name] = toolDropdown:Add(item.Name)
    end 
end)
for i,v in pairs({'E','R','C','F','X'}) do 
    abSetFolder.AddSwitch(nil,'Use: '..v,false,function(bool) set.abs[v] = bool end)
    coroutine.wrap(function()
        while wait(nil) do 
            if set.abs[v] and set.enabled then 
                game:GetService('VirtualInputManager'):SendKeyEvent(true,v,false,uwu)
            end 
        end 
    end)()
end 

local expEarned = primaryTab.AddLabel(nil,'Levels Gained: 0')
local goldEarned = primaryTab.AddLabel(nil,'Gold Earned: 0')
coroutine.wrap(function()
    while wait(nil) do 
        goldEarned.Text = ('Gold Earned: %d'):format(player.PlayerValues.Gold.Value - gold)
        expEarned.Text = ('Levels Gained: %d'):format(player.PlayerValues.Level.Value - lvl)
    end 
end)()

--//Buy Tab
local buyitem = buyFolder.AddSwitch(nil,'Start',false,function(bool) set.itemenabled = bool end)
buyFolder.AddLabel(nil,'May remove all items in inventory,')
buyFolder.AddLabel(nil,'proceed with caution.')
buyFolder.AddLabel(nil,'Some stuff may not work as well')

--// Credits Tab 
local creditTab = win.AddTab(nil,'Credits')
creditTab.AddLabel(nil,'Scripter: {}#1000 & aturner#5673')
creditTab.AddLabel(nil,'Insta-Kill Method: Invell')
creditTab.AddLabel(nil,'UI: 0xSingularity')


--// imgui-Finalize 
imgui.FormatWindows()
primaryTab.Show()
