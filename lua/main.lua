
local modules = (...):gsub(".[^.]+.[^.]+$", '') .. "."
local class = require('pl.class')
local tablex = require('pl.tablex')
local pretty = require('pl.pretty')

local client = Client(
    arg[2], 
    "asset_sample"
)



local mainView = ui.View(ui.Bounds(0, 1.5, 0,   1, 1, 1))
local pos = 0

local assets = Asset.Manager(client.client)

for line in io.lines("files.txt") do
    print("Adding ".. line)
    local asset = Asset.File(line)
    local view = Asset.View(asset, ui.Bounds(pos, 0, 0,   1, 0.5, 0.1))
    mainView:addSubview(view)
    assets:add(asset)
    pos = pos + 1.5
end


assets:add(head)

local app = App(client)

app.client.delegates.onConnected = function ()
    print("Connected!")
    
    assets:load("hello", function (name, asset)
        print("Finished ".. name .. ":", asset.data, asset:id())
    end)
end



app.mainView = mainView
app:connect()
app:run()