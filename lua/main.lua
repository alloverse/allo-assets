local client = Client(
    arg[2], 
    "asset_sample"
)
local app = App(client)

local mainView = ui.Surface(ui.Bounds(0, 0.7, 0,   1, 0.5, 0.1))
local button = ui.Button(ui.Bounds(0.0, 0.05, 0.0,   0.2, 0.2, 0.1))
local grabHandle = ui.GrabHandle(ui.Bounds( -0.5, 0.5, 0.3,   0.2, 0.2, 0.2))
mainView:addSubview(button)
mainView:addSubview(grabHandle)

button.onActivated = function()
    print("Hello!")
end

app.mainView = mainView
app:connect()
app:run()