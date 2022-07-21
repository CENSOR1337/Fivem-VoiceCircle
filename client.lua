local voiceModes = Config.Modes
local lerpSpeed = Config.LerpSpeed

local bThreadCreated = false
local currentVoiceMode = voiceModes[1]
local endTime = GetGameTimer()
local proximityRange = 0.0
local lerpRange = 0.0
local drawDuration = 5000

local _DrawMarker = DrawMarker
local _math_floor = math.floor
local _getEntityCoords = GetEntityCoords

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function CreateCricleThread()
    CreateThread(function()
        local localPed = PlayerPedId()
        while GetGameTimer() < endTime do
            local localPedCoords = _getEntityCoords(localPed)
            localPedCoords = vector3(localPedCoords.x, localPedCoords.y, localPedCoords.z - 0.1)
            local drawAlpha = _math_floor((endTime - GetGameTimer()) / drawDuration * 255)
            _DrawMarker(1, localPedCoords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, lerpRange, lerpRange, 0.125, currentVoiceMode.color.r, currentVoiceMode.color.g, currentVoiceMode.color.b, drawAlpha, false, true, 2, nil, nil, false)
            _DrawMarker(1, localPedCoords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, lerpRange, lerpRange, -0.125, currentVoiceMode.color.r, currentVoiceMode.color.g, currentVoiceMode.color.b, drawAlpha, false, true, 2, nil, nil, false)
            lerpRange = Lerp(lerpRange, proximityRange, lerpSpeed)
            Wait(0)
        end
    end)
end

local function UpdateVoiceInfos()
    local proximity = LocalPlayer.state.proximity
    currentVoiceMode = voiceModes[proximity.index]
    proximityRange = proximity.distance
end

AddEventHandler("pma-voice:setTalkingMode", function()
    UpdateVoiceInfos()
    if not (GetGameTimer() >= endTime) then
        CreateCricleThread()
    end
    endTime = GetGameTimer() + drawDuration
end)

CreateThread(function()
    while (GetResourceState("pma-voice") ~= "started") do
        Wait(0)
    end
    UpdateVoiceInfos()
end)
