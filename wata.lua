return function()
    local watermark = {}
    local RunService = game:GetService("RunService")
    local TextService = game:GetService("TextService")
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")

    local THEME_COLOR = Color3.fromRGB(175, 252, 149)
    local BACKGROUND_COLOR = Color3.fromRGB(20, 20, 22)
    local TEXT_COLOR = Color3.fromRGB(255, 255, 255)

    local container
    local backgroundFrame
    local accentLine
    local titleText
    local infoText
    
    function watermark:Initialize(title, subtitle)
        self.title = title or "nexus.priv"
        self.subtitle = subtitle or Players.LocalPlayer.Name
        self.startTime = tick()
        self.fps = 0
        self.frames = 0
        self.lastUpdate = tick()
        self.visible = true
        self.position = Vector2.new(20, 20)
        self.animationProgress = 0

        self:CreateDrawingObjects()

        RunService.RenderStepped:Connect(function()
            self.frames = self.frames + 1
            if tick() - self.lastUpdate >= 1 then
                self.fps = self.frames
                self.frames = 0
                self.lastUpdate = tick()
            end
        end)

        RunService.RenderStepped:Connect(function(deltaTime)
            if self.visible then
                self.animationProgress = math.min(1, self.animationProgress + deltaTime * 3)
            else
                self.animationProgress = math.max(0, self.animationProgress - deltaTime * 3)
            end
            
            if self.animationProgress > 0 then
                self:Draw(self.animationProgress)
            end
        end)
        
        return self
    end
    
    function watermark:CreateDrawingObjects()
        container = {
            Position = self.position,
            Size = Vector2.new(0, 0)
        }

        backgroundFrame = Drawing.new("Square")
        backgroundFrame.Filled = true
        backgroundFrame.Thickness = 0
        backgroundFrame.ZIndex = 10
        backgroundFrame.Color = BACKGROUND_COLOR
        backgroundFrame.Transparency = 0.85

        accentLine = Drawing.new("Square")
        accentLine.Filled = true
        accentLine.Thickness = 0
        accentLine.ZIndex = 11
        accentLine.Color = THEME_COLOR

        titleText = Drawing.new("Text")
        titleText.Center = false
        titleText.Outline = false
        titleText.Size = 16
        titleText.Font = 2
        titleText.ZIndex = 12
        titleText.Color = THEME_COLOR

        infoText = Drawing.new("Text")
        infoText.Center = false
        infoText.Outline = false
        infoText.Size = 15
        infoText.Font = 2
        infoText.ZIndex = 12
        infoText.Color = TEXT_COLOR
    end
    
    function watermark:SetVisible(visible)
        self.visible = visible
    end
    
    function watermark:SetPosition(position)
        self.position = position
    end
    
    function watermark:Draw(alpha)
        local time = os.date("%H:%M:%S")
        local ping = math.floor(Players.LocalPlayer:GetNetworkPing() * 1000)

        titleText.Text = self.title
        infoText.Text = string.format("%s | %d fps | %d ms | %s", self.subtitle, self.fps, ping, time)

        local titleSize = TextService:GetTextSize(titleText.Text, titleText.Size, Enum.Font.SourceSans, Vector2.new(1000, 1000))
        local infoSize = TextService:GetTextSize(infoText.Text, infoText.Size, Enum.Font.SourceSans, Vector2.new(1000, 1000))
        local width = math.max(titleSize.X, infoSize.X) + 25
        local height = titleSize.Y + infoSize.Y + 15
        

        container.Position = self.position
        container.Size = Vector2.new(width, height)
        

        local transparency = 1 * alpha
        local offset = (1 - alpha) * 20

        backgroundFrame.Visible = alpha > 0
        backgroundFrame.Transparency = 0.85 * alpha
        backgroundFrame.Position = container.Position + Vector2.new(offset, 0)
        backgroundFrame.Size = container.Size
        backgroundFrame.Transparency = transparency * 0.85
        local cornerRadius = 4
        backgroundFrame.Position = container.Position + Vector2.new(offset, 0)
        backgroundFrame.Size = container.Size
        
        -- Update accent line (top line)
        accentLine.Visible = alpha > 0
        accentLine.Position = container.Position + Vector2.new(offset, 0)
        accentLine.Size = Vector2.new(container.Size.X, 2)
        accentLine.Transparency = transparency
        
        -- Update text positions
        titleText.Visible = alpha > 0
        titleText.Position = container.Position + Vector2.new(offset + 10, 7)
        titleText.Transparency = transparency
        
        infoText.Visible = alpha > 0
        infoText.Position = container.Position + Vector2.new(offset + 10, titleSize.Y + 7)
        infoText.Transparency = transparency
    end
    
    function watermark:Destroy()
        if backgroundFrame then backgroundFrame:Remove() end
        if accentLine then accentLine:Remove() end
        if titleText then titleText:Remove() end
        if infoText then infoText:Remove() end
        
        backgroundFrame = nil
        accentLine = nil
        titleText = nil
        infoText = nil
    end
    
    return watermark
end
