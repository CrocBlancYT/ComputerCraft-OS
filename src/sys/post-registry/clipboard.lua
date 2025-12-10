local content = ""

local cursor = os.cursor

local function copy()
    -- get selection from os.desktop and cursor
    content = ''
end

local function paste()
    os.queueEvent('paste', content)
end

local keys_down = os.keys_down

local function isSpecial(keyPressed, targetKey)
    return
        (keyPressed == 'leftShift') and (keys_down[targetKey]) or
        (keyPressed == targetKey) and (keys_down['leftShift'])
end

os.getOrCreateSignal("key"):Connect(function (event, key, is_held)
    if is_held then return end

    if isSpecial(key, 'c') then
        copy()
    elseif isSpecial(key, 'v') then
        paste()
    end
end)