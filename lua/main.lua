
local modules = (...):gsub(".[^.]+.[^.]+$", '') .. "."
local class = require('pl.class')
local tablex = require('pl.tablex')
local pretty = require('pl.pretty')

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
            name = "85c96ef38aea6342df28"
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


local allonet = client.client

allonet:set_asset_request_callback(function (name, offset, length)
    print("Lua asset got a request for", name)
    local data = "Helo world"
    local chunk = string.sub(data, offset, offset + length)
    if name == "hello" then
        allonet:asset_send(name, "abc123", offset, string.len(data))
    else
        allonet:asset_send(name, nil, offset, 0)
    end
end)

-- Leave unassigned if you are not interrested receiving assets
allonet:set_asset_receive_callback(function (name, bytes, offset, total_size)
    -- Write the bytes received to your cache. 
    -- print("Received", string.len(bytes), " of", total_size, "bytes for asset", name, ":", bytes)
    print("Lua asset received some data")
end)

-- Leave unassigned if you are not interrested in assets
allonet:set_asset_state_callback(function (name, state)
    -- Called as asset availability on the network changes. 
    print("Lua asset state changed for", name)
end)



local app = App(client)

app.client.delegates.onConnected = function ()
    print("Connected!")
    -- Initiate a fetch of an asset. 
    -- Data for the asset will be provided on `receive_asset_callback` if the asset can be reached
    -- or `asset_state_callback` will be called with `navailable` state.
    allonet:asset_request("head")
end

local mainView = AssetBox(ui.Bounds(0, 1.5, 0,   1, 0.5, 0.1))
local button = ui.Button(ui.Bounds(0.0, 0.05, 0.0,   0.2, 0.2, 0.1))
local grabHandle = ui.GrabHandle(ui.Bounds( -0.5, 0.5, 0.3,   0.2, 0.2, 0.2))
-- mainView:addSubview(button)
-- mainView:addSubview(grabHandle)

button.onActivated = function()
    print("Hello!")
    begin()
end

app.mainView = mainView
app:connect()
app:run()