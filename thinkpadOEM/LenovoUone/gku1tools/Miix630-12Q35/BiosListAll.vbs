'
' List all BIOS settings
'
On Error Resume Next
Dim colItems

strComputer = "LOCALHOST"     ' Change as needed.
Set objWMIService = GetObject("WinMgmts:" _
    &"{ImpersonationLevel=Impersonate}!\\" & strComputer & "\root\wmi")
Set colItems = objWMIService.ExecQuery("Select * from Lenovo_BiosSetting")

For Each objItem in colItems
    If Len(objItem.CurrentSetting) > 0 Then
        Setting = ObjItem.CurrentSetting
	WScript.Echo Setting
    End If
Next
