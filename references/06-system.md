# 06 系统与网络控制

### caffeinate — 防休眠（长任务必配）
入口：
```bash
caffeinate -dimsu -t 3600 无关命令 &                  # 防睡眠 1 小时(d=磁盘 i=空闲睡眠 m=系统 s=插电时防睡眠 u=防屏幕暗)
caffeinate -w <pid>                                  # 跟随某进程,进程结束自动解除
```
权限：无。陷阱：`caffeinate 命令` 是包住命令执行期间不睡；纯 `-t 秒` 是定时防睡。

### pmset — 电源管理查询/设置（改设置需 sudo）
入口：
```bash
pmset -g                                             # 当前电源策略(含电量/充电状态线索)
pmset -g batt                                        # 电池状态:"AC Power"=插电,"Battery Power"=电池
pmset -g therm                                       # 热压力状态
```
权限：查询免授权,`pmset sleep 15` 这类设置需 sudo(向用户确认再动)。

### networksetup — 网络配置全读写
入口：
```bash
networksetup -listallhardwareports                   # 网卡列表(en0=WiFi 等)
networksetup -getinfo "Wi-Fi"                        # IP/掩码/路由/DHCP
networksetup -listpreferredwirelessnetworks en0      # 已存 WiFi 列表
networksetup -setdnsservers "Wi-Fi" 223.5.5.5 8.8.8.8    # 改 DNS(置空=恢复自动)
networksetup -setwebproxy "Wi-Fi" 127.0.0.1 7890     # HTTP 代理(配 Clash 用)
```
权限：改配置需管理员,弹窗授权或 sudo；查询免授权。
延伸：连接状态/周围网络扫描走 07 片 CoreWLAN。

### security — 钥匙串/证书
入口：
```bash
security list-keychains                              # 钥匙串列表
security find-generic-password -s 服务名 -w           # 读密码(-w 只出密码,会弹授权)
security find-certificate -a -p /path.pem            # 导出证书
security verify-cert -c cert.pem                     # 验证书
```
权限：读密码项会弹钥匙串授权；列表/证书查询免授权。陷阱：绝不在日志打印 -w 的输出。

### 系统信息与进程
入口：
```bash
sw_vers                                              # macOS 版本/构建号
uname -m                                             # arm64
scutil --get ComputerName                            # 电脑名
top -l 1 -n 5 -o cpu | tail -8                       # CPU 前 5 进程(单次采样)
memory_pressure -Q                                   # 内存压力等级
df -h /                                              # 磁盘余量
```
权限：无。

### 剪贴板管道
入口：`echo x | pbcopy`；`pbpaste > 文件`；配 `osascript` 可读写富文本剪贴板(见 05 片)。
