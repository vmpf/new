return function()
    local watermark = {
        textObjects = {},
        container = nil,
        lastUpdate = 0,
        refreshRate = 0.05, 
    }

    local uis = game:GetService("UserInputService")
    local rs = game:GetService("RunService")
    local stats = game:GetService("Stats")
    local players = game:GetService("Players")

    local function formatDate()
        local date = {os.date('%b', os.time()), os.date('%d', os.time()), os.date('%Y', os.time())}
        local day = tonumber(date[2])
        local suffix = (day == 1 and "st") or (day == 2 and "nd") or (day == 3 and "rd") or "th"
        date[2] = date[2] .. suffix
        return table.concat(date, ", ")
    end

    local function createText(label)
        local txt = Instance.new("TextLabel")
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.new(1, 1, 1)
        txt.Font = Enum.Font.Code
        txt.TextSize = 14
        txt.TextStrokeTransparency = 0.8
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Size = UDim2.new(0, 200, 0, 14)
        txt.Text = label
        txt.Parent = watermark.container
        return txt
    end

    function watermark:Initialize()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "NexusWatermark"
        screenGui.ResetOnSpawn = false
        pcall(function()
            screenGui.Parent = game:GetService("CoreGui")
        end)

        self.container = Instance.new("Frame")
        self.container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        self.container.BorderSizePixel = 0
        self.container.Position = UDim2.new(0, 10, 0, 10)
        self.container.Size = UDim2.new(0, 0, 0, 18)
        self.container.ClipsDescendants = true
        self.container.Parent = screenGui

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 6)
        padding.PaddingRight = UDim.new(0, 6)
        padding.Parent = self.container

        local txt = createText("initializing...")
        table.insert(self.textObjects, txt)

        rs.RenderStepped:Connect(function(dt)
            self.lastUpdate = self.lastUpdate + dt
            if self.lastUpdate >= self.refreshRate then
                self.lastUpdate = 0

                local fps = math.floor(1 / dt)
                local ping = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                local timeStr = os.date("%X", os.time())
                local dateStr = formatDate()
                local username = players.LocalPlayer and players.LocalPlayer.Name or "Unknown"

                local fullText = string.format("nexus.priv | %s | Roblox | %dfps | %dms | %s | %s", username, fps, ping, timeStr, dateStr)
                txt.Text = fullText

                local textSize = game:GetService("TextService"):GetTextSize(fullText, 14, Enum.Font.Code, Vector2.new(1000, 14))
                self.container.Size = UDim2.new(0, textSize.X + 12, 0, 18)
            end
        end)
    end

    return watermark
end
