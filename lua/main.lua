
local modules = (...):gsub(".[^.]+.[^.]+$", '') .. "."
local class = require('pl.class')
local tablex = require('pl.tablex')
local pretty = require('pl.pretty')

local host = arg[2]
local client = Client(host, "asset_sample" )
local app = App(client)


-- State for the current selection
local current = 1

-- List of our assets
local assets = {}

-- For each entry in files.txt
for line in io.lines("files.txt") do
    -- we create FileAssets
    local asset = Asset.File(line)
    asset.name = line:match(".+/(.+)%..+")
    table.insert(assets, asset)
    print("Added " .. line .. " as " .. asset.name)
end

-- The AssetManager takes care of serving assets added to it.
app.assetManager:add(assets)

-- Setup a view to display the seleted asset
local assetView = ui.View(ui.Bounds(0, 0, 0,   1, 1, 1))
assetView.specification = function (self)
    local spec = View.specification(self)
    spec.geometry = {
        type = "asset",
        name = assets[current]:id(),
    }
    return spec
end

-- Add a label to display the name
local label = ui.Label({
    bounds = ui.Bounds(0, 0.5, 0,   1, 1, 0.1),
    text = "Asset Preview",
    lineheight = 0.1,
})

-- and navigation buttons to go back and forth between assets
local prev = ui.Button(ui.Bounds(-1, 0, 0,   0.4, 0.4, 0.1))
prev.label:setText("<-")
local next = ui.Button(ui.Bounds( 1, 0, 0,   0.4, 0.4, 0.1))
next.label:setText("->")

-- Add all the views together
app.mainView.bounds = ui.Bounds(0, 1.5, 0,  1, 1, 0.1)
app.mainView.grabbable = true
app.mainView:addSubview(prev)
app.mainView:addSubview(next)
app.mainView:addSubview(label)
app.mainView:addSubview(assetView)

-- asset switching logic
function switch(dir)
    current = current + dir
    if current < 1 then current = #assets end
    if current > #assets then current = 1 end
    -- Set the new asset name
    label:setText(assets[current].name)
    -- Ask the asset view to send its new model information to the server
    assetView:updateComponents(assetView:specification())
end

-- Initiate state
switch(0)

-- Connect buttons
prev.onActivated = function() switch(-1) end
next.onActivated = function() switch(1) end

-- Add a little bit of animation
local animate = true
app:scheduleAction(0.01, true, function()
    if app.connected and animate then 
        assetView.bounds:rotate(3.14/180, 0, 1, 0)
        assetView:updateComponents(assetView:specification())
    end
end)

-- Toggle animation when model is touched
app.mainView.onInteraction = function (self, inter, body, sender)
    if body[1] == "poke" and body[2] then
        animate = not animate
    end
end

-- Run the app
app:connect()
app:run()