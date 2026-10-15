' ============================================================
'  OpenList  Windows 绿色版 —— 关闭脚本
' ============================================================
Option Explicit

Dim sh
Set sh = CreateObject("WScript.Shell")

sh.Run "cmd /c taskkill /IM openlist.exe /F >nul 2>&1", 0, True
WScript.Sleep 500

sh.Popup "OpenList 已关闭。" & vbCrLf & vbCrLf & _
          "全部数据保存在本目录 data\ 文件夹中。" & vbCrLf & _
          "下次双击「启动.vbs」即可恢复运行。", _
          3, "OpenList 绿色版", 64
