local expect = require "cc.expect"
local TextField = require 'lib.gui.TextField'
-- A text field that allows users to type text within it.
local TextFieldActOnKey = TextField:subclass()

-- TextFieldActOnKey constructor.
--
-- Parameters:
-- - root (Root): The root widget
-- - length (int): Width of the text field in characters.
-- - text (string): Initial contents of the TextFieldActOnKey.
function TextFieldActOnKey:init(root,length,text)
    -- TODO: Add auto-completion
    expect(1, root, "table")
    expect(2, length, "number")
    expect(3, text, "string")
    TextFieldActOnKey.superClass.init(self,root,length,text)

	self.key = 0
end

function TextFieldActOnKey:onKey() end

function TextFieldActOnKey:onKeyDown(key,held)
	self.key = key
	self:onKey()
    if key == keys.backspace then
        self.text = string.sub(self.text,1,math.max(self.char-2,0)) .. string.sub(self.text,self.char,#self.text)
        self:moveCursor(self.char-1)
        self:onChanged()
    elseif key == keys.delete then
        self.text = string.sub(self.text,1,math.max(self.char-1,0)) .. string.sub(self.text,self.char+1,#self.text)
        self:onChanged()
    elseif key == keys.home then
        self:moveCursor(1)
    elseif key == keys['end'] then
        self:moveCursor(#self.text+1)
    elseif key == keys.left then
        self:moveCursor(self.char-1)
    elseif key == keys.right then
        self:moveCursor(self.char+1)
    end
    self.dirty = true
    return true
end

return TextFieldActOnKey
