#!/usr/bin/swift
// PDFKit：PDF 文本提取/信息/搜索/合并/拆分
// 用法:
//   pdf.swift text <file.pdf> [页码]   提取全文或指定页(1-based)
//   pdf.swift info <file.pdf>          页数/标题/作者/是否加密
//   pdf.swift search <file.pdf> <词>   搜索,输出页码+片段
//   pdf.swift merge <out.pdf> <a.pdf> <b.pdf> ...
//   pdf.swift split <file.pdf> <输出目录>   每页一个 PDF
import PDFKit
import Foundation

let args = CommandLine.arguments
guard args.count > 2 else { print("usage: pdf.swift <text|info|search|merge|split> ..."); exit(1) }
let task = args[1]

func openDoc(_ p: String) -> PDFDocument? {
    let doc = PDFDocument(url: URL(fileURLWithPath: p))
    if doc == nil { print("cannot open: \(p)") }
    return doc
}

switch task {
case "text":
    guard let doc = openDoc(args[2]) else { exit(1) }
    if args.count > 3, let n = Int(args[3]) {
        guard n >= 1, n <= doc.pageCount, let page = doc.page(at: n-1) else { print("bad page \(n)"); exit(1) }
        print(page.string ?? "")
    } else {
        print(doc.string ?? "")
    }
case "info":
    guard let doc = openDoc(args[2]) else { exit(1) }
    print("pages: \(doc.pageCount)")
    print("title: \(doc.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String ?? "-")")
    print("author: \(doc.documentAttributes?[PDFDocumentAttribute.authorAttribute] as? String ?? "-")")
    print("encrypted: \(doc.isLocked)")
case "search":
    guard args.count > 3, let doc = openDoc(args[2]) else { exit(1) }
    let q = args[3].lowercased()
    for i in 0..<doc.pageCount {
        guard let page = doc.page(at: i), let s = page.string?.lowercased(), s.contains(q) else { continue }
        if let r = s.range(of: q) {
            let start = s.index(r.lowerBound, offsetBy: -min(30, s.distance(from: s.startIndex, to: r.lowerBound)), limitedBy: s.startIndex) ?? s.startIndex
            let endIdx = s.index(r.upperBound, offsetBy: 40, limitedBy: s.endIndex) ?? s.endIndex
            print("p\(i+1): …\(s[start..<endIdx].replacingOccurrences(of: "\n", with: " "))…")
        }
    }
case "merge":
    guard args.count > 4 else { print("merge needs out + 2+ inputs"); exit(1) }
    let out = PDFDocument()
    for p in args[3...] {
        guard let doc = openDoc(p) else { exit(1) }
        for i in 0..<doc.pageCount { if let pg = doc.page(at: i) { out.insert(pg, at: out.pageCount) } }
    }
    out.write(toFile: args[2])
    print("merged \(out.pageCount) pages -> \(args[2])")
case "split":
    guard args.count > 3, let doc = openDoc(args[2]) else { exit(1) }
    let dir = args[3]
    try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    let base = ((args[2] as NSString).lastPathComponent as NSString).deletingPathExtension
    for i in 0..<doc.pageCount {
        guard let pg = doc.page(at: i) else { continue }
        let single = PDFDocument()
        single.insert(pg, at: 0)
        let out = "\(dir)/\(base)-p\(i+1).pdf"
        single.write(toFile: out)
        print(out)
    }
default:
    print("unknown task: \(task)"); exit(1)
}
