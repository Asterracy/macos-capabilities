# 09 视觉识别（Vision framework）

### scripts/vision — 四合一本地识别：OCR/文字区域/物体/分类（已实测,中英混排,零联网）
入口：
```bash
S=~/.agents/skills/macos-capabilities/scripts
$S/vision all 图.png                 # 四合一(默认推荐)
$S/vision ocr 图.png                 # 只要文字(快)
$S/vision regions 图.png             # 只要文字块坐标(归一化 0~1)
$S/vision objects 图.png             # 物体类别+坐标(约80类,英文标签)
$S/vision classify 图.png            # 图像内容标签(英文)
任意子命令加 --json                   # 结构化输出
```
权限：无,纯离线,图片不出机。
阈值：文字 0.5 / 区域 0.3 / 物体 0.25 / 分类官方高召回过滤;低置信结果会注明"已过滤 N 个",**空结果如实汇报不装成功**。
源码 `scripts/vision.swift`(物体检测用 ObjC 动态派发,macOS 26 SDK 编译期隐藏该类型,运行时可用——改源码时保持该写法)。

### 截图 → 识别 组合
```bash
screencapture -x /tmp/snap.png       # 截屏(03 片)
S=$HOME/.agents/skills/macos-capabilities/scripts; $S/vision ocr /tmp/snap.png
```

### 其他 Vision 请求（需要时改源码,模式同 vision.swift）
| 请求 | 能力 |
|------|------|
| VNGenerateImageFeaturePrint | 图像指纹(以图搜图/去重,输出 32 字节向量) |
| VNDetectFaceRectanglesRequest | 人脸位置(还有 landmarks 五官细节) |
| VNDetectBarcodesRequest | 二维码/条形码(含解码内容) |
| VNDetectHorizonRequest | 水平线角度 |
| VNDetectRectanglesRequest | 任意矩形(文档边缘检测) |
| VNGeneratePersonSegmentationRequest | 人物抠图 mask |
| VNRecognizeTextRequest.revision | 语言扩展: recLanguages 加 ja/ko/fr/de 等 |

### VisionKit — 系统扫描仪界面(LiveText 级 OCR)
需要"相机扫描文档"交互流程时用 VisionKit 的 VNDocumentCameraViewController(需摄像头授权);纯程序化识别上面 requests 够用。

### 识图分工原则
本会话模型若支持图像输入,直接读图;**读不到或识别失败,才降级本片本地识别**——不要声明"无法识图",直接跑 `vision all`,结果以文本给用户。
