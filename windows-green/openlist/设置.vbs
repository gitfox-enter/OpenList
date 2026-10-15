' ============================================================
'  OpenList  Windows 绿色版 —— 设置（端口 / 密码）
'
'  1 = 修改端口
'  2 = 设置密码
'  3 = 取消密码（免密使用，推荐本机自用）
'  4 = 查看当前设置
'  0 = 退出
'
'  改完双击「启动.vbs」生效
' ============================================================
Option Explicit

Dim sh, fso, base, exe, cfgFile, dbFile, port, url
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

base = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
exe = base & "openlist.exe"
cfgFile = base & "data\config.json"
dbFile = base & "data\data.db"

If Not fso.FileExists(exe) Then
  MsgBox "找不到 openlist.exe，请把本脚本与它放在同一文件夹。", _
         vbCritical, "设置"
  WScript.Quit 1
End If

' ---------- 改配置前先停服务 ----------
If IsRunning() Then
  If MsgBox("修改设置需要先关闭正在运行的服务。" & vbCrLf & _
            "现在关闭 OpenList 吗？", vbYesNo + vbQuestion, "设置") = vbYes Then
    sh.Run "cmd /c taskkill /IM openlist.exe /F >nul 2>&1", 0, True
    WScript.Sleep 900
  Else
    MsgBox "已取消。请先关闭 OpenList 再改设置。", vbInformation, "设置"
    WScript.Quit 0
  End If
End If

If Not fso.FolderExists(base & "data") Then
  fso.CreateFolder base & "data"
End If

Dim choice
choice = InputBox( _
  "请选择要修改的项目：" & vbCrLf & vbCrLf & _
  "    1 = 修改端口" & vbCrLf & _
  "    2 = 设置 / 修改密码" & vbCrLf & _
  "    3 = 取消密码（免密使用）" & vbCrLf & _
  "    4 = 查看当前设置" & vbCrLf & _
  "    0 = 退出" & vbCrLf & vbCrLf & _
  "当前端口：" & GetPort() & vbCrLf & _
  "当前密码：" & PwdDesc(), _
  "OpenList 绿色版 - 设置", "4")

Select Case Trim(choice)
  Case "1"
    SetPortSub
  Case "2"
    SetPwdSub
  Case "3"
    ClearPwdSub
  Case "4"
    ShowSettingSub
  Case "0", ""
    ' 退出
  Case Else
    MsgBox "无效的选项：" & choice, vbExclamation, "设置"
End Select

' ============================================================
'  子过程
' ============================================================

Sub SetPortSub()
  Dim old, nw
  old = GetPort()
  nw = InputBox("当前端口：" & old & vbCrLf & vbCrLf & _
                "请输入新端口（1024 - 65535）：", "修改端口", old)
  If Trim(nw) = "" Then
    MsgBox "已取消，端口保持 " & old & "。", vbInformation, "设置"
    Exit Sub
  End If
  If Not IsNumeric(nw) Then
    MsgBox "端口必须是数字！", vbCritical, "设置"
    Exit Sub
  End If
  nw = CLng(nw)
  If nw < 1024 Or nw > 65535 Then
    MsgBox "端口需在 1024 - 65535 之间！", vbCritical, "设置"
    Exit Sub
  End If
  If PortInUse(nw) Then
    If MsgBox("端口 " & nw & " 已被其他程序占用。" & vbCrLf & _
              "仍然使用这个端口吗？（可能启动失败）", _
              vbYesNo + vbExclamation, "设置") <> vbYes Then
      Exit Sub
    End If
  End If

  If Not WritePort(nw) Then Exit Sub

  MsgBox "端口已改为 " & nw & "。" & vbCrLf & vbCrLf & _
         "新地址：http://127.0.0.1:" & nw & "/" & vbCrLf & vbCrLf & _
         "（原配置已备份为 config.json.bak）" & vbCrLf & vbCrLf & _
         "现在双击「启动.vbs」生效。", vbInformation, "设置"
End Sub

Function WritePort(nw)
' 精确替换 config.json 里 http_port 的数字；失败返回 False
  Dim ff, txt, fpos, cpos, kk, dStart, dEnd
  WritePort = False

  If Not fso.FileExists(cfgFile) Then
    MsgBox "找不到 data\config.json。" & vbCrLf & vbCrLf & _
           "请先双击一次「启动.vbs」让程序生成配置，再改端口。", _
           vbExclamation, "设置"
    Exit Function
  End If

  Set ff = fso.OpenTextFile(cfgFile, 1)
  txt = ff.ReadAll
  ff.Close

  fpos = InStr(txt, """http_port""")
  If fpos = 0 Then
    MsgBox "config.json 中找不到 http_port 字段，修改失败。", _
           vbCritical, "设置"
    Exit Function
  End If

  cpos = InStr(fpos, txt, ":")
  If cpos = 0 Then
    MsgBox "config.json 格式异常（http_port 后缺少冒号），修改失败。", _
           vbCritical, "设置"
    Exit Function
  End If

  kk = cpos + 1
  Do While Mid(txt, kk, 1) = " " Or Mid(txt, kk, 1) = vbTab Or _
          Mid(txt, kk, 1) = vbCr Or Mid(txt, kk, 1) = vbLf
    kk = kk + 1
  Loop
  dStart = kk
  Do While Mid(txt, kk, 1) >= "0" And Mid(txt, kk, 1) <= "9"
    kk = kk + 1
    If kk - dStart > 12 Then Exit Do
  Loop
  dEnd = kk

  If dEnd = dStart Then
    MsgBox "http_port 的值不是数字，修改失败。", vbCritical, "设置"
    Exit Function
  End If

  txt = Left(txt, dStart - 1) & CStr(nw) & Mid(txt, dEnd)

  ' 备份只留一份，避免目录堆积
  If fso.FileExists(cfgFile & ".bak") Then fso.DeleteFile cfgFile & ".bak", True
  fso.CopyFile cfgFile, cfgFile & ".bak", True

  Set ff = fso.CreateTextFile(cfgFile, True, True)
  ff.Write txt
  ff.Close
  WritePort = True
End Function

Sub SetPwdSub()
  Dim p1, p2
  p1 = InputBox("请输入新的管理员密码：" & vbCrLf & vbCrLf & _
                "（想免密码请改选菜单 3）", "设置密码", "")
  If p1 = "" Then
    MsgBox "已取消，密码未修改。" & vbCrLf & _
           "若想免密码，请选菜单 3。", vbInformation, "设置"
    Exit Sub
  End If
  p2 = InputBox("请再次输入以确认：", "确认密码", "")
  If p1 <> p2 Then
    MsgBox "两次输入不一致，密码未修改。", vbExclamation, "设置"
    Exit Sub
  End If
  If InStr(p1, " ") > 0 Or InStr(p1, """") > 0 Or InStr(p1, "&") > 0 Then
    MsgBox "密码不能包含空格、引号或 & 字符。" & vbCrLf & _
           "请换一个简单点的密码。", vbExclamation, "设置"
    Exit Sub
  End If

  sh.CurrentDirectory = base
  sh.Run "cmd /c " & """" & exe & """ admin set " & p1 & " >nul 2>&1", 0, True

  WriteCred "密码： " & p1

  MsgBox "密码已修改，并同步写入「账号密码.txt」。" & vbCrLf & vbCrLf & _
         "现在双击「启动.vbs」生效。", vbInformation, "设置"
End Sub

Sub ClearPwdSub()
  Dim ans2
  ans2 = MsgBox("确定要取消密码吗？" & vbCrLf & vbCrLf & _
        "取消后，网页登录框只需填admin，" & vbCrLf & _
        "密码留空即可进入。" & vbCrLf & vbCrLf & _
        "适合：只在自己电脑上用" & vbCrLf & _
        "不适合：开了局域网访问（0.0.0.0）给手机/别人用", _
        vbYesNo + vbQuestion, "取消密码")
  If ans2 <> vbYes Then Exit Sub

  sh.CurrentDirectory = base
  sh.Run "cmd /c " & """" & exe & """ admin set "" >nul 2>&1", 0, True

  WriteCred "密码：（空 —— 免密码使用，登录时密码栏留空即可）"

  MsgBox "已取消密码，现在打开网页直接用即可。" & vbCrLf & vbCrLf & _
         "双击「启动.vbs」生效。", vbInformation, "设置"
End Sub

Sub ShowSettingSub()
  MsgBox "当前设置" & vbCrLf & String(40, "-") & vbCrLf & _
         "  端口：" & GetPort() & vbCrLf & _
         "  地址：http://127.0.0.1:" & GetPort() & "/" & vbCrLf & _
         "  管理：http://127.0.0.1:" & GetPort() & "/@manage" & vbCrLf & _
         "  账号：admin" & vbCrLf & _
         "  密码：" & PwdDesc() & vbCrLf & vbCrLf & _
         "  数据库：" & IIf(fso.FileExists(dbFile), "已初始化", "未初始化") & vbCrLf & _
         "  监听：" & GetListen() & vbCrLf & vbCrLf & _
         "提示：本机自用建议选 3（免密码）。" & vbCrLf & _
         "若GetListen() 显示 0.0.0.0 且你在意局域网访问，" & vbCrLf & _
         "请务必设一个密码。", vbInformation, "当前设置"
End Sub

Sub WriteCred(pwdLine)
' 写/更新 账号密码.txt
  Dim tf, ts
  ts = "============================================================" & vbCrLf & _
       "  OpenList（Windows 绿色版）—— 登录信息" & vbCrLf & _
       "============================================================" & vbCrLf & vbCrLf & _
       "  网页地址： http://127.0.0.1:" & GetPort() & "/" & vbCrLf & _
       "  管理后台： http://127.0.0.1:" & GetPort() & "/@manage" & vbCrLf & _
       "  WebDAV：  http://127.0.0.1:" & GetPort() & "/dav" & vbCrLf & vbCrLf & _
       "  账号： admin" & vbCrLf & _
       "  " & pwdLine & vbCrLf & vbCrLf & _
       "------------------------------------------------------------" & vbCrLf & _
       "  此文件由「设置.vbs」自动生成" & vbCrLf & _
       "------------------------------------------------------------" & vbCrLf & vbCrLf & _
       "  改端口 / 改密码 → 双击「设置.vbs」" & vbCrLf & vbCrLf & _
       "  使用：" & vbCrLf & _
       "  1) 双击「启动.vbs」（后台静默，会问是否打开网页）" & vbCrLf & _
       "  2) 浏览器访问上面列出的地址" & vbCrLf & _
       "  3) 用完双击「关闭.vbs」" & vbCrLf & vbCrLf & _
       "  数据全在 data\ 文件夹，搬家 = 整个目录拷走。" & vbCrLf

  If fso.FileExists(base & "账号密码.txt") Then
    fso.DeleteFile base & "账号密码.txt", True
  End If
  Set tf = fso.CreateTextFile(base & "账号密码.txt", True, True)
  tf.Write ts
  tf.Close
End Sub

Function PwdDesc()
  Dim cred
  If Not fso.FileExists(base & "账号密码.txt") Then
    PwdDesc = "未知（双击一次「启动.vbs」生成）"
    Exit Function
  End If
  Dim f, s, i, line
  Set f = fso.OpenTextFile(base & "账号密码.txt", 1)
  s = f.ReadAll
  f.Close
  i = InStr(s, "密码：")
  If i = 0 Then
    PwdDesc = "未知"
    Exit Function
  End If
  i = i + 4
  Do While Mid(s, i, 1) = " " Or Mid(s, i, 1) = vbCr Or Mid(s, i, 1) = vbLf
    i = i + 1
  Loop
  line = ""
  Do While Mid(s, i, 1) <> vbCr And Mid(s, i, 1) <> vbLf And i <= Len(s)
    line = line & Mid(s, i, 1)
    i = i + 1
  Loop
  If InStr(line, "空") > 0 Or Len(Trim(line)) = 0 Then
    PwdDesc = "（空 —— 免密码使用）"
  Else
    PwdDesc = line
  End If
End Function

Function GetListen()
' 读取 scheme.address，判断监听范围
  Dim f, s, i, cpos, k, addr
  GetListen = "未知"
  If Not fso.FileExists(cfgFile) Then Exit Function
  Set f = fso.OpenTextFile(cfgFile, 1)
  s = f.ReadAll
  f.Close
  i = InStr(s, """address""")
  If i = 0 Then Exit Function
  cpos = InStr(i, s, ":")
  If cpos = 0 Then Exit Function
  k = cpos + 1
  Do While Mid(s, k, 1) = " " Or Mid(s, k, 1) = vbTab
    k = k + 1
  Loop
  If Mid(s, k, 1) = """" Then
    k = k + 1
    addr = ""
    Do While Mid(s, k, 1) <> """"
      addr = addr & Mid(s, k, 1)
      k = k + 1
    Loop
    If addr = "0.0.0.0" Then
      GetListen = "0.0.0.0（局域网可访问）"
    ElseIf addr = "127.0.0.1" Then
      GetListen = "127.0.0.1（仅本机，安全）"
    Else
      GetListen = addr
    End If
  End If
End Function

' ============================================================

Function GetPort()
  Dim f, s, i, cpos, k, num
  GetPort = "5244"
  If Not fso.FileExists(cfgFile) Then Exit Function
  Set f = fso.OpenTextFile(cfgFile, 1)
  s = f.ReadAll
  f.Close
  i = InStr(s, """http_port""")
  If i = 0 Then Exit Function
  cpos = InStr(i, s, ":")
  If cpos = 0 Then Exit Function
  k = cpos + 1
  Do While Mid(s, k, 1) = " " Or Mid(s, k, 1) = vbTab Or _
          Mid(s, k, 1) = vbCr Or Mid(s, k, 1) = vbLf
    k = k + 1
  Loop
  num = ""
  Do While Mid(s, k, 1) >= "0" And Mid(s, k, 1) <= "9"
    num = num & Mid(s, k, 1)
    k = k + 1
    If Len(num) > 12 Then Exit Do
  Loop
  If Len(num) > 0 Then GetPort = num
End Function

Function IsRunning()
  Dim http
  IsRunning = False
  Set http = CreateObject("WinHttp.WinHttpRequest.5.1")
  On Error Resume Next
  http.Option(6) = False
  http.Open "GET", "http://127.0.0.1:" & GetPort() & "/ping", False
  http.Send
  If Err.Number = 0 Then
    If http.Status = 200 Then IsRunning = True
    Err.Clear
  End If
  On Error GoTo 0
End Function

Function PortInUse(p)
  Dim http
  PortInUse = False
  Set http = CreateObject("WinHttp.WinHttpRequest.5.1")
  On Error Resume Next
  http.Option(6) = False
  http.Open "GET", "http://127.0.0.1:" & p & "/", False
  http.Send
  If Err.Number = 0 Then
    If http.Status > 0 Then PortInUse = True
    Err.Clear
  End If
  On Error GoTo 0
End Function
