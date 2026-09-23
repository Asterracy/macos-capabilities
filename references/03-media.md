# 03 音视频与屏幕捕捉

### screencapture — 截图/截窗口/录屏
入口：
```bash
screencapture -x /tmp/snap.png                      # 全屏,-x 静音
screencapture -c                                    # 全屏进剪贴板(不落盘)
screencapture -R100,200,600,400 /tmp/region.png     # 按坐标矩形截区域 x,y,w,h
screencapture -l $(osascript -e 'tell app "Safari" to id of window 1') /tmp/win.png  # 截指定窗口
screencapture -v /tmp/demo.mov                      # 录屏(交互选区)
```
权限：屏幕录制授权（截自己刚启动的终端窗口通常已授权；截其他 App 首次弹窗）。
延伸：截完直接 `scripts/vision all 图` 识别内容（09 片）。

### afplay — 播放音频文件（含 14 种系统提示音）
入口：
```bash
afplay /System/Library/Sounds/Ping.aiff             # 系统音: Basso/Blow/Bottle/Frog/Funk/Glass/Hero/Morse/Ping/Pop/Purr/Sosumi/Submarine/Tink
afplay -t 3 音频.mp3                                 # 只播前 3 秒
afplay -r 1.5 音频.mp3                               # 加速播放
```
权限：无。延伸：播报前想先提醒 → 先 Ping 再 say（05 片）。

### ffmpeg — 音视频转码/剪辑/抽帧/提取音轨（已装,9.0.1）
入口：
```bash
ffmpeg -i in.mov -c:v libx264 -crf 24 out.mp4       # 通用转码
ffmpeg -ss 00:01:00 -to 00:02:00 -i in.mp4 -c copy clip.mp4  # 无损剪片段
ffmpeg -i 视频.mp4 -vn -q:a 2 音轨.mp3                # 提取音轨
ffmpeg -i 视频.mp4 -ss 5 -frames:v 1 封面.png         # 抽帧
ffmpeg -f avfoundation -i ":0" -t 10 rec.m4a        # 麦克风录 10 秒(:0=默认麦)
```
权限：录麦/摄像头/屏幕需对应授权（首次弹窗）。

### AVFoundation（无 ffmpeg 时的系统级录制/转码）
需要程序化精细控制（设备枚举、实时帧）时才写 swift,日常转码剪辑 ffmpeg 覆盖。视频硬件编解码另有 VideoToolbox,ffmpeg 已自带。

### 语音备忘 — speak + 声音文件生成
```bash
say -v Tingting -o /tmp/out.aiff "文本"              # TTS 生成音频文件(非播放)
say -v '?' | grep zh_CN                             # 查已装中文音色(184 种已装)
```
详见 05 片。
