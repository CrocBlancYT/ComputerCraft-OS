
-- loading config
config = dofile('/config.lua')

-- loading built-in
local path = "/lib/built-in/"
local files = fs.list(path)

for f = 1, #files do
    local filename = files[f]
    local _, _, name = string.find(filename, '(.-)%.lua$')
    _G[name] = dofile(path .. filename)
end

-- executing autorun
local loaded_libraries = {}
function os.getLibrary(name)
    local lib = loaded_libraries[name] or dofile("/lib/"..name..'.lua')
    loaded_libraries[name] = lib
    return lib
end

local path = "/sys/"
local files = fs.list(path)

for f = 1, #files do
    local filename = files[f]
    dofile(path .. filename)
end

task.run()