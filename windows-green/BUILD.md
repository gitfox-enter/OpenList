# 重新打包（可选）

发布包由脚本 + 上游 exe + 本目录文档 打成一个 zip。
如果只想重新生成包，需要 Python 3 和上游 exe。

## 目录约定

```
打包工作目录/
├── openlist.exe                      ← 从上游 Release 下载
├── 启动.vbs / 关闭.vbs / 账号密码.txt   ← 本目录 windows-green/openlist/ 复制
└── README.md← 本目录 windows-green/openlist/ 复制
```

## 打包要点

1. **zip 顶层要有目录**（`OpenList-Windows绿色版/`），
   这样用户解压不会把文件散落到当前目录
2. **不要打包 `data\`** —— 里面是你的账号、网盘挂载、令牌
3. `.vbs` 保持 **GBK + CRLF**，不要转码
4. 压缩后记下 SHA256，写进 `RELEASE.md`

## 验证

打完包后务必做一次端到端验证：解压到**全新的空目录**，模拟用户首次双击：

- `admin set` 能成功（OpenList）
- `data\data.db` 能生成
- `GET /ping` 返回 `200` / `pong`
- 首页返回 200 且包含程序标题
- **进程日志里不能有任何浏览器启动痕迹**

最后一条最关键 —— 它验证了"点开不自动打开网页"这个需求真的做到了。
