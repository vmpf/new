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

local function createLine(p1, p2, color)
    local l = Drawing.new("Line")
    l.From = p1
    l.To = p2
    l.Color = color
    l.Thickness = 1
    l.Visible = true
    return l
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

    function self:CreateTab(name)
        local idx = #tabs + 1
        local tabX = windowPos.X + (idx - 1) * 60
        local tabText = createText(name, 13, Vector2.new(tabX, windowPos.Y - 2), false)
        table.insert(tabs, {name = name, text = tabText})
        tabContent[name] = {}

        tabText.Color = theme.darktext

        tabText.MouseEnter = function()
            tabText.Color = theme.accent
        end

        tabText.MouseLeave = function()
            if activeTab ~= name then
                tabText.Color = theme.darktext
            end
        end

        uis.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = uis:GetMouseLocation()
                local size = Vector2.new(tabText.TextBounds.X, tabText.TextBounds.Y)
                if mouse.X >= tabText.Position.X and mouse.X <= tabText.Position.X + size.X and mouse.Y >= tabText.Position.Y and mouse.Y <= tabText.Position.Y + size.Y then
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
                    local box = createBox(secBox.Position + Vector2.new(5, 20 + #tabContent[name] * 20), Vector2.new(12, 12), Color3.fromRGB(10, 10, 10))
                    local text = createText(label, 13, box.Position + Vector2.new(20, 0))
                    local state = false

                    table.insert(tabContent[name], box)
                    table.insert(tabContent[name], text)

                    uis.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local mouse = uis:GetMouseLocation()
                            if mouse.X >= box.Position.X and mouse.X <= box.Position.X + 12 and mouse.Y >= box.Position.Y and mouse.Y <= box.Position.Y + 12 then
                                state = not state
                                box.Color = state and theme.accent or Color3.fromRGB(10, 10, 10)
                                callback(state)
                            end
                        end
                    end)
                end

                function section:Keybind(label, callback)
                    local bindText = createText(label .. ": NONE", 13, secBox.Position + Vector2.new(5, 40 + #tabContent[name] * 20))
                    local key = nil
                    local binding = false

                    table.insert(tabContent[name], bindText)

                    uis.InputBegan:Connect(function(input)
                        local mouse = uis:GetMouseLocation()
                        local size = bindText.TextBounds
                        local pos = bindText.Position
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and not binding then
                            if mouse.X >= pos.X and mouse.X <= pos.X + size.X and mouse.Y >= pos.Y and mouse.Y <= pos.Y + size.Y then
                                binding = true
                                bindText.Text = label .. ": ..."
                            end
                        elseif binding and input.UserInputType == Enum.UserInputType.Keyboard then
                            binding = false
                            key = input.KeyCode
                            bindText.Text = label .. ": " .. key.Name
                            callback(key)
                        end
                    end)
                end

                return section
            end
        }
    end

    return self
end

return UILibrary -- this is just to test, adding more stuff slowly.
