' ============================================================
'  OpenList  Windows 绿色版 —— 启动脚本
'
'  双击运行：后台静默启动，不弹黑框
'  启动成功后会询问是否打开网页，你可以选「是」或「否」
' ============================================================
Option Explicit

Const PORT = 5244
Const URL = "http://127.0.0.1:5244/"
Const DEF_PASSWORD = "openlist"

Dim sh, http, fso, base, exe, dbFile, running, i, ans
Set sh = CreateObject("WScript.Shell")
Set http = CreateObject("WinHttp.WinHttpRequest.5.1")
Set fso = CreateObject("Scripting.FileSystemObject")

base = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
exe = base & "openlist.exe"
dbFile = base & "data\data.db"

' ---------- 1. 已在运行？ ----------
running = False
On Error Resume Next
http.Option(6) = False
http.Open "GET", URL & "ping", False
http.Send
If Err.Number = 0 Then
  If http.Status = 200 Then running = True
  Err.Clear
End If
On Error GoTo 0

If running Then
  ans = MsgBox("OpenList 已经在运行了。" & vbCrLf & vbCrLf & _
        "现在用浏览器打开网页吗？" & vbCrLf & _
        "（选「否」则只在后台运行，不打开浏览器）", _
        vbYesNo + vbQuestion, "OpenList 绿色版")
  If ans = vbYes Then
    sh.Run "cmd /c start """" " & URL, 0, False
  End If
  WScript.Quit 0
End If

' ---------- 2. 首次运行：自动设定通用密码 ----------
If Not fso.FileExists(dbFile) Then
  sh.CurrentDirectory = base
  sh.Run "cmd /c " & """" & exe & """ admin set " & DEF_PASSWORD & _
        " >nul 2>&1", 0, True
End If

' ---------- 3. 后台启动（不弹黑框） ----------
sh.CurrentDirectory = base
sh.Run """" & exe & """ server", 0, False

For i = 1 To 40
  WScript.Sleep 500
  running = False
  On Error Resume Next
  http.Open "GET", URL & "ping", False
  http.Send
  If Err.Number = 0 Then
    If http.Status = 200 Then running = True
    Err.Clear
  End If
  On Error GoTo 0
  If running Then Exit For
Next

' ---------- 4. 结果提示 + 询问是否打开网页 ----------
If running Then
  ans = MsgBox("启动成功（后台静默运行）。" & vbCrLf & vbCrLf & _
        "网页地址： " & URL & vbCrLf & _
        "管理后台： " & URL & "@manage" & vbCrLf & vbCrLf & _
        "账号： admin" & vbCrLf & _
        "密码： " & DEF_PASSWORD & vbCrLf & vbCrLf & _
        "现在用浏览器打开网页吗？", _
        vbYesNo + vbQuestion, "OpenList 绿色版")
  If ans = vbYes Then
    sh.Run "cmd /c start """" " & URL, 0, False
  Else
    MsgBox "已跳过打开浏览器。" & vbCrLf & vbCrLf & _
           "服务已在后台运行，你可以随时手动打开：" & vbCrLf & _
           URL & vbCrLf & vbCrLf & _
           "下次双击本文件仍会询问，可用完双击「关闭.vbs」停止。", _
           vbInformation, "OpenList 绿色版"
  End If
Else
  MsgBox "启动失败：openlist.exe 未能在 20 秒内就绪。" & vbCrLf & vbCrLf & _
         "排查方法：在本目录按住 Shift 右键 →" & vbCrLf & _
         "「在此处打开 PowerShell 窗口」，手动执行：" & vbCrLf & vbCrLf & _
         "    .\openlist.exe server" & vbCrLf & vbCrLf & _
         "查看屏幕上的报错信息。", vbCritical, "OpenList 绿色版 - 启动失败"
End If
