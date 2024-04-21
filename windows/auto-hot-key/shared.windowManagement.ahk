DoesWindowExist(windowHandleName)
{
    windowHandleId := WinExist(windowHandleName)
    doesExist := windowHandleId > 0

    return doesExist
}
IsWindowFocused(windowHandleName)
{
    windowHandleId := WinExist(windowHandleName)
    if (windowHandleId > 0)
    {
        activeWindowHandleId := WinExist("A")
        return activeWindowHandleId == windowHandleId
    }
    else
    {
        return false
    }
}

FocusWindowTitle(windowHandleName)
{
    isFocused := IsWindowFocused(windowHandleName)
    windowHandleId := WinExist(windowHandleName)
    if (windowHandleId > 0)
    {
        WinActivate, "ahk_id %windowHandleId%"
        WinShow, "ahk_id %windowHandleId%"
    }
}

FocusOrRun(windowHandleName, launchString)
{
    isOpen := DoesWindowExist(windowHandleName)
    if (isOpen = false)
    {
        runwait, %launchString%
    }
    FocusWindowTitle(windowHandleName)
}