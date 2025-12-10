local buffer = {}

local function lerp(a, b, alpha)
    return a + (b - a) * alpha
end

function buffer:drawLine(x1,y1, x2,y2, blit)
    -- simple but prob unefficient (sqrt operation) // use algorithm raycast instead
    local max_dist = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
    for dist = 0, max_dist do
        self[lerp(x1, x2, dist/max_dist)][lerp(y1, y2, dist/max_dist)] = blit
    end
    return self
end

function buffer:drawSquare(x1,y1, x2,y2, blit)
    for x = x1, x2 do
        for y = y1, y2 do
            self[x][y] = blit
        end
    end
    return self
end

-- function window:drawEllipse() end -- future implementation

function buffer:render()
    for _, line in pairs(self) do
        for _, blit in pairs(line) do
            term.blit(blit.text, blit.textColor, blit.backgroundColor)
        end
    end
    return self
end

function buffer:clear()
    local backgroundColor = self.backgroundColor
    
    for x = 1, self.xSize do
        local line = {}
        for y = 1, self.ySize do
            line[y] = {
                text = '',
                textColor = backgroundColor,
                backgroundColor = backgroundColor,
            }
        end
        self[x] = line
    end

    return self
end

function os.newBuffer(xSize, ySize, backgroundColor)
    local instance = {
        xSize = xSize, ySize = ySize,
        backgroundColor = colors.toBlit(backgroundColor)
    }
    
    return setmetatable(instance, {__index = buffer}):clear()
end
