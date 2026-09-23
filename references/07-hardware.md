# 07 硬件与近场连接

### scripts/wifi — CoreWLAN 封装：WiFi 扫描/连接状态（已实测）
入口：
```bash
S=~/.agents/skills/macos-capabilities/scripts
$S/wifi scan          # 周围网络按信号强度排序(SSID + dBm,-40 强 / -80 弱)
$S/wifi scan 20       # 前 20 个
$S/wifi status        # 当前连接: SSID/BSSID/信号/信道
```
权限：**扫描免授权**；status 里的 SSID 名需定位授权(拿不到会显示 nil,信号/信道仍可用)。
陷阱：CoreWiFi 对频繁扫描节流,短时间重复调用返回空,等 ~10 秒重试。

### CoreLocation — 定位（swift 直调,需定位授权）
```swift
import CoreLocation
let m = CLLocationManager()
m.delegate = /* 实现 didUpdateLocations */; m.requestLocation()
// 单次坐标: m.location?.coordinate.latitude/longitude, 海拔 altitude, 精度 horizontalAccuracy
```
权限：首次弹定位授权;拒绝后 status 维度拿不到坐标。终端跑 swift 时授权对象是终端 App。

### CoreBluetooth — BLE 设备扫描/读写（swift 直调,需蓝牙授权）
```swift
import CoreBluetooth
let cm = CBCentralManager(delegate: nil, queue: nil)
// 扫描: cm.scanForPeripherals(withServices: nil)  回调 didDiscover外设(名字/RSSI/广播数据)
// 蓝牙开关状态: cm.state == .poweredOn
```
权限：首次弹蓝牙授权。真实现协议栈(连接/服务/特征读写)在 CBPeripheral/CBCharacteristic。

### IOKit / SMC — 传感器读数（温度/风扇/电压）
无公开 swift 一行式;成熟做法用 `powermetrics`(需 sudo)或编译 smc 工具。CPU/GPU 占比优先 `top`/`powermetrics`,温度数据非必须不折腾。

### IOBluetooth（经典蓝牙）/ CoreHID — 底层设备
连接经典蓝牙设备、读 HID 原始报文用,日常外设问题用 `system_profiler SPBluetoothDataType`（02 片）先看清单再决定是否写代码。

### NearbyInteraction / MultipeerConnectivity
UWB 测距(Mac 无 UWB 芯片,仅 iPhone 互联场景)/ 设备间 P2P 传数据(Mac↔Mac 可用,需双方跑同一 App)。遇到再深入。
