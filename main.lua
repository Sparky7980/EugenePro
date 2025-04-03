-- Load the HydraHub UI library from GitHub
local UILib = loadstring(game:HttpGet('https://raw.githubusercontent.com/StepBroFurious/Script/main/HydraHubUi.lua'))()

-- Create a new window. (Parameters: game name, userId, rank)
local Window = UILib.new("EugenePro", game.Players.LocalPlayer.UserId, "Premium")

-- Create a category (with an icon asset)
local Category1 = Window:Category("Main", "http://www.roblox.com/asset/?id=8395621517")

-- Create a sub-button under the category (with its own icon)
local SubButton1 = Category1:Button("Combat", "http://www.roblox.com/asset/?id=8395747586")

-- Create a section in the sub-button. The second parameter defines the side ("Left" or "Right")
local Section1 = SubButton1:Section("Section", "Left")

-- Add a Button control for toggling invisibility.
Section1:Button({
    Title = "Invisible",
    ButtonName = "Toggle Invisible",
    Description = "Makes you invisible when pressed",
}, function(value)
    local player = game.Players.LocalPlayer
    if player and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = part.Transparency == 0 and 1 or 0
            end
        end
        print("Invisibility toggled.")
    end
end)

-- Add a Button control for emergency kick (kicks the user automatically when pressed).
Section1:Button({
    Title = "Emergency Kick",
    ButtonName = "Kick Me",
    Description = "Immediately kicks you from the game",
}, function(value)
    local player = game.Players.LocalPlayer
    if player then
        player:Kick("Emergency Kick triggered.")
    end
    print("Emergency kick executed.")
end)

-- Add a Slider control for Walkspeed.
Section1:Slider({
    Title = "Walkspeed",
    Description = "",
    Default = 16,
    Min = 0,
    Max = 120,
}, function(value)
    print("Slider value:", value)
end)

-- Add a ColorPicker control.
Section1:ColorPicker({
    Title = "Colorpicker",
    Description = "",
    Default = Color3.new(1, 0, 0),
}, function(value)
    print("Color selected:", value)
end)
