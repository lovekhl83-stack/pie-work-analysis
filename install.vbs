Set fso   = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

src = fso.GetParentFolderName(WScript.ScriptFullName) & "\PIE.html"
dst = shell.ExpandEnvironmentStrings("%USERPROFILE%") & "\Desktop\PIE.html"

If Not fso.FileExists(src) Then
    MsgBox "PIE.html not found. Place install.vbs and PIE.html in the same folder.", 16, "Error"
    WScript.Quit
End If

fso.CopyFile src, dst, True

MsgBox "PIE installed successfully!" & Chr(13) & Chr(10) & Chr(13) & Chr(10) & _
    "PIE.html copied to Desktop." & Chr(13) & Chr(10) & _
    "Double-click PIE.html to launch." & Chr(13) & Chr(10) & Chr(13) & Chr(10) & _
    "A license key is required on first launch." & Chr(13) & Chr(10) & _
    "Contact: lovekhl83@gmail.com", 64, "PIE Setup"

shell.Run "explorer.exe /select," & Chr(34) & dst & Chr(34)
