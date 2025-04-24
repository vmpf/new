local watermark = {}

function watermark:Initialize(title, subtitle)
    self.title = title or "nexus.priv"
    self.subtitle = subtitle or "Private"
    self.startTime = tick()
    self.fps = 0
    self.frames = 0
    self.lastUpdate = tick()

    game:GetService("RunService").RenderStepped:Connect(function()
        self.frames = self.frames + 1
        if tick() - self.lastUpdate >= 1 then
            self.fps = self.frames
            self.frames = 0
            self.lastUpdate = tick()
        end
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        self:draw()
    end)
end

function watermark:draw()
    local TextService = game:GetService("TextService")
    local pos = Vector2.new(10, 8) -- Closer to top-left
    local time = os.date("%H:%M:%S")
    local text = string.format("%s | %s | FPS: %s | %s", self.title, self.subtitle, self.fps, time)
    local size = TextService:GetTextSize(text, 16, Enum.Font.SourceSans, Vector2.new(9999, 9999))

    local frame = Drawing.new("Square")
    frame.Position = pos - Vector2.new(6, 4)
    frame.Size = size + Vector2.new(12, 8)
    frame.Color = Color3.new(0, 0, 0)
    frame.Filled = true
    frame.Transparency = 0.65
    frame.ZIndex = 2

    local outline = Drawing.new("Square")
    outline.Position = frame.Position
    outline.Size = frame.Size
    outline.Color = Color3.fromRGB(175, 252, 149) -- Matching UI
    outline.Thickness = 1
    outline.Filled = false
    outline.ZIndex = 3

    local textObj = Drawing.new("Text")
    textObj.Text = text
    textObj.Position = pos
    textObj.Size = 16
    textObj.Color = Color3.new(1, 1, 1)
    textObj.Center = false
    textObj.Outline = true
    textObj.Font = 2
    textObj.ZIndex = 4

    task.delay(0.03, function()
        frame:Remove()
        outline:Remove()
        textObj:Remove()
    end)
end

return function() return watermark end
