' ============================================================
'  OpenList  Windows 绿色版 —— 启动脚本
'  双击运行：后台静默启动，不会自动打开浏览器
'  启动成功后请手动访问 http://127.0.0.1:5244/
' ============================================================
Option Explicit

Const PORT = 5244
Const URL = "http://127.0.0.1:5244/"
Const DEF_PASSWORD = "openlist"

Dim sh, http, fso, base, exe, dbFile, running, i
Set sh = CreateObject("WScript.Shell")
Set http = CreateObject("WinHttp.WinHttpRequest.5.1")
Set fso = CreateObject("Scripting.FileSystemObject")

base = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
exe = base & "openlist.exe"
dbFile = base & "data\data.db"

' ---------- 1. 已在运行则直接提示 ----------
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
  sh.Popup "OpenList 已在运行。" & vbCrLf & vbCrLf & _
            "请直接用浏览器访问：" & vbCrLf & URL, _
            3, "OpenList 绿色版", 64
  WScript.Quit 0
End If

' ---------- 2. 首次运行：自动设定通用密码 ----------
If Not fso.FileExists(dbFile) Then
  Dim waitSh
  Set waitSh = CreateObject("WScript.Shell")
  waitSh.CurrentDirectory = base
  waitSh.Run "cmd /c " & """" & exe & """ admin set " & DEF_PASSWORD & _
            " >nul 2>&1", 0, True
End If

' ---------- 3. 启动服务（完全隐藏窗口） ----------
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

' ---------- 4. 结果提示 ----------
If running Then
  sh.Popup "启动成功（后台静默运行，未打开浏览器）。" & vbCrLf & vbCrLf & _
            "网页地址： " & URL & vbCrLf & _
            "管理后台： " & URL & "@manage" & vbCrLf & vbCrLf & _
            "账号： admin" & vbCrLf & _
            "密码： " & DEF_PASSWORD & vbCrLf & vbCrLf & _
            "（以上为默认密码，可用 关闭.vbs 后执行" & vbCrLf & _
            " openlist.exe admin set 新密码 修改）", _
            8, "OpenList 绿色版", 64
Else
  sh.Popup "启动失败：openlist.exe 未能在 20 秒内就绪。" & vbCrLf & vbCrLf & _
            "排查方法：在本目录按住 Shift 右键 →" & vbCrLf & _
            "「在此处打开 PowerShell 窗口」，手动执行：" & vbCrLf & vbCrLf & _
            "    .\openlist.exe server" & vbCrLf & vbCrLf & _
            "查看屏幕上的报错信息。", 10, "OpenList 绿色版 - 启动失败", 16
End If
