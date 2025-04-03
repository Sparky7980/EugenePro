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

-- Add a Button control to the section.
Section1:Button({
    Title = "Kill All",
    ButtonName = "KILL!!",
    Description = "kills everyone",
}, function(value)
    print("Button pressed:", value)
end)

-- Add a Toggle control to the section.
Section1:Toggle({
    Title = "Auto Farm Coins",
    Description = "Optional Description here",
    Default = false,
}, function(value)
    print("Toggle changed:", value)
end)

-- Add a Slider control to the section.
Section1:Slider({
    Title = "Walkspeed",
    Description = "",
    Default = 16,
    Min = 0,
    Max = 120,
}, function(value)
    print("Slider value:", value)
end)

-- Add a ColorPicker control to the section.
Section1:ColorPicker({
    Title = "Colorpicker",
    Description = "",
    Default = Color3.new(1, 0, 0),  -- Note: Color3.new expects values between 0 and 1.
}, function(value)
    print("Color selected:", value)
end)

-- Add a Textbox control to the section.
Section1:Textbox({
    Title = "Damage Multiplier",
    Description = "",
    Default = "",
}, function(value)
    print("Textbox value:", value)
end)

-- Add a Keybind control to the section.
Section1:Keybind({
    Title = "Kill All",
    Description = "",
    Default = Enum.KeyCode.Q,
}, function(value)
    print("Keybind pressed:", value)
end)
