# macOS Capabilities

一个面向 AI Agent 的 **macOS 本机能力百科 / Skill 能力包**。

它把 macOS 自带的命令行工具、系统框架和自动化能力整理成可直接调用的能力索引，让 Agent 在处理本机任务时，优先复用系统原生能力，而不是为每一个任务重新造轮子。

> 核心目标：**本地执行、按需调用、尽量不联网、不上传数据。**

---

## 能做什么

本项目目前覆盖这些能力：

- **图像与视觉**
  - OCR
  - 物体识别
  - 图像分类
- **PDF / 文档**
  - 文本提取
  - 搜索
  - 合并 / 拆分
  - 文档格式转换
- **文件与格式处理**
  - 图片缩放 / 转换 / 元数据
  - `txt / html / rtf / docx` 互转
  - `plist / JSON` 互转
  - 磁盘镜像与挂载
- **系统搜索与信息读取**
  - Spotlight 全盘搜索
  - 文件元数据查询
  - 系统与硬件信息
- **音视频**
  - 截图 / 录屏
  - 音频播放
  - 音视频录制与转码
- **自动化**
  - TTS 语音播报
  - 系统弹窗 / 通知
  - App 自动化
  - 定时任务 / 常驻任务
- **系统与网络**
  - 防休眠
  - 电源管理
  - 网络配置
  - 钥匙串 / 证书
  - 剪贴板
- **硬件能力**
  - Wi‑Fi 扫描与状态
  - 蓝牙
  - 定位
  - HID
- **端侧文本智能**
  - 分词
  - 实体抽取
  - 语义相似度
  - 日期 / 地址 / 链接 / 电话检测

---

## 设计思路

这个仓库不是一个“单体工具”，而是一套 **Agent 可按需读取的 macOS 能力知识库**。

Agent 的推荐使用方式是：

1. 先从 `SKILL.md` 查能力索引
2. 找到对应的 `references/*.md`
3. 读取该能力的最小必要说明
4. 调用系统 CLI、Swift helper 或 AppleScript 完成任务

这样可以避免 Agent 为了完成一个简单本机任务，反复搜索或生成不必要的代码。

---

## 四种调用路径

### 1. 系统 CLI 直调

优先使用 macOS 自带工具，例如：

```bash
sips
textutil
plutil
mdfind
mdls
system_profiler
screencapture
afplay
say
launchctl
caffeinate
pmset
networksetup
security
pbcopy
pbpaste
```

### 2. Swift helper

`scripts/` 中包含若干已经准备好的 Swift 能力封装，同时保留源码：

```text
scripts/
├── detect
├── detect.swift
├── nl
├── nl.swift
├── pdf
├── pdf.swift
├── vision
├── vision.swift
├── wifi
└── wifi.swift
```

典型调用示例：

```bash
scripts/vision <task> <image>
scripts/pdf <task> ...
scripts/nl <task> ...
scripts/detect <type?> <text>
scripts/wifi <scan|status>
```

### 3. AppleScript / osascript

用于：

- 控制 Mail / Notes / Calendar 等 App
- 系统弹窗
- 通知
- 音量控制
- GUI 级自动化

### 4. Shortcuts

可通过：

```bash
shortcuts run <快捷指令名>
```

调用本机快捷指令。

---

## 能力索引

| 能力 | 入口 | 文档 |
|---|---|---|
| 图像识别 / OCR / 分类 | `scripts/vision` | `references/09-vision.md` |
| PDF 提取 / 搜索 / 合并 / 拆分 | `scripts/pdf` | `references/04-docs.md` |
| 文本智能 / 实体 / 相似度 | `scripts/nl` | `references/08-intelligence.md` |
| 日期 / 地址 / 链接 / 电话检测 | `scripts/detect` | `references/08-intelligence.md` |
| Wi‑Fi 扫描 / 状态 | `scripts/wifi` | `references/07-hardware.md` |
| 文件 / 图片 / 格式转换 | 系统 CLI | `references/01-files.md` |
| Spotlight / 系统信息 | 系统 CLI | `references/02-search.md` |
| 截图 / 录屏 / 音视频 | 系统 CLI / AVFoundation | `references/03-media.md` |
| App 自动化 / 通知 / TTS | `osascript` / `say` | `references/05-automation.md` |
| 电源 / 网络 / 钥匙串 / 剪贴板 | 系统 CLI | `references/06-system.md` |
| 蓝牙 / 定位 / HID | 系统框架 | `references/07-hardware.md` |

---

## 权限说明

很多能力无需额外授权，但涉及隐私或系统控制时，macOS 可能会要求权限。

### 通常无需授权

- 文件格式处理
- Spotlight 搜索
- PDF 处理
- 大部分 `scripts/` helper
- `say`
- `afplay`
- `pbcopy / pbpaste`

### 可能需要授权

- **屏幕录制**：截图某些窗口或屏幕内容
- **自动化**：AppleScript 首次控制某个 App
- **麦克风 / 摄像头**：AVFoundation 录制
- **定位**：读取部分 Wi‑Fi / 位置相关信息

建议在 Agent 执行前先判断权限需求，避免在任务中途卡住。

---

## 目录结构

```text
macos-capabilities/
├── SKILL.md
├── references/
│   ├── 01-files.md
│   ├── 02-search.md
│   ├── 03-media.md
│   ├── 04-docs.md
│   ├── 05-automation.md
│   ├── 06-system.md
│   ├── 07-hardware.md
│   ├── 08-intelligence.md
│   └── 09-vision.md
└── scripts/
    ├── detect / detect.swift
    ├── nl / nl.swift
    ├── pdf / pdf.swift
    ├── vision / vision.swift
    └── wifi / wifi.swift
```

---

## 适合哪些 Agent

任何能够：

- 读取本地 Markdown
- 执行 Shell
- 运行 Swift / AppleScript
- 访问 macOS 本地环境

的 Agent 都可以使用这套能力索引。

尤其适合：

- Codex / Claude Code 一类工程 Agent
- 本地 AI Agent
- 自建 Agent Runtime
- 需要尽量减少联网依赖的自动化工作流

---

## 为什么做这个项目

很多 macOS 能力其实系统已经原生提供，但 Agent 往往不知道：

- 哪个系统命令最合适
- 哪个 API 在当前 macOS 版本可用
- 哪些操作需要权限
- 哪些老示例已经失效
- 哪些能力可以完全本地完成

这个仓库的目的，就是把这些 **已经实测过的 macOS 本机能力** 整理成一份 Agent 能直接使用的“能力地图”。

---

## 已知注意事项

项目中已经记录了一些实测坑，例如：

- 新版 macOS SDK 中，部分旧 API 调用方式会失效
- CoreWiFi 高频扫描可能被系统节流
- `textutil` 处理无 charset 声明的 HTML 时可能出现中文乱码
- TTS 前应先检查系统是否处于静音状态

更详细内容请查看对应 `references/` 文档。

---

## 隐私

本项目的设计方向是 **local-first**：

- 优先使用 macOS 本机能力
- 不依赖远程服务完成本地任务
- 不主动上传文件或数据
- 只有在你明确使用联网工具或外部服务时，数据才可能离开本机

---

## 状态

当前版本：**v1.0.0**

这个仓库仍会继续补充新的 macOS 能力、系统 API 实测结果，以及更适合 Agent 调用的 helper。
