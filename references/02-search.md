# 02 信息检索

### mdfind — Spotlight 全盘秒搜（文件名/内容/元数据）
入口：
```bash
mdfind -name AGENTS.md                              # 按文件名
mdfind "kMDItemTextContent == 'risk of bias'c"      # 按内容,c=忽略大小写
mdfind -onlyin ~/Documents "kMDItemContentType == 'net.daringfireball.markdown'"  # 限定目录+类型
mdfind "kMDItemFSContentChangeDate >= \$time.today(-1)"   # 最近 1 天改过的文件
```
权限：免授权,但 Spotlight 索引没覆盖的深目录搜不到（对方目录可另用 `find`）。
延伸：UTI 类型查询 `mdls -name kMDItemContentType 文件` 先看一个样本。

### mdls — 读文件全部元数据（EXIF/文档属性/音视频信息）
入口：
```bash
mdls 文件.pdf                                       # 全部属性
mdls -name kMDItemTitle -name kMDItemAuthors 文件.pdf # 指定属性(可逗号连多个)
```
权限：无。延伸：图片 EXIF 细节比 mdfind 全,摄影师字段/焦距/ GPS 都在。

### system_profiler — 硬件/软件/网络全套报告
入口：
```bash
system_profiler SPHardwareDataType                  # 机型/芯片/内存/序列号
system_profiler SPAudioDataType SPBluetoothDataType # 音频设备/蓝牙设备
system_profiler SPApplicationsDataType -detailLevel mini  # 已装应用(带路径)
system_profiler -listDataTypes                      # 列出全部数据类型
```
权限：无。陷阱：不带 dataType 会跑全量,很慢；网络共享目录等敏感报告别随意外发。

### defaults — 用户偏好读写（含 GUI 隐藏开关）
入口：
```bash
defaults read -g AppleLocale                        # 读全局键
defaults read com.apple.finder                      # 读某 App 域
defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder  # 写+生效
defaults find safari                                # 按关键词搜
```
权限：无。陷阱：写第三方 App 域需该 App 文档确认键名；`killall` 会重启对应 App。

### 深度遍历兜底 — find / grep
Spotlight 没索引（外置盘、新文件、被排除目录）时用：
```bash
find ~/Library -name "*.plist" -mtime -7 2>/dev/null      # 目录树按名/时间
grep -rl "关键词" 目录/ --include="*.md"                    # 内容逐文件搜
```
