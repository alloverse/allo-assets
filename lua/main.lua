
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

local files = { "sphere", "helmet", "torus", "cylinder", }

-- For each entry in files.txt
for _, name in ipairs(files) do
    local file = "assets/"..name..".glb"
    -- We add a FileAsset
    local asset = Asset.File(file)
    assets:add(asset)

    -- And set up an entity to display it
    local view = Asset.View(asset, ui.Bounds(pos, 0, 0,   1, 0.5, 0.1))
    mainView:addSubview(view)
    
    -- Move over the next one a bit
    pos = pos + 1.5
end


local app = ui.App(client)
app.mainView = mainView
if app:connect() then app:run() end