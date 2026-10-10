-- [[ ⚡ MAX Hub v1.8.1 - GOLD EDITION ]]
if getgenv().MAXHubCleanup then pcall(getgenv().MAXHubCleanup) end
do
    local cg = game:GetService("CoreGui")
    for _, n in ipairs({ "MAXHub", "MAXHubIconGui", "MAXHubStats" }) do
        local g = cg:FindFirstChild(n)
        if g then g:Destroy() end
    end
end

local RUN = { conns = {}, cleanups = {} }
RUN.id = (getgenv().MAXHubRunId or 0) + 1
getgenv().MAXHubRunId = RUN.id
function RUN.alive() return getgenv().MAXHubRunId == RUN.id end
function RUN.track(c) table.insert(RUN.conns, c) return c end
getgenv().MAXHubLoaded = true
getgenv().AutoEndRound = false getgenv().AutoReset = false
getgenv().PlayerESPEnabled = false getgenv().RoleESPEnabled = false getgenv().GunESPEnabled = false getgenv().AutoGrabGun = false getgenv().AutoFarmEnabled = false getgenv().AutoShotEnabled = false getgenv().KillAuraEnabled = false getgenv().FlyEnabled = false getgenv().NoClipEnabled = false getgenv().AntiFlingEnabled = false getgenv().FullbrightEnabled = false getgenv().RainbowUIEnabled = false getgenv().GlassModeEnabled = false getgenv().AngelAuraEnabled = false getgenv().InfiniteJumpsEnabled = false

local Players = game:GetService("Players") local TweenService = game:GetService("TweenService") local UserInputService = game:GetService("UserInputService") local RunService = game:GetService("RunService") local HttpService = game:GetService("HttpService") local Lighting = game:GetService("Lighting") local LocalPlayer = Players.LocalPlayer local Camera = workspace.CurrentCamera
local onlineItems = {} local isLoaded = false local grabDebounce = false
local apiBase = "https://685dd885-32bd-4a4c-a712-8898791ea1cb-00-melrwd2vbenf.sisko.replit.dev/api"
local defaultWalkSpeed = 16 local defaultJumpPower = 50 getgenv().CurrentCustomSpeed = defaultWalkSpeed getgenv().CurrentCustomJump = defaultJumpPower getgenv().SpeedAndJumpLoop = true
local origAmbient = Lighting.Ambient local origOutdoorAmbient = Lighting.OutdoorAmbient local origBrightness = Lighting.Brightness local origFogEnd = Lighting.FogEnd

getgenv().MAXHubCleanup = function()
    getgenv().MAXHubRunId = (getgenv().MAXHubRunId or 0) + 1
    for _, c in ipairs(RUN.conns) do pcall(function() c:Disconnect() end) end
    table.clear(RUN.conns)

    if getgenv().InfiniteJumpConn then
        pcall(function() getgenv().InfiniteJumpConn:Disconnect() end)
        getgenv().InfiniteJumpConn = nil
    end
    local st = getgenv().MAXState
    if st then
        for _, k in ipairs({ "noclipConn", "flyConn" }) do
            if st[k] then pcall(function() st[k]:Disconnect() end) st[k] = nil end
        end
        st.farmPaused = false
        st.erRun = (st.erRun or 0) + 1
    end

    for _, fn in ipairs(RUN.cleanups) do pcall(fn) end

    for _, p in ipairs(Players:GetPlayers()) do
        local ch = p.Character
        if ch then
            for _, n in ipairs({ "MAXHubHighlight", "MAXHubBillboard" }) do
                local o = ch:FindFirstChild(n)
                if o then o:Destroy() end
            end
        end
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "GunMAXHighlight" then v:Destroy() end
    end

    pcall(function()
        Lighting.Ambient = origAmbient
        Lighting.OutdoorAmbient = origOutdoorAmbient
        Lighting.Brightness = origBrightness
        Lighting.FogEnd = origFogEnd
    end)
    local c = LocalPlayer.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
        hum.WalkSpeed = defaultWalkSpeed
        hum.JumpPower = defaultJumpPower
    end

    local cg = game:GetService("CoreGui")
    for _, n in ipairs({ "MAXHub", "MAXHubIconGui", "MAXHubStats" }) do
        local g = cg:FindFirstChild(n)
        if g then g:Destroy() end
    end
end

task.spawn(function() while getgenv().SpeedAndJumpLoop and RUN.alive() do task.wait(0.3) local c=LocalPlayer.Character local h=c and c:FindFirstChildOfClass("Humanoid") if h then if not h.UseJumpPower then h.UseJumpPower=true end if h.WalkSpeed~=getgenv().CurrentCustomSpeed and getgenv().CurrentCustomSpeed~=defaultWalkSpeed then h.WalkSpeed=getgenv().CurrentCustomSpeed end if h.JumpPower~=getgenv().CurrentCustomJump and getgenv().CurrentCustomJump~=defaultJumpPower then h.JumpPower=getgenv().CurrentCustomJump end end if getgenv().FullbrightEnabled then Lighting.Ambient=Color3.fromRGB(255,255,255) Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255) Lighting.Brightness=2 Lighting.FogEnd=999999 end end end)

task.spawn(function() while RUN.alive() and task.wait(0.1) do if getgenv().AntiFlingEnabled then local c = LocalPlayer.Character local hrp = c and c:FindFirstChild("HumanoidRootPart") if hrp then local vel = hrp.Velocity if vel.Magnitude > 500 then hrp.Velocity = Vector3.new(0, 0, 0) hrp.RotVelocity = Vector3.new(0, 0, 0) end end end end end)

pcall(function() setfpscap(60) end)
task.spawn(function() local vu = game:GetService("VirtualUser") RUN.track(LocalPlayer.Idled:Connect(function() vu:CaptureController() vu:ClickButton2(Vector2.new()) end)) end)
getgenv().InfiniteJumpConn = nil
local function toggleInfiniteJump(v)
    getgenv().InfiniteJumpsEnabled = v
    if getgenv().InfiniteJumpConn then getgenv().InfiniteJumpConn:Disconnect() getgenv().InfiniteJumpConn = nil end
    if v then
        getgenv().InfiniteJumpConn = UserInputService.JumpRequest:Connect(function()
            if getgenv().InfiniteJumpsEnabled then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end

local OrionLib=(function() local Orion={} local TS=game:GetService("TweenService") local CG=game:GetService("CoreGui") local OrionGui=Instance.new("ScreenGui") OrionGui.Name="MAXHub" OrionGui.Parent=CG OrionGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
local Accent=Color3.fromRGB(100,150,255) local Bg=Color3.fromRGB(25,25,30) local Panel=Color3.fromRGB(32,32,38) local Elem=Color3.fromRGB(40,40,46) local Text=Color3.fromRGB(220,220,220) local TextDim=Color3.fromRGB(140,140,150)
local ObjectsToColor={} local function Corner(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 6) c.Parent=p return c end
function Orion:ChangeThemeColor(newColor) Accent=newColor for obj,prop in pairs(ObjectsToColor) do if obj and obj.Parent then obj[prop]=newColor else ObjectsToColor[obj]=nil end end end
function Orion:GetAccent() return Accent end
function Orion:MakeNotification(Cfg) task.spawn(function() local N=Instance.new("Frame") N.Parent=OrionGui N.BackgroundColor3=Panel N.BorderSizePixel=0 N.Position=UDim2.new(0.5,0,-0.1,0) N.AnchorPoint=Vector2.new(0.5,0) N.Size=UDim2.new(0,300,0,60) Corner(N,8) local S=Instance.new("Frame") S.Parent=N S.BackgroundColor3=Accent S.BorderSizePixel=0 S.Size=UDim2.new(0,4,1,0) ObjectsToColor[S]="BackgroundColor3" local T=Instance.new("TextLabel") T.Parent=N T.BackgroundTransparency=1 T.Size=UDim2.new(1,-20,0,18) T.Position=UDim2.new(0,14,0,8) T.Font=Enum.Font.GothamBold T.Text=Cfg.Name or "MAX Hub" T.TextColor3=Text T.TextSize=14 local C=Instance.new("TextLabel") C.Parent=N C.BackgroundTransparency=1 C.Size=UDim2.new(1,-20,0,20) C.Position=UDim2.new(0,14,0,30) C.Font=Enum.Font.Gotham C.Text=Cfg.Content or "" C.TextColor3=TextDim C.TextSize=12 TS:Create(N,TweenInfo.new(0.3),{Position=UDim2.new(0.5,0,0.05,0)}):Play() task.wait(Cfg.Time or 3) local o=TS:Create(N,TweenInfo.new(0.3),{Position=UDim2.new(0.5,0,-0.1,0)}) o:Play() o.Completed:Wait() N:Destroy() end) end
local function MakeDraggable(handle, target)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            local endConn
            endConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    endConn:Disconnect()
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    RUN.track(UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local d = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
end
function Orion:MakeWindow(Cfg) local W={} local M=Instance.new("Frame") M.Name="MainWindow" M.Parent=OrionGui M.BackgroundColor3=Bg M.BorderSizePixel=0 M.Position=UDim2.new(0.5,-240,0.5,-180) M.Size=UDim2.new(0,480,0,360) M.Active=true M.ClipsDescendants=true Corner(M,10) local BgImage=Instance.new("ImageLabel") BgImage.Name="CustomBackground" BgImage.Parent=M BgImage.BackgroundTransparency=1 BgImage.Size=UDim2.new(1,0,1,0) BgImage.Position=UDim2.new(0,0,0,0) BgImage.Image="rbxassetid://131110531238687" BgImage.ImageTransparency=0.35 BgImage.ZIndex=0 BgImage.ScaleType=Enum.ScaleType.Crop local H=Instance.new("Frame") H.Parent=M H.BackgroundColor3=Panel H.BorderSizePixel=0 H.Size=UDim2.new(1,0,0,32) Corner(H,10) H.ZIndex=2 MakeDraggable(H,M) local Title=Instance.new("TextLabel") Title.Parent=H Title.BackgroundTransparency=1 Title.Size=UDim2.new(1,-10,1,0) Title.Position=UDim2.new(0,12,0,0) Title.Font=Enum.Font.GothamBold Title.Text=Cfg.Name or "MAX Hub" Title.TextColor3=Text Title.TextSize=14 Title.ZIndex=3 local S=Instance.new("Frame") S.Name="SidePanel" S.Parent=M S.BackgroundColor3=Panel S.BackgroundTransparency=0.2 S.BorderSizePixel=0 S.Position=UDim2.new(0,0,0,32) S.Size=UDim2.new(0,130,1,-32) S.ZIndex=2 local SL=Instance.new("UIListLayout") SL.Parent=S SL.SortOrder=Enum.SortOrder.LayoutOrder SL.Padding=UDim.new(0,2) local CT=Instance.new("Frame") CT.Name="ContainerPanel" CT.Parent=M CT.BackgroundTransparency=1 CT.BorderSizePixel=0 CT.Position=UDim2.new(0,130,0,32) CT.Size=UDim2.new(1,-130,1,-32) CT.ZIndex=2 local Tabs={}
function W:MakeTab(TC) local NT={} local B=Instance.new("TextButton") B.Parent=S B.BackgroundColor3=Panel B.BorderSizePixel=0 B.Size=UDim2.new(1,-8,0,32) B.Position=UDim2.new(0,4,0,0) B.Font=Enum.Font.Gotham B.Text="  "..(TC.Name or "Tab") B.TextColor3=TextDim B.TextSize=13 B.TextXAlignment=Enum.TextXAlignment.Left B.ZIndex=3 Corner(B,6) local P=Instance.new("ScrollingFrame") P.Parent=CT P.BackgroundTransparency=1 P.Size=UDim2.new(1,-10,1,-10) P.Position=UDim2.new(0,5,0,5) P.Visible=false P.ScrollBarThickness=2 P.CanvasSize=UDim2.new(0,0,0,0) P.ZIndex=3 local PL=Instance.new("UIListLayout") PL.Parent=P PL.SortOrder=Enum.SortOrder.LayoutOrder PL.Padding=UDim.new(0,5) PL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() P.CanvasSize=UDim2.new(0,0,0,PL.AbsoluteContentSize.Y+15) end) B.MouseButton1Click:Connect(function() for _,t in pairs(Tabs) do t.P.Visible=false t.B.BackgroundColor3=Panel t.B.TextColor3=TextDim ObjectsToColor[t.B]=nil end P.Visible=true B.BackgroundColor3=Accent B.TextColor3=Color3.fromRGB(255,255,255) ObjectsToColor[B]="BackgroundColor3" end) table.insert(Tabs,{B=B,P=P}) if #Tabs==1 then P.Visible=true B.BackgroundColor3=Accent B.TextColor3=Color3.fromRGB(255,255,255) ObjectsToColor[B]="BackgroundColor3" end
function NT:AddButton(BC) local Bt=Instance.new("TextButton") Bt.Parent=P Bt.BackgroundColor3=Elem Bt.BorderSizePixel=0 Bt.Size=UDim2.new(1,-4,0,30) Bt.Font=Enum.Font.Gotham Bt.Text=BC.Name or "Button" Bt.TextColor3=Text Bt.TextSize=13 Bt.ZIndex=4 Corner(Bt,6) Bt.MouseButton1Click:Connect(function() if BC.Callback then BC.Callback() end end) end
function NT:AddToggle(TC) local TF=Instance.new("Frame") TF.Parent=P TF.BackgroundColor3=Elem TF.BorderSizePixel=0 TF.Size=UDim2.new(1,-4,0,30) TF.ZIndex=4 Corner(TF,6) local L=Instance.new("TextLabel") L.Parent=TF L.BackgroundTransparency=1 L.Size=UDim2.new(1,-50,1,0) L.Position=UDim2.new(0,10,0,0) L.Font=Enum.Font.Gotham L.Text=TC.Name or "Toggle" L.TextColor3=Text L.TextSize=13 L.TextXAlignment=Enum.TextXAlignment.Left L.ZIndex=4 local Sw=Instance.new("Frame") Sw.Parent=TF Sw.BackgroundColor3=Color3.fromRGB(60,60,65) Sw.BorderSizePixel=0 Sw.Position=UDim2.new(1,-36,0.5,-7) Sw.Size=UDim2.new(0,26,0,14) Sw.ZIndex=4 Corner(Sw,7) local Dt=Instance.new("Frame") Dt.Parent=Sw Dt.BackgroundColor3=Color3.fromRGB(255,255,255) Dt.BorderSizePixel=0 Dt.Position=UDim2.new(0,2,0,2) Dt.Size=UDim2.new(0,10,0,10) Dt.ZIndex=4 Corner(Dt,5) local a=TC.Default or false local function Upd() if a then Sw.BackgroundColor3=Accent Dt:TweenPosition(UDim2.new(1,-12,0,2),"Out","Quart",0.2) ObjectsToColor[Sw]="BackgroundColor3" else Sw.BackgroundColor3=Color3.fromRGB(60,60,65) Dt:TweenPosition(UDim2.new(0,2,0,2),"Out","Quart",0.2) ObjectsToColor[Sw]=nil end end Upd() TF.InputBegan:Connect(function(i) if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then a=not a Upd() if TC.Callback then TC.Callback(a) end end end) end
function NT:AddLabel(LC) local L=Instance.new("TextLabel") L.Parent=P L.BackgroundTransparency=1 L.Size=UDim2.new(1,-4,0,20) L.Font=Enum.Font.Gotham L.Text=LC.Text or "" L.TextColor3=TextDim L.TextSize=11 L.ZIndex=4 return L end
function NT:AddTextbox(BC) local BF=Instance.new("Frame") BF.Parent=P BF.BackgroundColor3=Elem BF.BorderSizePixel=0 BF.Size=UDim2.new(1,-4,0,44) BF.ZIndex=4 Corner(BF,6) local BL=Instance.new("TextLabel") BL.Parent=BF BL.BackgroundTransparency=1 BL.Size=UDim2.new(1,0,0,16) BL.Position=UDim2.new(0,8,0,3) BL.Font=Enum.Font.Gotham BL.Text=BC.Name or "Textbox" BL.TextColor3=TextDim BL.TextSize=11 BL.TextXAlignment=Enum.TextXAlignment.Left BL.ZIndex=4 local BX=Instance.new("TextBox") BX.Parent=BF BX.BackgroundColor3=Color3.fromRGB(30,30,35) BX.BorderSizePixel=0 BX.Size=UDim2.new(1,-16,0,18) BX.Position=UDim2.new(0,8,0,21) BX.Font=Enum.Font.Gotham BX.PlaceholderText=BC.Placeholder or "" BX.Text="" BX.TextColor3=Text BX.TextSize=12 BX.TextXAlignment=Enum.TextXAlignment.Left BX.ZIndex=4 Corner(BX,4) BX.FocusLost:Connect(function(ep) if BC.Callback then BC.Callback(BX.Text,ep) end end) return BX end return NT end return W end function Orion:Init() end return Orion end)()

local Window=OrionLib:MakeWindow({Name="⚡ MAX Hub v1.8.1 🎂"}) OrionLib:Init() local MainTab=Window:MakeTab({Name="Main"}) local VisualsTab=Window:MakeTab({Name="Visuals"}) local ValuesTab=Window:MakeTab({Name="Values"}) local TradeTab=Window:MakeTab({Name="Trade"}) local SettingsTab=Window:MakeTab({Name="Settings"})

-- ==============================================
-- LIQUID GLASS MODE 2.1
-- ==============================================
local glassConnection = nil
local hoverConnections = {}
RUN.cleanups[#RUN.cleanups+1] = function()
    if glassConnection then glassConnection:Disconnect() glassConnection = nil end
    for _, conn in ipairs(hoverConnections) do pcall(function() conn:Disconnect() end) end
    hoverConnections = {}
end
local function applyGlassMode(enabled)
    getgenv().GlassModeEnabled = enabled
    local mainWin = nil
    local coreGui = game:GetService("CoreGui")
    for _, gui in ipairs(coreGui:GetChildren()) do
        if gui.Name == "MAX Hub" or gui.Name == "MAXHub" then
            mainWin = gui:FindFirstChild("MainWindow")
            break
        end
    end
    if not mainWin then OrionLib:MakeNotification({Name="MAX Hub", Content="Window not found!", Time=2}) return end
    local existingStroke = mainWin:FindFirstChild("GlassStroke")
    local existingGrad = mainWin:FindFirstChild("GlassGradient")
    if glassConnection then glassConnection:Disconnect() glassConnection = nil end
    if enabled then
        TweenService:Create(mainWin, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {BackgroundTransparency = 0.15}):Play()
        if not existingStroke then
            local stroke = Instance.new("UIStroke")
            stroke.Name = "GlassStroke" stroke.Color = Color3.fromRGB(100, 150, 255) stroke.Thickness = 0 stroke.Transparency = 0.2 stroke.Parent = mainWin
            TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Thickness = 1.5}):Play()
        end
        if not existingGrad then
            local grad = Instance.new("UIGradient")
            grad.Name = "GlassGradient"
            grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 25, 55)), ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 30, 75))})
            grad.Rotation = 45 grad.Parent = mainWin
        end
        local pulsePhase = 0
        glassConnection = RunService.RenderStepped:Connect(function(dt)
            if not existingStroke and mainWin then existingStroke = mainWin:FindFirstChild("GlassStroke") end
            if existingStroke and existingStroke.Parent then
                pulsePhase = pulsePhase + dt * 2
                local pulse = (math.sin(pulsePhase) + 1) / 2
                existingStroke.Color = Color3.fromHSV(0.6, 0.8, 0.7 + pulse * 0.3)
                existingStroke.Transparency = 0.4 - pulse * 0.25
            end
        end)
        for _, gui in ipairs(coreGui:GetChildren()) do
            if gui.Name == "MAX Hub" or gui.Name == "MAXHub" then
                for _, btn in ipairs(gui:GetDescendants()) do
                    if btn:IsA("TextButton") and not btn:GetAttribute("GlassHover") then
                        btn:SetAttribute("GlassHover", true)
                        local enterConn = btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play() end)
                        local leaveConn = btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play() end)
                        table.insert(hoverConnections, enterConn) table.insert(hoverConnections, leaveConn)
                    end
                end
            end
        end
        mainWin.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(mainWin, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 480, 0, 360)}):Play()
        OrionLib:MakeNotification({Name="MAX Hub", Content="✦ Liquid Glass Mode ON ✦", Time=2})
    else
        TweenService:Create(mainWin, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        if existingStroke then local s = existingStroke TweenService:Create(s, TweenInfo.new(0.3), {Thickness = 0}):Play() task.delay(0.35, function() if s and s.Parent then s:Destroy() end end) end
        if existingGrad then existingGrad:Destroy() end
        for _, conn in ipairs(hoverConnections) do if conn then conn:Disconnect() end end
        hoverConnections = {}
        OrionLib:MakeNotification({Name="MAX Hub", Content="Lite Mode", Time=2})
    end
end

-- ==============================================
-- 👼 ANGEL AURA (GOLD WINGS + THEME SYNC)
-- ==============================================
local auraConnection = nil
local auraParticles = {}
local auraBeams = {}
local auraAttachments = {}
local wingColorConnection = nil

local function getWingColor()
    if getgenv().RainbowUIEnabled then
        return Color3.fromHSV((tick() * 0.2) % 1, 1, 1)
    else
        return OrionLib:GetAccent() or Color3.fromRGB(255, 215, 100)
    end
end

local function updateWingColors()
    local color = getWingColor()
    for _, beam in ipairs(auraBeams) do
        if beam and beam.Parent then
            beam.Color = ColorSequence.new(color, color)
        end
    end
end

local function createAngelAura()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if auraConnection then auraConnection:Disconnect() auraConnection = nil end
    if wingColorConnection then wingColorConnection:Disconnect() wingColorConnection = nil end
    for _, obj in ipairs(auraBeams) do if obj and obj.Parent then obj:Destroy() end end
    for _, obj in ipairs(auraAttachments) do if obj and obj.Parent then obj:Destroy() end end
    auraBeams = {} auraAttachments = {}
    
    local goldColor = Color3.fromRGB(255, 215, 100)
    local positions = {
        {Vector3.new(1.5, 1.5, 1), Vector3.new(4, 3, 1)},
        {Vector3.new(1.5, 1, 1), Vector3.new(4.5, 1.5, 1)},
        {Vector3.new(1.5, 0.5, 1), Vector3.new(3.5, 0, 1)}
    }
    for side = -1, 1, 2 do
        for i, pos in ipairs(positions) do
            local a1 = Instance.new("Attachment", hrp)
            a1.Position = Vector3.new(side * pos[1].X, pos[1].Y, pos[1].Z)
            table.insert(auraAttachments, a1)
            local a2 = Instance.new("Attachment", hrp)
            a2.Position = Vector3.new(side * pos[2].X, pos[2].Y, pos[2].Z)
            table.insert(auraAttachments, a2)
            local beam = Instance.new("Beam")
            beam.Attachment0 = a1 beam.Attachment1 = a2
            beam.Width0 = 1.5 beam.Width1 = 0.3
            beam.Color = ColorSequence.new(goldColor, goldColor)
            beam.Transparency = NumberSequence.new(0.4)
            beam.LightEmission = 1 beam.FaceCamera = true
            beam.Parent = hrp
            table.insert(auraBeams, beam)
        end
    end
    
    -- Пульсация + синхронизация с темой
    local pulsePhase = 0
    auraConnection = RunService.Heartbeat:Connect(function(dt)
        if not char or not char.Parent then
            if auraConnection then auraConnection:Disconnect() auraConnection = nil end
            if wingColorConnection then wingColorConnection:Disconnect() wingColorConnection = nil end
            for _, obj in ipairs(auraBeams) do if obj and obj.Parent then obj:Destroy() end end
            for _, obj in ipairs(auraAttachments) do if obj and obj.Parent then obj:Destroy() end end
            auraBeams = {} auraAttachments = {}
            return
        end
        pulsePhase = pulsePhase + dt * 2
        local pulse = (math.sin(pulsePhase) + 1) / 2
        local baseColor = getWingColor()
        local pulsedColor = baseColor:Lerp(Color3.new(1,1,1), pulse * 0.3)
        for _, beam in ipairs(auraBeams) do
            if beam and beam.Parent then
                beam.Color = ColorSequence.new(pulsedColor, pulsedColor)
            end
        end
    end)
    
    -- Обновление цвета при смене темы
    wingColorConnection = RunService.RenderStepped:Connect(function()
        if getgenv().RainbowUIEnabled then
            local rainbowColor = Color3.fromHSV((tick() * 0.2) % 1, 1, 1)
            for _, beam in ipairs(auraBeams) do
                if beam and beam.Parent then
                    beam.Color = ColorSequence.new(rainbowColor, rainbowColor)
                end
            end
        end
    end)
end

local function removeAngelAura()
    if auraConnection then auraConnection:Disconnect() auraConnection = nil end
    if wingColorConnection then wingColorConnection:Disconnect() wingColorConnection = nil end
    for _, obj in ipairs(auraBeams) do if obj and obj.Parent then obj:Destroy() end end
    for _, obj in ipairs(auraAttachments) do if obj and obj.Parent then obj:Destroy() end end
    auraBeams = {} auraAttachments = {}
end

RUN.cleanups[#RUN.cleanups+1] = removeAngelAura

ValuesTab:AddLabel({Text="💎 VALUES"}) local StatusLabel=ValuesTab:AddLabel({Text="Click Sync"}) local ResultLabel=ValuesTab:AddLabel({Text=" "})
local function syncPrices() StatusLabel.Text="Syncing..." task.spawn(function() local s,r=pcall(function() return game:HttpGet(apiBase.."/values") end) if s and r then local s2,d=pcall(function() return HttpService:JSONDecode(r) end) if s2 and d then onlineItems={} local count=0 if d.items and type(d.items)=="table" then for k,v in pairs(d.items) do if type(v)=="table" and v.name then onlineItems[k:lower()]=v count=count+1 end end isLoaded=true StatusLabel.Text="✅ "..count.." skins!" elseif type(d)=="table" then for k,v in pairs(d) do if type(v)=="table" and v.name then onlineItems[k:lower()]=v count=count+1 end end isLoaded=true StatusLabel.Text="✅ "..count.." skins!" else StatusLabel.Text="❌ Format" end else StatusLabel.Text="❌ JSON" end else StatusLabel.Text="❌ Offline" end end) end
ValuesTab:AddButton({Name="Sync",Callback=syncPrices}) ValuesTab:AddTextbox({Name="Search",Placeholder="chroma fang...",Callback=function(t,ep) if not ep or t=="" then return end local q=t:lower():gsub(" ",""):gsub("'","") if isLoaded and onlineItems[q] then ResultLabel.Text="🎯 "..onlineItems[q].name.." | "..onlineItems[q].supreme return end if isLoaded then for k,i in pairs(onlineItems) do if k:find(q) or (i.name and i.name:lower():find(t:lower())) then ResultLabel.Text="🎯 "..i.name.." | "..i.supreme return end end end ResultLabel.Text="❌" end}) task.delay(math.random() * 5, syncPrices)

TradeTab:AddLabel({Text="💱 TRADE"}) local TradeResultLabel=TradeTab:AddLabel({Text=" "})
local function getItemValue(n, tag)
    if not n then return 0, "?" end
    local function norm(s) return (tostring(s):lower():gsub("[%s']", "")) end
    local cn = norm(n)

    local function cv(v)
        if not v then return 0 end
        if type(v) == "number" then return v end
        local digits = (tostring(v):gsub("%D", ""))
        return tonumber(digits) or 0
    end

    if not isLoaded then return 0, n end

    if tag == "FX" then
        local it = onlineItems["chroma" .. cn]
        if it then return cv(it.supreme), it.name end
    end

    local it = onlineItems[cn]
    if it then return cv(it.supreme), it.name end

    local best, bestLen
    for k, i in pairs(onlineItems) do
        if type(i) == "table" and i.name
            and (k:find(cn, 1, true) or norm(i.name):find(cn, 1, true)) then
            if not bestLen or #k < bestLen then best, bestLen = i, #k end
        end
    end
    if best then return cv(best.supreme), best.name end
    return 0, n
end
local function scanTrade() TradeResultLabel.Text="" task.wait(0.05) if not isLoaded then TradeResultLabel.Text="❌ Sync!" return end TradeResultLabel.Text="Scanning..." task.spawn(function() local pg=LocalPlayer:FindFirstChild("PlayerGui") local tg=pg and (pg:FindFirstChild("TradeGUI") or pg:FindFirstChild("TradeGUI_Phone")) if not tg then TradeResultLabel.Text="❌ No trade!" return end local tr=tg:FindFirstChild("Container") and tg.Container:FindFirstChild("Trade") if not tr then TradeResultLabel.Text="❌ Error!" return end local yf=tr:FindFirstChild("YourOffer") local tff=tr:FindFirstChild("TheirOffer") if not yf or not tff then TradeResultLabel.Text="❌ Slots!" return end local mt,tt=0,0 local ml,tl={},{} local yc=yf:FindFirstChild("Slots") or yf local tc=tff:FindFirstChild("Slots") or tff for _,s in ipairs(yc:GetChildren()) do if s:IsA("Frame") and s.Name=="Container" then local iname=nil local tag=nil for _,c in ipairs(s:GetDescendants()) do if c.Name=="Label" and c.Text~="" and c.Text~="Loading" and c.Text~=".." then iname=c.Text end if c.Name=="TagName" and c.Text~="" then tag=c.Text end end if iname then local v,cn=getItemValue(iname,tag) mt=mt+v table.insert(ml,cn..": "..v) end end end for _,s in ipairs(tc:GetChildren()) do if s:IsA("Frame") and s.Name=="Container" then local iname=nil local tag=nil for _,c in ipairs(s:GetDescendants()) do if c.Name=="Label" and c.Text~="" and c.Text~="Loading" and c.Text~=".." then iname=c.Text end if c.Name=="TagName" and c.Text~="" then tag=c.Text end end if iname then local v,cn=getItemValue(iname,tag) tt=tt+v table.insert(tl,cn..": "..v) end end end local rp="YOU: "..mt.." | THEM: "..tt if mt>tt then rp=rp.." | ❌ -"..(mt-tt) elseif tt>mt then rp=rp.." | ✅ +"..(tt-mt) else rp=rp.." | 🤝" end TradeResultLabel.TextWrapped = true
TradeResultLabel.TextYAlignment = Enum.TextYAlignment.Top
TradeResultLabel.Text = rp .. "\n\nYOU:\n" .. table.concat(ml, "\n") .. "\n\nTHEM:\n" .. table.concat(tl, "\n")
TradeResultLabel.Size = UDim2.new(1, -4, 0, 15 * (#ml + #tl + 6)) end) end
TradeTab:AddButton({Name="Scan",Callback=scanTrade})

local function smoothTeleport(tgt) local c=LocalPlayer.Character local h=c and c:FindFirstChild("HumanoidRootPart") if not h then return end local tw=TweenService:Create(h,TweenInfo.new(math.clamp((h.Position-tgt.Position).Magnitude/25,0.3,4),Enum.EasingStyle.Linear),{CFrame=tgt}) tw:Play() return tw end
local function teleportToLobby() local c=LocalPlayer.Character local h=c and c:FindFirstChild("HumanoidRootPart") if not h then return end local l=workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("LobbyWorkspace") if l then local s=l:FindFirstChildWhichIsA("SpawnLocation") or l:FindFirstChild("Spawn") or l:FindFirstChildWhichIsA("BasePart") if s then smoothTeleport(s.CFrame+Vector3.new(0,4,0)) return end end smoothTeleport(CFrame.new(-108,134,-12)) end

local function gmh()
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LocalPlayer then continue end
        local pc=p.Character
        local pb=p:FindFirstChild("Backpack")
        if pc and (pc:FindFirstChild("Knife") or (pb and pb:FindFirstChild("Knife"))) then
            local h=pc:FindFirstChild("Head")
            if h then return h,pc end
        end
    end
    return nil,nil
end
local function iv(h,tc) if not h or not tc then return false end local o=Camera.CFrame.Position local d=(h.Position-o).Unit*500 local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Exclude rp.FilterDescendantsInstances={LocalPlayer.Character,tc} local rr=workspace:Raycast(o,d,rp) return not (rr and rr.Instance and rr.Instance.CanCollide and not rr.Instance:IsDescendantOf(tc)) end
local function autoShotFire() local c=LocalPlayer.Character local t=c and c:FindFirstChildOfClass("Tool") if not t or t.Name~="Gun" then return end local h,tc=gmh() if not h then return end if iv(h,tc) then local handle=t:FindFirstChild("Handle") if handle then local oldCFrame=handle.CFrame handle.CFrame=CFrame.new(handle.Position,h.Position) t:Activate() task.defer(function() if handle and handle.Parent then handle.CFrame=oldCFrame end end) else t:Activate() end end end

local function applyHighlight(p,c,en) local ch=p.Character if not ch then return end local hl=ch:FindFirstChild("MAXHubHighlight") local bgui=ch:FindFirstChild("MAXHubBillboard") if not en then if hl then hl:Destroy() end if bgui then bgui:Destroy() end return end if not hl then hl=Instance.new("Highlight") hl.Name="MAXHubHighlight" hl.OutlineColor=Color3.new(1,1,1) hl.OutlineTransparency=0.2 hl.FillTransparency=0.6 hl.Parent=ch end hl.FillColor=c local hrp=ch:FindFirstChild("HumanoidRootPart") if not hrp then return end if not bgui then bgui=Instance.new("BillboardGui") bgui.Name="MAXHubBillboard" bgui.Size=UDim2.new(0,160,0,40) bgui.AlwaysOnTop=true bgui.ExtentsOffset=Vector3.new(0,3,0) bgui.Parent=ch local tl=Instance.new("TextLabel") tl.Name="InfoLabel" tl.Size=UDim2.new(1,0,1,0) tl.BackgroundTransparency=1 tl.Font=Enum.Font.GothamBold tl.TextSize=13 tl.TextStrokeTransparency=0.3 tl.TextStrokeColor3=Color3.new(0,0,0) tl.Parent=bgui end local myHRP=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if myHRP and bgui:FindFirstChild("InfoLabel") then local dist=math.floor((hrp.Position-myHRP.Position).Magnitude) local rn="Innocent" if c==Color3.fromRGB(255,0,0) then rn="MURDER" elseif c==Color3.fromRGB(0,0,255) then rn="SHERIFF" end bgui.InfoLabel.TextColor3=c bgui.InfoLabel.Text=p.Name.."\n["..rn.." | "..dist.."m]" end end
local playerColors={} task.spawn(function() while RUN.alive() and task.wait(0.3) do if not getgenv().RoleESPEnabled and not getgenv().PlayerESPEnabled then table.clear(playerColors) continue end for _,p in ipairs(Players:GetPlayers()) do if p==LocalPlayer then continue end if getgenv().RoleESPEnabled then local ch=p.Character local b=p:FindFirstChild("Backpack") if (ch and ch:FindFirstChild("Knife")) or (b and b:FindFirstChild("Knife")) then playerColors[p]=Color3.fromRGB(255,0,0) elseif (ch and ch:FindFirstChild("Gun")) or (b and b:FindFirstChild("Gun")) then playerColors[p]=Color3.fromRGB(0,0,255) else playerColors[p]=Color3.fromRGB(0,255,0) end elseif getgenv().PlayerESPEnabled then playerColors[p]=Color3.fromRGB(255,255,0) end end end end)
RUN.track(RunService.RenderStepped:Connect(function() local myChar=LocalPlayer.Character local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart") if getgenv().RainbowUIEnabled then OrionLib:ChangeThemeColor(Color3.fromHSV((tick()*0.2)%1,1,1)) end if getgenv().PlayerESPEnabled or getgenv().RoleESPEnabled then for _,p in ipairs(Players:GetPlayers()) do if p==LocalPlayer then continue end if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and playerColors[p] then applyHighlight(p,playerColors[p],true) end end end if myHRP then local currentTool=myChar and myChar:FindFirstChildOfClass("Tool") if getgenv().AutoShotEnabled and currentTool and currentTool.Name=="Gun" then local th,tc=gmh() if th and tc and tc:FindFirstChild("HumanoidRootPart") then local dist=(th.Position-myHRP.Position).Magnitude if dist<=35 then autoShotFire() end end end if getgenv().KillAuraEnabled and currentTool and currentTool.Name=="Knife" then for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local ehrp=p.Character.HumanoidRootPart local dist=(ehrp.Position-myHRP.Position).Magnitude if dist<=4.5 then currentTool:Activate() end end end end end end))
local function clearAllESP() for _,p in ipairs(Players:GetPlayers()) do applyHighlight(p,nil,false) end for _,v in ipairs(workspace:GetDescendants()) do if v.Name=="GunDrop" then if v:FindFirstChild("GunMAXHighlight") then v.GunMAXHighlight:Destroy() end end end end
local activeGunHighlights = {}
local function setupGunRainbow(gun) if not gun or not gun.Parent then return end local jointPart = gun:IsA("BasePart") and gun or gun:FindFirstChildWhichIsA("BasePart") or gun:FindFirstChild("Normal") if not jointPart then return end local highlight = gun:FindFirstChild("GunMAXHighlight") or Instance.new("Highlight") highlight.Name = "GunMAXHighlight" highlight.OutlineColor = Color3.fromRGB(255, 255, 255) highlight.OutlineTransparency = 0.1 highlight.FillTransparency = 0.3 highlight.Enabled = getgenv().GunESPEnabled highlight.Parent = gun activeGunHighlights[gun] = highlight if getgenv().AutoGrabGun and not grabDebounce then grabDebounce = true task.spawn(function() local c = LocalPlayer.Character local hrp = c and c:FindFirstChild("HumanoidRootPart") if hrp and jointPart and jointPart.Parent then local orig = hrp.CFrame hrp.CFrame = jointPart.CFrame + Vector3.new(0, 2, 0) task.wait(0.15) hrp.CFrame = orig OrionLib:MakeNotification({Name="MAX Hub", Content="Gun grabbed!", Time=2}) end task.wait(3.5) grabDebounce = false end) end end
RUN.track(workspace.DescendantAdded:Connect(function(descendant) if descendant.Name == "GunDrop" then task.wait(0.1) setupGunRainbow(descendant) end end))
RUN.track(workspace.DescendantRemoving:Connect(function(descendant) if descendant.Name == "GunDrop" then activeGunHighlights[descendant] = nil end end))
for _, obj in ipairs(workspace:GetDescendants()) do if obj.Name == "GunDrop" then setupGunRainbow(obj) end end
task.spawn(function() while RUN.alive() and task.wait(0.1) do if getgenv().GunESPEnabled then local hue = (tick() * 0.15) % 1 local rainbowColor = Color3.fromHSV(hue, 1, 1) for gun, highlight in pairs(activeGunHighlights) do if highlight and highlight.Parent then highlight.Enabled = true highlight.FillColor = rainbowColor else activeGunHighlights[gun] = nil end end else for gun, highlight in pairs(activeGunHighlights) do if highlight and highlight.Parent then highlight.Enabled = false end end end end end)

-- ===== AUTO FARM v9 (v7 + хуки для Auto End Round / Auto Reset, скорость до 1000) =====
-- Заменяет прошлый блок целиком: от `getgenv().FarmSpeed = 30`
-- до конца текстбокса "Farm Height". RunService уже объявлен выше в хабе.

getgenv().FarmSpeed = 30 
getgenv().FarmHeight = 0 

local farmConn = nil
local noclipConn = nil
local farmCoin = nil
local farmContainer = nil
local lastScan = 0
local holdUntil = 0
local pickTime = 0
local pickLimit = 0
getgenv().FarmDebug = false  -- пишет в F9 статус раз в секунду

local lastDbg = 0
local virtPos = nil 
local coinStart = nil
local tried = setmetatable({}, { __mode = "k" }) 
local banned = setmetatable({}, { __mode = "k" }) 

local function findContainer()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "CoinContainer" then
            return obj
        end
    end
end

local function pickCoin(hrp)
    if not (farmContainer and farmContainer.Parent) then
        local st = getgenv().MAXState
        if st and st.container then
            farmContainer = st.container()
        else
            if tick() - lastScan < 1 then return nil end
            lastScan = tick()
            farmContainer = findContainer()
        end
        if not farmContainer then return nil end
    end

    local best, bestDist
    local now = tick()
    for _, coin in ipairs(farmContainer:GetChildren()) do
        if coin:IsA("BasePart")
            and (not tried[coin] or now - tried[coin] > 3)
            and not (banned[coin] and banned[coin] > now) then
            local d = (coin.Position - hrp.Position).Magnitude
            if not bestDist or d < bestDist then
                best, bestDist = coin, d
            end
        end
    end
    return best, bestDist
end

local function stopAutoFarm()
    getgenv().AutoFarmEnabled = false
    if farmConn then
        farmConn:Disconnect()
        farmConn = nil
    end
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    farmCoin = nil
    holdUntil = 0
    virtPos = nil

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

RUN.cleanups[#RUN.cleanups+1] = stopAutoFarm

local function startAutoFarm()
    if farmConn then farmConn:Disconnect() end
    if noclipConn then noclipConn:Disconnect() end
    farmCoin = nil
    holdUntil = 0
    virtPos = nil

  
    noclipConn = RunService.Stepped:Connect(function()
        if not getgenv().AutoFarmEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)

    farmConn = RunService.Heartbeat:Connect(function(dt)
        if not getgenv().AutoFarmEnabled then return end

        -- пауза: Auto End Round / Auto Reset сами управляют персонажем
        local st = getgenv().MAXState
        if st and st.farmPaused then
            
            if not st.flinging then
                local pc = LocalPlayer.Character
                local ph = pc and pc:FindFirstChild("HumanoidRootPart")
                if ph then ph.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
            end
            return
        end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then
            farmCoin = nil
            return
        end

      
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero

        
        if getgenv().FarmDebug and tick() - lastDbg > 1 then
            lastDbg = tick()
            local total, free = 0, 0
            local now = tick()
            if farmContainer and farmContainer.Parent then
                for _, c in ipairs(farmContainer:GetChildren()) do
                    if c:IsA("BasePart") then
                        total = total + 1
                        if (not tried[c] or now - tried[c] > 3) and not (banned[c] and banned[c] > now) then
                            free = free + 1
                        end
                    end
                end
            end
            print(string.format("[Farm] контейнер=%s монет=%d доступных=%d цель=%s скорость=%s",
                tostring(farmContainer ~= nil and farmContainer.Parent ~= nil),
                total, free, farmCoin and "есть" or "нет", tostring(getgenv().FarmSpeed)))
        end

        if not (farmCoin and farmCoin.Parent) then
            holdUntil = 0
            local coin, d = pickCoin(hrp)
            farmCoin = coin
            if not farmCoin then
                virtPos = nil 
                return
            end
            coinStart = farmCoin.Position
            local speed = math.max(tonumber(getgenv().FarmSpeed) or 30, 1)
            pickTime = tick()
            pickLimit = (d or 0) / speed + 2 
        end

        
        if holdUntil == 0 and tick() - pickTime > pickLimit then
            if getgenv().FarmDebug then
                print(string.format("[Farm] skip (не долетел за %.1fс, осталось %.1f): %s",
                    tick() - pickTime, (farmCoin.Position - hrp.Position).Magnitude, farmCoin.Name))
            end
            tried[farmCoin] = tick()
            farmCoin = nil
            return
        end

        local target = farmCoin.Position + Vector3.new(0, tonumber(getgenv().FarmHeight) or 0, 0)
        local speed = math.max(tonumber(getgenv().FarmSpeed) or 30, 1)
        local rot = hrp.CFrame - hrp.CFrame.Position

       
        if not virtPos or (virtPos - hrp.Position).Magnitude > 15 then
            virtPos = hrp.Position
        end

        local delta = target - virtPos
        local dist = delta.Magnitude
        local step = speed * dt

        if dist <= step then
            
            virtPos = target
            hrp.CFrame = CFrame.new(target) * rot

            if holdUntil == 0 then
                holdUntil = tick() + 0.06
                local coin = farmCoin
                
                if st and st.onArrive then st.onArrive(coin) end
                task.spawn(function()
                    pcall(function()
                        if firetouchinterest then
                            firetouchinterest(hrp, coin, 0)
                            task.wait()
                            firetouchinterest(hrp, coin, 1)
                        end
                    end)
                end)
            elseif tick() >= holdUntil then
                tried[farmCoin] = tick()
                farmCoin = nil
                holdUntil = 0
            end
        else
           
            virtPos = virtPos + delta.Unit * step
            hrp.CFrame = CFrame.new(virtPos) * rot
        end
    end)
end

MainTab:AddToggle({
    Name = "Auto Farm Coins",
    Default = false,
    Callback = function(v)
        getgenv().AutoFarmEnabled = v
        if v then
            if not firetouchinterest then
                OrionLib:MakeNotification({
                    Name = "Auto Farm",
                    Content = "Executor без firetouchinterest: монеты не соберутся",
                    Time = 5
                })
            end
            startAutoFarm()
        else
            stopAutoFarm()
        end
    end
})

MainTab:AddTextbox({
    Name = "Farm Speed (30 = test)",
    Placeholder = "5-1000",
    Callback = function(t, enterPressed)
        if enterPressed and tonumber(t) then
            getgenv().FarmSpeed = math.clamp(tonumber(t), 5, 1000)
        end
    end
})

MainTab:AddTextbox({
    Name = "Farm Height (0 = on coin)",
    Placeholder = "-10 to 0",
    Callback = function(t, enterPressed)
        if enterPressed and tonumber(t) then
            getgenv().FarmHeight = math.clamp(tonumber(t), -10, 0)
        end
    end
})
do
    local function setLowPower(v)
        pcall(function() RunService:Set3dRenderingEnabled(not v) end)
        pcall(function() if setfpscap then setfpscap(v and 20 or 60) end end)
        pcall(function()
            settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
        end)
    end
    RUN.cleanups[#RUN.cleanups+1] = function() setLowPower(false) end

    MainTab:AddToggle({
        Name = "Low Power (мульти-окна)",
        Default = false,
        Callback = setLowPower
    })
end


getgenv().MAXState = getgenv().MAXState or {}
getgenv().FlySpeedMultiplier = getgenv().FlySpeedMultiplier or 1 


function toggleNoClip()
    local S = getgenv().MAXState
    if S.noclipConn then
        S.noclipConn:Disconnect()
        S.noclipConn = nil
    end
    if not getgenv().NoClipEnabled then return end

    S.noclipConn = game:GetService("RunService").Stepped:Connect(function()
        if not getgenv().NoClipEnabled then return end
        local char = game:GetService("Players").LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

-- Fly: хаб ставит getgenv().FlyEnabled и вызывает эту функцию при включении.
-- Управление: W/A/S/D по направлению камеры, Space вверх, Shift/Ctrl вниз.
-- Скорость полёта = скорость бега (текстбокс Speed) * FlySpeedMultiplier.
-- На телефоне: стик + прыжок. Выключается сам, когда FlyEnabled = false.
function enableFly()
    local S = getgenv().MAXState
    if S.flyConn then
        S.flyConn:Disconnect()
        S.flyConn = nil
    end

    S.flyPos = nil
    S.flyVel = nil

    local UIS = game:GetService("UserInputService")
    local plr = game:GetService("Players").LocalPlayer

    S.flyConn = game:GetService("RunService").RenderStepped:Connect(function(dt)
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if not getgenv().FlyEnabled then
            S.flyPos = nil
            S.flyVel = nil
            if hum then hum.PlatformStand = false end
            if S.flyConn then
                S.flyConn:Disconnect()
                S.flyConn = nil
            end
            return
        end
        if not hrp or not hum then return end

        local cam = workspace.CurrentCamera
        local dir = Vector3.new(0, 0, 0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            dir = dir - Vector3.new(0, 1, 0)
        end
        -- телефон / геймпад: стик даёт MoveDirection
        if dir.Magnitude == 0 and hum.MoveDirection.Magnitude > 0 then
            dir = hum.MoveDirection
        end

        hum.PlatformStand = true
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

        -- скорость полёта = скорость бега (текстбокс Speed) * множитель
        local speed = hum.WalkSpeed * (tonumber(getgenv().FlySpeedMultiplier) or 1)
        local targetVel = Vector3.new(0, 0, 0)
        if dir.Magnitude > 0 then
            targetVel = dir.Unit * speed
        end
        -- плавный разгон и торможение
        S.flyVel = (S.flyVel or Vector3.new(0, 0, 0)):Lerp(targetVel, math.clamp(dt * 10, 0, 1))

        
        if not S.flyPos or (S.flyPos - hrp.Position).Magnitude > 15 then
            S.flyPos = hrp.Position
        end
        S.flyPos = S.flyPos + S.flyVel * dt

        
        local look = cam.CFrame.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude > 0.01 then
            hrp.CFrame = CFrame.new(S.flyPos, S.flyPos + flat)
        else
            hrp.CFrame = CFrame.new(S.flyPos) * (hrp.CFrame - hrp.CFrame.Position)
        end
    end)
end

-- Время суток (кнопки Morning / Day / Evening / Night)
function setTime(mode)
    local hours = { morning = 7, day = 14, evening = 18.5, night = 0 }
    local t = hours[mode]
    if t then
        game:GetService("Lighting").ClockTime = t
    end
end
-- ===== AUTO END ROUND + AUTO RESET (v2: надёжное определение полного мешка) =====
-- Работает только при включённом Auto Farm Coins.
--
-- Auto End Round: когда фарм закончен (мешок полный или монеты кончились),
--   Murderer  -> встаёт и убивает всех (по очереди телепортируется к каждому)
--   Sheriff   -> стреляет в мардера издалека (без телепорта), запасной вариант - телепорт
--   Innocent  -> пытается зафлингить мардера, чтобы раунд закончился
-- Auto Reset: когда фарм закончен, просто ресетает персонажа.
-- Если включены обе: сначала End Round, а если раунд так и не кончился, потом ресет.
--
-- getgenv().BagSize = размер мешка (по умолчанию 40). Если твой мешок другой, поменяй.

getgenv().MAXState = getgenv().MAXState or {}
local S = getgenv().MAXState
getgenv().BagSize = getgenv().BagSize or 40

S.pending = setmetatable({}, { __mode = "k" })
S.collected = 0
S.failStreak = 0
S.phase = "farming"
S.farmPaused = false

local function dbg(...)
    if getgenv().FarmDebug then print("[EndRound]", ...) end
end

-- ---------- вспомогательное ----------

function S.enabled()
    return getgenv().AutoFarmEnabled and (getgenv().AutoEndRound or getgenv().AutoReset)
end

function S.container()
    local c = S.cont
    if c and c.Parent then return c end
    S.cont = nil
    local now = tick()
    if now - (S.lastScan or 0) < 1 then return nil end
    S.lastScan = now
    
    for _, m in ipairs(workspace:GetChildren()) do
        local f = m:FindFirstChild("CoinContainer")
        if f then S.cont = f return f end
    end
    
    if now - (S.lastDeep or 0) > 5 then
        S.lastDeep = now
        for _, o in ipairs(workspace:GetDescendants()) do
            if o.Name == "CoinContainer" then S.cont = o return o end
        end
    end
    return nil
end

function S.active() -- раунд идёт и режим включён
    return S.enabled() and S.container() ~= nil
end

function S.me() -- char, hum, hrp или nil, если мёртв
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and hrp and hum.Health > 0 then
        return char, hum, hrp
    end
    return nil
end

function S.role()
    local c = LocalPlayer.Character
    local b = LocalPlayer:FindFirstChild("Backpack")
    if (c and c:FindFirstChild("Knife")) or (b and b:FindFirstChild("Knife")) then return "murderer" end
    if (c and c:FindFirstChild("Gun")) or (b and b:FindFirstChild("Gun")) then return "sheriff" end
    return "innocent"
end

function S.murderer() 
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local c = p.Character
            local b = p:FindFirstChild("Backpack")
            if (c and c:FindFirstChild("Knife")) or (b and b:FindFirstChild("Knife")) then
                return p, c
            end
        end
    end
    return nil, nil
end

function S.alive(plr)
    local c = plr.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    return h ~= nil and h.Health > 0 and c:FindFirstChild("HumanoidRootPart") ~= nil
end

function S.inMap(pos) 
    local cont = S.container()
    local map = cont and cont.Parent
    if map and map:IsA("Model") then
        local ok, cf, size = pcall(map.GetBoundingBox, map)
        if ok and cf and size then
            local rel = cf:PointToObjectSpace(pos)
            return math.abs(rel.X) <= size.X / 2 + 80
                and math.abs(rel.Y) <= size.Y / 2 + 80
                and math.abs(rel.Z) <= size.Z / 2 + 80
        end
    end
    return true
end

function S.equip(name)
    local char, hum = S.me()
    if not char then return nil end
    local tool = char:FindFirstChild(name)
    if not tool then
        local bp = LocalPlayer:FindFirstChild("Backpack")
        local t = bp and bp:FindFirstChild(name)
        if t then
            hum:EquipTool(t)
            task.wait(0.15)
        end
    end
    return char:FindFirstChild(name)
end

function S.nextVictim(skip)
    local _, _, myHrp = S.me()
    if not myHrp then return nil end
    local best, bestD
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not skip[p] and S.alive(p) then
            local hrp = p.Character.HumanoidRootPart
            if S.inMap(hrp.Position) then
                local d = (hrp.Position - myHrp.Position).Magnitude
                if not bestD or d < bestD then
                    best, bestD = p, d
                end
            end
        end
    end
    return best
end

-- ---------- определение "монета собрана" и "мешок полный" ----------

-- слепок монеты в момент подлёта; потом сравниваем: что-то изменилось = собрана
function S.sig(coin)
    return {
        tr = coin.Transparency,
        ct = coin.CanTouch,
        tt = coin:FindFirstChildWhichIsA("TouchTransmitter") ~= nil,
        n = #coin:GetDescendants(),
        pos = coin.Position,
    }
end

function S.changed(coin, sig)
    if not coin.Parent then return true end
    return coin.Transparency ~= sig.tr
        or coin.CanTouch ~= sig.ct
        or (coin:FindFirstChildWhichIsA("TouchTransmitter") ~= nil) ~= sig.tt
        or #coin:GetDescendants() ~= sig.n
        or (coin.Position - sig.pos).Magnitude > 3
end

function S.onArrive(coin) -- вызывается автофармом при подлёте к монете
    S.pending[coin] = { t = tick(), sig = S.sig(coin) }
end

-- мешок по интерфейсу игры: true / false / nil (не нашли интерфейс)
function S.bagFull()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local bag = S.bag
    if not (bag and bag.Parent) then
        bag = nil
        if tick() - (S.bagScan or 0) > 3 then -- не сканируем интерфейс слишком часто
            S.bagScan = tick()
            for _, o in ipairs(pg:GetDescendants()) do
                if o.Name == "CashBag" then bag = o break end
            end
            S.bag = bag
        end
    end
    if not bag then return nil end

    local full = bag:FindFirstChild("Full", true)
    if full and full:IsA("GuiObject") and full.Visible then return true end

    local coins = bag:FindFirstChild("Coins", true)
    if coins and (coins:IsA("TextLabel") or coins:IsA("TextButton")) then
        local n = tonumber(string.match(coins.Text, "%d+"))
        if n and n >= (tonumber(getgenv().BagSize) or 40) then return true end
    end
    return false
end

-- число монет из интерфейса игры (nil, если не нашли)
function S.bagCount()
    S.bagFull() -- заодно обновит S.bag
    local bag = S.bag
    if not (bag and bag.Parent) then return nil end
    local coins = bag:FindFirstChild("Coins", true)
    if coins and (coins:IsA("TextLabel") or coins:IsA("TextButton")) then
        return tonumber(string.match(coins.Text, "%d+"))
    end
    return nil
end

-- точный счётчик прямо от сервера: ремоут CoinCollected, если он есть в игре
-- (формат из памяти: тип, собрано, максимум; если не совпадёт, значение просто игнорируется)
S.serverCount, S.serverMax = nil, nil
task.spawn(function()
    local RS = game:GetService("ReplicatedStorage")
    local ev
    for _ = 1, 10 do
        for _, o in ipairs(RS:GetDescendants()) do
            if o.Name == "CoinCollected" and o:IsA("RemoteEvent") then ev = o break end
        end
        if ev or not RUN.alive() then break end
        task.wait(1)
    end
    if not ev then return end
    RUN.track(ev.OnClientEvent:Connect(function(...)
        local a = { ... }
        local cur, mx = tonumber(a[2]), tonumber(a[3])
        if cur and mx and cur <= mx then
            S.serverCount, S.serverMax = cur, mx
        end
        if getgenv().FarmDebug then print("[CoinCollected]", ...) end
    end))
end)

-- ---------- режимы по ролям ----------

-- Murderer: убить всех
function S.killAll()
    local knife = S.equip("Knife")
    if not knife then dbg("нож не найден") return end

    local skip = {}
    local t0 = tick()
    while S.active() and tick() - t0 < 90 do
        local victim = S.nextVictim(skip)
        if not victim then break end

        local vt0 = tick()
        while S.active() and tick() - vt0 < 3 and S.alive(victim) do
            local _, _, myHrp = S.me()
            if not myHrp then return end
            local vh = victim.Character.HumanoidRootPart
            myHrp.CFrame = CFrame.lookAt(vh.Position - vh.CFrame.LookVector * 2, vh.Position)
            myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            knife:Activate()
            task.wait(0.12)
        end
        if S.alive(victim) then skip[victim] = true end -- не убился за 3 секунды: пропускаем
    end
end

function S.shootMurdererClose()
    local gun = S.equip("Gun")
    if not gun then dbg("пистолет не найден") return end
    local _, _, hrp0 = S.me()
    if not hrp0 then return end
    local origCF = hrp0.CFrame

    local t0, shots = tick(), 0
    while S.active() and tick() - t0 < 30 do
        local _, mc = S.murderer()
        local mhrp = mc and mc:FindFirstChild("HumanoidRootPart")
        local mhum = mc and mc:FindFirstChildOfClass("Humanoid")
        if not mhrp or not mhum or mhum.Health <= 0 then break end
        local _, _, hrp = S.me()
        if not hrp then return end

        -- ищем точку рядом с мардером, откуда его видно
        local mp = mhrp.Position
        local look = mhrp.CFrame.LookVector
        local right = mhrp.CFrame.RightVector
        local cands = {
            mp - look * 12, mp + right * 12, mp - right * 12, mp + look * 12,
            mp - look * 25, mp + right * 25, mp - right * 25,
        }
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = { LocalPlayer.Character, mc }
        local best = cands[1]
        for _, c in ipairs(cands) do
            local from = c + Vector3.new(0, 2, 0)
            if not workspace:Raycast(from, mp - from, rp) then best = c break end
        end

        hrp.CFrame = CFrame.lookAt(best + Vector3.new(0, 2, 0), mp)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        task.wait(0.12)
        local vel = mhrp.AssemblyLinearVelocity
        S.fireAt(gun, mhrp.Position + Vector3.new(vel.X, 0, vel.Z) * 0.15, ({2, 4, 3, 1, 5})[(shots % 5) + 1])
        shots = shots + 1
        task.wait(0.5)
    end

    local _, _, hrp = S.me()
    if hrp then hrp.CFrame = origCF end -- вернуться на место
end
-- Sheriff: выстрел через всю карту, без телепорта
-- ищет remote выстрела у пистолета (в MM2 это KnifeLocal.CreateBeam.RemoteFunction)
function S.gunRemote(gun)
    local r = gun and gun:FindFirstChild("Shoot")
    if r and r:IsA("RemoteEvent") then return r end
    return nil
end

function S.fireAt(gun, pos, forceV)
    local char, hum, hrp = S.me()
    if not (char and hrp and gun) then return false end
    local rf = gun:FindFirstChild("Shoot")
    if not rf then return false end
    if gun.Parent ~= char then
        pcall(function() hum:EquipTool(gun) end)
        task.wait(0.15)
    end
    local v = forceV
    if not v then
        S.variant = ((S.variant or 0) % 5) + 1
        v = S.variant
    end
    local offsets = {
        Vector3.new(0, 0, 0), Vector3.new(0, 4, 6), Vector3.new(0, 8, 0),
        Vector3.new(6, 4, 0), Vector3.new(0, 15, 12),
    }
    local origin
    if v == 1 then
        local att = hrp:FindFirstChild("GunRaycastAttachment")
        origin = att and att.WorldCFrame or hrp.CFrame
    else
        origin = CFrame.lookAt(pos + offsets[v], pos)
    end
    pcall(function() rf:FireServer(origin, CFrame.new(pos)) end)
    dbg("выстрел, вариант", v)
    return true
end

-- Sheriff: стреляем по кругу разными вариантами, пока мардер не умрёт 
function S.shootMurderer()
    local gun = S.equip("Gun")
    if not gun then dbg("пистолет не найден") return end
    local order = { 2, 4, 3, 1, 5 }
    local t0, shots = tick(), 0
    while S.active() and tick() - t0 < 120 do
        local _, mc = S.murderer()
        local mhrp = mc and mc:FindFirstChild("HumanoidRootPart")
        local mhum = mc and mc:FindFirstChildOfClass("Humanoid")
        if not mhrp or not mhum or mhum.Health <= 0 then return end
        if not S.me() then return end
        gun = S.equip("Gun") or gun
        local vel = mhrp.AssemblyLinearVelocity
        S.fireAt(gun, mhrp.Position + Vector3.new(vel.X, 0, vel.Z) * 0.15, order[(shots % #order) + 1])
        shots = shots + 1
        task.wait(0.6)
    end
end

-- Innocent: зафлинговать мардера 
-- флингует убийцу, пока он жив и раунд идёт; если умер, ждёт респавна в лобби и продолжает
function S.flingMurderer(targetChar)
    local deadline = tick() + 120
    while (S.active() or S.manualFling) and tick() < deadline do
        local mc = targetChar
        if not mc or not mc.Parent then
            local _, c = S.murderer()
            mc = c
        end
        local mh = mc and mc:FindFirstChildOfClass("Humanoid")
        if not mc or not mh or mh.Health <= 0 then break end -- убийца умер или исчез

        if S.me() then
            S.flingOnce(mc)
            task.wait(0.2)
        else
            task.wait(0.3) -- мы мертвы, ждём модельку в лобби
        end
    end
    S.flinging = false
end
function S.flingOnce(targetChar)
    local mc = targetChar
    if not mc then local _, c = S.murderer() mc = c end
    if not mc then return end
    local char, _, hrp = S.me()
    if not hrp then return end

    local origCF = hrp.CFrame
    local saved = {}
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            saved[part] = part.CustomPhysicalProperties
            part.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
        end
    end

    S.flinging = true -- чтобы автофарм на паузе не гасил скорость во время флинга
    local t0 = tick()
        while (S.active() or S.manualFling) and tick() - t0 < 25 do
        local _, _, myHrp = S.me()
        local mhrp = mc:FindFirstChild("HumanoidRootPart")
        local mhum = mc:FindFirstChildOfClass("Humanoid")
        if not myHrp or not mhrp or not mhum or mhum.Health <= 0 then break end

        myHrp.CFrame = mhrp.CFrame
        myHrp.AssemblyAngularVelocity = Vector3.new(0, 100000, 0)
        myHrp.AssemblyLinearVelocity = Vector3.new(100000, 100000, 100000)
        RunService.Heartbeat:Wait()
    end

    S.flinging = false

    -- вернуть персонажа на место и обнулить скорость
    local _, _, myHrp = S.me()
    if myHrp then
        myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        myHrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        myHrp.CFrame = origCF
    end
    for part, props in pairs(saved) do
        if part.Parent then part.CustomPhysicalProperties = props end
    end
end

function S.reset()
    local _, hum = S.me()
    if hum then hum.Health = 0 end
end

-- ---------- запуск после окончания фарма ----------

function S.finish(reason)
    S.phase = "running"
    S.farmPaused = true
    dbg("фарм закончен:", reason, "роль:", S.role())

    task.spawn(function()
        if getgenv().AutoEndRound and S.me() then
            local role = S.role()
            local ok, err = pcall(function()
                if role == "murderer" then
                    S.killAll()
                elseif role == "sheriff" then
                    S.shootMurderer()
                else
                    S.flingMurderer()
                end
            end)
            S.flinging = false
            if not ok then dbg("ошибка:", err) end
        end

        -- Auto Reset: сам по себе, либо запасной вариант, если раунд не закончился
        if getgenv().AutoReset and S.active() then
            S.reset()
        end
        S.phase = "done"
    end)
end

-- ---------- главный цикл ----------

S.erRun = (S.erRun or 0) + 1

task.spawn(function()
    local run = S.erRun
    local lastCont = nil
    local emptySince = nil
    local lastPrint = 0

    while S.erRun == run do
        task.wait(0.4)

        if not S.enabled() then
            S.farmPaused = false
            S.phase = "farming"
            continue
        end

        local cont = S.container()
        if cont ~= lastCont then -- новый раунд (или раунд кончился)
            lastCont = cont
            S.collected = 0
            S.deadRun = false
            S.failStreak = 0
            S.serverCount = nil
            S.pending = setmetatable({}, { __mode = "k" })
            S.phase = "farming"
            S.farmPaused = false
            emptySince = nil
        end
        if not cont then continue end

        -- смотрим, что стало с монетами, к которым мы подлетали
        local now = tick()
        for coin, rec in pairs(S.pending) do
            if S.changed(coin, rec.sig) then
                S.collected = S.collected + 1
                S.failStreak = 0
                S.pending[coin] = nil
            elseif now - rec.t > 2.5 then
                S.failStreak = S.failStreak + 1 -- подлетели, а монета не изменилась
                S.pending[coin] = nil
            end
        end

        if getgenv().FarmDebug and now - lastPrint > 1 then
            lastPrint = now
            print(string.format("[EndRound] свой счёт=%d, игра=%s, неудач подряд=%d, мешок(GUI)=%s, фаза=%s",
                S.collected, tostring(S.serverCount or S.bagCount()), S.failStreak, tostring(S.bagFull()), S.phase))
        end

        if S.phase == "farming" and S.me() then
            local coins = 0
            for _, c in ipairs(cont:GetChildren()) do
                if c:IsA("BasePart") then coins = coins + 1 end
            end
            if coins == 0 then
                emptySince = emptySince or now
            else
                emptySince = nil
            end

            local target = S.serverMax or tonumber(getgenv().BagSize) or 40
            local real = S.serverCount or S.bagCount() -- число из самой игры, если нашли
            local guiState = S.bagFull()
            local full
            if real then
                full = real >= target -- верим игре, а не своему счётчику
            else
                full = guiState == true or (guiState == nil and S.collected >= target)
            end
            local have = real or S.collected
            -- "застряли" только ближе к концу, иначе лаг даёт ложное срабатывание
            local stuck = have >= target * 0.7 and S.failStreak >= 8
            local noCoins = emptySince ~= nil and have > 0 and now - emptySince > 4

            if full or stuck or noCoins then
                local why = full and ("мешок полный (" .. tostring(have) .. "/" .. tostring(target) .. ")")
                    or stuck and ("монеты перестали собираться (" .. tostring(have) .. ")")
                    or ("монеты кончились (" .. tostring(have) .. ")")
S.finish(why)
            end
        end
 
        -- умер во время фарма: добиваем убийцу из лобби
        if S.phase == "farming" and not S.me() and getgenv().AutoEndRound and not S.deadRun then
            if S.role() ~= "murderer" and S.murderer() then
                S.deadRun = true
                S.phase = "running"
                S.farmPaused = true
                dbg("я умер, флингую убийцу")
                task.spawn(function()
                    pcall(S.flingMurderer)
                    S.flinging = false
                    S.phase = "done"
                end)
            end
        end
    end
end)

-- ---------- две кнопки ----------

MainTab:AddToggle({
    Name = "Auto End Round",
    Default = false,
    Callback = function(v)
        getgenv().AutoEndRound = v
    end
})

MainTab:AddToggle({
    Name = "Auto Reset (full bag)",
    Default = false,
    Callback = function(v)
        getgenv().AutoReset = v
    end
})
function S.sheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local c, b = p.Character, p:FindFirstChild("Backpack")
            if (c and c:FindFirstChild("Gun")) or (b and b:FindFirstChild("Gun")) then
                return p, c
            end
        end
    end
end

MainTab:AddButton({
    Name = "Fling Sheriff (get gun)",
    Callback = function()
        local _, c = S.sheriff()
        if not c then return end
        task.spawn(function()
            S.manualFling = true
            pcall(S.flingMurderer, c)
            S.manualFling = false
            S.flinging = false
        end)
    end
})
MainTab:AddButton({
    Name = "Fling Murderer",
    Callback = function()
        task.spawn(function()
            S.manualFling = true
            pcall(S.flingMurderer)
            S.manualFling = false
            S.flinging = false
        end)
    end
})
MainTab:AddButton({
    Name = "Server Hop",
    Callback = function()
        task.spawn(function()
        	task.wait(math.random() * 6)
            local TeleportService = game:GetService("TeleportService")
            local base = "https://games.roblox.com/v1/games/" .. game.PlaceId
                .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"

            local function fetch(url)
                local ok, body = pcall(function() return game:HttpGet(url) end)
                if not ok or not body then
                    local req = (syn and syn.request) or http_request or request
                    if req then
                        local ok2, r = pcall(req, { Url = url, Method = "GET" })
                        if ok2 and r and r.Body then body, ok = r.Body, true end
                    end
                end
                if not ok or not body then return nil end
                local ok3, data = pcall(function() return HttpService:JSONDecode(body) end)
                return ok3 and data or nil
            end

            local list, cursor = {}, nil
            for _ = 1, 3 do
                local data = fetch(cursor and (base .. "&cursor=" .. cursor) or base)
                if not data or not data.data then
                    print("[Hop] список серверов не получен (запрос заблокирован или 429)")
                    break
                end
                for _, sv in ipairs(data.data) do
                    if sv.id ~= game.JobId and sv.playing and sv.maxPlayers
                        and sv.playing < sv.maxPlayers - 1 then
                        table.insert(list, sv.id)
                    end
                end
                cursor = data.nextPageCursor
                if not cursor then break end
            end

            print("[Hop] подходящих серверов:", #list)
            if #list == 0 then
                print("[Hop] список пуст, хоп отменён (чтобы не попасть в тот же)")
                return
            end

            for attempt = 1, 5 do
                local id = list[math.random(#list)]
                print("[Hop] пробую сервер", id)
                local ok, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer)
                end)
                if ok then return end
                print("[Hop] ошибка:", err)
                task.wait(2)
            end
        end)
    end
})
MainTab:AddToggle({
    Name = "Disable 3D Rendering",
    Default = false,
    Callback = function(v)
        pcall(function() RunService:Set3dRenderingEnabled(not v) end)
    end
})
MainTab:AddButton({Name="Teleport to Lobby",Callback=teleportToLobby})
MainTab:AddToggle({Name="Auto Shot (Sheriff)",Default=false,Callback=function(v) getgenv().AutoShotEnabled=v end})
MainTab:AddToggle({Name="Kill Aura (Murderer)",Default=false,Callback=function(v) getgenv().KillAuraEnabled=v end})
MainTab:AddToggle({Name="Anti-Fling",Default=false,Callback=function(v) getgenv().AntiFlingEnabled=v if v then OrionLib:MakeNotification({Name="MAX Hub",Content="Anti-Fling ON!",Time=2}) else OrionLib:MakeNotification({Name="MAX Hub",Content="Anti-Fling OFF",Time=2}) end end})
MainTab:AddToggle({Name="Infinite Jumps",Default=false,Callback=function(v) toggleInfiniteJump(v) end})
MainTab:AddLabel({Text="SPEED & JUMP"})
MainTab:AddTextbox({Name="Speed",Placeholder="16",Callback=function(t,ep) if ep and tonumber(t) then getgenv().CurrentCustomSpeed=tonumber(t) local c=LocalPlayer.Character if c and c:FindFirstChildOfClass("Humanoid") then c:FindFirstChildOfClass("Humanoid").WalkSpeed=tonumber(t) end end end})
MainTab:AddButton({Name="Reset Speed",Callback=function() getgenv().CurrentCustomSpeed=defaultWalkSpeed local c=LocalPlayer.Character if c and c:FindFirstChildOfClass("Humanoid") then c:FindFirstChildOfClass("Humanoid").WalkSpeed=defaultWalkSpeed end end})
MainTab:AddTextbox({Name="Jump",Placeholder="50",Callback=function(t,ep) if ep and tonumber(t) then getgenv().CurrentCustomJump=tonumber(t) local c=LocalPlayer.Character if c and c:FindFirstChildOfClass("Humanoid") then c:FindFirstChildOfClass("Humanoid").UseJumpPower=true c:FindFirstChildOfClass("Humanoid").JumpPower=tonumber(t) end end end})
MainTab:AddButton({Name="Reset Jump",Callback=function() getgenv().CurrentCustomJump=defaultJumpPower local c=LocalPlayer.Character if c and c:FindFirstChildOfClass("Humanoid") then c:FindFirstChildOfClass("Humanoid").JumpPower=defaultJumpPower end end})
MainTab:AddToggle({Name="Fly",Default=false,Callback=function(v) getgenv().FlyEnabled=v if v then enableFly() end end})
MainTab:AddToggle({Name="NoClip",Default=false,Callback=function(v) getgenv().NoClipEnabled=v toggleNoClip() end})

VisualsTab:AddToggle({Name="Player ESP",Default=false,Callback=function(v) getgenv().PlayerESPEnabled=v if not v then clearAllESP() end end})
VisualsTab:AddToggle({Name="Role ESP",Default=false,Callback=function(v) getgenv().RoleESPEnabled=v if not v then clearAllESP() end end})
VisualsTab:AddToggle({Name="Gun Dropped ESP",Default=false,Callback=function(v) getgenv().GunESPEnabled=v if not v then clearAllESP() end end})
VisualsTab:AddToggle({Name="Auto Grab Gun",Default=false,Callback=function(v) getgenv().AutoGrabGun=v end})
VisualsTab:AddButton({Name="Teleport to Gun",Callback=function() local c=LocalPlayer.Character local hrp=c and c:FindFirstChild("HumanoidRootPart") if not hrp then return end for gun,_ in pairs(activeGunHighlights) do if gun and gun.Parent then local gp=gun:IsA("BasePart") and gun or gun:FindFirstChildWhichIsA("BasePart") or gun:FindFirstChild("Normal") if gp then local orig=hrp.CFrame hrp.CFrame=gp.CFrame+Vector3.new(0,2,0) task.wait(0.15) hrp.CFrame=orig OrionLib:MakeNotification({Name="MAX Hub",Content="Gun grabbed!",Time=2}) return end end end OrionLib:MakeNotification({Name="MAX Hub",Content="Gun not dropped!",Time=2}) end})
VisualsTab:AddLabel({Text="👼 AURAS"})
VisualsTab:AddToggle({Name="Angel Wings Aura",Default=false,Callback=function(v) getgenv().AngelAuraEnabled=v if v then createAngelAura() else removeAngelAura() end end})

SettingsTab:AddLabel({Text="🌫️ WORLD"})
SettingsTab:AddToggle({Name="Fullbright",Default=false,Callback=function(v) getgenv().FullbrightEnabled=v if not v then Lighting.Ambient=origAmbient Lighting.OutdoorAmbient=origOutdoorAmbient Lighting.Brightness=origBrightness Lighting.FogEnd=origFogEnd end end})
SettingsTab:AddLabel({Text="🕐 TIME OF DAY"})
SettingsTab:AddButton({Name="Morning",Callback=function() setTime("morning") end})
SettingsTab:AddButton({Name="Day",Callback=function() setTime("day") end})
SettingsTab:AddButton({Name="Evening",Callback=function() setTime("evening") end})
SettingsTab:AddButton({Name="Night",Callback=function() setTime("night") end})
SettingsTab:AddLabel({Text="🎨 UI THEME"})
SettingsTab:AddButton({Name="Blue",Callback=function() getgenv().RainbowUIEnabled=false OrionLib:ChangeThemeColor(Color3.fromRGB(100,150,255)) end})
SettingsTab:AddButton({Name="Red",Callback=function() getgenv().RainbowUIEnabled=false OrionLib:ChangeThemeColor(Color3.fromRGB(255,75,75)) end})
SettingsTab:AddButton({Name="Green",Callback=function() getgenv().RainbowUIEnabled=false OrionLib:ChangeThemeColor(Color3.fromRGB(50,220,120)) end})
SettingsTab:AddButton({Name="Purple",Callback=function() getgenv().RainbowUIEnabled=false OrionLib:ChangeThemeColor(Color3.fromRGB(180,80,255)) end})
SettingsTab:AddButton({Name="🌸 Pink",Callback=function() getgenv().RainbowUIEnabled=false OrionLib:MakeNotification({Name="MAX Hub",Content="Pink theme!",Time=1}) OrionLib:ChangeThemeColor(Color3.fromRGB(255,105,180)) end})
SettingsTab:AddButton({Name="🥇 Gold",Callback=function() getgenv().RainbowUIEnabled=false OrionLib:ChangeThemeColor(Color3.fromRGB(255,215,100)) end})
SettingsTab:AddToggle({Name="Rainbow UI",Default=false,Callback=function(v) getgenv().RainbowUIEnabled=v end})
SettingsTab:AddLabel({Text="🔮 GLASS MODE"})
SettingsTab:AddToggle({Name="Liquid Glass Theme",Default=false,Callback=function(v) applyGlassMode(v) end})
SettingsTab:AddLabel({Text="🚀 PERFORMANCE"})
SettingsTab:AddButton({Name="FPS Unlocker: ON",Callback=function() pcall(function() setfpscap(9999) end) OrionLib:MakeNotification({Name="MAX Hub",Content="FPS Unlocked!",Time=2}) end})
SettingsTab:AddButton({Name="FPS Unlocker: 60",Callback=function() pcall(function() setfpscap(60) end) OrionLib:MakeNotification({Name="MAX Hub",Content="FPS: 60",Time=2}) end})
-- ОНЛАЙН-СЧЁТЧИК (нужен /api/ping на сервере)
do
    local label = SettingsTab:AddLabel({Text = "👥 Online: ..."})
    local sid = HttpService:GenerateGUID(false)

    local function ping()
        local ok, res = pcall(function() return game:HttpGet(apiBase .. "/ping?id=" .. sid) end)
        if ok and res then
            local ok2, d = pcall(function() return HttpService:JSONDecode(res) end)
            if ok2 and type(d) == "table" and d.online then
                label.Text = "👥 Online: " .. tostring(d.online)
                return
            end
        end
        label.Text = "👥 Online: —"
    end

    task.spawn(function()
        while (not RUN) or RUN.alive() do
            ping()
            task.wait(60)
        end
    end)
end
-- ==============================================
-- ❌ CLOSE + 🎯 HUB ICON + 📊 PING/FPS
-- ==============================================

-- ===== 1. КРЕСТИК ЗАКРЫТИЯ =====
local mainWindow = nil
local coreGui = game:GetService("CoreGui")
for _, gui in ipairs(coreGui:GetChildren()) do
    if gui.Name == "MAX Hub" or gui.Name == "MAXHub" then
        mainWindow = gui:FindFirstChild("MainWindow")
        break
    end
end

if mainWindow then
    -- Ищем Header (полоска сверху)
    local header = mainWindow:FindFirstChild("Frame") or mainWindow:GetChildren()[2]
    for _, child in ipairs(mainWindow:GetChildren()) do
        if child:IsA("Frame") and child.Size.Y.Scale == 0 and child.Size.Y.Offset == 32 then
            header = child
            break
        end
    end
    
    if header then
        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "CloseButton"
        closeBtn.Parent = header
        closeBtn.Size = UDim2.new(0, 24, 0, 24)
        closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
        closeBtn.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.TextSize = 16
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.ZIndex = 10
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 6)
        closeCorner.Parent = closeBtn

        closeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(mainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.wait(0.3)
    mainWindow.Visible = false
    if getgenv().HubIcon then
        getgenv().HubIcon.Visible = true
    end
end)
        
        closeBtn.MouseEnter:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play()
        end)
        closeBtn.MouseLeave:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 75, 75)}):Play()
        end)
    end
end

-- ===== 2. ИКОНКА ХАБА (плавающая, перетаскиваемая) =====
local hubIconGui = Instance.new("ScreenGui")
hubIconGui.Name = "MAXHubIconGui"
hubIconGui.Parent = coreGui
hubIconGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
hubIconGui.ResetOnSpawn = false
hubIconGui.IgnoreGuiInset = true

local hubIcon = Instance.new("ImageButton")
hubIcon.Name = "MAXHubIcon"
hubIcon.Size = UDim2.new(0, 50, 0, 50)
hubIcon.Position = UDim2.new(0, 20, 0.5, -25)
hubIcon.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
hubIcon.BorderSizePixel = 0
hubIcon.Image = "rbxassetid://131110531238687"  -- моя картинка фона (можете поставить свою)
hubIcon.ImageTransparency = 0.3
hubIcon.AutoButtonColor = false
hubIcon.Visible = true
hubIcon.Parent = hubIconGui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(1, 0)
iconCorner.Parent = hubIcon

local iconStroke = Instance.new("UIStroke")
iconStroke.Color = Color3.fromRGB(255, 215, 100)
iconStroke.Thickness = 2
iconStroke.Transparency = 0.2
iconStroke.Parent = hubIcon

getgenv().HubIcon = hubIcon

-- Перетаскивание
local dragging = false
local dragStart = nil
local startPos = nil

hubIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = hubIcon.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

hubIcon.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            hubIcon.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end)

-- Открытие/закрытие хаба при клике (toggle)
local clickStart = nil
hubIcon.MouseButton1Down:Connect(function()
    clickStart = tick()
end)

hubIcon.MouseButton1Up:Connect(function()
    if clickStart and (tick() - clickStart) < 0.2 then
        if mainWindow then
            if mainWindow.Visible then
                -- Закрываем хаб
                TweenService:Create(mainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0)
                }):Play()
                task.wait(0.3)
                mainWindow.Visible = false
                hubIcon.Visible = true  -- показываем иконку
            else
                -- Открываем хаб
                mainWindow.Visible = true
                mainWindow.Size = UDim2.new(0, 0, 0, 0)
                TweenService:Create(mainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 480, 0, 360)
                }):Play()
                hubIcon.Visible = true  -- иконка остаётся видимой (можно скрыть если хочешь)
            end
        end
    end
    clickStart = nil
end)
-- Анимация пульсации
task.spawn(function()
    while hubIconGui and hubIconGui.Parent do
        if hubIcon.Visible then
            TweenService:Create(iconStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.7,
                Thickness = 3
            }):Play()
            task.wait(1)
            TweenService:Create(iconStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.2,
                Thickness = 2
            }):Play()
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

-- ===== 3. PING + FPS =====
local statsGui = Instance.new("ScreenGui")
statsGui.Name = "MAXHubStats"
statsGui.Parent = coreGui
statsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
statsGui.ResetOnSpawn = false
statsGui.IgnoreGuiInset = true

local statsFrame = Instance.new("Frame")
statsFrame.Name = "Stats"
statsFrame.Size = UDim2.new(0, 130, 0, 50)
statsFrame.Position = UDim2.new(1, -140, 0, 10)
statsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
statsFrame.BackgroundTransparency = 0.3
statsFrame.BorderSizePixel = 0
statsFrame.Parent = statsGui

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = statsFrame

local statsStroke = Instance.new("UIStroke")
statsStroke.Color = Color3.fromRGB(255, 215, 100)
statsStroke.Thickness = 1.5
statsStroke.Transparency = 0.3
statsStroke.Parent = statsFrame

local pingLabel = Instance.new("TextLabel")
pingLabel.Name = "PingLabel"
pingLabel.Size = UDim2.new(1, -10, 0.5, 0)
pingLabel.Position = UDim2.new(0, 5, 0, 3)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "📡 Ping: ---"
pingLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
pingLabel.TextSize = 13
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextXAlignment = Enum.TextXAlignment.Left
pingLabel.Parent = statsFrame

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FpsLabel"
fpsLabel.Size = UDim2.new(1, -10, 0.5, 0)
fpsLabel.Position = UDim2.new(0, 5, 0.5, -2)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "🎮 FPS: ---"
fpsLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
fpsLabel.TextSize = 13
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Parent = statsFrame

-- Обновление Ping
task.spawn(function()
    while statsGui and statsGui.Parent do
        local ping = 0
        pcall(function()
            ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        local pingColor = Color3.fromRGB(100, 255, 150)
        if ping > 100 then pingColor = Color3.fromRGB(255, 255, 100) end
        if ping > 200 then pingColor = Color3.fromRGB(255, 100, 100) end
        pingLabel.Text = "📡 Ping: "..ping.."ms"
        pingLabel.TextColor3 = pingColor
        task.wait(1)
    end
end)

-- Обновление FPS
task.spawn(function()
    local fpsCount = 0
    local lastTime = tick()
    RUN.track(RunService.RenderStepped:Connect(function()
        fpsCount = fpsCount + 1
    end))
    while statsGui and statsGui.Parent do
        task.wait(1)
        local currentTime = tick()
        local fps = math.floor(fpsCount / (currentTime - lastTime))
        fpsCount = 0
        lastTime = currentTime
        local fpsColor = Color3.fromRGB(100, 200, 255)
        if fps < 60 then fpsColor = Color3.fromRGB(255, 255, 100) end
        if fps < 30 then fpsColor = Color3.fromRGB(255, 100, 100) end
        fpsLabel.Text = "🎮 FPS: "..fps
        fpsLabel.TextColor3 = fpsColor
    end
end)

-- Кнопка для показа/скрытия статистики
SettingsTab:AddLabel({Text="📊 STATS"})
SettingsTab:AddToggle({Name="Show Ping/FPS",Default=true,Callback=function(v)
    statsFrame.Visible = v
end})
