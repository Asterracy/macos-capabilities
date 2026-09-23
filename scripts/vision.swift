#!/usr/bin/swift
// macOS Vision framework 视觉识别（移植自 mac-vision vision-all.swift，拆分为独立子命令）
// 用法: vision.swift <all|ocr|regions|objects|classify> <图片路径> [--json]
import Vision
import Foundation
import AppKit

let args = CommandLine.arguments
guard args.count > 2 else {
    print("usage: vision.swift <all|ocr|regions|objects|classify> <image> [--json]")
    exit(1)
}
let task = args[1].lowercased()
let path = args[2]
let asJson = args.contains("--json")
guard ["all", "ocr", "regions", "objects", "classify"].contains(task) else {
    print("unknown task: \(task)"); exit(1)
}

guard let img = NSImage(contentsOfFile: path),
      let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    print("cannot load image: \(path)"); exit(1)
}

let textThreshold: Float = 0.5
let textRegionThreshold: Float = 0.3
let objectThreshold: Float = 0.25

struct TextLine { let string: String; let conf: Float }
struct TextRegion { let x: Double; let y: Double; let w: Double; let h: Double; let conf: Float }
struct ObjectHit { let label: String; let conf: Float; let x: Double; let y: Double; let w: Double; let h: Double }
struct ClassHit { let label: String; let conf: Float }

var texts: [TextLine] = []
var textRegions: [TextRegion] = []
var objects: [ObjectHit] = []
var classes: [ClassHit] = []
var textFiltered = 0, objectFiltered = 0, classFiltered = 0

// ① OCR
let textReq = VNRecognizeTextRequest { req, _ in
    guard let results = req.results as? [VNRecognizedTextObservation] else { return }
    for o in results {
        guard let c = o.topCandidates(1).first else { continue }
        if c.confidence >= textThreshold { texts.append(TextLine(string: c.string, conf: c.confidence)) }
        else { textFiltered += 1 }
    }
}
textReq.recognitionLanguages = ["zh-Hans", "en-US"]
textReq.recognitionLevel = .accurate

// ② 文字区域
let textRegionReq = VNDetectTextRectanglesRequest { req, _ in
    guard let results = req.results as? [VNTextObservation] else { return }
    for o in results where o.confidence >= textRegionThreshold {
        let b = o.boundingBox
        textRegions.append(TextRegion(x: b.origin.x, y: b.origin.y, w: b.size.width, h: b.size.height, conf: o.confidence))
    }
}
textRegionReq.reportCharacterBoxes = false

// ③ 图像分类
let classifyReq = VNClassifyImageRequest { req, _ in
    guard let results = req.results as? [VNClassificationObservation] else { return }
    for o in results {
        if o.hasMinimumPrecision(0.1, forRecall: 0.8) { classes.append(ClassHit(label: o.identifier, conf: o.confidence)) }
        else { classFiltered += 1 }
    }
}

// ④ 物体检测（ObjC 动态派发：编译期类型被 macOS 26 SDK 隐藏，运行时可用）
func runObjects() {
    if let objCls = NSClassFromString("VNRecognizeObjectsRequest") as? VNRequest.Type {
        let objReq = objCls.init()
        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        try? handler.perform([objReq])
        if let results = objReq.results as? [VNRecognizedObjectObservation] {
            for o in results {
                for l in o.labels where l.confidence >= objectThreshold {
                    let b = o.boundingBox
                    objects.append(ObjectHit(label: l.identifier, conf: l.confidence,
                                             x: b.origin.x, y: b.origin.y, w: b.size.width, h: b.size.height))
                }
                if o.labels.contains(where: { $0.confidence < objectThreshold }) { objectFiltered += 1 }
            }
        }
    }
}

let handler = VNImageRequestHandler(cgImage: cg, options: [:])
switch task {
case "ocr": try handler.perform([textReq])
case "regions": try handler.perform([textRegionReq])
case "classify": try handler.perform([classifyReq])
case "objects": runObjects()
case "all":
    runObjects()
    try handler.perform([textReq, textRegionReq, classifyReq])
default: break
}

func emit(_ name: String, _ items: [[String: Any]]) -> [String: Any] { [name: items] }

if asJson {
    var jsonObj: [String: Any] = [:]
    if ["all", "ocr"].contains(task) {
        jsonObj["text"] = texts.map { ["string": $0.string, "confidence": $0.conf] as [String: Any] }
        if textFiltered > 0 { jsonObj["textFiltered"] = textFiltered }
    }
    if ["all", "regions"].contains(task) {
        jsonObj["textRegions"] = textRegions.map { ["x": $0.x, "y": $0.y, "w": $0.w, "h": $0.h, "confidence": $0.conf] as [String: Any] }
    }
    if ["all", "objects"].contains(task) {
        jsonObj["objects"] = objects.map { ["label": $0.label, "confidence": $0.conf, "x": $0.x, "y": $0.y, "w": $0.w, "h": $0.h] as [String: Any] }
        if objectFiltered > 0 { jsonObj["objectFiltered"] = objectFiltered }
    }
    if ["all", "classify"].contains(task) {
        jsonObj["classes"] = classes.map { ["label": $0.label, "confidence": $0.conf] as [String: Any] }
        if classFiltered > 0 { jsonObj["classFiltered"] = classFiltered }
    }
    if let data = try? JSONSerialization.data(withJSONObject: jsonObj, options: [.prettyPrinted, .sortedKeys]),
       let str = String(data: data, encoding: .utf8) { print(str) }
} else {
    if ["all", "ocr"].contains(task) {
        if texts.isEmpty { print("文字: 未识别到") } else {
            print("文字 (\(texts.count) 行):")
            texts.forEach { print("  \($0.string)  (\(String(format: "%.2f", $0.conf)))") }
            if textFiltered > 0 { print("  已过滤 \(textFiltered) 个低置信度") }
        }
    }
    if ["all", "regions"].contains(task) {
        if textRegions.isEmpty { print("文字区域: 未检测到") } else {
            print("文字区域 (\(textRegions.count) 个, 归一化坐标):")
            textRegions.forEach { print("  (\(String(format: "%.3f", $0.x)), \(String(format: "%.3f", $0.y))) \(String(format: "%.2f", $0.w))x\(String(format: "%.2f", $0.h))") }
        }
    }
    if ["all", "objects"].contains(task) {
        if objects.isEmpty { print("物体: 未识别到") } else {
            print("物体 (\(objects.count) 个):")
            objects.forEach { print("  \($0.label)  (\(String(format: "%.2f", $0.conf)))") }
        }
    }
    if ["all", "classify"].contains(task) {
        if classes.isEmpty { print("分类: 无有效标签") } else {
            print("分类 (\(classes.count) 个):")
            classes.forEach { print("  \($0.label)  (\(String(format: "%.2f", $0.conf)))") }
        }
    }
}
