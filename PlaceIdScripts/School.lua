local services = setmetatable({},{__index = function(_,serv) return game:GetService(serv) end})
local classRemotes = services.ReplicatedStorage.Classes
local prevConnections = {}

local localPlayer = services.Players.LocalPlayer

function fireBack(remote, times, ...)
    local args = {...}
    return remote.OnClientEvent:Connect(function()
        for i = 0, times do
            remote:FireServer(unpack(args))
        end
    end)
end

local classFuncs = {
    swimming = function() end,
    
    art = function() 
        local function getCanvasData()
            local canvas = {}
            for _,part in next, workspace.ArtClassReal.MainEasel.CanvasToCopy:GetChildren() do
                canvas[part.Name] = part.BrickColor.Number
            end
            return canvas
        end
        
        local function fillCanvas()
            for name,num in next, getCanvasData() do
                services.ReplicatedStorage.Tools.Paint.SetColor:FireServer(workspace.ArtClassReal.Easel.Canvas:FindFirstChild(name), BrickColor.new(num))
            end
        end
		
		
        return {
            classRemotes.BookCheck.OnClientEvent:Connect(function()
                task.wait(1)
                fillCanvas()
            end)
        }
    end,
    
    computer = function()
        return {fireBack(classRemotes.Computer, 1, 1)}
    end,

    chemistry = function()
        return {fireBack(classRemotes.Chemistry, 1, "SequenceDone")}
    end,

    pe = function()
        return {
            classRemotes.Timer.OnClientEvent:Connect(function()
		localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1604, 20, 9)
		task.wait(1)
		if not workspace:FindFirstChild("PE Class") then return end
                fireclickdetector(workspace["PE Class"].Bell.ClickDetector, 4)
            end)   
        }
    end,
    
    english = function()
        local label = localPlayer.PlayerGui.EnglishClass.Frame.question
        return {
            label:GetPropertyChangedSignal("Text"):Connect(function()
                classRemotes.English:FireServer(label.Parent.D.Answer.Value)
            end)
        }   
    end,

    baking = function()
        local flavorFrame = localPlayer.PlayerGui.Baking.FlavorSelect
        local linerFrame = localPlayer.PlayerGui.Baking.LinerSelect
        local icingFrame = localPlayer.PlayerGui.Baking.IcingSelect
        local addedIndex = 0

        fireBackData = {
            {services.ReplicatedStorage.Cooking.Butter, 1},
            {services.ReplicatedStorage.Cooking.Sugar, 15},
            {services.ReplicatedStorage.Cooking.Mixer, 1, 300},
            {services.ReplicatedStorage.Cooking.Flour, 15},
            {services.ReplicatedStorage.Cooking.Milk, 1}
        }

        function getFireBackConns()
            local connections = {}
            for _,data in next, fireBackData do
                table.insert(connections, fireBack(data[1], data[2], data[3]))
            end
            return connections
        end

        function getFrameConns()
            local connections = {}
            for i,frame in next, {flavorFrame, linerFrame, icingFrame} do
                table.insert(connections, frame:GetPropertyChangedSignal("Visible"):Connect(function()
                    if frame.Visible then
                        task.wait(.6)
                        getconnections(frame:FindFirstChildOfClass("TextButton").MouseButton1Click)[1]:Fire()

                        if i == 3 then
                            task.wait(.6)
                            services.ReplicatedStorage.Cooking.Toppings:FireServer("Done", "")
                            localPlayer.PlayerGui.Baking.Enabled = false
                        end
                    end
                end))
            end
            return connections
        end

        function getAllConns()
            local t1 = getFireBackConns()
            local t2 = getFrameConns()
            for _,connection in next, t2 do
                table.insert(t1, connection)
            end
            return t1
        end

        return {
            classRemotes.BookCheck.OnClientEvent:Connect(function()
                fireclickdetector(workspace.BakingCounters.CounterStuff.ClaimButton.ClickDetector, 5)
            end),

            services.ReplicatedStorage.Cooking.Egg.OnClientEvent:Connect(function(p1)
                if not p1 then return end
                fireclickdetector(workspace.BakingCounters.CounterStuff.BakingCupcakesIngredients.egg.ClickDetector, 3)
                task.wait(3.5)
                fireclickdetector(workspace.BakingCounters.CounterStuff.BakingCupcakesIngredients.egg.ClickDetector, 3)
            end),

            localPlayer.Character.ChildAdded:Connect(function(child)
                if child.Name == "Cupcake Pan" then
                    if addedIndex == 0 then
                        localPlayer.Character.Humanoid:MoveTo(workspace.BakingCounters.CounterStuff.Oven.Door.Position)
                    else
                        localPlayer.Character.Humanoid:MoveTo(workspace.BakingCounters.CounterStuff.Place.Position)
                    end
                    addedIndex += 1
                end
            end),

            unpack(getAllConns())
        }
    end
}

classRemotes.Starting.OnClientEvent:Connect(function(class)
    local class = string.lower(string.gsub(class, " class", ""))
    if not classFuncs[class] then return end
    game:GetService("ReplicatedStorage").Classes.Starting:FireServer()

    local newConnections = classFuncs[class]() or {}

    for _,connection in next, prevConnections do
        connection:Disconnect()
    end; prevConnections = {}

    for _,connection in next, newConnections do
        table.insert(prevConnections, connection)
    end
end)

localPlayer.ChildAdded:Connect(function(child)
    if child.Name == "Homework" then
        repeat task.wait() until child:FindFirstChildOfClass("BoolValue")
        for i,homework in next, child:GetChildren() do
            homework.Complete:FireServer()
            task.wait(.5)
            fireclickdetector(workspace["Homeworkbox_" .. homework.Name].Click.ClickDetector, 3)
            if i == 3 then
                task.wait(4)
                services.ReplicatedStorage.SceptorTeleport:FireServer("BeachHouse")
            end
        end
    end
end)

local function getLocker()
    local closestMag = math.huge; local closetLocker;
    for _,door in next, workspace:GetDescendants() do
        if door:IsA("MeshPart") and door.Name == "LockerDoor" then
            local mag = (door.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
            if mag < closestMag then closestMag = mag; closestLocker = door end
        end
    end
    return closestLocker
end

local function getBooks()
    repeat task.wait() until #localPlayer.Locker:GetChildren() == 5
    task.wait(10)
    
    local locker = getLocker()
    fireclickdetector(locker.ClickDetector)
    services.ReplicatedStorage.Lockers.Code:FireServer(locker, "0000", "Create")

    for _,book in next, localPlayer.Locker:GetChildren() do
        services.ReplicatedStorage.Lockers.Contents:InvokeServer("Take", book)
    end

    localPlayer.PlayerGui.Locker.Enabled = false
end

getBooks()
