#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent


appListPath := A_ScriptDir . "\apps.txt"
exclusionListPath := A_ScriptDir . "\exclusions.txt"
hidScriptPath := ".\dist\hid_sender\hid_sender.exe"
gamingLayerCode := "0x87"
baseLayerCode := "0x86"
addingApplication := false
excludingApplication := false
isGamingLayer := false
winTitle := ""
winClass := ""
counter := 0

if (!FileExist(appListPath)) {
    FileAppend "", appListPath
}
if (!FileExist(exclusionListPath)) {
    FileAppend "", exclusionListPath
}
appList := FileRead(appListPath)
exclusionList := FileRead(exclusionListPath)

GetApps() {
    Global appList
    return StrSplit(appList, "`n")
}

GetExclusions() {
    Global exclusionList
    return StrSplit(exclusionList, "`n")
}

SetTimer WatchActiveWindow, 50

WatchActiveWindow()
{
    Global winTitle, winClass, isGamingLayer, baseLayerCode, gamingLayerCode, counter

    if (WinExist("A")) {
        newWinTitle := WinGetTitle()
        newWinClass := WinGetClass()
        if (newWinTitle == winTitle && newWinClass == winClass) {
            counter++ ; Sometimes alt-tabbing too fast might result in layers not changing
        }
        if (counter >= 3) {
            counter := 0
            return
        }

        winTitle := newWinTitle
        winClass := newWinClass

        for exclusion in GetExclusions() {
            if (exclusion != "" && (InStr(winTitle, exclusion) || InStr(winClass, exclusion))) {
                return
            }
        }

        isGamingApp := false
        for app in GetApps() {
            if (app != "" && (InStr(winTitle, app) || InStr(winClass, app))) {
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
A_TrayMenu.Add("Exclude application (F4)", MenuHandler)

MenuHandler(ItemName, ItemPos, TrayMenu) {
    Global addingApplication, excludingApplication

    if (ItemName == "Add application (F3)") {
        addingApplication := true
        SetTimer () => addingApplication := false, 15000
    }

    if (ItemName == "Exclude application (F4)") {
        excludingApplication := true
        SetTimer () => excludingApplication := false, 15000
    }
}

$f3::{
    Global addingApplication, appList, appListPath

    if (!addingApplication || !WinExist("A")) {
        SendInput "{F3}"
        return
    }

    winTitle := WinGetTitle()
    winClass := WinGetClass()
    appNameInput := InputBox("Add application`nTitle: " . winTitle . "`nClass: " . winClass)
    if (appNameInput.Result == "Cancel") {
        addingApplication := false
        return
    }
    appName := appNameInput.value
    if (appName == "") {
        FileAppend winTitle . "`n", appListPath
        FileAppend winClass . "`n", appListPath
    } else {
        FileAppend appName . "`n", appListPath
    }
    appList := FileRead(appListPath)
    addingApplication := false
}

$f4::{
    Global excludingApplication, exclusionList, exclusionListPath

    if (!excludingApplication || !WinExist("A")) {
        SendInput "{F4}"
        return
    }

    winTitle := WinGetTitle()
    winClass := WinGetClass()
    appNameInput := InputBox("Exclude application`nTitle: " . winTitle . "`nClass: " . winClass)
    if (appNameInput.Result == "Cancel") {
        excludingApplication := false
        return
    }
    appName := appNameInput.value
    if (appName == "") {
        FileAppend winTitle . "`n", exclusionListPath
        FileAppend winClass . "`n", exclusionListPath
    } else {
        FileAppend appName . "`n", exclusionListPath
    }
    exclusionList := FileRead(exclusionListPath)
    excludingApplication := false
}
