Default = "\\192.168.204.17"

inputMSG = InputBox ( "������:", "", Default)

If IsEmpty(inputMSG) Then wscript.quit

If inputMSG = "" Then 
    msgbox "ֵ����Ϊ��" 
    wscript.quit
End if

bat_cmd = "cmd /c " & "start " & inputMSG
Set wss = createobject("wscript.shell")
wss.run(bat_cmd), vbhide
wscript.quit