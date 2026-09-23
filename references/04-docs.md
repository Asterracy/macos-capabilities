# 04 文档处理

### scripts/pdf — PDFKit 封装：提取/信息/搜索/合并/拆分（已实测,支持中文）
入口：
```bash
S=~/.agents/skills/macos-capabilities/scripts
$S/pdf text 文献.pdf                # 提取全文(OCR 层的文本,非扫描件)
$S/pdf text 文献.pdf 3              # 只提取第 3 页
$S/pdf info 文献.pdf                # 页数/标题/作者/是否加密
$S/pdf search 文献.pdf "bias"       # 关键词搜索,输出页码+上下文片段
$S/pdf merge out.pdf a.pdf b.pdf    # 合并(顺序=参数顺序)
$S/pdf split 文献.pdf 输出目录/      # 每页拆成独立 PDF
```
权限：无,文件读得到就能处理。陷阱：扫描版 PDF 无文本层,text 提取为空 → 截页成图后走 `scripts/vision ocr`（09 片）。
源码 `scripts/pdf.swift`,新需求(加密/旋转/加水印)改源码 `swiftc -O` 重编译。

### QuickLook — 不打开文件生成缩略图/预览
入口：
```bash
qlmanage -t -s 512 -o /tmp/ 文件.docx               # 生成 512px 缩略图 /tmp/文件.docx.png
qlmanage -p 文件                                     # 打开系统预览窗(交互,agent 少用)
```
权限：无。延伸：缩略图可喂给 vision 识别排版；支持格式多(pdf/office/视频/代码)。

### 预览.app 自动化 — 批量注释/签名/旋转
入口：
```bash
open -a Preview 文件.pdf                            # 打开;进一步操作走 osascript GUI 脚本(需辅助功能授权)
```
批量处理优先用 scripts/pdf + sips 组合,GUI 自动化是最后手段。

### 文档三兄弟分工
- **结构化提取**（要正文文字）→ `scripts/pdf text`
- **外观快照**（要版面样子）→ `qlmanage -t` 或 `screencapture`
- **格式转换** → `textutil`（01 片,txt/rtf/docx/html 互转）、`pandoc`（已装,md/docx/pdf/epub,学术写作主力）

### Pandoc 补充（已装 3.10.2）
```bash
pandoc in.md -o out.docx                            # md→docx
pandoc in.md --pdf-engine=xelatex -o out.pdf        # md→pdf(中文需 CJK 字体声明)
pandoc in.docx -t markdown -o out.md                # docx→md(文献整理常用)
```
