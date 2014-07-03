-----------------------------------------------------------------------------------------------
-- Client Lua Script for RuneInspector
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- RuneInspector Module Definition
-----------------------------------------------------------------------------------------------
local RuneInspector = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999

local setmetatable, pairs, ipairs = setmetatable, pairs, ipairs
local tostring, Print = tostring, Print
local random = math.random
local strformat = string.format
local tinsert, tremove = table.insert, table.remove
---

local runeTypes = {	
	[1] = "Water";
	[2] = "Fire";
	[3] = "Air";
	[4] = "Earth";
	[5] = "Logic";
	[6] = "Fusion";
	[7] = "Life"
}

--------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function RuneInspector:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function RuneInspector:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- RuneInspector OnLoad
-----------------------------------------------------------------------------------------------
function RuneInspector:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("RuneInspector.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- RuneInspector OnDocLoaded
-----------------------------------------------------------------------------------------------
function RuneInspector:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "RuneInspectorForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("ri", "OnRuneInspectorOn", self)
		Apollo.RegisterSlashCommand("rigear", "OnRuneInspectorGear", self)


		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- RuneInspector Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

function RuneInspector:GetItemRunes(item)
	local total = {}
	local free = {}
	for i,v in ipairs(runeTypes) do 
		total[v] = 0
		free[v] = 0
	end
	
	sigils = item:GetSigils()
	if sigils ~= nil then
		runes = sigils["arSigils"]
		for k,v in pairs(runes) do
			rName = v.strName
			total[rName] = total[rName] + 1
			if v.itemGlyph == nil then
				free[rName] = free[rName] + 1
			end
		end
	else
		return nil
	end

	local retVal = {}
	retVal["total"] = total
	retVal["free"] = free
	return retVal
end

function RuneInspector:GetRuneTotals()
	local me=GameLib.GetPlayerUnit()
	local eq=me:GetEquippedItems()

	local total = {}
	local free = {}

	for i,v in ipairs(runeTypes) do 
		total[v] = 0
		free[v] = 0
	end
	
	for key,item in pairs(eq) do
		local runes = self:GetItemRunes(item)
		if runes ~= nil then
			local iTotal = runes["total"]
			local iFree = runes["free"]
			for idx,runeType in ipairs(runeTypes) do
				total[runeType] = total[runeType] + iTotal[runeType]
				free[runeType] = free[runeType] + iFree[runeType]
			end
		end
	end

	local retVal = {}
	retVal["total"] = total
	retVal["free"] = free
	return retVal
end

-- on SlashCommand "/rigear"
-- Temporary command to list gear runeslots.
function RuneInspector:OnRuneInspectorGear()
	me=GameLib.GetPlayerUnit()
	eq=me:GetEquippedItems()
	for key,item in pairs(eq) do
		local runes = self:GetItemRunes(item)
		if runes ~= nil then
			local iTotal = runes["total"]
			local iFree  = runes["free"]
			local strRunes = ""
			for k,v in pairs(iTotal) do
				if tonumber(v) > 0 then
					strRunes = strRunes .. " " .. k .. ":" .. v
				end
			end
			Print(item:GetName() .. strRunes)
		end
	end
end

-- on SlashCommand "/ri"
function RuneInspector:OnRuneInspectorOn()
	local runes = self:GetRuneTotals()
	local total = runes["total"]
	local free = runes["free"]

	for idx,v in ipairs(runeTypes) do
		local totalTag = v .. "Total"
		local totalVal = strformat("%d",total[v])
		local freeTag = v .. "Free"
		local freeVal = strformat("%d",free[v])
		self.wndMain:FindChild(totalTag):SetText(totalVal)
		self.wndMain:FindChild(freeTag):SetText(freeVal)
	end
	self.wndMain:Show(true)
end

---------------------------------------------------------------------------------------------------
-- RuneInspectorForm Functions
---------------------------------------------------------------------------------------------------

function RuneInspector:OnCancel( wndHandler, wndControl, eMouseButton )
	self.wndMain:Show(false)
end

-----------------------------------------------------------------------------------------------
-- RuneInspector Instance
-----------------------------------------------------------------------------------------------
local RuneInspectorInst = RuneInspector:new()
RuneInspectorInst:Init()
