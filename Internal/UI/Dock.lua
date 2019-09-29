--[[

MIT License

Copyright (c) 2019 Mitchell Davis <coding.jackalope@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]

local DrawCommands = require(SLAB_PATH .. '.Internal.Core.DrawCommands')
local MenuState = require(SLAB_PATH .. '.Internal.UI.MenuState')
local Mouse = require(SLAB_PATH .. '.Internal.Input.Mouse')
local Style = require(SLAB_PATH .. '.Style')

local Dock = {}

local Instances = {}
local Pending = nil

local function GetOverlayBounds(Type)
	local X, Y, W, H = 0, 0, 0, 0
	local ViewW, ViewH = love.graphics.getWidth(), love.graphics.getHeight()
	local Offset = 75

	if Type == 'Left' then
		W = 100
		H = 150
		X = Offset
		Y = ViewH * 0.5 - H * 0.5
	elseif Type == 'Right' then
		W = 100
		H = 150
		X = ViewW - Offset - W
		Y = ViewH * 0.5 - H * 0.5
	elseif Type == 'Bottom' then
		W = ViewW * 0.55
		H = 100
		X = ViewW * 0.5 - W * 0.5
		Y = ViewH - Offset - H
	end

	return X, Y, W, H
end

local function DrawOverlay(Type)
	local X, Y, W, H = GetOverlayBounds(Type)
	local Color = {0.29, 0.59, 0.83, 0.65}
	local TitleH = 14
	local Spacing = 6

	local MouseX, MouseY = Mouse.Position()
	if X <= MouseX and MouseX <= X + W and Y <= MouseY and MouseY <= Y + H then
		Color = {0.50, 0.75, 0.96, 0.65}
		Pending = Type
	end

	DrawCommands.Rectangle('fill', X, Y, W, TitleH, Color)
	DrawCommands.Rectangle('line', X, Y, W, TitleH, {0, 0, 0, 1})

	Y = Y + TitleH + Spacing
	H = H - TitleH - Spacing
	DrawCommands.Rectangle('fill', X, Y, W, H, Color)
	DrawCommands.Rectangle('line', X, Y, W, H, {0, 0, 0, 1})
end

local function GetInstance(Id)
	if Instances[Id] == nil then
		local Instance = {}
		Instance.Id = Id
		Instance.Windows = {}
		Instances[Id] = Instance
	end
	return Instances[Id]
end

function Dock.DrawOverlay()
	DrawCommands.SetLayer('Dock')
	DrawCommands.Begin()

	DrawOverlay('Left')
	DrawOverlay('Right')
	DrawOverlay('Bottom')

	DrawCommands.End()
end

function Dock.Commit(Window)
	if Pending ~= nil and Mouse.IsReleased(1) then
		local Instance = GetInstance(Pending)

		if Window ~= nil then
			Instance.Windows[Window.Id] = Window
		end

		Pending = nil
	end
end

function Dock.GetDock(WinId)
	for K, V in pairs(Instances) do
		if V.Windows[WinId] ~= nil then
			return K
		end
	end

	return nil
end

function Dock.GetBounds(Type)
	local X, Y, W, H = 0, 0, 0, 0
	local ViewW, ViewH = love.graphics.getWidth(), love.graphics.getHeight()
	local MainMenuBarH = MenuState.MainMenuBarH
	local TitleH = Style.Font:getHeight()

	if Type == 'Left' then
		Y = MainMenuBarH
		W = 150
		H = ViewH - Y - TitleH
	elseif Type == 'Right' then
		X = ViewW - 150
		Y = MainMenuBarH
		W = 150
		H = ViewH - Y - TitleH
	elseif Type == 'Bottom' then
		Y = ViewH - 150
		W = ViewW
		H = 150
	end

	return X, Y, W, H
end

function Dock.AlterOptions(WinId, Options)
	Options = Options == nil and {} or Options

	for Id, Instance in pairs(Instances) do
		if Instance.Windows[WinId] ~= nil then

			Options.AllowMove = false
			Options.Layer = 'Dock'
			if Id == 'Left' then
				Options.SizerFilter = {'E'}
			elseif Id == 'Right' then
				Options.SizerFilter = {'W'}
			elseif Id == 'Bottom' then
				Options.SizerFilter = {'N'}
			end

			break
		end
	end
end

return Dock
