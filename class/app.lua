local Menu, Editor = require("menu"), require("Editor")
local App = class("App")


function App.static:run(...)
    local editor = Editor()
    local menu = Menu(editor.actions)
end


return App
