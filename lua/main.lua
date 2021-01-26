
local modules = (...):gsub(".[^.]+.[^.]+$", '') .. "."
local class = require('pl.class')
local tablex = require('pl.tablex')
local pretty = require('pl.pretty')
require 'asset'


local head = FileAsset("assets/DamagedHelmet.glb")

function readall(filename)
    local fh = assert(io.open(filename, "rb"))
    local contents = assert(fh:read(_VERSION <= "Lua 5.2" and "*a" or "a"))
    fh:close()
    return contents
end

class.AssetBox(ui.View)
function AssetBox:_init(bounds)
    self:super(bounds)
    self.texture = nil
    self.color = nil
end

function AssetBox:specification()
    local s = self.bounds.size
    local w2 = s.width / 2.0
    local h2 = s.height / 2.0
    local mySpec = tablex.union(ui.View.specification(self), {
        geometry = {
            type = "asset",
            name = head:id()
        },
        material = {
        },
    })
    if self.texture then
      mySpec.material.texture = self.texture
    end
    if self.color then
      mySpec.material.color = self.color
    end
    return mySpec
end

-- Set a base64-encoded png texture on a surface.
-- Use e g https://www.base64-image.de/ to convert your image to base64.
-- Please keep this small, as this base64 hack is very resource intensive.
function AssetBox:setTexture(base64png)
    self.texture = base64png
    if self:isAwake() then
      local mat = self:specification().material
      self:updateComponents({
          material= mat
      })
    end
end

function AssetBox:setColor(rgba)
    self.color = rgba
    if self:isAwake() then
      local mat = self:specification().material
      self:updateComponents({
          material= mat
      })
    end
end


local client = Client(
    arg[2], 
    "asset_sample"
)


local assets = AssetManager(client.client)

assets:add(head)

local app = App(client)

app.client.delegates.onConnected = function ()
    print("Connected!")
    
    assets:load("hello", function (name, asset)
        print("Finished ".. name .. ":", asset.data, asset:id())
    end)
end

local mainView = AssetBox(ui.Bounds(0, 1.5, 0,   1, 0.5, 0.1))
local button = ui.Button(ui.Bounds(0.0, 0.05, 0.0,   0.2, 0.2, 0.1))
local grabHandle = ui.GrabHandle(ui.Bounds( -0.5, 0.5, 0.3,   0.2, 0.2, 0.2))
-- mainView:addSubview(button)
-- mainView:addSubview(grabHandle)

button.onActivated = function()
    print("Hello!")
end

app.mainView = mainView
app:connect()
app:run()