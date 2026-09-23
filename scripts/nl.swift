#!/usr/bin/swift
// NaturalLanguage 框架：分词/实体/词性/语言识别/端侧句向量相似度
// 用法:
//   nl.swift lang <text>            语言识别
//   nl.swift tokenize <text>        分词
//   nl.swift ner <text>             命名实体识别
//   nl.swift pos <text>             词性标注
//   nl.swift sim <text1> <text2>    语义相似度(0~1, 端侧句向量)
import NaturalLanguage
import Foundation

let args = CommandLine.arguments
guard args.count > 2 else { print("usage: nl.swift <lang|tokenize|ner|pos|sim> <text> [text2]"); exit(1) }
let task = args[1]
let text = args[2]

func detect(_ s: String) -> NLLanguage {
    NLLanguageRecognizer.dominantLanguage(for: s) ?? .english
}

func cosine(_ a: [Double], _ b: [Double]) -> Double {
    guard a.count == b.count, !a.isEmpty else { return 0 }
    var dot = 0.0, na = 0.0, nb = 0.0
    for i in 0..<a.count { dot += a[i]*b[i]; na += a[i]*a[i]; nb += b[i]*b[i] }
    let d = (na.squareRoot() * nb.squareRoot())
    return d == 0 ? 0 : dot / d
}

func embed(_ s: String) -> [Double]? {
    let lang = detect(s)
    guard let emb = NLEmbedding.sentenceEmbedding(for: lang) else { return nil }
    return emb.vector(for: s)
}

switch task {
case "lang":
    print(detect(text).rawValue)
case "tokenize":
    var toks: [String] = []
    let tagger = NLTagger(tagSchemes: [.tokenType])
    tagger.string = text
    tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .tokenType) { _, range in
        toks.append(String(text[range])); return true
    }
    print(toks.joined(separator: " | "))
case "ner":
    let tagger = NLTagger(tagSchemes: [.nameType])
    tagger.string = text
    tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, range in
        if let t = tag, t.rawValue != "OtherWord", t.rawValue != "Whitespace" {
            print("\(text[range])\t\(t.rawValue)")
        }
        return true
    }
case "pos":
    let tagger = NLTagger(tagSchemes: [.lexicalClass])
    tagger.string = text
    tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, range in
        if let t = tag { print("\(text[range])\t\(t.rawValue)") }
        return true
    }
case "sim":
    guard args.count > 3 else { print("sim needs two texts"); exit(1) }
    guard let va = embed(text), let vb = embed(args[3]) else {
        print("embedding not available for this language"); exit(2)
    }
    print(String(format: "%.4f", cosine(va, vb)))
default:
    print("unknown task: \(task)"); exit(1)
}
