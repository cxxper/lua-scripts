-- COMRP Job Automation script by MNGC
--
-- TODO: 
-- - check if player is still in a shipment vehicle
-- - miner job
-- - code improvements

-- this script requires moonloader and sampfuncs functions to work.
require "moonloader"
require "sampfuncs"

-- to allow the use of config files [.ini] in our script.
local inicfg = require "inicfg"

-- to allow the use of certain functions (samponservermessage) to work.
local sampev = require "lib.samp.events"

-- our variables to be loaded/written on our config file.
inifile = "MNGC.ini"
local config = inicfg.load(inicfg.load({
	Global = {
	        AutomateShipment = true,
          	AutomatePizza = true,
        	AutomateGetCrates = false, 
	        AutomateMiner = true,
	},
	GetCratesConfig = {
		enablePot = true,
		enableCrack = true,
		enableMP1 = true,
		enableMP2 = true,
		enableAll = true,
		enableBoat = true,
		enableAir = true
	},
	Placeholder = {
		Automate1 = false,
		Automate2 = false,
		Automate3 = false,
	}
}, inifile ))

toggle_crates = 0

-- FUNCTIONS... --

function main()
-- check if sampfuncs or samp is loaded, if not terminate the script.
        if not isSampLoaded() or not isSampfuncsLoaded()
		then
			return
		end
		-- wait until samp is loaded.
	while not isSampAvailable() do
		wait (100)
	end
	-- Initialize the commands for this script
        init_cmds()
	sampAddChatMessage("MNGC Automation Script initialized.", -1)
	-- save changes to the ini
	save()
	while true do -- initialize autogetcrates and autogetpizza functions 
		init_autogetcrates()
		init_pizza()
	end	
	wait(-1)
end

function save()
	inicfg.save(config, inifile)
end

function init_cmds()
	-- our commands
        sampRegisterChatCommand("togshipment", togshipment)
        sampRegisterChatCommand("togcrate", togcrate)
        sampRegisterChatCommand("togpizza", togpizza)
        sampRegisterChatCommand("togminer", togminer)
	sampRegisterChatCommand("mine", startmining)
end

-- SHIPMENT & AUTOGETCRATES --

function sampev.onServerMessage(color, text)
	-- find the string in player's chatbox
	local crates = string.find(text, "All current checkpoints")
	if crates and config.Global.AutomateGetCrates then
		toggle_crates = 1
	end
	local ship1, msg = string.find(text, "This vehicle's engine is not running")
	local ship2, msg2 = string.find(text, "SHIPMENT CONTRACTOR:")
	-- activate if AutomateShipment returns true and found strings ship1 and ship2
	if config.Global.AutomateShipment then
         	if ship2 then
		          check2 = true	
	        end

	        if ship1 then
		          check1 = true
         	end
		if check2 and check1 then
		          sampSendChat("/loadshipment")
		          sampSendChat("/car engine")
	 	          sampAddChatMessage("automatic loadshipment success", 0xFFFFFF)
		          check1 = false
		          check2 = false
	        end
	end
end

function togshipment()
	-- check if AutomateShipment returns true.
	if config.Global.AutomateShipment then -- if it is then disable it.
		config.Global.AutomateShipment = false
		check1 = false
		check2 = false
		save()
		sampAddChatMessage("toggled autoshipment off", -1) 
	else
		config.Global.AutomateShipment = true -- otherwise if it's disabled enable it.
		save() -- save changes to ini
		sampAddChatMessage("toggled autoshipment on", -1)
	end
end

-- AutoGetCrates --

function init_autogetcrates()
	       -- check if it's enabled
        if config.Global.AutomateGetCrates then
		if config.GetCratesConfig.enableAll then
			if config.GetCratesConfig.enablePot and isCharInArea2d(playerPed, 69.0425,-293.7464,61.8631,-291.9752, false) then
				-- if auto get crate pot is enabled and player is in certain area, send the command to server
				sampSendChat("/getcrate")
				wait(500)
				sampSendChat("pot")
				wait(1000)
			end
			if config.GetCratesConfig.enableCrack and isCharInArea2d(playerPed,69.0425,-293.7464,61.8631,-291.9752, false) then
				sampSendChat("/getcrate")
				wait(500)
				sampSendChat("crack")
				wait(1000)
			end
		end
		wait(0)
	end
end

function togcrate(args)
        if #args == 0 then
		sampAddChatMessage("Usage: /togcrate (pot / crack)", -1)
	end
	-- check if the argument provided is "pot"
	if (args == "pot" or args == "POT" or args == "Pot") then
		if config.GetCratesConfig.enablePot then
		    config.GetCratesConfig.enablePot = false
			if save() then
				sampAddChatMessage("AutoGetCrates: disabled pot", -1)
			end
		else
			config.GetCratesConfig.enablePot = true
			if save() then
				sampAddChatMessage("AutoGetCrates: enabled pot", -1)
				config.GetCratesConfig.enableCrack = false
			end
		end
	end
	-- check if argument provided is "crack". 
	if (args == "crack" or args == "CRACK" or args == "Crack") then
		if config.GetCratesConfig.enableCrack then
			config.GetCratesConfig.enableCrack = false
			if save() then
				sampAddChatMessage("AutoGetCrates: disabled crack", -1)
			end
		else
			config.GetCratesConfig.enableCrack = true
			if save() then
				sampAddChatMessage("AutoGetCrates: enabled crack", -1)
				config.GetCratesConfig.enablePot = false
			end
		end
	end
end

-- AutoGetPizza --

function togpizza()
	-- check if automatepizza is enabled
	if config.Global.AutomatePizza then
		config.Global.AutomatePizza = false -- disables it
		sampAddChatMessage("get pizza automation off", -1)
	        save()
	else
		config.Global.AutomatePizza = true -- enables it
		sampAddChatMessage("get pizza automation on", -1)
	        save()	
	end
end

function init_pizza()
	-- same in autogetdrugcrates
        if config.Global.AutomatePizza then
		if isCharInModel(playerPed, 448) and isCharInArea2d(playerPed, 2106.1599,-1785.8787, 2100.1829,-1790.1743, false) then
			sampSendChat("/getpizza")
			sampAddChatMessage("DEBUG: success", -1)
			wait(3000)
		end
	end
end

-- WORK IN PROGRESS : MINER --

function init_miner()
   -- work in progress
         sampAddChatMessage("work in progress, expect bugs from this feature.", -1)
        if config.Global.AutomateMiner then
		if isCharInArea2d(playerPed, 2679.8337,-810.9595,2667.1487,-824.3948, false) then
			sampAddChatMessage("DEBUG: in area", -1)
		end
   end
end

function startmining()
	sampAddChatMessage("DEBUG: trying to mine", -1)
	setVirtualKeyDown(1, true)
	setVirtualKeyDown(1, false)
end

function togminer()
	if config.Global.AutomateMiner then
		config.Global.AutomateMiner = false
		save()
		sampAddChatMessage("Toggled autominer off", -1)
	else
		config.Global.AutomateMiner = true
		save()
		sampAddChatMessage("Toggled autominer on", -1)
	end
end
