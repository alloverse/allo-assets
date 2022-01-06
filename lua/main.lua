
local modules = (...):gsub(".[^.]+.[^.]+$", '') .. "."
local class = require('pl.class')
local tablex = require('pl.tablex')
local pretty = require('pl.pretty')
local vec3 = require'allo.deps.alloui.lib.cpml.modules.vec3'

local host = arg[2]
local client = Client(host, "asset_sample" )
local app = ui.App(client)


-- State for the current selection
local current = 1

-- List of our assets
local assets = {}

-- list of convertsoin jobs
local conversion = {}

local images = {
    quit = ui.Asset.File("images/quit.png"),
}
app.assetManager:add(images)

local models = { "helmet", "sphere", "torus", "cylinder", }
-- For each entry in files.txt
for _, name in ipairs(models) do
    -- we create FileAssets
    local asset = Asset.File("assets/"..name..".glb")
    asset.name = name
    table.insert(assets, asset)
end

-- The AssetManager takes care of serving assets added to it.
app.assetManager:add(assets)

-- Setup a view to display the seleted asset
local assetView = ui.View(ui.Bounds(0, 0, 0))
assetView.specification = function (self)
    local spec = ui.View.specification(self)
    spec.geometry = {
        type = "asset",
        name = assets[current]:id(),
    }
    spec.material = { shader_name = "pbr" }
    return spec
end

-- Add a label to display the name
local label = ui.Label({
    bounds = ui.Bounds(0, 0.7, 0,   1, 0.15, 0.1),
    text = "Asset Preview",
    lineheight = 0.1,
})

-- and navigation buttons to go back and forth between assets
local prev = ui.Button(ui.Bounds(-1, 0, 0,   0.4, 0.4, 0.1))
prev.label:setText("<-")
local next = ui.Button(ui.Bounds( 1, 0, 0,   0.4, 0.4, 0.1))
next.label:setText("->")

local quitButton = app.mainView:addSubview(ui.Button(ui.Bounds( 1, 0.5, 0,   0.1, 0.1, 0.1)))
quitButton:setDefaultTexture(images.quit)
quitButton.onActivated = function()
    app:quit()
end

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

function add(asset, name, scale)
    scale = scale or 1
    asset.name = name or asset.name
    table.insert(assets, asset)
    current = #assets
    label:setText(asset.name or asset:id())
    assetView.bounds:scale(scale, scale, scale)
    assetView:updateComponents(assetView:specification())
end

-- Initiate state
switch(0)

-- Connect buttons
prev.onActivated = function() switch(-1) end
next.onActivated = function() switch(1) end

-- Add a little bit of animation
local animate = false
app:scheduleAction(0.03, true, function()
    if app.connected and animate then 
        assetView.bounds:rotate(3.14/180, 0, 1, 0)
        assetView:updateComponents(assetView:specification())
    end
end)

app:scheduleAction(1, true, function()
    if app.connected then
        for id, item in pairs(conversion) do
            print("check " .. id)
            local asset = item:check()
            if asset then
                app.assetManager:add(asset, tonumber)
                add(asset, item.filename, item.scale)
                conversion[id] = nil
            end
        end
    end
end)

-- Toggle animation when model is touched
app.mainView.onTouchDown = function()
    animate = not animate
end

local function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

-- allow user to drop files onto viewer to display them
app.mainView.acceptedFileExtensions = {'glb', 'scad'}
app.mainView.onFileDropped = function(view, filename, asset_id)
    print("Got a file dropped on me ", filename, asset_id, "Downloading and displaying it...")
    -- load and publish the asset
    if ends_with(filename, ".glb") then 
        app.assetManager:load(asset_id, function (name, asset)
            if not asset then 
                print("Did not manage to download ".. name)
                return
            end
            app.assetManager:add(asset, true)
            add(asset, filename)
        end)
    elseif ends_with(filename, ".scad") then
        print("SCAD")
        app.assetManager:load(asset_id, function (name, asset)
            if not asset then 
                print("Did not manage to download ".. name)
                return
            end

            conversion[asset:id()] = {
                openscadpath = "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD",
                blenderpath = "/Volumes/Data/Applications/Blender.app/Contents/MacOS/Blender",
                filename = filename,
                asset = asset,
                scadfile = "source."..filename,
                resultfile = "result."..filename,
                scale = 0.01,
                start = function (self)
                    local scadfile = io.open(self.scadfile, "wb")
                    assert(scadfile)
                    scadfile:write(asset.data)
                    scadfile:close()

                    self.handle = io.popen("sh convert_scad.sh \"" .. self.scadfile .. "\" \"" .. self.resultfile .. "\" &")
                end,
                check = function (self)
                    local resultfile = io.open(self.resultfile, "rb")
                    if resultfile == nil then
                        print("no result")
                        return nil
                    else
                        print("reading result")
                        local asset = Asset(resultfile:read("*a"))
                        resultfile:close()
                        self.handle:close()
                        os.remove(self.resultfile)
                        return asset
                    end
                end,
            }

            conversion[asset:id()]:start()
        end)
    end
end

if app:connect() then app:run() end
