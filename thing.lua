

-- Scream And Run thing

-- LocalScript inside StarterPlayer > StarterPlayerScripts



local Players = game:GetService("Players")

local TweenService = game:GetService("TweenService")

local UserInputService = game:GetService("UserInputService")

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")



local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")



--==================================================

-- SETTINGS

--==================================================



local GUI_TITLE = "Scream And Run thing"



local MONSTER_NAME = "CatInTheHat"

local ESCAPE_DOOR_NAME = "EndingDoor"

local BACKPACK_FOLDER_NAME = "BackPack"

local BACKPACK_MODEL_NAME = "BackPack"



local METERS_PER_STUD = 0.28

local UPDATE_INTERVAL = 0.15



local COLORS = {

    Monster = Color3.fromRGB(255, 55, 55),

    ["Unlotted Backpacks"] = Color3.fromRGB(0, 255, 90),

    ["Lotted Backpacks"] = Color3.fromRGB(255, 145, 0),

    ["All Backpacks"] = Color3.fromRGB(255, 225, 0),

    ["Escape Door"] = Color3.fromRGB(40, 145, 255),

    Players = Color3.fromRGB(255, 255, 255),

}



local BACKGROUND = Color3.fromRGB(20, 20, 25)

local PANEL_COLOR = Color3.fromRGB(29, 29, 36)

local ROW_COLOR = Color3.fromRGB(39, 39, 48)

local ACCENT_COLOR = Color3.fromRGB(255, 65, 65)

local TEXT_COLOR = Color3.fromRGB(245, 245, 250)

local MUTED_COLOR = Color3.fromRGB(155, 155, 170)

local OFF_COLOR = Color3.fromRGB(220, 55, 65)

local ON_COLOR = Color3.fromRGB(0, 205, 105)



--==================================================

-- STATE

--==================================================



local closed = false

local minimized = false

local updateAccumulator = 0



local espEnabled = {

    Monster = false,

    ["Unlotted Backpacks"] = false,

    ["Lotted Backpacks"] = false,

    ["All Backpacks"] = false,

    ["Escape Door"] = false,

    Players = false,

}



-- Text settings are independent for each ESP.

local textEnabled = {

    Monster = true,

    ["Unlotted Backpacks"] = true,

    ["Lotted Backpacks"] = true,

    ["All Backpacks"] = true,

    ["Escape Door"] = true,

    Players = true,

}



local monsterObjects = {}

local backpackObjects = {}

local doorObjects = {}

local playerObjects = {}



local toggleButtons = {}

local textToggleButtons = {}

local tabButtons = {}

local tabPages = {}



--==================================================

-- REMOVE OLD GUI

--==================================================



local oldGui = playerGui:FindFirstChild("ScreamAndRunGui")



if oldGui then

    oldGui:Destroy()

end



--==================================================

-- GUI HELPERS

--==================================================



local screenGui = Instance.new("ScreenGui")

screenGui.Name = "ScreamAndRunGui"

screenGui.ResetOnSpawn = false

screenGui.IgnoreGuiInset = true

screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

screenGui.Parent = playerGui



local function create(className, properties, parent)

    local object = Instance.new(className)



    for property, value in pairs(properties) do

        object[property] = value

    end



    object.Parent = parent

    return object

end



local function addCorner(object, radius)

    create("UICorner", {

        CornerRadius = UDim.new(0, radius or 8),

    }, object)

end



local function addStroke(object, color, thickness, transparency)

    return create("UIStroke", {

        Color = color or ACCENT_COLOR,

        Thickness = thickness or 1,

        Transparency = transparency or 0,

    }, object)

end



local function tween(object, duration, properties, style, direction)

    local animation = TweenService:Create(

        object,

        TweenInfo.new(

            duration,

            style or Enum.EasingStyle.Quint,

            direction or Enum.EasingDirection.Out

        ),

        properties

    )



    animation:Play()

    return animation

end



--==================================================

-- MAIN WINDOW

--==================================================



local main = create("Frame", {

    Name = "MainWindow",

    AnchorPoint = Vector2.new(0.5, 0.5),

    Position = UDim2.new(0.5, 0, 0.5, 0),

    Size = UDim2.fromOffset(490, 400),

    BackgroundColor3 = BACKGROUND,

    BorderSizePixel = 0,

    ClipsDescendants = true,

}, screenGui)



addCorner(main, 12)

addStroke(main, Color3.fromRGB(70, 70, 85), 1, 0.15)



local originalSize = main.Size



--==================================================

-- HEADER

--==================================================



local header = create("Frame", {

    Name = "Header",

    Size = UDim2.new(1, 0, 0, 48),

    BackgroundColor3 = PANEL_COLOR,

    BorderSizePixel = 0,

}, main)



create("TextLabel", {

    Name = "Title",

    Position = UDim2.fromOffset(15, 0),

    Size = UDim2.new(1, -120, 1, 0),

    BackgroundTransparency = 1,

    Text = GUI_TITLE,

    TextColor3 = TEXT_COLOR,

    TextSize = 18,

    Font = Enum.Font.GothamBold,

    TextXAlignment = Enum.TextXAlignment.Left,

}, header)



local minimizeButton = create("TextButton", {

    Name = "Minimize",

    Position = UDim2.new(1, -77, 0, 8),

    Size = UDim2.fromOffset(30, 30),

    BackgroundColor3 = ROW_COLOR,

    BorderSizePixel = 0,

    Text = "—",

    TextColor3 = TEXT_COLOR,

    TextSize = 18,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

}, header)



addCorner(minimizeButton, 7)



local closeButton = create("TextButton", {

    Name = "Close",

    Position = UDim2.new(1, -39, 0, 8),

    Size = UDim2.fromOffset(30, 30),

    BackgroundColor3 = ACCENT_COLOR,

    BorderSizePixel = 0,

    Text = "X",

    TextColor3 = Color3.new(1, 1, 1),

    TextSize = 16,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

}, header)



addCorner(closeButton, 7)



closeButton.MouseEnter:Connect(function()

    if not closed then

        tween(closeButton, 0.12, {

            BackgroundColor3 = Color3.fromRGB(255, 105, 105),

        })

    end

end)



closeButton.MouseLeave:Connect(function()

    if not closed then

        tween(closeButton, 0.12, {

            BackgroundColor3 = ACCENT_COLOR,

        })

    end

end)



--==================================================

-- TABS

--==================================================



local tabBar = create("Frame", {

    Name = "TabBar",

    Position = UDim2.fromOffset(10, 57),

    Size = UDim2.new(1, -20, 0, 38),

    BackgroundTransparency = 1,

}, main)



create("UIListLayout", {

    FillDirection = Enum.FillDirection.Horizontal,

    HorizontalAlignment = Enum.HorizontalAlignment.Left,

    VerticalAlignment = Enum.VerticalAlignment.Center,

    Padding = UDim.new(0, 7),

    SortOrder = Enum.SortOrder.LayoutOrder,

}, tabBar)



local content = create("Frame", {

    Name = "Content",

    Position = UDim2.fromOffset(10, 103),

    Size = UDim2.new(1, -20, 1, -113),

    BackgroundTransparency = 1,

}, main)



local function createTab(name, label, order)

    local button = create("TextButton", {

        Name = name .. "Tab",

        Size = UDim2.new(1 / 3, -5, 1, 0),

        BackgroundColor3 = ROW_COLOR,

        BorderSizePixel = 0,

        Text = label,

        TextColor3 = MUTED_COLOR,

        TextSize = 13,

        Font = Enum.Font.GothamBold,

        AutoButtonColor = false,

        LayoutOrder = order,

    }, tabBar)



    addCorner(button, 7)



    local page = create("ScrollingFrame", {

        Name = name .. "Page",

        Size = UDim2.fromScale(1, 1),

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        ScrollBarThickness = 4,

        ScrollBarImageColor3 = ACCENT_COLOR,

        CanvasSize = UDim2.new(),

        AutomaticCanvasSize = Enum.AutomaticSize.Y,

        Visible = false,

    }, content)



    create("UIListLayout", {

        SortOrder = Enum.SortOrder.LayoutOrder,

        Padding = UDim.new(0, 6),

    }, page)



    create("UIPadding", {

        PaddingTop = UDim.new(0, 3),

        PaddingBottom = UDim.new(0, 6),

        PaddingRight = UDim.new(0, 5),

    }, page)



    tabButtons[name] = button

    tabPages[name] = page



    return button, page

end



local espTabButton, espPage = createTab("ESP", "👁️  ESP", 1)

local playerTabButton, playerPage = createTab("Player", "🏃  Player", 2)

local otherTabButton, otherPage = createTab("Other", "⚙️  Other", 3)



local function selectTab(name)

    if closed then

        return

    end



    for tabName, button in pairs(tabButtons) do

        local selected = tabName == name



        tween(button, 0.15, {

            BackgroundColor3 = selected and ACCENT_COLOR or ROW_COLOR,

            TextColor3 = selected and Color3.new(1, 1, 1) or MUTED_COLOR,

        })



        tabPages[tabName].Visible = selected

    end

end



espTabButton.Activated:Connect(function()

    selectTab("ESP")

end)



playerTabButton.Activated:Connect(function()

    selectTab("Player")

end)



otherTabButton.Activated:Connect(function()

    selectTab("Other")

end)



--==================================================

-- DISTANCE HELPERS

--==================================================



local function getCharacterRoot(character)

    if not character then

        return nil

    end



    return character:FindFirstChild("HumanoidRootPart")

        or character:FindFirstChildWhichIsA("BasePart")

end



local function getDistanceInMeters(part)

    local root = getCharacterRoot(player.Character)



    if not root or not part or not part.Parent then

        return nil

    end



    return (root.Position - part.Position).Magnitude * METERS_PER_STUD

end



--==================================================

-- ESP OBJECT CREATION

--==================================================



local function makeHighlight(model, color)

    local highlight = Instance.new("Highlight")

    highlight.Name = "ScreamRunESPHighlight"

    highlight.Adornee = model

    highlight.FillColor = color

    highlight.FillTransparency = 0.5

    highlight.OutlineColor = color

    highlight.OutlineTransparency = 1

    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    highlight.Parent = screenGui



    return highlight

end



local function makeBillboard(part, labelText, color, showText)

    local billboard = Instance.new("BillboardGui")

    billboard.Name = "ScreamRunESPLabel"

    billboard.Adornee = part

    billboard.Size = UDim2.fromOffset(190, 42)

    billboard.StudsOffset = Vector3.new(0, 3, 0)

    billboard.AlwaysOnTop = true

    billboard.MaxDistance = 100000

    billboard.Enabled = showText

    billboard.Parent = screenGui



    local label = Instance.new("TextLabel")

    label.Name = "Label"

    label.Size = UDim2.fromScale(1, 1)

    label.BackgroundTransparency = 1

    label.Text = labelText

    label.TextColor3 = color

    label.TextStrokeColor3 = Color3.new(0, 0, 0)

    label.TextStrokeTransparency = 0.15

    label.TextSize = 14

    label.Font = Enum.Font.GothamBold

    label.TextWrapped = true

    label.Parent = billboard



    return billboard, label

end



local function updateDistanceLabel(label, part, labelText)

    if not label or not label.Parent then

        return

    end



    local distance = getDistanceInMeters(part)



    if distance then

        label.Text = string.format("%s\n%.1f meters", labelText, distance)

    else

        label.Text = labelText

    end

end



local function applyTextVisibility(objects, settingName)

    if not objects then

        return

    end



    local show = textEnabled[settingName] == true



    if objects.billboard then

        objects.billboard.Enabled = show

    end

end



--==================================================

-- MONSTER ESP

--==================================================



local function removeMonsterESP(model)

    local objects = monsterObjects[model]



    if not objects then

        return

    end



    if objects.highlight then

        objects.highlight:Destroy()

    end



    if objects.billboard then

        objects.billboard:Destroy()

    end



    monsterObjects[model] = nil

end



local function addMonsterESP(model)

    if closed or not espEnabled["Monster"] then

        return

    end



    if not model:IsA("Model") or model.Name ~= MONSTER_NAME then

        return

    end



    if not model:IsDescendantOf(workspace) or monsterObjects[model] then

        return

    end



    local part = model.PrimaryPart

        or model:FindFirstChild("HumanoidRootPart", true)

        or model:FindFirstChildWhichIsA("BasePart", true)



    if not part then

        return

    end



    local highlight = makeHighlight(model, COLORS.Monster)



    local billboard, label = makeBillboard(

        part,

        "Monster",

        COLORS.Monster,

        textEnabled["Monster"]

    )



    monsterObjects[model] = {

        highlight = highlight,

        billboard = billboard,

        label = label,

        part = part,

        labelText = "Monster",

    }



    updateDistanceLabel(label, part, "Monster")

end



local function refreshMonsterESP()

    if not espEnabled["Monster"] then

        for model in pairs(monsterObjects) do

            removeMonsterESP(model)

        end

        return

    end



    for _, object in ipairs(workspace:GetDescendants()) do

        if object:IsA("Model") and object.Name == MONSTER_NAME then

            addMonsterESP(object)

        end

    end

end



--==================================================

-- ESCAPE DOOR ESP

-- Finds Models named EndingDoor anywhere in Workspace.

--==================================================



local function removeDoorESP(model)

    local objects = doorObjects[model]



    if not objects then

        return

    end



    if objects.highlight then

        objects.highlight:Destroy()

    end



    if objects.billboard then

        objects.billboard:Destroy()

    end



    doorObjects[model] = nil

end



local function addDoorESP(model)

    if closed or not espEnabled["Escape Door"] then

        return

    end



    if not model:IsA("Model") or model.Name ~= ESCAPE_DOOR_NAME then

        return

    end



    if not model:IsDescendantOf(workspace) or doorObjects[model] then

        return

    end



    local part = model.PrimaryPart

        or model:FindFirstChild("HumanoidRootPart", true)

        or model:FindFirstChildWhichIsA("BasePart", true)



    if not part then

        return

    end



    local highlight = makeHighlight(model, COLORS["Escape Door"])



    local billboard, label = makeBillboard(

        part,

        "Escape Door",

        COLORS["Escape Door"],

        textEnabled["Escape Door"]

    )



    doorObjects[model] = {

        highlight = highlight,

        billboard = billboard,

        label = label,

        part = part,

        labelText = "Escape Door",

    }



    updateDistanceLabel(label, part, "Escape Door")

end



local function refreshDoorESP()

    if not espEnabled["Escape Door"] then

        for model in pairs(doorObjects) do

            removeDoorESP(model)

        end

        return

    end



    for _, object in ipairs(workspace:GetDescendants()) do

        if object:IsA("Model") and object.Name == ESCAPE_DOOR_NAME then

            addDoorESP(object)

        end

    end

end



--==================================================

-- BACKPACK DETECTION

-- Only scans Models inside workspace.BackPack.

-- Prompt inside Handle = Unlotted (green).

-- No prompt inside Handle = Lotted (orange).

-- All Backpacks = both types in yellow.

--==================================================



local function getBackpackFolder()

    local folder = workspace:FindFirstChild(BACKPACK_FOLDER_NAME)



    if folder and folder:IsA("Folder") then

        return folder

    end



    return nil

end



local function findBackpackHandle(model)

    if not model or not model:IsA("Model") then

        return nil

    end



    if model.Name ~= BACKPACK_MODEL_NAME then

        return nil

    end



    local handle = model:FindFirstChild("Handle", true)



    if handle and handle:IsA("BasePart") then

        return handle

    end



    return nil

end



local function classifyBackpack(model)

    local handle = findBackpackHandle(model)



    if not handle then

        return nil

    end



    local prompt = handle:FindFirstChildWhichIsA("ProximityPrompt", true)



    if prompt then

        return "Unlotted", handle

    end



    return "Lotted", handle

end



local function removeBackpackESP(model)

    local objects = backpackObjects[model]



    if not objects then

        return

    end



    if objects.highlight then

        objects.highlight:Destroy()

    end



    if objects.billboard then

        objects.billboard:Destroy()

    end



    backpackObjects[model] = nil

end



local function addBackpackESP(model, requestedKind)

    if closed then

        return

    end



    local folder = getBackpackFolder()



    if not folder or not model or not model:IsA("Model") then

        return

    end



    if model.Name ~= BACKPACK_MODEL_NAME

        or not model:IsDescendantOf(folder) then

        return

    end



    local detectedKind, handle = classifyBackpack(model)



    if not detectedKind or not handle then

        return

    end



    local kind



    if espEnabled["All Backpacks"] then

        kind = "All Backpacks"

    elseif requestedKind == detectedKind

        and espEnabled[requestedKind .. " Backpacks"] then

        kind = requestedKind .. " Backpacks"

    elseif espEnabled[detectedKind .. " Backpacks"] then

        kind = detectedKind .. " Backpacks"

    else

        removeBackpackESP(model)

        return

    end



    local color

    local labelText



    if kind == "All Backpacks" then

        color = COLORS["All Backpacks"]

        labelText = "Backpack"

    elseif kind == "Unlotted Backpacks" then

        color = COLORS["Unlotted Backpacks"]

        labelText = "Unlotted Backpack"

    else

        color = COLORS["Lotted Backpacks"]

        labelText = "Lotted Backpack"

    end



    local existing = backpackObjects[model]



    if existing

        and existing.kind == kind

        and existing.part == handle then



        applyTextVisibility(existing, kind)

        return

    end



    if existing then

        removeBackpackESP(model)

    end



    local highlight = makeHighlight(model, color)



    local billboard, label = makeBillboard(

        handle,

        labelText,

        color,

        textEnabled[kind]

    )



    backpackObjects[model] = {

        highlight = highlight,

        billboard = billboard,

        label = label,

        part = handle,

        kind = kind,

        labelText = labelText,

    }



    updateDistanceLabel(label, handle, labelText)

end



local function refreshBackpackESP()

    local folder = getBackpackFolder()



    if not folder then

        for model in pairs(backpackObjects) do

            removeBackpackESP(model)

        end

        return

    end



    if not espEnabled["All Backpacks"]

        and not espEnabled["Unlotted Backpacks"]

        and not espEnabled["Lotted Backpacks"] then



        for model in pairs(backpackObjects) do

            removeBackpackESP(model)

        end



        return

    end



    for _, object in ipairs(folder:GetDescendants()) do

        if object:IsA("Model") and object.Name == BACKPACK_MODEL_NAME then

            local detectedKind = classifyBackpack(object)



            if detectedKind then

                if espEnabled["All Backpacks"] then

                    addBackpackESP(object, "All Backpacks")

                elseif espEnabled[detectedKind .. " Backpacks"] then

                    addBackpackESP(object, detectedKind)

                else

                    removeBackpackESP(object)

                end

            else

                removeBackpackESP(object)

            end

        end

    end



    for model in pairs(backpackObjects) do

        if not model:IsDescendantOf(folder) then

            removeBackpackESP(model)

        end

    end

end



--==================================================

-- PLAYER ESP

-- White highlight, displays each player's name.

-- Never creates ESP for the local player.

--==================================================



local function removePlayerESP(targetPlayer)

    local objects = playerObjects[targetPlayer]



    if not objects then

        return

    end



    if objects.highlight then

        objects.highlight:Destroy()

    end



    if objects.billboard then

        objects.billboard:Destroy()

    end



    playerObjects[targetPlayer] = nil

end



local function addPlayerESP(targetPlayer)

    if closed or not espEnabled["Players"] then

        return

    end



    if targetPlayer == player then

        return

    end



    local character = targetPlayer.Character



    if not character then

        return

    end



    local part = getCharacterRoot(character)



    if not part then

        return

    end



    local existing = playerObjects[targetPlayer]



    if existing and existing.character == character then

        applyTextVisibility(existing, "Players")

        return

    elseif existing then

        removePlayerESP(targetPlayer)

    end



    local highlight = makeHighlight(character, COLORS.Players)



    local displayName = targetPlayer.DisplayName



    local billboard, label = makeBillboard(

        part,

        displayName,

        COLORS.Players,

        textEnabled["Players"]

    )



    playerObjects[targetPlayer] = {

        highlight = highlight,

        billboard = billboard,

        label = label,

        part = part,

        character = character,

        labelText = displayName,

    }



    updateDistanceLabel(label, part, displayName)

end



local function refreshPlayerESP()

    if not espEnabled["Players"] then

        for targetPlayer in pairs(playerObjects) do

            removePlayerESP(targetPlayer)

        end

        return

    end



    for _, targetPlayer in ipairs(Players:GetPlayers()) do

        if targetPlayer ~= player then

            addPlayerESP(targetPlayer)

        end

    end

end



--==================================================

-- REFRESH TEXT VISIBILITY

--==================================================



local function refreshTextForESP(name)

    if name == "Monster" then

        for _, objects in pairs(monsterObjects) do

            applyTextVisibility(objects, "Monster")

        end



    elseif name == "Escape Door" then

        for _, objects in pairs(doorObjects) do

            applyTextVisibility(objects, "Escape Door")

        end



    elseif name == "Players" then

        for _, objects in pairs(playerObjects) do

            applyTextVisibility(objects, "Players")

        end



    elseif name == "All Backpacks" then

        for _, objects in pairs(backpackObjects) do

            if objects.kind == "All Backpacks" then

                applyTextVisibility(objects, "All Backpacks")

            end

        end



    elseif name == "Unlotted Backpacks" then

        for _, objects in pairs(backpackObjects) do

            if objects.kind == "Unlotted Backpacks" then

                applyTextVisibility(objects, "Unlotted Backpacks")

            end

        end



    elseif name == "Lotted Backpacks" then

        for _, objects in pairs(backpackObjects) do

            if objects.kind == "Lotted Backpacks" then

                applyTextVisibility(objects, "Lotted Backpacks")

            end

        end

    end

end



--==================================================

-- SWITCH VISUALS

--==================================================



local function updateSwitch(button, enabled)

    if not button then

        return

    end



    local track = button:FindFirstChild("SwitchTrack")

    local knob = track and track:FindFirstChild("SwitchKnob")



    if not track or not knob then

        return

    end



    tween(track, 0.18, {

        BackgroundColor3 = enabled and ON_COLOR or OFF_COLOR,

    })



    tween(knob, 0.18, {

        Position = enabled

            and UDim2.new(1, -21, 0.5, 0)

            or UDim2.new(0, 3, 0.5, 0),

    })

end



local function updateAllSwitches()

    for name, button in pairs(toggleButtons) do

        updateSwitch(button, espEnabled[name])

    end



    for name, button in pairs(textToggleButtons) do

        updateSwitch(button, textEnabled[name])

    end

end



--==================================================

-- SET ESP TOGGLE

--==================================================



local function setToggle(name, enabled)

    if closed then

        return

    end



    -- All Backpacks disables both individual backpack ESPs.

    if name == "All Backpacks" and enabled then

        espEnabled["Unlotted Backpacks"] = false

        espEnabled["Lotted Backpacks"] = false

    end



    -- Individual backpack ESP disables All Backpacks.

    if (name == "Unlotted Backpacks" or name == "Lotted Backpacks")

        and enabled then

        espEnabled["All Backpacks"] = false

    end



    espEnabled[name] = enabled



    -- Show Text options only appear when their ESP is enabled.

    if textToggleButtons[name] then

        textToggleButtons[name].Visible = enabled

    end



    updateAllSwitches()



    if name == "Monster" then

        refreshMonsterESP()



    elseif name == "Escape Door" then

        refreshDoorESP()



    elseif name == "Players" then

        refreshPlayerESP()



    elseif name == "Unlotted Backpacks"

        or name == "Lotted Backpacks"

        or name == "All Backpacks" then

        refreshBackpackESP()

    end

end



local function setTextToggle(name, enabled)

    if closed then

        return

    end



    textEnabled[name] = enabled



    updateAllSwitches()

    refreshTextForESP(name)

end



--==================================================

-- CREATE SLIDING SWITCH

--==================================================



local function createSwitch(parent)

    local track = create("Frame", {

        Name = "SwitchTrack",

        AnchorPoint = Vector2.new(0, 0.5),

        Position = UDim2.new(1, -61, 0.5, 0),

        Size = UDim2.fromOffset(48, 24),

        BackgroundColor3 = OFF_COLOR,

        BorderSizePixel = 0,

    }, parent)



    addCorner(track, 12)



    local knob = create("Frame", {

        Name = "SwitchKnob",

        AnchorPoint = Vector2.new(0, 0.5),

        Position = UDim2.new(0, 3, 0.5, 0),

        Size = UDim2.fromOffset(18, 18),

        BackgroundColor3 = Color3.new(1, 1, 1),

        BorderSizePixel = 0,

    }, track)



    addCorner(knob, 9)



    return track

end



--==================================================

-- CREATE ESP ROW + SHOW TEXT ROW

--==================================================



local function createToggleRow(parent, name, description, order)

    local row = create("TextButton", {

        Name = name:gsub("%s+", "") .. "Toggle",

        Size = UDim2.new(1, -2, 0, 57),

        BackgroundColor3 = ROW_COLOR,

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,

        LayoutOrder = order * 2,

    }, parent)



    addCorner(row, 8)



    local rowStroke = addStroke(

        row,

        Color3.fromRGB(65, 65, 78),

        1,

        0.55

    )



    create("TextLabel", {

        Name = "Label",

        Position = UDim2.fromOffset(12, 7),

        Size = UDim2.new(1, -100, 0, 22),

        BackgroundTransparency = 1,

        Text = name,

        TextColor3 = TEXT_COLOR,

        TextSize = 14,

        Font = Enum.Font.GothamBold,

        TextXAlignment = Enum.TextXAlignment.Left,

    }, row)



    create("TextLabel", {

        Name = "Description",

        Position = UDim2.fromOffset(12, 29),

        Size = UDim2.new(1, -100, 0, 18),

        BackgroundTransparency = 1,

        Text = description,

        TextColor3 = MUTED_COLOR,

        TextSize = 10,

        Font = Enum.Font.Gotham,

        TextXAlignment = Enum.TextXAlignment.Left,

        TextTruncate = Enum.TextTruncate.AtEnd,

    }, row)



    createSwitch(row)



    toggleButtons[name] = row



    row.MouseEnter:Connect(function()

        if not closed then

            tween(row, 0.12, {

                BackgroundColor3 = Color3.fromRGB(48, 48, 59),

            })



            tween(rowStroke, 0.12, {

                Transparency = 0.15,

            })

        end

    end)



    row.MouseLeave:Connect(function()

        if not closed then

            tween(row, 0.12, {

                BackgroundColor3 = ROW_COLOR,

            })



            tween(rowStroke, 0.12, {

                Transparency = 0.55,

            })

        end

    end)



    row.Activated:Connect(function()

        setToggle(name, not espEnabled[name])

    end)



    -- Separate Show Text toggle, hidden until its ESP is enabled.

    local textRow = create("TextButton", {

        Name = name:gsub("%s+", "") .. "ShowTextToggle",

        Size = UDim2.new(1, -2, 0, 42),

        BackgroundColor3 = Color3.fromRGB(32, 32, 39),

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,

        Visible = false,

        LayoutOrder = order * 2 + 1,

    }, parent)



    addCorner(textRow, 8)

    addStroke(textRow, Color3.fromRGB(65, 65, 78), 1, 0.65)



    create("TextLabel", {

        Name = "Label",

        Position = UDim2.fromOffset(12, 0),

        Size = UDim2.new(1, -100, 1, 0),

        BackgroundTransparency = 1,

        Text = "Show Text",

        TextColor3 = TEXT_COLOR,

        TextSize = 12,

        Font = Enum.Font.GothamMedium,

        TextXAlignment = Enum.TextXAlignment.Left,

    }, textRow)



    createSwitch(textRow)



    textToggleButtons[name] = textRow



    textRow.Activated:Connect(function()

        setTextToggle(name, not textEnabled[name])

    end)

end



--==================================================

-- ESP TAB

--==================================================



createToggleRow(

    espPage,

    "Monster",

    "Red ESP for CatInTheHat",

    1

)



createToggleRow(

    espPage,

    "Unlotted Backpacks",

    "Green: Handle has a ProximityPrompt",

    2

)



createToggleRow(

    espPage,

    "Lotted Backpacks",

    "Orange: Handle has no ProximityPrompt",

    3

)



createToggleRow(

    espPage,

    "All Backpacks",

    "Yellow: show both backpack types",

    4

)



createToggleRow(

    espPage,

    "Escape Door",

    "Blue ESP for EndingDoor models",

    5

)



createToggleRow(

    espPage,

    "Players",

    "White ESP with each player's name",

    6

)



--==================================================

-- PLAYER / OTHER TABS

--==================================================



--==================================================
-- TPWALK SPEEDHACK SLIDER
-- Uses small CFrame offsets; Humanoid.WalkSpeed is never changed.
-- The slider starts at the character's current WalkSpeed baseline.
--==================================================

local speedhackBaseline = 16
local speedhackTarget = 16
local speedhackDragging = false
local speedhackConnections = {}

local speedRow = create("Frame", {
    Name = "SpeedhackRow",
    Size = UDim2.new(1, -4, 0, 104),
    BackgroundColor3 = ROW_COLOR,
    BorderSizePixel = 0,
    LayoutOrder = 1,
}, playerPage)
addCorner(speedRow, 8)
addStroke(speedRow, Color3.fromRGB(65, 65, 78), 1, 0.45)

local speedTitle = create("TextLabel", {
    Name = "Title",
    Position = UDim2.fromOffset(12, 8),
    Size = UDim2.new(1, -24, 0, 22),
    BackgroundTransparency = 1,
    Text = "Speedhack",
    TextColor3 = TEXT_COLOR,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, speedRow)

local speedValueLabel = create("TextLabel", {
    Name = "Value",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -12, 0, 8),
    Size = UDim2.fromOffset(100, 22),
    BackgroundTransparency = 1,
    Text = "16.0 studs/s",
    TextColor3 = ACCENT_COLOR,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Right,
}, speedRow)

local speedTrack = create("Frame", {
    Name = "SliderTrack",
    Position = UDim2.new(0, 12, 0, 53),
    Size = UDim2.new(1, -24, 0, 8),
    BackgroundColor3 = Color3.fromRGB(65, 65, 78),
    BorderSizePixel = 0,
}, speedRow)
addCorner(speedTrack, 4)

local speedFill = create("Frame", {
    Name = "Fill",
    Size = UDim2.new(16 / 100, 0, 1, 0),
    BackgroundColor3 = ACCENT_COLOR,
    BorderSizePixel = 0,
}, speedTrack)
addCorner(speedFill, 4)

local speedKnob = create("Frame", {
    Name = "Knob",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(16 / 100, 0, 0.5, 0),
    Size = UDim2.fromOffset(16, 16),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ZIndex = 2,
}, speedTrack)
addCorner(speedKnob, 8)

local speedHitbox = create("TextButton", {
    Name = "SliderHitbox",
    Position = UDim2.new(0, 8, 0, 38),
    Size = UDim2.new(1, -16, 0, 38),
    BackgroundTransparency = 1,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 3,
}, speedRow)

create("TextLabel", {
    Name = "Range",
    Position = UDim2.new(0, 12, 0, 72),
    Size = UDim2.new(1, -24, 0, 18),
    BackgroundTransparency = 1,
    Text = "0  —  100 studs/s",
    TextColor3 = MUTED_COLOR,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
}, speedRow)

local SPEED_MIN = 0
local SPEED_MAX = 100

local function setSpeedhackValue(value)
    speedhackTarget = math.clamp(math.floor(value + 0.5), SPEED_MIN, SPEED_MAX)
    local alpha = (speedhackTarget - SPEED_MIN) / (SPEED_MAX - SPEED_MIN)
    speedFill.Size = UDim2.new(alpha, 0, 1, 0)
    speedKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
    speedValueLabel.Text = string.format("%d studs/s", speedhackTarget)
end

local function setSpeedFromInput(input)
    local width = speedTrack.AbsoluteSize.X
    if width <= 0 then return end
    local alpha = math.clamp(
        (input.Position.X - speedTrack.AbsolutePosition.X) / width,
        0,
        1
    )
    setSpeedhackValue(SPEED_MIN + alpha * (SPEED_MAX - SPEED_MIN))
end

speedHitbox.InputBegan:Connect(function(input)
    if closed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        speedhackDragging = true
        setSpeedFromInput(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if speedhackDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        setSpeedFromInput(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        speedhackDragging = false
    end
end)

local function updateSpeedhackBaseline()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        speedhackBaseline = humanoid.WalkSpeed
        setSpeedhackValue(speedhackBaseline)
    end
end

player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        speedhackBaseline = humanoid.WalkSpeed
        setSpeedhackValue(speedhackBaseline)
    end
end)

updateSpeedhackBaseline()

-- TPWalk: add only the difference between the slider target and the
-- character's normal WalkSpeed. At the baseline value, no extra offset is added.
pcall(function()
    RunService:UnbindFromRenderStep("ScreamRunTPWalk")
end)

RunService:BindToRenderStep("ScreamRunTPWalk", Enum.RenderPriority.Character.Value + 1, function(deltaTime)
    if closed or speedhackTarget == speedhackBaseline then
        return
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root or humanoid.Health <= 0 then
        return
    end

    local moveDirection = humanoid.MoveDirection
    if moveDirection.Magnitude < 0.01 then
        return
    end

    local extraSpeed = speedhackTarget - speedhackBaseline
    root.CFrame = root.CFrame + moveDirection * extraSpeed * deltaTime
end)



--==================================================
-- JUMP HEIGHT SLIDER
-- Uses Humanoid.JumpHeight (with UseJumpPower disabled while the slider is active).
--==================================================

local jumpMin, jumpMax = 0, 100
local jumpValue = 7.2
local jumpDragging = false
local jumpOriginals = setmetatable({}, { __mode = "k" })

local function applyJumpHeight(value, humanoid)
    jumpValue = math.clamp(math.floor(value * 10 + 0.5) / 10, jumpMin, jumpMax)
    if humanoid then
        if not jumpOriginals[humanoid] then
            jumpOriginals[humanoid] = {
                UseJumpPower = humanoid.UseJumpPower,
                JumpPower = humanoid.JumpPower,
                JumpHeight = humanoid.JumpHeight,
            }
        end
        humanoid.UseJumpPower = false
        humanoid.JumpHeight = jumpValue
    end
end

local jumpRow = create("Frame", {
    Name = "JumpHeightRow",
    Size = UDim2.new(1, -4, 0, 104),
    BackgroundColor3 = ROW_COLOR,
    BorderSizePixel = 0,
    LayoutOrder = 2,
}, playerPage)
addCorner(jumpRow, 8)
addStroke(jumpRow, Color3.fromRGB(65, 65, 78), 1, 0.45)

create("TextLabel", {
    Name = "Title", Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 22),
    BackgroundTransparency = 1, Text = "Jump Height", TextColor3 = TEXT_COLOR,
    TextSize = 14, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
}, jumpRow)
local jumpValueLabel = create("TextLabel", {
    Name = "Value", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 8),
    Size = UDim2.fromOffset(100, 22), BackgroundTransparency = 1, Text = "7.2 studs",
    TextColor3 = ACCENT_COLOR, TextSize = 12, Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Right,
}, jumpRow)
local jumpTrack = create("Frame", {
    Name = "SliderTrack", Position = UDim2.new(0, 12, 0, 53), Size = UDim2.new(1, -24, 0, 8),
    BackgroundColor3 = Color3.fromRGB(65, 65, 78), BorderSizePixel = 0,
}, jumpRow)
addCorner(jumpTrack, 4)
local jumpFill = create("Frame", {
    Name = "Fill", Size = UDim2.new(jumpValue / jumpMax, 0, 1, 0),
    BackgroundColor3 = ACCENT_COLOR, BorderSizePixel = 0,
}, jumpTrack)
addCorner(jumpFill, 4)
local jumpKnob = create("Frame", {
    Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(jumpValue / jumpMax, 0, 0.5, 0), Size = UDim2.fromOffset(16, 16),
    BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2,
}, jumpTrack)
addCorner(jumpKnob, 8)
local jumpHitbox = create("TextButton", {
    Name = "SliderHitbox", Position = UDim2.new(0, 8, 0, 38), Size = UDim2.new(1, -16, 0, 38),
    BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 3,
}, jumpRow)
create("TextLabel", {
    Name = "Range", Position = UDim2.new(0, 12, 0, 72), Size = UDim2.new(1, -24, 0, 18),
    BackgroundTransparency = 1, Text = "0  —  100 studs", TextColor3 = MUTED_COLOR,
    TextSize = 10, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
}, jumpRow)

local function setJumpSlider(value)
    jumpValue = math.clamp(math.floor(value * 10 + 0.5) / 10, jumpMin, jumpMax)
    local alpha = jumpValue / jumpMax
    jumpFill.Size = UDim2.new(alpha, 0, 1, 0)
    jumpKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
    jumpValueLabel.Text = string.format("%.1f studs", jumpValue)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then applyJumpHeight(jumpValue, humanoid) end
end
local function setJumpFromInput(input)
    local width = jumpTrack.AbsoluteSize.X
    if width <= 0 then return end
    local alpha = math.clamp((input.Position.X - jumpTrack.AbsolutePosition.X) / width, 0, 1)
    setJumpSlider(jumpMin + alpha * (jumpMax - jumpMin))
end
jumpHitbox.InputBegan:Connect(function(input)
    if closed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        jumpDragging = true
        setJumpFromInput(input)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if jumpDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        setJumpFromInput(input)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        jumpDragging = false
    end
end)

--==================================================
-- FEATURE TOGGLES: Noclip, Fullbright, No Fog, Instant Interact
--==================================================

local featureStates = { Noclip = false, Fullbright = false, ["No Fog"] = false, ["Instant Interact"] = false }
local featureRows = {}
local noclipConnection
local originalCollisions = setmetatable({}, { __mode = "k" })
local lightingOriginals = nil
local fogOriginals = nil
local originalPromptDurations = setmetatable({}, { __mode = "k" })
local promptAddedConnection

local function makePromptInstant(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    if originalPromptDurations[prompt] == nil then
        originalPromptDurations[prompt] = prompt.HoldDuration
    end
    prompt.HoldDuration = 0
end

local function restorePromptDurations()
    for prompt, originalDuration in pairs(originalPromptDurations) do
        if prompt and prompt.Parent then
            prompt.HoldDuration = originalDuration
        end
        originalPromptDurations[prompt] = nil
    end
end

local function makeFeatureToggle(parent, name, description, order)
    local row = create("TextButton", {
        Name = name:gsub("%s+", "") .. "Toggle", Size = UDim2.new(1, -4, 0, 57),
        BackgroundColor3 = ROW_COLOR, BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        LayoutOrder = order,
    }, parent)
    addCorner(row, 8)
    local outline = addStroke(row, Color3.fromRGB(65, 65, 78), 1, 0.45)
    create("TextLabel", {
        Name = "Label", Position = UDim2.fromOffset(12, 7), Size = UDim2.new(1, -100, 0, 22),
        BackgroundTransparency = 1, Text = name, TextColor3 = TEXT_COLOR, TextSize = 14,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    create("TextLabel", {
        Name = "Description", Position = UDim2.fromOffset(12, 29), Size = UDim2.new(1, -100, 0, 18),
        BackgroundTransparency = 1, Text = description, TextColor3 = MUTED_COLOR, TextSize = 10,
        Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)
    local pill = create("Frame", {
        Name = "Switch", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(42, 23), BackgroundColor3 = OFF_COLOR, BorderSizePixel = 0,
    }, row)
    addCorner(pill, 12)
    local dot = create("Frame", {
        Name = "Dot", Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(17, 17),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
    }, pill)
    addCorner(dot, 9)
    featureRows[name] = { row = row, pill = pill, dot = dot, outline = outline }
    row.Activated:Connect(function()
        if not closed then
            featureStates[name] = not featureStates[name]
            local enabled = featureStates[name]
            tween(pill, 0.12, { BackgroundColor3 = enabled and ON_COLOR or OFF_COLOR })
            tween(dot, 0.12, { Position = enabled and UDim2.fromOffset(22, 3) or UDim2.fromOffset(3, 3) })
            tween(outline, 0.12, { Transparency = enabled and 0.15 or 0.45 })
            if name == "Noclip" then
                if enabled then
                    if noclipConnection then noclipConnection:Disconnect() end
                    noclipConnection = RunService.Stepped:Connect(function()
                        if closed or not featureStates.Noclip then return end
                        local character = player.Character
                        if not character then return end
                        for _, part in ipairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                if originalCollisions[part] == nil then originalCollisions[part] = part.CanCollide end
                                part.CanCollide = false
                            end
                        end
                    end)
                else
                    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
                    for part, wasCollidable in pairs(originalCollisions) do
                        if part and part.Parent then part.CanCollide = wasCollidable end
                        originalCollisions[part] = nil
                    end
                end
            elseif name == "Fullbright" then
                if enabled then
                    if not lightingOriginals then
                        lightingOriginals = {
                            Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
                            GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient,
                            OutdoorAmbient = Lighting.OutdoorAmbient, ExposureCompensation = Lighting.ExposureCompensation,
                        }
                    end
                    Lighting.Brightness = 3
                    Lighting.ClockTime = 14
                    Lighting.GlobalShadows = false
                    Lighting.Ambient = Color3.new(1, 1, 1)
                    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
                    Lighting.ExposureCompensation = 0
                elseif lightingOriginals then
                    for property, value in pairs(lightingOriginals) do Lighting[property] = value end
                    lightingOriginals = nil
                end
            elseif name == "Instant Interact" then
                if enabled then
                    for _, descendant in ipairs(workspace:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            makePromptInstant(descendant)
                        end
                    end
                    if promptAddedConnection then promptAddedConnection:Disconnect() end
                    promptAddedConnection = workspace.DescendantAdded:Connect(function(descendant)
                        if not closed and featureStates["Instant Interact"] and descendant:IsA("ProximityPrompt") then
                            makePromptInstant(descendant)
                        end
                    end)
                else
                    if promptAddedConnection then promptAddedConnection:Disconnect(); promptAddedConnection = nil end
                    restorePromptDurations()
                end
            elseif name == "No Fog" then
                if enabled then
                    if not fogOriginals then fogOriginals = { FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd } end
                    Lighting.FogStart = 0
                    Lighting.FogEnd = 1000000
                    for _, effect in ipairs(Lighting:GetDescendants()) do
                        if effect:IsA("Atmosphere") then
                            effect:SetAttribute("ScreamRunOriginalDensity", effect.Density)
                            effect:SetAttribute("ScreamRunOriginalHaze", effect.Haze)
                            effect:SetAttribute("ScreamRunOriginalGlare", effect.Glare)
                            effect.Density = 0
                            effect.Haze = 0
                            effect.Glare = 0
                        end
                    end
                else
                    if fogOriginals then
                        Lighting.FogStart = fogOriginals.FogStart
                        Lighting.FogEnd = fogOriginals.FogEnd
                        fogOriginals = nil
                    end
                    for _, effect in ipairs(Lighting:GetDescendants()) do
                        if effect:IsA("Atmosphere") then
                            local density = effect:GetAttribute("ScreamRunOriginalDensity")
                            local haze = effect:GetAttribute("ScreamRunOriginalHaze")
                            local glare = effect:GetAttribute("ScreamRunOriginalGlare")
                            if density ~= nil then effect.Density = density; effect:SetAttribute("ScreamRunOriginalDensity", nil) end
                            if haze ~= nil then effect.Haze = haze; effect:SetAttribute("ScreamRunOriginalHaze", nil) end
                            if glare ~= nil then effect.Glare = glare; effect:SetAttribute("ScreamRunOriginalGlare", nil) end
                        end
                    end
                end
            end
        end
    end)
    row.MouseEnter:Connect(function()
        if not closed then tween(row, 0.12, { BackgroundColor3 = Color3.fromRGB(48, 48, 59) }) end
    end)
    row.MouseLeave:Connect(function()
        if not closed then tween(row, 0.12, { BackgroundColor3 = ROW_COLOR }) end
    end)
    return row
end

makeFeatureToggle(playerPage, "Noclip", "Walk through walls and objects", 3)
makeFeatureToggle(otherPage, "Fullbright", "Brighten the world", 1)
makeFeatureToggle(otherPage, "No Fog", "Disable fog and atmosphere haze", 2)
makeFeatureToggle(otherPage, "Instant Interact", "Make all proximity prompts instant", 3)

-- Apply jump-height setting to newly spawned characters too.
player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid and not closed then
        task.wait(0.1)
        applyJumpHeight(jumpValue, humanoid)
    end
end)

local initialCharacter = player.Character
local initialHumanoid = initialCharacter and initialCharacter:FindFirstChildOfClass("Humanoid")
if initialHumanoid then
    jumpValue = initialHumanoid.JumpHeight
    setJumpSlider(jumpValue)
end


--==================================================

-- SMOOTH DRAGGING

--==================================================



local dragging = false

local dragStart

local startPosition

local dragInput

local targetPosition = main.Position



header.Active = true



header.InputBegan:Connect(function(input)

    if closed then

        return

    end



    if input.UserInputType == Enum.UserInputType.MouseButton1

        or input.UserInputType == Enum.UserInputType.Touch then



        dragging = true

        dragStart = input.Position

        startPosition = targetPosition



        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then

                dragging = false

                dragInput = nil

            end

        end)

    end

end)



UserInputService.InputChanged:Connect(function(input)

    if closed then

        return

    end



    if dragging and (

        input.UserInputType == Enum.UserInputType.MouseMovement

        or input.UserInputType == Enum.UserInputType.Touch

    ) then

        dragInput = input

    end

end)



RunService.RenderStepped:Connect(function(deltaTime)

    if closed then

        return

    end



    if dragging and dragInput and dragStart and startPosition then

        local delta = dragInput.Position - dragStart



        targetPosition = UDim2.new(

            startPosition.X.Scale,

            startPosition.X.Offset + delta.X,

            startPosition.Y.Scale,

            startPosition.Y.Offset + delta.Y

        )

    end



    main.Position = main.Position:Lerp(

        targetPosition,

        math.clamp(deltaTime * 22, 0, 1)

    )

end)



--==================================================

-- MINIMIZE

--==================================================



minimizeButton.Activated:Connect(function()

    if closed then

        return

    end



    minimized = not minimized



    if minimized then

        minimizeButton.Text = "+"

        tabBar.Visible = false

        content.Visible = false



        tween(main, 0.25, {

            Size = UDim2.fromOffset(490, 48),

        })

    else

        minimizeButton.Text = "—"



        tween(main, 0.25, {

            Size = originalSize,

        })



        task.delay(0.15, function()

            if closed or minimized then

                return

            end



            tabBar.Visible = true

            content.Visible = true

        end)

    end

end)



--==================================================

-- SMOOTH CLOSE

--==================================================



closeButton.Activated:Connect(function()

    if closed then

        return

    end



    closed = true
    dragging = false
    speedhackDragging = false
    pcall(function()
        RunService:UnbindFromRenderStep("ScreamRunTPWalk")
    end)
    jumpDragging = false
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    if promptAddedConnection then promptAddedConnection:Disconnect(); promptAddedConnection = nil end
    restorePromptDurations()
    for part, wasCollidable in pairs(originalCollisions) do
        if part and part.Parent then part.CanCollide = wasCollidable end
        originalCollisions[part] = nil
    end
    for humanoid, original in pairs(jumpOriginals) do
        if humanoid and humanoid.Parent then
            humanoid.UseJumpPower = original.UseJumpPower
            humanoid.JumpPower = original.JumpPower
            humanoid.JumpHeight = original.JumpHeight
        end
    end
    if lightingOriginals then
        for property, value in pairs(lightingOriginals) do Lighting[property] = value end
        lightingOriginals = nil
    end
    if fogOriginals then
        Lighting.FogStart = fogOriginals.FogStart
        Lighting.FogEnd = fogOriginals.FogEnd
        fogOriginals = nil
    end
    for _, effect in ipairs(Lighting:GetDescendants()) do
        if effect:IsA("Atmosphere") then
            local density = effect:GetAttribute("ScreamRunOriginalDensity")
            local haze = effect:GetAttribute("ScreamRunOriginalHaze")
            local glare = effect:GetAttribute("ScreamRunOriginalGlare")
            if density ~= nil then effect.Density = density; effect:SetAttribute("ScreamRunOriginalDensity", nil) end
            if haze ~= nil then effect.Haze = haze; effect:SetAttribute("ScreamRunOriginalHaze", nil) end
            if glare ~= nil then effect.Glare = glare; effect:SetAttribute("ScreamRunOriginalGlare", nil) end
        end
    end

    local animation = tween(main, 0.22, {

        Size = UDim2.fromOffset(0, 0),

        BackgroundTransparency = 1,

        Position = main.Position + UDim2.fromOffset(0, 15),

    }, Enum.EasingStyle.Back, Enum.EasingDirection.In)



    tween(closeButton, 0.12, {

        BackgroundTransparency = 1,

        TextTransparency = 1,

    })



    tween(minimizeButton, 0.12, {

        BackgroundTransparency = 1,

        TextTransparency = 1,

    })



    animation.Completed:Wait()



    for model in pairs(monsterObjects) do

        removeMonsterESP(model)

    end



    for model in pairs(backpackObjects) do

        removeBackpackESP(model)

    end



    for model in pairs(doorObjects) do

        removeDoorESP(model)

    end



    for targetPlayer in pairs(playerObjects) do

        removePlayerESP(targetPlayer)

    end



    screenGui:Destroy()

end)



--==================================================

-- WORLD CHANGE LISTENERS

--==================================================



workspace.DescendantAdded:Connect(function(descendant)

    if closed then

        return

    end



    task.defer(function()

        if closed or not descendant.Parent then

            return

        end



        if descendant:IsA("Model") then

            if descendant.Name == MONSTER_NAME

                and espEnabled["Monster"] then

                addMonsterESP(descendant)

            end



            if descendant.Name == ESCAPE_DOOR_NAME

                and espEnabled["Escape Door"] then

                addDoorESP(descendant)

            end

        end



        -- Backpack ESP only scans the designated folder.

        local folder = getBackpackFolder()



        if not folder then

            return

        end



        if descendant == folder then

            refreshBackpackESP()

            return

        end



        if not descendant:IsDescendantOf(folder) then

            return

        end



        local current = descendant



        while current and current ~= folder do

            if current:IsA("Model")

                and current.Name == BACKPACK_MODEL_NAME then



                if espEnabled["All Backpacks"]

                    or espEnabled["Unlotted Backpacks"]

                    or espEnabled["Lotted Backpacks"] then



                    refreshBackpackESP()

                end



                break

            end



            current = current.Parent

        end

    end)

end)



workspace.DescendantRemoving:Connect(function(descendant)

    if closed then

        return

    end



    if descendant:IsA("Model") then

        removeMonsterESP(descendant)

        removeDoorESP(descendant)

        removeBackpackESP(descendant)

    end

end)



--==================================================

-- PLAYER LISTENERS

--==================================================



local function connectPlayer(targetPlayer)

    targetPlayer.CharacterAdded:Connect(function()

        task.wait(0.25)



        if not closed and espEnabled["Players"] and targetPlayer ~= player then

            addPlayerESP(targetPlayer)

        end

    end)

end



for _, targetPlayer in ipairs(Players:GetPlayers()) do

    if targetPlayer ~= player then

        connectPlayer(targetPlayer)

    end

end



Players.PlayerAdded:Connect(function(targetPlayer)

    connectPlayer(targetPlayer)



    task.defer(function()

        if not closed and espEnabled["Players"] then

            addPlayerESP(targetPlayer)

        end

    end)

end)



Players.PlayerRemoving:Connect(function(targetPlayer)

    removePlayerESP(targetPlayer)

end)



--==================================================

-- DISTANCE / OBJECT UPDATES

--==================================================



RunService.Heartbeat:Connect(function(deltaTime)

    if closed then

        return

    end



    updateAccumulator += deltaTime



    if updateAccumulator < UPDATE_INTERVAL then

        return

    end



    updateAccumulator = 0



    -- Monster labels and missing parts.

    for model, objects in pairs(monsterObjects) do

        if not model:IsDescendantOf(workspace) then

            removeMonsterESP(model)

        else

            local part = objects.part



            if not part or not part.Parent then

                part = model.PrimaryPart

                    or model:FindFirstChild("HumanoidRootPart", true)

                    or model:FindFirstChildWhichIsA("BasePart", true)



                objects.part = part



                if part and objects.billboard then

                    objects.billboard.Adornee = part

                end

            end



            if part then

                updateDistanceLabel(objects.label, part, objects.labelText)

            end

        end

    end



    -- Escape door labels and missing parts.

    for model, objects in pairs(doorObjects) do

        if not model:IsDescendantOf(workspace) then

            removeDoorESP(model)

        else

            local part = objects.part



            if not part or not part.Parent then

                part = model.PrimaryPart

                    or model:FindFirstChild("HumanoidRootPart", true)

                    or model:FindFirstChildWhichIsA("BasePart", true)



                objects.part = part



                if part and objects.billboard then

                    objects.billboard.Adornee = part

                end

            end



            if part then

                updateDistanceLabel(objects.label, part, objects.labelText)

            end

        end

    end



    -- Backpack labels and prompt/category changes.

    for model, objects in pairs(backpackObjects) do

        local folder = getBackpackFolder()



        if not folder or not model:IsDescendantOf(folder) then

            removeBackpackESP(model)

        else

            local detectedKind, handle = classifyBackpack(model)



            if not detectedKind or not handle then

                removeBackpackESP(model)

            else

                local desiredKind



                if espEnabled["All Backpacks"] then

                    desiredKind = "All Backpacks"

                elseif espEnabled[detectedKind .. " Backpacks"] then

                    desiredKind = detectedKind .. " Backpacks"

                end



                if not desiredKind then

                    removeBackpackESP(model)

                elseif objects.kind ~= desiredKind or objects.part ~= handle then

                    removeBackpackESP(model)

                    addBackpackESP(model, desiredKind)

                else

                    if objects.billboard then

                        objects.billboard.Adornee = handle

                    end



                    updateDistanceLabel(

                        objects.label,

                        handle,

                        objects.labelText

                    )

                end

            end

        end

    end



    -- Player labels. Never display ESP for the local player.

    for targetPlayer, objects in pairs(playerObjects) do

        if targetPlayer == player or targetPlayer.Parent ~= Players then

            removePlayerESP(targetPlayer)

        else

            local character = targetPlayer.Character



            if not character or not character:IsDescendantOf(workspace) then

                removePlayerESP(targetPlayer)

            else

                local part = getCharacterRoot(character)



                if part then

                    objects.part = part

                    objects.character = character

                    objects.labelText = targetPlayer.DisplayName



                    if objects.billboard then

                        objects.billboard.Adornee = part

                    end



                    updateDistanceLabel(

                        objects.label,

                        part,

                        targetPlayer.DisplayName

                    )

                end

            end

        end

    end

end)



--==================================================

-- INITIALIZE

--==================================================



selectTab("ESP")

updateAllSwitches()
