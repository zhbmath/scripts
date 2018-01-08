Default = "\\192.168.204.17"

inputMSG = InputBox ( "请输入:", "", Default)

If IsEmpty(inputMSG) Then wscript.quit

If inputMSG = "" Then 
    msgbox "值不能为空" 
    wscript.quit
End if

bat_cmd = "cmd /c " & "start " & inputMSG
Set wss = createobject("wscript.shell")
wss.run(bat_cmd), vbhide
wscript.quit