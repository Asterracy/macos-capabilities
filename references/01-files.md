# 01 文件与格式

### sips — 图片信息/缩放/格式转换/裁剪/旋转
入口：
```bash
sips -g pixelWidth -g pixelHeight 图.png            # 读尺寸(还有 dpi/色彩空间/EXIF)
sips -s format jpeg in.png --out out.jpg            # 格式转换(jpeg/png/tiff/bmp/gif/heic)
sips -Z 1024 in.png --out small.png                 # 最长边缩到 1024(保持比例)
sips -z 600 800 in.png                              # 强制 600x800
sips -c 500 500 in.png                              # 中心裁剪
```
权限：无。陷阱：`-Z`/`-z` 顺序是 高 宽；无 `--out` 会覆盖原图。

### textutil — txt/html/rtf/rtfd/docx/wordml/odt/webarchive 互转
入口：
```bash
textutil -convert txt in.html -output out.txt       # convert 目标: txt/rtf/rtfd/html/docx/odt
textutil -convert docx a.rtf b.html -output out.docx  # 多文件合并转换
textutil -info in.docx                              # 看格式/编码/字数
```
权限：无。陷阱：无 charset 声明的 HTML 中文乱码，先补 `<meta charset="utf-8">`；复杂 docx 样式会丢（保留样式用 pandoc，已装）。

### plutil — plist ↔ JSON/XML 互转、校验
入口：
```bash
plutil -convert xml1 a.json -o a.plist              # json→plist; convert 目标: xml1/json/binary1
plutil -convert json -o - a.plist                   # plist→json 输出到 stdout
plutil -lint a.plist                                # 校验语法
```
权限：无。陷阱：convert 的格式参数是 `xml1` 不是 `plist`。

### ditto / xattr / file — 复制保留元数据、扩展属性、类型探测
入口：
```bash
ditto src dst                                       # 复制目录/文件,保留资源 fork 和元数据(比 cp 全)
xattr -w tag value 文件 && xattr -p tag 文件         # 写/读扩展属性; -l 列全部; -c 清空
file 文件                                            # 类型探测(二进制也报)
```
权限：无。

### hdiutil — 磁盘镜像创建/挂载/转换
入口：
```bash
hdiutil create -size 100m -fs APFS -volname V x.dmg # 建空镜像
hdiutil create -srcfolder 目录/ -volname V x.dmg    # 目录打包成 dmg
hdiutil attach x.dmg -nobrowse -quiet               # 挂载(quiet 静音)
hdiutil detach /Volumes/V -quiet                    # 卸载
hdiutil convert x.dmg -format UDZO -o y.dmg         # 格式转换(UDZO压缩/UDRO只读)
```
权限：挂载可能首次弹窗。

### diskutil — 磁盘/分区/卷信息与操作
入口：
```bash
diskutil list                                       # 全部磁盘分区表
diskutil info /dev/diskXsY | grep -E "Volume Name|Mount"  # 卷信息
```
权限：只读免授权；格式化/分区类操作破坏性,执行前必须向用户确认。

### 系统剪贴板
入口：`echo x | pbcopy` / `pbpaste`；截图进剪贴板：`screencapture -c`（见 03 片）。
