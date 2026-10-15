# OpenList — Windows 绿色版脚本

> **非官方整合包**。`openlist.exe` 为上游官方 Release 原版文件（SHA256 见
> [RELEASE.md](RELEASE.md)），本目录**只提供** Windows 一键启动/关闭脚本与中文说明，
> 不修改上游任何一行代码。
>
> 上游项目：https://github.com/OpenListTeam/OpenList　官方文档：https://doc.oplist.org/

## 为什么需要这一份

上游只发布官方 Release，没有 Windows 侧的启动脚本。手动跑 `openlist.exe server`
会弹一个黑窗口，关掉窗口进程就死，也没人告诉你默认密码在哪。

这份脚本解决三件事：

1. **后台静默启动** —— 双击即跑，不弹黑框
2. **不自动打开浏览器** —— 启动后你自己决定什么时候开
3. **首次运行自动完成初始化** —— 自动设一个公开的通用密码，不需要手动敲命令

## 快速开始

1. 从本fork 的 **Releases** 下载 `OpenList-Windows绿色版.zip`
2. 解压到任意文件夹（会得到 `OpenList-Windows绿色版\` 子目录）
3. 双击 **`启动.vbs`**，弹出"启动成功"即表示服务已在后台运行
4. **手动**打开浏览器访问 http://127.0.0.1:5244/
5. 用 `admin` / `openlist` 登录
6. 用完双击 **`关闭.vbs`**

## 登录信息

| 项 | 值 |
|---|---|
| 网页地址 | http://127.0.0.1:5244/ |
| 管理后台 | http://127.0.0.1:5244/@manage |
| WebDAV | http://127.0.0.1:5244/dav |
| 账号 | `admin` |
| 默认密码 | `openlist` |

> `openlist` 是**公开的通用密码**，任何人都能看到。服务默认只监听本机，
> 适合个人自用。要改密码：双击 `关闭.vbs`，在本目录按住 Shift 右键 →
> 「在此处打开 PowerShell 窗口」，执行 `.\openlist.exe admin set 你的新密码`。

## 脚本做了什么

### `启动.vbs`

```
1. ping http://127.0.0.1:5244/ping
   ├─ 已响应 → 提示"已在运行"，直接退出（不会重复起进程）
   └─ 无响应 ↓
2. 检查 data\data.db 是否存在
   └─ 不存在 → 执行 openlist.exe admin set openlist（完成首次初始化）
3. 后台启动 openlist.exe server（窗口样式 0 = 完全隐藏）
4. 轮询 /ping 最多 20 秒
   ├─ 通了 → 弹"启动成功"，告知地址与账号密码
   └─ 没通 → 弹"启动失败"，并给出手动执行的排查命令
```

路径全部从 `WScript.ScriptFullName` 推导，**不含任何硬编码盘符**，绿色包可搬到任意位置。

### `关闭.vbs`

`taskkill /IM openlist.exe /F`，然后提示数据仍在 `data\`。

## 常见问题

**Q：双击没反应？**
脚本是隐藏窗口运行的，属正常。弹出的提示框会告知是否成功。

**Q：提示"启动失败"？**
多半是端口被占。本目录按住 Shift 右键 →「在此处打开 PowerShell 窗口」，
手动执行 `.\openlist.exe server`，屏幕上的报错就是原因。

**Q：端口能改吗？**
可以。改 `data\config.json` 里的 `scheme.http_port`，再把 `启动.vbs` 中三处
`5244` 改成同一个数字。
⚠️ `启动.vbs` 是 **GBK 编码**，用记事本编辑时务必选「ANSI」保存，
选 UTF-8 会导致中文乱码。

**Q：怎么开机自启？**
`Win+R` → `shell:startup` → 把 `启动.vbs` 的快捷方式放进去。

**Q：能给手机用吗？**
可以，但要先改密码。Windows 防火墙放行 5244 端口后，手机访问
`http://<电脑IP>:5244/`。默认密码是公开的，**不一定要改**。

## 编码说明

`.vbs` 文件是 **GBK（代码页 936）+ CRLF**。这是必须的：

- Windows Script Host 按 ANSI 代码页读取 `.vbs`，UTF-8 会导致中文全部乱码
- 换行符必须是 CRLF，否则 WScript 可能解析异常

用编辑器修改时记得保持这两点。

## 许可

上游 OpenList 遵循 **AGPL-3.0**。本目录不含任何个人数据，不修改上游代码，
仅附带启动/关闭脚本与说明文档。
