# 08 端侧智能：NLP · 数据检测 · 语音识别 · 声音分析

### scripts/nl — NaturalLanguage 封装：分词/实体/词性/语言识别/语义相似度（已实测,中文就绪）
入口：
```bash
S=~/.agents/skills/macos-capabilities/scripts
$S/nl lang "文本"                    # 语言识别 → zh-Hans
$S/nl tokenize "探索macOS内置框架"    # 分词 → 探索 | macOS | 内置 | 框架
$S/nl ner "Racy 在浙江大学做 meta 分析"   # 命名实体(人名/地名/组织)
$S/nl pos "The quick brown fox"      # 词性标注
$S/nl sim "文本A" "文本B"             # 语义相似度 0~1(端侧句向量,中文 640 维已在本机)
```
权限：无,纯离线。
延伸：sim 实测参考——同义改写 ≈0.95,弱相关 ≈0.3；批量语义去重/聚类用 sim 两两算或改源码产向量。
源码 `scripts/nl.swift`。

### scripts/detect — NSDataDetector：自然语言抽结构化信息（已实测,支持中文自然语言时间）
入口：
```bash
S=~/.agents/skills/macos-capabilities/scripts
$S/detect "下周三下午三点开组会"        # 全类型抽取(日期/地址/链接/电话/航班)
$S/detect date "5月20号发货"           # 只抽日期(自然语言→精确时间戳)
$S/detect link "详情见 https://x.cn 或发邮件"   # 只抽链接
echo "文本..." | $S/detect -           # 长文本走 stdin
```
权限：无。输出格式 `类型\t原文\t→ 解析结果`。实测:"下周三下午三点"→2026-09-09 15:00 CST。

### Speech — 语音转文字 STT（swift 直调,需麦克风授权）
```swift
import Speech
SFSpeechRecognizer.requestAuthorization { _ in }
let rec = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))!
// 音频文件转写: SFSpeechURLRecognitionRequest(url: 音频url), 回调逐段出文本
// 实时转写: SFSpeechAudioBufferRecognitionRequest + AVAudioEngine 喂缓冲
```
权限：麦克风 + 语音识别双授权。快速路径:短音频先 ffmpeg 抽轨(03 片)再喂。
注意:有网时走服务端识别更准,离线用 `requiresOnDeviceRecognition = true`。

### SoundAnalysis — 环境声音分类（swift 直调）
识别 300+ 类声音(掌声/门铃/猫狗叫/哭声/警报/流水…),流式或文件。需要时以 SNClassifySoundRequest 写 swift,参考 vision.swift 的请求模式。

### ShazamKit — 音频指纹匹配（识别"放的是什么歌"）
对录音做指纹后匹配 Apple 曲库,需联网。遇识曲需求再写,权限=麦克风。

### CoreML / CreateML — 自定义模型跑/训
```bash
# 跑: 模型 .mlmodel 拖进 swift 项目或 swiftc 直接引用,推理几行
# 训(文本分类器示例):
#   swift 脚本里 MLTextClassifier(trainingData: ..., algorithm: .maxEnt)
```
本机 M5/16GB 可跑小型推理;大模型训练不现实。系统自带模型已覆盖大部分需求(见 09 片)。

### 负清单（已实测不可用,勿再试）
- **FoundationModels**(Apple 端侧大模型) → `deviceNotEligible`(M5/16GB 仍不可用,疑似需 Apple Intelligence 开关+区域支持;用户启用后此条目应复查)
- 中文 NER 粒度粗(人名常标 OtherWord),关键实体抽取结果需人工复核
