# 05 自动化：App 控制 · 通知 · 语音播报 · 定时任务

### osascript — 控制系统 App（AppleScript/JXA）
入口：
```bash
osascript -e 'tell application "Notes" to get name of every note'    # 备忘录
osascript -e 'tell application "Reminders" to get name of every list' # 提醒事项
osascript -e 'tell application "Mail" to get subject of every message of inbox'  # 邮件标题
osascript -e 'tell application "Finder" to get selection as alias list'          # Finder 选中项
```
权限：自动化授权,首次控制每个 App 弹一次窗；System Events/UI 脚本另需辅助功能授权。
陷阱：中文 App 名用英文名(Mail/Notes)；App 必须装着,否则 -1728 错误。
语言选择：简单取数 AppleScript 够用；复杂逻辑用 JXA(`osascript -l JavaScript`)。

### osascript 三件输出 — 弹窗 / 通知横幅 / 音量
入口：
```bash
# 通知横幅(非阻塞,右上角,自动消失)
osascript -e 'display notification "内容" with title "标题" subtitle "副题" sound name "Glass"'
# 对话框(阻塞等用户,超时自动关闭)
osascript -e 'display dialog "要点确认?" buttons {"取消","继续"} default button 2 giving up after 60'
#   返回: button returned:"继续", gave up:false / 超时 gave up:true
# 需要用户输入文本:
osascript -e 'display dialog "说明" default answer ""'   # 返回 text returned:...
# 音量(语音播报前必查静音,否则哑)
osascript -e "get volume settings"                       # 看 muted
osascript -e "set volume output volume 80"               # 0-100
osascript -e "set volume output muted false"
```

### say — TTS 语音播报（184 种音色已装,含 20+ 中文）
入口：
```bash
say -v Tingting "任务完成"                           # 中文推荐: Tingting/Meijia/Eddy/Flo
say -v Tingting -r 200 "快点说"                      # 语速(词/分,默认~175)
say -f 文本.txt                                      # 读文件
say -v Tingting -o /tmp/out.aiff "文本"              # 生成音频文件不播放(配 afplay/挂通知用)
say -v '?' | grep zh_CN                              # 列中文音色
```
权限：无。陷阱：**先查静音再播**(上一节音量命令)；深夜降音量。
组合拳：`afplay 系统音 → say 播报 → display dialog 等确认` 三级递进。

### launchctl — 定时/常驻任务（用户级 LaunchAgent）
入口：
```bash
# 1. 写 plist 到 ~/Library/LaunchAgents/com.racy.xxx.plist (launchd 格式,StartInterval/StartCalendarEvent 定时)
# 2. 加载: launchctl load ~/Library/LaunchAgents/com.racy.xxx.plist
# 3. 查:  launchctl list | grep racy    卸载: launchctl unload ...
plutil -lint ~/Library/LaunchAgents/*.plist          # 写完先校验
```
权限：无。陷阱：脚本路径用绝对路径；日志重定向写进 plist 的 StandardOutPath。
一次性延时任务不需要 launchd,shell 里 `sleep` 即可。

### shortcuts — 快捷指令 CLI
入口：
```bash
shortcuts list                                       # 本机库当前为空
shortcuts run "名字"                                  # 用户建了快捷指令后从这里触发
shortcuts create  # 无此子命令,建快捷指令要在 Shortcuts.app 里手工/Automator
```
延伸：Automator.app(`open -a Automator`)可做工作流,但 agent 场景优先直接 CLI。
