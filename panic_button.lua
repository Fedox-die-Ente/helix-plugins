local PLUGIN = PLUGIN


-- add your class variables down here to the table
local classTable = {
   -- CLASS_DCLASSNORMAL,
   -- CLASS_SCP106
}

-- add your team variables down here to the table
local factionTable = {
   -- FACTION_HUMAN,
   -- FACTION_SCP
}

function PLUGIN:PlayerCanPressPanicButton(ply)
    -- Here you can add some checks like if player is handcuffed or smth
    -- just return false or true then..
    return true
end 

PLUGIN.name = "Panic Button"
PLUGIN.author = "Fedox"
PLUGIN.description = "Adds the ability for players to press a panic button."
PLUGIN.license = [[
Copyright 2023 Fedox
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
]]

ix.config.Add("Should the Panic play a sound?", true, "Should the panic button play the specified sound?", nil, {
    category = "PanicButton"
})

ix.config.Add("Which sound should be played on press?", "npc/attack_helicopter/aheli_damaged_alarm1.wav", "Which sound should be played as soon as you press the panic button?", nil, {
    category = "PanicButton"
})

ix.config.Add("Seconds until Panicbutton can be used again", 20, "Which sound should be played as soon as you press the panic button?", nil, {
    data = {min = 1, max = 9999},
    category = "PanicButton"
})

if CLIENT then
    local playerCooldowns = {} 
    local function PlayPanicButtonSound(soundPath)
        surface.PlaySound(soundPath)
    end


    function PLUGIN:PlayerButtonDown(ply, button)
        if button == KEY_P and IsFirstTimePredicted() then
            local currentTime = CurTime()
            local cooldown = ix.config.Get("Seconds until Panicbutton can be used again")
            local lastPressTime = playerCooldowns[ply] or 0

            if currentTime - lastPressTime >= cooldown then
                local meta = ply:GetCharacter()
                local class = meta:GetClass()
                if PLUGIN:PlayerCanPressPanicButton(ply) then

                    local function tableHasValue(table,value)
                        for _, value in ipairs(table) do if (playerClass == value) then return true end end
                        return false
                    end

                    for _, v in ipairs(player.GetAll()) do
                        local char = v:GetCharacter()
                        local playerClass = char:GetClass()
                        local playerFaction = char:GetFaction()
                        if(tableHasValue(classTable,playerClass) or tableHasValue(factionTable,playerFaction)) then
                            if ix.config.Get("Should the Panic play a sound?") then
                                    local soundPath = ix.config.Get("Which sound should be played on press?")
                                    PlayPanicButtonSound(soundPath)
                                    playerCooldowns[ply] = currentTime 
                                    v:ChatNotify("The player " .. ply:Nick() .. " has pressed the panic button. His last recorded position was: "..char:GetData("panicButtonLastArea", "No location recorded.."))
                            end 
                        end
                    end
                    
                else
                    ply:Notify("You can't press the panic button now..")
                end
            else
                ply:EmitSound("buttons/combine_button_locked.wav")
            end
        end
    end
end

hook.Add("OnPlayerAreaChanged", "panicbutton", function(client, oldID, newID)
    local char = client:GetCharacter()
    char:SetData("panicButtonLastArea", newID)
end)
