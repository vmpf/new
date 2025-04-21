local UILibrary = {}
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

local theme = {
    background = Color3.fromRGB(15, 15, 15),
    section = Color3.fromRGB(20, 20, 20),
    accent = Color3.fromRGB(255, 130, 0),
    outline = Color3.fromRGB(60, 60, 60),
    text = Color3.fromRGB(255, 255, 255),
    darktext = Color3.fromRGB(100, 100, 100)
}

local function createText(txt, size, pos, center, col)
    local t = Drawing.new("Text")
    t.Text = txt
    t.Size = size
    t.Position = pos
    t.Center = center or false
    t.Color = col or theme.text
    t.Outline = true
    t.Visible = true
    return t
end

local function createBox(pos, size, color)
    local b = Drawing.new("Square")
    b.Position = pos
    b.Size = size
    b.Color = color
    b.Filled = true
    b.Visible = true
    return b
end

local function inBounds(pos, size, mouse)
    return mouse.X >= pos.X and mouse.X <= pos.X + size.X and mouse.Y >= pos.Y and mouse.Y <= pos.Y + size.Y
end

function UILibrary:CreateWindow(title)
    local self = {}
    local elements = {}
    local tabs = {}
    local activeTab = nil
    local tabContent = {}

    local windowPos = Vector2.new(400, 200)
    local windowSize = Vector2.new(500, 310)

    local winOutline = createBox(windowPos - Vector2.new(1, 1), windowSize + Vector2.new(2, 2), theme.outline)
    local winBg = createBox(windowPos, windowSize, theme.background)
    local titleText = createText(title, 14, windowPos + Vector2.new(windowSize.X / 2, -20), true, theme.accent)

    table.insert(elements, winOutline)
    table.insert(elements, winBg)
    table.insert(elements, titleText)

    rs.RenderStepped:Connect(function()
        local mouse = uis:GetMouseLocation()
        for _, t in pairs(tabs) do
            local txt = t.text
            local pos = txt.Position
            local size = txt.TextBounds
            local hovering = inBounds(pos, size, mouse)
            if hovering and activeTab ~= t.name then
                txt.Color = theme.accent
            elseif not hovering and activeTab ~= t.name then
                txt.Color = theme.darktext
            end
        end
    end)

    function self:CreateTab(name)
        local idx = #tabs + 1
        local tabX = windowPos.X + (idx - 1) * 60
        local tabText = createText(name, 13, Vector2.new(tabX, windowPos.Y - 2), false, theme.darktext)
        table.insert(tabs, {name = name, text = tabText})
        tabContent[name] = {}

        uis.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = uis:GetMouseLocation()
                local size = Vector2.new(tabText.TextBounds.X, tabText.TextBounds.Y)
                if inBounds(tabText.Position, size, mouse) then
                    for _, v in pairs(tabContent) do
                        for _, e in pairs(v) do
                            e.Visible = false
                        end
                    end
                    for _, t in pairs(tabs) do
                        t.text.Color = theme.darktext
                    end
                    for _, e in pairs(tabContent[name]) do
                        e.Visible = true
                    end
                    tabText.Color = theme.accent
                    activeTab = name
                end
            end
        end)

        return {
            CreateSection = function(_, label)
                local section = {}
                local secBox = createBox(windowPos + Vector2.new(10 + ((#tabContent[name] % 2) * 240), 30), Vector2.new(230, 260), theme.section)
                local secLabel = createText(label, 13, secBox.Position + Vector2.new(5, 0))

                table.insert(tabContent[name], secBox)
                table.insert(tabContent[name], secLabel)

                function section:Checkbox(label, callback)
                    local box = createBox(secBox.Position + Vector2.new(5, 30 + #tabContent[name] * 20), Vector2.new(12, 12), Color3.fromRGB(10, 10, 10))
                    local text = createText(label, 13, box.Position + Vector2.new(20, 0))
                    local state = false

                    table.insert(tabContent[name], box)
                    table.insert(tabContent[name], text)

                    uis.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local mouse = uis:GetMouseLocation()
                            if inBounds(box.Position, Vector2.new(12, 12), mouse) then
                                state = not state
                                box.Color = state and theme.accent or Color3.fromRGB(10, 10, 10)
                                callback(state)
                            end
                        end
                    end)
                end

                function section:Slider(label, min, max, callback)
                    local barPos = secBox.Position + Vector2.new(5, 40 + #tabContent[name] * 20)
                    local bar = createBox(barPos, Vector2.new(150, 4), theme.outline)
                    local fill = createBox(barPos, Vector2.new(0, 4), theme.accent)
                    local text = createText(label .. ": " .. min, 13, barPos + Vector2.new(0, -14))

                    table.insert(tabContent[name], bar)
                    table.insert(tabContent[name], fill)
                    table.insert(tabContent[name], text)

                    local dragging = false

                    uis.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local mouse = uis:GetMouseLocation()
                            if inBounds(bar.Position, bar.Size, mouse) then
                                dragging = true
                            end
                        end
                    end)

                    uis.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)

                    rs.RenderStepped:Connect(function()
                        if dragging then
                            local mouse = uis:GetMouseLocation()
                            local rel = math.clamp((mouse.X - bar.Position.X) / bar.Size.X, 0, 1)
                            fill.Size = Vector2.new(bar.Size.X * rel, 4)
                            local val = math.floor(min + (max - min) * rel)
                            text.Text = label .. ": " .. val
                            callback(val)
                        end
                    end)
                end

                function section:Dropdown(label, options, callback)
                    local dropdown = {}
                    local basePos = secBox.Position + Vector2.new(5, 50 + #tabContent[name] * 20)
                    local box = createBox(basePos, Vector2.new(150, 16), theme.outline)
                    local text = createText(label .. ": " .. options[1], 13, basePos + Vector2.new(2, -1))

                    table.insert(tabContent[name], box)
                    table.insert(tabContent[name], text)

                    local open = false
                    local selected = options[1]

                    uis.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local mouse = uis:GetMouseLocation()
                            if inBounds(box.Position, box.Size, mouse) then
                                open = not open
                                if open then
                                    for i, opt in ipairs(options) do
                                        local optBox = createBox(basePos + Vector2.new(0, i * 16), Vector2.new(150, 16), theme.section)
                                        local optText = createText(opt, 13, optBox.Position + Vector2.new(2, -1))
                                        table.insert(tabContent[name], optBox)
                                        table.insert(tabContent[name], optText)

                                        uis.InputBegan:Connect(function(input2)
                                            if input2.UserInputType == Enum.UserInputType.MouseButton1 then
                                                local mouse2 = uis:GetMouseLocation()
                                                if inBounds(optBox.Position, optBox.Size, mouse2) then
                                                    selected = opt
                                                    text.Text = label .. ": " .. opt
                                                    callback(opt)
                                                    open = false
                                                    for j = #tabContent[name], 1, -1 do
                                                        if tabContent[name][j] == optBox or tabContent[name][j] == optText then
                                                            table.remove(tabContent[name], j):Remove()
                                                        end
                                                    end
                                                end
                                            end
                                        end)
                                    end
                                else
                                    for i = #tabContent[name], 1, -1 do
                                        if tabContent[name][i].Position.Y > box.Position.Y then
                                            table.remove(tabContent[name], i):Remove()
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end

                return section
            end
        }
    end

    return self
end

return UILibrary
