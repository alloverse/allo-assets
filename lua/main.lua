
local modules = (...):gsub(".[^.]+.[^.]+$", '') .. "."
local class = require('pl.class')
local tablex = require('pl.tablex')
local pretty = require('pl.pretty')

local host = arg[2]
local client = Client(host, "asset_sample" )

-- The AssetManager takes care of sending and receiving assets.
local assets = Asset.Manager(client.client)

-- For each entry in files.txt
for line in io.lines("files.txt") do
    -- we add a FileAsset to the manager
    local asset = Asset.File(line)
    asset.name = line:match(".+/(.+)%..+")
    assets:add(asset)
    print("Added " .. line .. " as " .. asset.name)
end

-- Setup a view to display the asset
local mainView = Asset.View(assets:get(1), ui.Bounds(0, 1.5, 0,   1, 1, 1))
-- a label to display the name
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
mainView:addSubview(prev)
mainView:addSubview(next)
mainView:addSubview(label)


-- Track the current selection
local current = 1

-- asset switching logic
function switch(dir)
    current = current + dir
    if current < 1 then current = assets:count() end
    if current > assets:count() then current = 1 end
    local asset = assets:get(current)
    mainView:asset(asset)
    label:setText(asset.name)
end

prev.onActivated = function ()
    switch(-1)
end

next.onActivated = function ()
    switch(1)
end

-- Initiate state
switch(0)

-- Run the app
local app = App(client)
app.mainView = mainView
app:connect()
app:run()