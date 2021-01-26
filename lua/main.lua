
local modules = (...):gsub(".[^.]+.[^.]+$", '') .. "."
local class = require('pl.class')
local tablex = require('pl.tablex')
local pretty = require('pl.pretty')

local client = Client(
    arg[2],
    "asset_sample"
)

-- The AssetManager takes care of sending and receiving assets
local assets = Asset.Manager(client.client)

-- Parent of all asset views
local mainView = ui.View(ui.Bounds(0, 1.5, 0,   1, 1, 1))
local pos = 0

-- For each entry in files.txt
for line in io.lines("files.txt") do
    print("Adding ".. line)
    -- We add a FileAsset
    local asset = Asset.File(line)
    assets:add(asset)

    -- And set up an entity to display it
    local view = Asset.View(asset, ui.Bounds(pos, 0, 0,   1, 0.5, 0.1))
    mainView:addSubview(view)
    
    -- Move over the next one a bit
    pos = pos + 1.5
end


local app = App(client)
app.mainView = mainView
app:connect()
app:run()