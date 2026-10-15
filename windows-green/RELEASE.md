# Release 下载与校验

## 下载

**Releases** 页面下载 `OpenList-Windows绿色版.zip`（约 48 MB）。

## 为什么仓库里没有 exe

`openlist.exe` 官方二进制为 **143,720,448 字节（约 137 MB）**，
超过 GitHub 单文件 100 MB 的硬性限制，无法直接提交进仓库。
因此本fork 的仓库里**只放脚本与文档**，程序本体通过 Release 附件分发。

## 文件校验

| 文件 | 大小（字节） | SHA256 |
|---|---|---|
| `openlist.exe`（官方 windows-amd64，未修改） | 143,720,448 | `234ee38f142858ba12d57dd57d181c9ed4a77f952b8420c053e7ab98e3db3172` |
| `OpenList-Windows绿色版.zip`（本包） | 50,163,262 | `16301a5cbf18460be3d4e7487084032f96ff66936ecbee9a77fbffcdfa9c3b5e` |

解压后可自行校验：

```powershell
Get-FileHash .\openlist.exe -Algorithm SHA256
```

## zip 内容清单

```
OpenList-Windows绿色版/
├── README.md          使用说明
├── openlist.exe       官方程序本体（未修改）
├── 启动.vbs           一键启动（GBK，后台静默，不开浏览器）
├── 关闭.vbs           一键关闭
└── 账号密码.txt       登录信息
```

运行时才会生成 `data\`（配置、数据库、日志）。
**发布包内不含 `data\`**，你的账号、网盘挂载、令牌等个人数据不会被带出去。

## 端口速查

| 用途 | 地址 |
|---|---|
| 网页| http://127.0.0.1:5244/ |
| 管理后台 | http://127.0.0.1:5244/@manage |
| WebDAV | http://127.0.0.1:5244/dav |

> 注：上游默认端口是 **5244**（不是 AList 时代的 5245）。
