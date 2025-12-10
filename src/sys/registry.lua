
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

local onScreenRefresh = os.getOrCreateSignal("refresh")
local function refreshScreen()
    os.desktop:clear()
    onScreenRefresh:Fire()
    os.desktop:render()
end

os.onScreenRefresh = onScreenRefresh
os.refreshScreen = refreshScreen

local keys_down = {}
os.keys_down = keys_down

local getKeyName = keys.getName
os.getOrCreateSignal("key"):Connect(function (event, key, is_held)
    keys_down[getKeyName(key)] = true
end)

os.getOrCreateSignal("key_up"):Connect(function (event, key)
    keys_down[getKeyName(key)] = false
end)

local width, height = term.getSize()

local desktop = os.newBuffer(width, height, colors.black)
local cursor = {
    fromX = nil, fromY = nil,
    toX = nil, toY = nil
}

os.desktop = desktop
os.cursor = cursor

local function toPixelId(x, y)
    return y * width + x
end

local function fromPixelId(id)
    local x = id % width
    local y = (id / width) - x
    return x, y
end

local function displayCursor()
    local pixel_from = toPixelId(cursor.fromX, cursor.fromY)
    local pixel_to = toPixelId(cursor.toX, cursor.toY)
    
    local blit = desktop[cursor.fromX][cursor.fromY]
    
    desktop[cursor.fromX][cursor.fromY] = {
        text = blit.text,
        textColor = blit.text == "" and blit.textColor or colors.toBlit(desktop.backgroundColor),
        backgroundColor = colors.toBlit(colors.white)
    }
    
    for pixel = pixel_from + 1, pixel_to do
        local x, y = fromPixelId(pixel)
        local blit = desktop[x][y]
        
        if not (blit.text == "") then
            desktop[x][y] = {
                text = blit.text,
                textColor = colors.toBlit(desktop.backgroundColor),
                backgroundColor = colors.toBlit(colors.grey)
            }
        end
    end
end

os.getOrCreateSignal("refresh"):Connect(displayCursor)

os.getOrCreateSignal("mouse_click"):Connect(function (event, button, x, y)
    if not (button == 1) then return end
    cursor.fromX = x
    cursor.fromY = y
    
    if not keys_down['leftShift'] then
        cursor.toX = x
        cursor.toY = y
    end
end)

os.getOrCreateSignal("mouse_drag"):Connect(function (event, button, x, y)
    if not (button == 1) then return end
    cursor.toX = x
    cursor.toY = y
end)
