-- taskbar [][][][][]
-- exit

-- explorer
-- files / folders
-- right click -> (create, delete) (folder / file)

local _, height = term.getSize()

local task_bar_y = height - 3



os.onScreenRefresh:Connect()