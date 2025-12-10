
function os.getOrCreateSignal(name)
    return signals.getSignals()[name] or signals.new(name)
end

task.new(function()
    while true do
        local args = os.pullEventRaw()
        os.getOrCreateSignal(args[1]):Fire(unpack(args))
    end
end)

local function isInArea(x1,y1, x2,y2, x,y)
    return x1 < x and x < x2 and y1 < y and y < y2
end

function os.newButton(x1,y1, x2,y2, onMouseClick)
    local handle = {isActive = true}
    handle.conn = os.getOrCreateSignal("mouse_click"):Connect(function(event, button, x, y)
        if not handle.isActive then return end
        if not isInArea(x1,y1, x2,y2, x,y) then return end
        onMouseClick(x,y, button)
    end)
    return handle
end

local refresh_signal = os.getOrCreateSignal("refresh")
local refresh_events = {"mouse_click", "mouse_scroll", "mouse_up", "key", "key_up", "char"}

local function refresh(...)
    refresh_signal:Fire(...)
end

for _, event in pairs(refresh_events) do
    os.getOrCreateSignal(event):Connect(refresh)
end

os.onScreenRefresh = refresh_signal