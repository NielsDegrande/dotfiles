-- Clipboard.
hs.hotkey.bind({"alt", "shift"}, "V", function()
    local clipboardContent = hs.pasteboard.readString()
    if type(clipboardContent) == "string" then
        hs.notify.new({
            title = "Clipboard",
            informativeText = clipboardContent
        }):send()
    end
end)
