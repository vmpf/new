return function()
    local watermark = {}
    local RunService = game:GetService("RunService")
    local TextService = game:GetService("TextService")
    local Players = game:GetService("Players")

    local THEME_COLOR = Color3.fromRGB(128, 0, 128)  
    local BACKGROUND_COLOR = Color3.fromRGB(15, 15, 15)  
    local TEXT_COLOR = Color3.fromRGB(255, 255, 255) 
    local outerBorder
    local innerBorder
    local mainFrame
    local headerLine
    local titleText
    local infoText
    
    function watermark:Initialize(title, subtitle)
        self.title = title or "Nexus.Priv"
        self.subtitle = subtitle or Players.LocalPlayer.Name
        self.startTime = tick()
        self.fps = 0
        self.frames = 0
        self.lastUpdate = tick()
        self.visible = true
        self.position = Vector2.new(20, 20)
        self:CreateDrawingObjects()
        RunService.RenderStepped:Connect(function()
            self.frames = self.frames + 1
            if tick() - self.lastUpdate >= 1 then
                self.fps = self.frames
                self.frames = 0
                self.lastUpdate = tick()
            end
        end)
        RunService.RenderStepped:Connect(function()
            if self.visible then
                self:Draw()
            end
        end)
        
        return self
    end
    
    function watermark:CreateDrawingObjects()
        outerBorder = Drawing.new("Square")
        outerBorder.Filled = false
        outerBorder.Thickness = 1
        outerBorder.ZIndex = 9
        outerBorder.Color = THEME_COLOR
        innerBorder = Drawing.new("Square")
        innerBorder.Filled = false
        innerBorder.Thickness = 1
        innerBorder.ZIndex = 10
        innerBorder.Color = Color3.fromRGB(0, 0, 0)
        mainFrame = Drawing.new("Square")
        mainFrame.Filled = true
        mainFrame.Thickness = 0
        mainFrame.ZIndex = 8
        mainFrame.Color = BACKGROUND_COLOR
        mainFrame.Transparency = 0.9
        headerLine = Drawing.new("Square")
        headerLine.Filled = true
        headerLine.Thickness = 0
        headerLine.ZIndex = 11
        headerLine.Color = THEME_COLOR
        headerLine.Transparency = 1
        titleText = Drawing.new("Text")
        titleText.Center = false
        titleText.Outline = false
        titleText.Size = 15
        titleText.Font = 2
        titleText.ZIndex = 12
        titleText.Color = THEME_COLOR
        infoText = Drawing.new("Text")
        infoText.Center = false
        infoText.Outline = false
        infoText.Size = 13
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
    
    function watermark:Draw()
    local ping = math.floor(Players.LocalPlayer:GetNetworkPing() * 1000)
    titleText.Text = self.title
    infoText.Text = string.format("%s | %d fps | %d ms", self.subtitle, self.fps, ping)
    local titleSize = TextService:GetTextSize(titleText.Text, titleText.Size, Enum.Font.SourceSans, Vector2.new(1000, 1000))
    local infoSize = TextService:GetTextSize(infoText.Text, infoText.Size, Enum.Font.SourceSans, Vector2.new(1000, 1000))
    local width = math.max(titleSize.X, infoSize.X) + 20
    local height = titleSize.Y + infoSize.Y + 20

    local headerHeight = titleSize.Y + 6
    mainFrame.Visible = self.visible
    mainFrame.Position = self.position
    mainFrame.Size = Vector2.new(width + 2, height + 2)
    outerBorder.Visible = self.visible
    outerBorder.Position = self.position
    outerBorder.Size = Vector2.new(width + 2, height + 2)
    innerBorder.Visible = self.visible
    innerBorder.Position = self.position + Vector2.new(1, 1)
    innerBorder.Size = Vector2.new(width, height)
    headerLine.Visible = self.visible
    headerLine.Position = self.position + Vector2.new(1, headerHeight)
    headerLine.Size = Vector2.new(width, 1)
    titleText.Visible = self.visible
    titleText.Position = self.position + Vector2.new(10, 3)

    infoText.Visible = self.visible
    infoText.Position = self.position + Vector2.new(10, headerHeight + 5)
    end
    
    function watermark:Destroy()
        if outerBorder then outerBorder:Remove() end
        if innerBorder then innerBorder:Remove() end
        if mainFrame then mainFrame:Remove() end
        if headerLine then headerLine:Remove() end
        if titleText then titleText:Remove() end
        if infoText then infoText:Remove() end
        
        outerBorder = nil
        innerBorder = nil
        mainFrame = nil
        headerLine = nil
        titleText = nil
        infoText = nil
    end
    
    return watermark
end
