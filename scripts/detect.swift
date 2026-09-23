#!/usr/bin/swift
// NSDataDetector：从自然语言文本抽取结构化信息(日期/地址/链接/电话/航班)
// 用法:
//   detect.swift <text>              抽取全部类型
//   detect.swift date <text>         仅日期时间(支持"下周三下午三点"这类自然语言)
//   detect.swift address|link|phone|transit <text>
//   echo "文本" | detect.swift -     从 stdin 读
import Foundation

let args = CommandLine.arguments
let keywords = ["date", "address", "link", "phone", "transit"]
var text = ""
var types: NSTextCheckingResult.CheckingType = [.date, .address, .link, .phoneNumber, .transitInformation]
if args.count == 1 || (args.count == 2 && keywords.contains(args[1].lowercased())) {
    text = readLine() ?? ""
    if args.count == 2 {
        switch args[1].lowercased() {
        case "date": types = [.date]
        case "address": types = [.address]
        case "link": types = [.link]
        case "phone": types = [.phoneNumber]
        case "transit": types = [.transitInformation]
        default: break
        }
    }
} else if args.count >= 2, keywords.contains(args[1].lowercased()) {
    switch args[1].lowercased() {
    case "date": types = [.date]
    case "address": types = [.address]
    case "link": types = [.link]
    case "phone": types = [.phoneNumber]
    case "transit": types = [.transitInformation]
    default: break
    }
    text = args.dropFirst(2).joined(separator: " ")
} else {
    text = args.dropFirst(1).joined(separator: " ")
}
guard !text.isEmpty else { print("no input"); exit(1) }
guard let detector = try? NSDataDetector(types: types.rawValue) else { print("detector init failed"); exit(2) }
let hits = detector.matches(in: text, range: NSRange(text.startIndex..., in: text))
if hits.isEmpty { print("(no matches)"); exit(0) }
let df = DateFormatter()
df.dateStyle = .full; df.timeStyle = .full; df.locale = Locale(identifier: "zh_CN")
for m in hits {
    let matched = text[Range(m.range, in: text)!]
    if let d = m.date { print("date\t\(matched)\t-> \(df.string(from: d))") }
    else if let a = m.components?.description, m.resultType == .address { print("address\t\(matched)\t-> \(a)") }
    else if let u = m.url { print("link\t\(matched)\t-> \(u.absoluteString)") }
    else if let p = m.phoneNumber { print("phone\t\(matched)\t-> \(p)") }
    else if m.resultType == .transitInformation, let c = m.components { print("transit\t\(matched)\t-> \(c)") }
}
