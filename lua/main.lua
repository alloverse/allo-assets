
local modules = (...):gsub(".[^.]+.[^.]+$", '') .. "."
local class = require('pl.class')
local tablex = require('pl.tablex')
local pretty = require('pl.pretty')

local client = Client(
    arg[2], 
    "asset_sample"
)

local assets = Asset.Manager(client.client)
local head = Asset.File("assets/DamagedHelmet.glb")
assets:add(head)


local app = App(client)

app.client.delegates.onConnected = function ()
    print("Connected!")
    
    assets:load("hello", function (name, asset)
        print("Finished ".. name .. ":", asset.data, asset:id())
    end)
end

local view = AssetView(head, ui.Bounds(0, 1.5, 0,   1, 0.5, 0.1))

app.mainView = view
app:connect()
app:run()