---
name: macos-capabilities
description: >-
  macOS 本机能力百科:系统框架与内置工具的实测用法索引。覆盖图像识别/文档处理(PDF)/
  文件格式转换/信息检索/音视频/语音播报与通知弹窗/系统与网络控制/硬件(WiFi·蓝牙·定位)/
  端侧智能(NLP·实体抽取·语义相似度·数据检测)。当任务可能用本机系统能力解决时加载:
  识别、转换、提取、扫描、播报、弹窗、自动化、系统查询、硬件状态、文本智能。
  纯本地,不联网,不传数据。
version: 1.0.0
---

# macOS 能力百科

本机系统框架与内置 CLI 的实测索引。**按需读片**：从下表找到能力 → 读对应 references 片 → 照入口命令调用。不要全量读完再动手。

四条调用路径：

1. **CLI 直调** — 系统自带命令，入口直接给
2. **swift 模板** — `scripts/` 下的编译好的二进制（源码 .swift 同目录，可 `swift xxx.swift` 解释执行）
3. **osascript** — 控制 App / 弹窗 / 通知
4. **shortcuts** — `shortcuts run <名>`（本机库当前为空）

## 能力索引

| 能力 | 入口 | 详见 |
|------|------|------|
| 图像识别(OCR/物体/分类) | `scripts/vision <task> <图>` | references/09-vision.md |
| PDF 提取/搜索/合并/拆分 | `scripts/pdf <task> ...` | references/04-docs.md |
| 文本智能(分词/实体/相似度) | `scripts/nl <task> ...` | references/08-intelligence.md |
| 文本抽日期/地址/链接/电话 | `scripts/detect <type?> <text>` | references/08-intelligence.md |
| WiFi 扫描/连接状态 | `scripts/wifi <scan\|status>` | references/07-hardware.md |
| 图片格式/缩放/元数据 | `sips` | references/01-files.md |
| 文档格式互转(txt/html/rtf/docx) | `textutil` | references/01-files.md |
| plist/JSON 互转 | `plutil` | references/01-files.md |
| 磁盘镜像/挂载 | `hdiutil` | references/01-files.md |
| 全盘检索(文件名/内容/元数据) | `mdfind` / `mdls` | references/02-search.md |
| 硬件/系统信息报告 | `system_profiler` | references/02-search.md |
| 截图/录屏 | `screencapture` | references/03-media.md |
| 音频播放/系统提示音 | `afplay` | references/03-media.md |
| 音视频录制/转码 | AVFoundation / `ffmpeg`(已装) | references/03-media.md |
| 语音播报(TTS) | `say` | references/05-automation.md |
| 弹窗/通知横幅/音量 | `osascript` | references/05-automation.md |
| 定时/常驻任务 | `launchctl` | references/05-automation.md |
| 防休眠 | `caffeinate` | references/06-system.md |
| 电源管理 | `pmset` | references/06-system.md |
| 网络配置 | `networksetup` | references/06-system.md |
| 钥匙串/证书 | `security` | references/06-system.md |
| 剪贴板 | `pbcopy` / `pbpaste` | references/06-system.md |
| 蓝牙/定位/HID | 框架直调 | references/07-hardware.md |
| App 自动化(Mail/Notes/日历…) | `osascript` | references/05-automation.md |

## 权限地图（先查这里再动手）

- **免授权**：01/02/04 片全部命令；scripts 全部；`say`/`afplay`/`pbcopy`
- **需授权（首次弹窗或系统设置 → 隐私与安全性）**：
  - 屏幕录制 → `screencapture` 截全屏以外的窗口内容
  - 自动化 → `osascript` 首次控制每个 App 时
  - 麦克风/摄像头 → AVFoundation 录制
  - 定位 → 读当前 SSID（`wifi status`；扫描不需要）
- **不可用**：FoundationModels(Apple 端侧大模型) → `deviceNotEligible`（M5/16GB,勿再试）

## 已知陷阱（实测踩过）

- macOS 26 SDK：部分 API 编译期隐藏需 ObjC 动态派发（vision.swift 已封装）；老示例的方法/属性语法可能过时
- CoreWiFi 频繁扫描会被节流返回空，等 ~10 秒重试
- `textutil` 转无 charset 声明的 HTML 中文会乱码，输入需带 `<meta charset="utf-8">`
- 语音播报前先 `osascript -e "get volume settings"` 查静音，否则是哑的
