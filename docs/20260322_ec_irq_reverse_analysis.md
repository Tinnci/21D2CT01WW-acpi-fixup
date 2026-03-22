# ThinkPad Z13 Gen1 EC IRQ 逆向分析报告
# N3GHT15W (Engineering EC v0.15) — Ghidra + Capstone 综合分析

日期: 2026-03-22
固件: N3GHT15W (SPI dump, Slot A @ 0x1000)
基址: 0x10070000, VT @ 0x10070100 (80 entries)
工具: Ghidra 12.0.4 headless + Capstone 5.0.7

---

## 1. 执行摘要

通过 Ghidra headless 反编译了 EC 固件中的 **52/56 个唯一 IRQ handler**（共 1543 行 C 伪代码），
并深度追踪了 **76 个关键子函数**（3739 行，含 3 级调用链）。
成功识别了 EC 的完整中断架构、任务调度器、ACPI EC 命令通道、SMBus/I2C 主控状态机、
以及 eSPI 级联分发机制。

---

## 2. EC 内核架构

### 2.1 NVIC 中断控制函数

| 函数地址 | 命名 | NVIC 寄存器 | 作用 |
|:---------|:-----|:-----------|:-----|
| 0x10082700 | ec_irq_clear_pending | ICPR (0xE000E280) | 清除指定 IRQ 的 pending 标志 |
| 0x10082720 | ec_irq_disable | ICER (0xE000E180) | 禁用指定 IRQ |
| 0x10082740 | ec_irq_enable | ISER (0xE000E100) | 启用指定 IRQ |

三个函数结构完全一致：
1. 检查当前是否处于特权模式 (`isCurrentModePrivileged`)
2. 保存并禁用全局中断 (`disableIRQinterrupts`)
3. 写入对应 NVIC 寄存器: `*(reg_base + (irq >> 5) * 4) = 1 << (irq & 0x1f)`
4. 恢复全局中断状态

### 2.2 任务调度器 — ec_task_post (0x100720D4)

```
任务 ID 范围: 1 ~ 0x6C (108 个任务槽)
数据结构: 链表，每个节点 1 字节 (delta-encoded next pointer)
    DAT_1007212c → 控制块:
        [+1] head (第一个任务 ID)
        [+2] tail (最后一个任务 ID)
        [+3] flags (bit1 = "当前任务重入")
        [+4] status flags
        [+5] current_task_id
    DAT_10072130 → 任务数组 [0x6C bytes]
        值 0x80 = slot 空闲
        值 0x7F = 队尾标记
        其他值 = delta 到下一个任务

操作: 将 task_id 追加到调度队列末尾
调用者: 20+ 处 (SMBus, GPIO, ACPI, eSPI 等)
```

关键任务 ID:
- **0x48** (十进制 72): SMBus/I2C 事务调度 — 由 ec_gpio_handler_sub 中大量调用
- **0x53** (十进制 83): SMBus 中断触发后调度 — 由 IRQ20/IRQ40 直接调用

### 2.3 位分发函数 — ec_fifo_push (0x10086FB8)

```c
void ec_fifo_push(uint bitmask, int callback_table) {
    for (int i = 0; bitmask != 0; i++, bitmask >>= 1) {
        if (bitmask & 1) {
            callback_table[i]();   // 调用第 i 个函数指针
        }
    }
}
```
- 用于 eSPI handler (IRQ44/IRQ50/IRQ51): 从中断状态寄存器读取 bitmask，逐位分发到对应 handler
- 3 处调用点

---

## 3. 中断向量表完整映射

### 3.1 系统异常 (VT 0-15)

| VT# | 地址 | 名称 | 功能 |
|:----|:-----|:-----|:-----|
| 0 | 0x200C8000 | SP_Main | 初始栈顶 |
| 1 | 0x100701F4 | Reset_Handler | CRT0 启动 |
| 2 | 0x10070290 | NMI_Handler | 解压缩代码 (LZ) |
| 3 | 0x1007029C | HardFault_Handler | 解压缩代码 (LZ) |
| 4 | 0x100702A8 | MemManage_Handler | 解压缩代码 (LZ) |
| 5 | 0x100702B4 | BusFault_Handler | 解压缩代码 (LZ) |
| 6 | 0x100702C0 | UsageFault_Handler | 解压缩代码 (LZ) |
| 11 | 0x100702CC | SVC_Handler | 存根 (LZ 代码尾部) |
| 12 | 0x100702D8 | DebugMon_Handler | 存根 |
| 14 | 0x100702E4 | PendSV_Handler | 存根 |
| 15 | 0x100702F0 | SysTick_Handler | 存根 |

> **注**: VT 2-6 的地址指向 LZ 解压缩算法的不同入口点，这些并非真正的异常 handler，
> 而是 EC 固件压缩 payload 的解压缩函数 (CRT0 阶段使用)。

### 3.2 IRQ Handler 功能分类

| 类别 | IRQ 编号 | Handler 数量 | 核心外设 | 关键子函数 |
|:-----|:---------|:------------|:---------|:-----------|
| **ACPI EC** | 7, 8 | 2 | ACPI_EC_BLOCK (0x400E0000) | ec_acpi_cmd_handler, ec_irq_enable |
| **SMBus/I2C** | 20, 35-40, 48 | 8 | SMBUS (0x400A5000-0x400AF000) | FUN_10085518 (状态机), ec_task_post |
| **eSPI** | 11, 29, 31-32, 42-47, 49-51, 53-59, 61-63 | 21 | eSPI (0x400BB000) | ec_espi_sub, ec_fifo_push |
| **键盘** | 10, 24, 26 | 3 | KBD_BLOCK (0x400C1000-0x400CF000) | 直接寄存器操作 |
| **GPIO** | 6, 60 | 2 | GPIO_0/1 (0x40080000-0x4009F000) | ec_gpio_sub, ec_gpio_handler_sub |
| **SRAM** | 5, 41 | 2 | 仅 SRAM 操作 | FUN_10099b80 |
| **默认** | 0-2, 12-18, 21-23, 27-28, 33-34, 52 | 19 (共享) | EC_FLASH 判断 | 0x100702FC |
| **存根** | 3, 4, 9, 25, 30 | 5 | ≤5 指令 | — |

---

## 4. ACPI EC 子系统 (IRQ7 + IRQ8)

### 4.1 中断流程

```
IRQ8_Handler (0x1008BB58):                     ← OBF (输出缓冲满) 中断
    ec_irq_disable(0x18=IRQ24)                 ← 暂停 KBD 中断
    ec_acpi_cmd_handler(0)                     ← 处理 ACPI EC 命令
    更新 pending 标志: status[0x10] |= status[0x0E]
    ec_irq_enable(0x18=IRQ24)                  ← 恢复 KBD 中断

IRQ7_Handler (0x1008BB74):                     ← IBF (输入缓冲满) 中断
    ec_irq_enable(0x18=IRQ24)                  ← 仅重新启用 KBD
```

### 4.2 ACPI EC 命令调度器 (0x10098500)

```
ec_acpi_cmd_handler(channel):
    遍历 6 个 ACPI EC 通道:
        通道配置: DAT_10098540[i * 0xC]
            [+4] = ACPI EC 实例编号 (0-5)
            [+7] = SCI 中断掩码 1
            [+8] = SCI 中断掩码 2
        ACPI EC 寄存器块: DAT_10098544[instance * 0x2000]
            [+0x02] = 命令数据
            [+0x04] = 命令数据 2
            [+0x0C] = 中断使能掩码
            [+0x0E] = 中断状态寄存器
            [+0x10] = pending 标志
            [+0x12] = 通道活跃标志
        如果通道活跃 && (中断掩码 & 状态) != 0:
            → FUN_10087060(channel_id)          ← 处理该通道的 EC 命令
```

### 4.3 ACPI EC 通道处理器 (0x10087060)

```
FUN_10087060(channel):
    channel_config = DAT_100870fc[channel * 0xC]
    ec_block = DAT_10087100[instance * 0x2000]

    清除通道中断使能: ec_block[0x0C] &= ~mask

    如果 "一次性" 标志:
        清除标志并返回
    否则:
        读取 EC 数据寄存器 (offset 0x02 或 0x04)
        清零数据寄存器
        检查 SCI 掩码:
            掩码1 匹配 → FUN_10082454(channel, 0, ~data)  ← 发送 SCI 到主机
            掩码2 匹配 → FUN_10082414(channel, 0xFFFF)     ← 发送 SCI 应答

    恢复通道中断使能: ec_block[0x0C] |= mask
```

---

## 5. SMBus/I2C 子系统

### 5.1 硬件总线映射

| 外设地址 | 总线名称 | 连接设备 (推测) |
|:---------|:---------|:---------------|
| 0x400A5000 | SMBUS_0 (index 20) | 系统 SMBus (电池/充电器) |
| 0x400A7000 | SMBUS_1 (index 28) | PD 控制器 TPS65982 |
| 0x400A9000 | SMBUS_2 (index 36) | 未知 |
| 0x400AB000 | SMBUS_3 (index 44) | KB8002 USB4 Retimer |
| 0x400AD000 | SMBUS_4 (index 52) | 未知 |
| 0x400AF000 | SMBUS_5 (index 60) | 电池/充电芯片 (BQ25710?) |

### 5.2 IRQ 分组

```
IRQ20 (0x1008BC2E) — SMBus 全局中断:
    写入 DAT_1008bc50 = 2  (状态清除)
    写入 DAT_1008bc54 |= 2 (通知标志)
    ec_task_post(0x53)      → 调度 SMBus 任务

IRQ35-39 (0x1008BBD4-0x1008BC1C) — SMBus 通道中断:
    共享状态机入口:
        读取 status[0x42] bit6 检查
        读取 data[0x40] (16-bit)
        检查 bit11 → 选择 TX 或 RX callback
        调用对应函数指针 (从通道结构中取)
        清除 status[0x42] = 0x20
    → ec_irq_clear_pending(10) ← 清除 IRQ10 (KBD 相关)

IRQ40 (0x1008BC40) — SMBus 完成:
    设置通知标志 |= 2
    ec_task_post(0x53)

IRQ48 (0x1008BC64) — SMBus 主控中断:
    ec_irq_disable(8)
    检查 SMBus 控制器状态:
        status[2] bit1 (传输完成?):
            如果 controller[1] == 0x01 (master mode):
                清除中断标志
                ec_smbus_master_tx(param, 0)
            否则:
                ec_smbus_master_rx(param, data, flag)
        status[0] bit0 (NACK/错误):
            清除错误标志
    ec_irq_enable(8)
```

### 5.3 SMBus 主控状态机 (0x10085518)

FUN_10085518 是一个复杂的 I2C/SMBus 协议状态机:

```
通道状态结构 (0x48 bytes per channel) @ DAT_10085570:
    [+0x00] flags: bit0=active, bit1=error, bit2=TX, bit3=RX_PEC,
                   bit4=in_progress, bit5=direction, bit6=last_byte, bit7=complete
    [+0x01] bus_status
    [+0x05] task_id (用于 ec_task_post)
    [+0x06] bus_index
    [+0x08] byte_counter
    [+0x09] state (状态机步骤)
    [+0x0A] length
    [+0x0B] PEC value
    [+0x0C] error_code
    [+0x10] tx_cmd_sequence (指向命令序列表)
    [+0x14] data_buffer
    [+0x18] descriptor pointer
    [+0x1C] flags2
    [+0x24] callback_even
    [+0x28] callback_odd
    [+0x2C] error_callback_even
    [+0x30] error_callback_odd
    [+0x34] PEC accumulator (4 bytes)
    [+0x36] saved length
    [+0x37] saved arg
    [+0x3A] saved bus_status

状态机步骤 (命令序列表中的操作码):
    0x01 = START (发送起始条件)
    0x02 = CHECK_BUS (检查总线状态)
    0x03 = SEND_ADDR (发送地址+方向位)
    0x04 = SEND_DESCRIPTOR_BYTE (发送描述符字节)
    0x05 = SEND_LENGTH (发送数据长度)
    0x06 = RECV_BYTE (接收一个字节)
    0x07 = SEND_DATA (发送数据块, 支持 DMA)
    0x08 = RECV_DATA (接收数据块, 支持 DMA)
    0x09 = WAIT_TIMEOUT
    0x0A = CALC_PEC (计算 PEC)
    0x0B = RELEASE_BUS
    0x0C = STOP (发送停止条件)

错误码:
    0x13 = 总线忙
    0x19 = 协议错误
    0x1F = PEC 校验失败
```

### 5.4 SMBus 主控发送/接收 API

```c
ec_smbus_master_tx(bus_index, direction):
    state = FUN_1007f884()  // 查找总线对应的通道状态
    state[0] = (state[0] & 0xDF) | 1 | (direction << 5)
    ec_task_post(state->descriptor->task_id)

ec_smbus_master_rx(bus_index, length, pec_flag):
    state = FUN_1007f884()
    state[0] = (state[0] & 0xF7) | 3 | (pec_flag << 3)
    state[1] = length
    ec_task_post(state->descriptor->task_id)
```

---

## 6. eSPI 子系统

### 6.1 eSPI 寄存器布局 (0x400BB000)

```
eSPI 控制器有 8 个逻辑通道 (channel 0-7)，每通道 7 个寄存器:
    通道 N 基址: 0x400BB000 + N * 7 偏移 (非线性映射):
        [+0x00+N*2] = status_low
        [+0x01+N*2] = status_high
        [+0x0A+N*2] = irq_status
        [+0x0C+N*2] = irq_enable
        [+0x1E+N]   = control
        [+0x70+N]   = extra_status
        [+0x28+N]   = data/extended

全局寄存器:
    0x400BB028-0x400BB03F: 扩展通道寄存器
```

### 6.2 eSPI 级联分发模式

```
21 个 eSPI IRQ 分为 3 组:

组 A (低优先级): IRQ42-47
    → 直接调用 ec_irq_clear_pending(event_id)
    → event_id 映射: 0x27, ?, ?, 0x32, 0x33, 0x38

组 B (中优先级): IRQ49-51, IRQ53-59
    → 部分调用 ec_espi_sub() (eSPI 状态解析)
    → 部分调用 ec_fifo_push() (位分发到 callback)
    → 然后 ec_irq_clear_pending()

组 C (高优先级): IRQ11, IRQ61-63
    → 简单的 clear-pending 调用
    → IRQ11: event 0x39, IRQ61: event 0x25, IRQ62: event 0x30
```

### 6.3 ec_espi_sub (0x10086AD4)

```
ec_espi_sub(channel):
    state = DAT_10086b5c[channel * 4]  // 通道状态指针
    flags = state[2]

    if bit7(flags):  // 传输完成
        FUN_100856e0(channel)  // 完成 callback
        state[2] = 0x80
    elif bit2(flags):  // 数据就绪
        关闭 alive 标志
        FUN_10085574(channel, state[0])  // 数据传输
        state[2] = 4
    else:
        确定长度: bit5 → 0x3F, bit4 → 0x10, else → 0
        result = FUN_10085518(channel, length)  // SMBus 状态机!
        if result == 1:
            关闭 alive, 禁用 IRQ
        else:
            ec_irq_clear_pending(event_irq[channel])

    注: eSPI 通道复用了 SMBus 状态机 (FUN_10085518)!
```

---

## 7. GPIO 子系统

### 7.1 GPIO 硬件布局

```
GPIO_0 (0x40080000-0x4008F000):
    8 个端口, 每端口 4 个寄存器 @ 2K 间距:
    Port 0: 0x40081000 [ctrl, out, stat, irq]
    Port 1: 0x40083000
    Port 2: 0x40085000
    Port 3: 0x40087000
    Port 4: 0x40089000
    Port 5: 0x4008B000
    Port 6: 0x4008D000
    Port 7: 0x4008F000

GPIO_1 (0x40090000-0x4009F000):
    8 个端口, 同样布局:
    Port 0: 0x40091000
    ...
    Port 7: 0x4009F000
```

### 7.2 IRQ60 — 主 GPIO 中断

```
IRQ60_Handler (0x1008BC88):
    if flag[0] != 0:
        ec_gpio_sub()                   // GPIO 基础处理
    if flag[0x71] bit2 && (flag[0x70] bit6 || flag[1] != 0):
        ec_thunk_irq60()               // 扩展 GPIO 处理
    if DAT_1008bccc[0x48] bit7:
        ec_gpio_handler_sub(data)       // I2C/SMBus 事务管理器
        清除标志
```

---

## 8. 键盘子系统

### 8.1 KBD 硬件

```
6 个 KBD 寄存器块:
    0x400C1000  (基础)
    0x400C7000
    0x400C9000
    0x400CB000
    0x400CD000
    0x400CF000

每块 4 字节: [status, data, control, irq]
```

### 8.2 IRQ 分组

```
IRQ10 (0x1008BAD0): KBD scancode 中断
IRQ24 (0x1008BA58): KBD OBF (输出缓冲满)
IRQ26 (0x1008BAA8): KBD IBF (输入缓冲满)
```

---

## 9. SRAM 全局变量映射

```
SRAM 范围: 0x200C0000 - 0x200C8000 (32KB)
SP 初始值: 0x200C8000

已识别的关键数据区:
    0x200C11D0: ACPI EC 相关数据
    0x200C1424: eSPI 通道状态
    0x200C1580: GPIO 配置表
    0x200C161C: 系统控制块
    0x200C173C: SMBus 地址表
    0x200C17BC: 共享配置 (被3个模块引用)
    0x200C1850: 任务队列
    0x200C1C3C: eSPI 数据缓冲
    0x200C1ECC: eSPI 控制状态
    0x200C3D70: GPIO 扩展数据
    0x200C4130: 固件信息块
    0x200C4498: SMBus 事务描述符
    0x200C64A8: SMBus 数据缓冲
    0x200C65B8: ACPI EC 通道表
    0x200C6A30: 系统启动参数
```

---

## 10. 关键发现与 PD 控制器问题关联

### 10.1 PD 控制器初始化路径

N3GHT15W (engineering EC) 中 PD 控制器的预期初始化流程:

```
1. ec_gpio_handler_sub(1) ← IRQ60 调用
   ↓
2. Switch case 3: SMBus 地址查找 → FUN_100942c8(address & 0x7F)
   ↓
3. FUN_1009cf98(port_index) ← 检查端口状态
   ↓
4. FUN_1009067c() ← 全局检查 (可能是 PD firmware ready 检查)
   ↓
5. 如果成功: ec_task_post(0x48) ← 启动 SMBus 事务
   ↓
6. FUN_10085518(channel, ...) ← SMBus 状态机执行 I2C 序列
```

### 10.2 问题分析

**PD 控制器 (TPS65982) 在 N3GHT15W 中不初始化的可能原因:**
1. FUN_1009067c() (全局检查函数) 返回 0 — 表示 PD firmware 不 ready
2. FUN_100942c8() (地址查找) 返回 -1 — 表示目标 I2C 地址不在配置表中
3. 两种情况都导致 pcVar6[-0x15] = error_code, 然后设置 error 标志

**需要验证**: 对比 N3GHT68W/69W 中的:
- FUN_100942c8 的 I2C 地址表 (SRAM @ 0x200C173C)
- FUN_1009067c 的实现是否有变化
- ec_gpio_handler_sub 的 switch case 3 路径

---

## 11. 交叉引用统计

| 函数 | XRef 数量 | 备注 |
|:-----|:---------:|:-----|
| ec_irq_clear_pending | 20 | 所有 eSPI handler 调用 |
| ec_irq_disable | 20 | SMBus/KBD/eSPI 锁定 |
| ec_irq_enable | 20 | SMBus/KBD/eSPI 解锁 |
| ec_task_post | 20+ | 全系统任务调度 |
| FUN_100883f8 | 20 | 高频工具函数 |
| FUN_100744fc | 20 | 高频工具函数 |
| FUN_100942c8 | 13 | SMBus 地址查找 |
| FUN_10082d98 | 11 | SMBus 数据写入 |
| FUN_10082fcc | 9 | GPIO/eSPI 工具 |
| ec_espi_sub | 5 | eSPI 通道分发 |
| ec_fifo_push | 3 | 位分发 |

---

## 12. 输出文件

| 文件 | 行数 | 内容 |
|:-----|:----:|:-----|
| docs/ec_irq_decompiled.txt | 1543 | VT 映射表 + 52/56 IRQ handler 反编译 C 代码 |
| docs/ec_deep_decompiled.txt | 3739 | 12 个关键函数 + 64 个子函数 (3级) + 全局变量表 |
| scripts/EC_IRQ_Export.java | ~200 | Ghidra headless IRQ 反编译脚本 |
| scripts/EC_Deep_Decompile.java | ~280 | Ghidra headless 深度反编译脚本 |
| scripts/ec_irq_reverse.py | ~400 | Capstone IRQ 分析脚本 (外设分类) |

---

## 13. 后续工作

1. **PD 控制器对比**: 在 N3GHT68W SPI dump 上运行同样的 Ghidra 分析，对比
   FUN_100942c8 地址表和 FUN_1009067c 检查逻辑

2. **QEMU 仿真**: 使用 QEMU 的 ARM Cortex-M 模拟器运行 EC二进制，观察 SMBus
   事务序列 (需要实现 eSPI/SMBus 外设模拟)

3. **ec_task_post 任务 ID 完整映射**: 追踪所有 108 个任务的处理函数

4. **ACPI EC 命令表反编译**: 追踪 6 个 ACPI EC 通道的命令处理逻辑，映射所有
   EC RAM 区域和 SCI 事件

5. **跨版本 diff**: 使用 BinDiff 或手动对比 N3GHT15W vs N3GHT68W 中的关键函数
