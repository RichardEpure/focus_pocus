#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent


appListPath := A_ScriptDir . "\apps.txt"
hidScriptPath := ".\dist\hid_sender\hid_sender.exe"
gamingLayerCode := "0x87"
baseLayerCode := "0x86"
delimiter := "::"
addingApplication := false
isGamingLayer := false
winTitle := ""
winClass := ""
counter := 0

if (!FileExist(appListPath)) {
    FileAppend "", appListPath
}
appList := FileRead(appListPath)

GetKeywords() {
    Global appList, delimiter
    return StrSplit(appList, "`n", "::")
}

SetTimer WatchActiveWindow, 50

WatchActiveWindow()
{
    Global winTitle, winClass, isGamingLayer, baseLayerCode, gamingLayerCode, delimiter, counter

    if (WinExist("A")) {
        newWinTitle := WinGetTitle("A")
        newWinClass := WinGetClass("A")
        if (newWinTitle == winTitle && newWinClass == winClass) {
            counter++ ; Sometimes alt-tabbing too fast might result in layers not changing
        }
        if (counter >= 3) {
            counter := 0
            return
        }
        winTitle := newWinTitle
        winClass := newWinClass
        isGamingApp := false
        for word in GetKeywords() {
            if (word != "" && (InStr(winTitle, word) || InStr(winClass, word))) {
                isGamingApp := true
                break
            }
        }

        if (isGamingApp && !isGamingLayer) {
            RunWait(hidScriptPath . " " . gamingLayerCode)
            isGamingLayer := true
        } else if (!isGamingApp & isGamingLayer) {
            RunWait(hidScriptPath . " " . baseLayerCode)
            isGamingLayer := false
        }
    } else if (isGamingLayer) {
        RunWait(hidScriptPath . " " . baseLayerCode)
        isGamingLayer := false
    }
}

A_TrayMenu.Add("Add application (F3)", MenuHandler)

MenuHandler(ItemName, ItemPos, TrayMenu) {
    Global addingApplication

    if (ItemName == "Add application (F3)") {
        addingApplication := true
        SetTimer () => addingApplication := false, 15000
    }
}

$f3::{
    Global addingApplication, appList

    if (!addingApplication || !WinExist("A")) {
        SendInput "{F3}"
        return
    }

    winTitle := WinGetTitle("A")
    winClass := WinGetClass("A")
    appNameInput := InputBox(winTitle . delimiter . winClass)
    if (appNameInput.Result == "Cancel") {
        addingApplication := false
        return
    }
    appName := appNameInput.value
    if (appName == "") {
        FileAppend winTitle . delimiter . winClass . "`n", A_ScriptDir . "\apps.txt"
    } else {
        FileAppend appName . "`n", A_ScriptDir . "\apps.txt"
    }
    appList := FileRead(appListPath)
    addingApplication := false
}
