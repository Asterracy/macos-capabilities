#!/usr/bin/swift
// CoreWLAN：WiFi 扫描与连接状态
// 用法:
//   wifi.swift scan [N]     扫描周围网络(按信号去重,默认前10)
//   wifi.swift status       当前连接(读SSID需定位权限,扫描不需要)
import CoreWLAN
import Foundation

let args = CommandLine.arguments
let task = args.count > 1 ? args[1] : "scan"
guard let iface = CWWiFiClient.shared().interface() else { print("no wifi interface"); exit(1) }

switch task {
case "scan":
    let top = args.count > 2 ? Int(args[2]) ?? 10 : 10
    guard let nets = try? iface.scanForNetworks(withName: nil) else { print("scan failed"); exit(2) }
    var best: [String: Int] = [:]
    for n in nets {
        guard let ssid = n.ssid else { continue }
        if best[ssid] == nil || best[ssid]! < n.rssiValue { best[ssid] = n.rssiValue }
    }
    for (ssid, rssi) in best.sorted(by: { $0.value > $1.value }).prefix(top) {
        print("\(ssid)\t\(rssi) dBm")
    }
    if best.isEmpty { print("(扫描结果为空 — CoreWiFi 对频繁扫描节流, 等待约10秒后重试)") }
case "status":
    print("ssid: \(iface.ssid() ?? "nil (需定位权限)")")
    print("bssid: \(iface.bssid() ?? "-")")
    print("rssi: \(iface.rssiValue()) dBm")
    print("channel: \(iface.wlanChannel()?.channelNumber ?? 0)")
    print("country: \(iface.countryCode() ?? "-")")
default:
    print("usage: wifi.swift <scan|status> [N]"); exit(1)
}
