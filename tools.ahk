#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

Menu, Tray, NoStandard 

Menu, Tray, Add, Exit, ByeScript 

Menu, Tray, Default, Exit 

Menu Tray, Tip, JS Tools

mSpd=5

Trans = 255;

^SPACE:: Winset, AlwaysOnTop, , A

~#SPACE:: 
  Trans-= 85
  If (Trans <= 0)
  {
    Trans+=255
  }
  WinSet, Transparent, %Trans%, A

return

;#x::
;WinSet, Region, 50-0 W200 H250 , A
;return

Toggle := False

#c::
  Toggle := !Toggle

  if(Toggle){
    SetTimer DisplayColor, 1
  } else{
    ToolTip	, , , 1				; fix persistent tooltip
    SetTimer DisplayColor, Off
    ToolTip	, , , 1				; fix persistent tooltip
  }

return

DisplayColor()
{

  X = 0
  Y = 0

  str = ""

  MouseGetPos , X, Y
  PixelGetColor, str, X, Y, RGB
  ToolTip , %str%, X+10, Y+8, 1

  If (GetKeyState("f12","p")){
    clipboard:= str
  }

}

^up::Goto, keyMouse

^down:: Goto, keyMouse
^right:: Goto, keyMouse
^left:: Goto, keyMouse

^Numpad1::
  mSpd=1
return

^Numpad2::
  mSpd=2
return

^Numpad3::
  mSpd=3
return

^Numpad4::
  mSpd=4
return

^Numpad5::
  mSpd=5
return

^Numpad6::
  mSpd=6
return

^Numpad7::
  mSpd=7
return

^Numpad8::
  mSpd=8
return

^Numpad9::
  mSpd=9
return

keyMouse:

  while(GetKeyState("up","p") | GetKeyState("down","p") | GetKeyState("left","p") | GetKeyState("right","p")){

    mouseGetPos, mPX, mPY

    if(GetKeyState("up","p")){
      mPY-=mSpd
    }
    if(GetKeyState("down","p")){
      mPY+=mSpd
    }
    if(GetKeyState("left","p")){
      mPX-=mSpd
    }
    if(GetKeyState("right","p")){
      mPX+=mSpd
    }

    mouseMove, mPX, mPY
    Sleep, 20				;change to use timer
  }
return

+^c::

  #If WinActive("ahk_class CabinetWClass") ; explorer

  explorerHwnd := WinActive("ahk_class CabinetWClass")
  if (explorerHwnd)
  {
    for window in ComObjCreate("Shell.Application").Windows
    {
      if (window.hwnd==explorerHwnd){
        dir:= window.Document.Folder.Self.Path
      } else {

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DEFAULT TO DESKTOP

        val = CSIDL_0x0010
        VarSetCapacity(fpath, 256) 
        DllCall( "shell32\SHGetFolderPathA", "uint", 0, "int", val, "uint", 0, "int", 0, "str", fpath) 

        dir:=fpath
      }
    }
  }

  #If
    msgbox %dir%

  if(!FileExist("%dir%/CppProj")){
    FileCreateDir, %dir%/CppProj
    FileCreateDir, %dir%/CppProj/.vscode

    FileAppend, #include <iostream>`nusing namespace std;`n`nint main(){`n`n`treturn 0;`n}, %dir%\CppProj\main.cpp

  FileAppend, {`n	"version": "2.0.0"`,`n	"tasks": [`n		{`n			"type": "cppbuild"`,`n			"label": "C/C++: g++.exe build active file"`,`n			"command": "C:\\MinGW\\bin\\g++.exe"`,`n			"args": [`n				"-g"`,`n				"${file}"`,`n				"-o"`,`n				"${fileDirname}\\${fileBasenameNoExtension}.exe"`n			]`,`n			"options": {`n				"cwd": "C:\\MinGW\\bin"`n			}`,`n			"problemMatcher": [`n				"$gcc"`n			]`,`n			"group": {`n				"kind": "build"`,`n				"isDefault": true`n			}`,`n			"detail": "compiler: C:\\MinGW\\bin\\g++.exe"`n		}`n	]`n}, %dir%\CppProj\.vscode\tasks.json

FileAppend, {`n "version": "0.2.0"`,`n "configurations": [`n {`n "name": "g++.exe - Build and debug active file"`,`n "type": "cppdbg"`,`n "request": "launch"`,`n "program": "${fileDirname}\\${fileBasenameNoExtension}.exe"`,`n "args": []`,`n "stopAtEntry": false`,`n "cwd": "${workspaceFolder}"`,`n "environment": []`,`n "externalConsole": false`,`n "MIMode": "gdb"`,`n "miDebuggerPath": "C:/MinGW/bin/gdb.exe"`,`n "setupCommands": [`n {`n "description": "Enable pretty-printing for gdb"`,`n "text": "-enable-pretty-printing"`,`n "ignoreFailures": true`n }`n ]`,`n "preLaunchTask": "C/C++: g++.exe build active file"`n }`n ]`n}, %dir%\CppProj\.vscode\launch.json

if(FileExist("C:\Program Files\Microsoft VS Code\Code.exe")){
  Run, C:\Program Files\Microsoft VS Code\Code.exe -g "%dir%/CppProj/main.cpp:5" "%dir%/CppProj"
} else {

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;TODO:  USE REGISTRY INSTEAD OF INI

  myIniFile := A_ScriptDir . "\vscodepath.ini"

  if not (FileExist(myIniFile)) { ; creates the ini file if it does not exist

    FileAppend,
    (
    [mySection]
    myPermanentVar=0
    ), % myIniFile, utf-16 ; save your ini file asUTF-16LE

    InputBox, OutputVar, VS Code Path, Please enter your path to vscode

    IniWrite % OutputVar, % myIniFile, mySection, myPermanentVar ; writes the new value to the ini file

    Run, "%OutputVar%" -g "%dir%/CppProj/main.cpp:5" "%dir%/CppProj"

  } else {

    IniRead, vloc, % myIniFile, mySection, myPermanentVar ; reads the value from the ini file specifying its section and the key

    Run, "%vloc%" -g "%dir%/CppProj/main.cpp:5" "%dir%/CppProj"

  }

}

Sleep, 2000

Send ^+``

}
return

ByeScript: 

  ExitApp 

Return