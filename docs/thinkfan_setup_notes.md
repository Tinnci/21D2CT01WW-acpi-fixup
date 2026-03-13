# ThinkPad Z13 风扇控制设置

**日期:** 2026-01-06  
**系统:** CachyOS x86_64 (基于Arch), ThinkPad Z13, KDE Plasma 6.5.4

## 安装

- 从AUR安装了 `thinkfan` v2.0.0
- `lm_sensors` 已预装

## 配置

**配置文件:** `/etc/thinkfan.conf`

```yaml
sensors:
  - hwmon: /sys/class/hwmon
    name: k10temp
    indices: [1]
  - hwmon: /sys/class/hwmon
    name: nvme
    indices: [1]
    optional: true

fans:
  - tpacpi: /proc/acpi/ibm/fan

levels:
  - [0, 0, 50]              # 50°C以下关闭风扇
  - ["level 2", 48, 60]     # 48-60°C 低速
  - ["level 4", 58, 70]     # 58-70°C 中速
  - ["level 6", 68, 80]     # 68-80°C 高速
  - ["level auto", 78, 120] # 78°C以上自动/最大速度
```

## 监控的传感器

- **AMD Ryzen CPU** (k10temp驱动) - 主要温度传感器
- **NVMe固态硬盘** (可选) - 驱动器温度

## 风扇接口

- **ThinkPad ACPI接口:** `/proc/acpi/ibm/fan`
- 支持等级0-7、自动模式和完全释放模式

## 服务状态

- ✅ **开机自启** (`systemctl is-enabled thinkfan.service`)
- ✅ **与Arch/KDE同时启动**
- ✅ **睡眠/唤醒钩子已启用** (休眠后自动重启)

## 使用方法

```bash
# 检查状态
sudo systemctl status thinkfan.service

# 实时查看日志
journalctl -u thinkfan -f

# 手动启动/停止(如需要)
sudo systemctl start thinkfan.service
sudo systemctl stop thinkfan.service

# 测试配置(不运行守护程序)
sudo thinkfan -n
```

## 热管理行为

| 温度范围 | 风扇速度 | 行为 |
|---|---|---|
| 0-50°C | 关闭 (0) | 风扇完全关闭 |
| 48-60°C | 低速 (2) | 安静运行 |
| 58-70°C | 中速 (4) | 平衡冷却 |
| 68-80°C | 高速 (6) | 主动冷却 |
| 78°C+ | 自动 | 最大速度/系统控制 |

## 注意事项

- 风扇控制独立于KDE/桌面环境
- 以系统服务形式运行(在用户登录前启动)
- 自动从休眠/唤醒循环恢复
- 可在 `/etc/thinkfan.conf` 中调整配置

## 当前系统传感器

- `ath11k_hwmon` (WiFi适配器) - 52°C
- `amdgpu-pci` (集成GPU) - 55°C 边缘温度
- `nvme-pci` (固态硬盘) - 55.9°C
- `k10temp` (CPU) - 主要监控

## 故障排除

### 错误: thinkpad_acpi: Fan_control seems disabled

**问题描述:**
```
thinkfan[PID]: ERROR: Kernel module thinkpad_acpi: Fan_control seems disabled.
```

**根本原因:**
- `thinkpad_acpi` 内核模块默认禁用用户态的风扇控制（出于安全考虑）

**解决方案:**

1. **创建模块配置文件:**
```bash
echo "options thinkpad_acpi fan_control=1" | sudo tee /etc/modprobe.d/99-thinkfan.conf
```

2. **重新加载模块 (立即生效):**
```bash
sudo modprobe -r thinkpad_acpi && sudo modprobe thinkpad_acpi
```

3. **验证配置:**
```bash
# 检查模块参数是否启用
cat /sys/module/thinkpad_acpi/parameters/fan_control
# 应输出: Y (表示已启用)

# 测试风扇控制
sudo thinkfan -n
```

4. **重启系统 (永久生效):**
```bash
sudo reboot
```

**预期结果:**
- `journalctl -u thinkfan -f` 不再显示 "Fan_control seems disabled" 错误
- 风扇自动根据温度调节
