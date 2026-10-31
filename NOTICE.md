# NOTICE / 来源与声明

本项目为 **Redmi Note 12 Turbo / POCO F5 (`marble`)** 在 **LineageOS 24 (Android 17, GKI 5.10)** 上的自定义内核与 AnyKernel3 刷机包，包含 Droidspaces 容器全量支持与内置 BakaSU (ReSukiSU) root 支持。

本项目基于开源社区项目构建，遵循对应开源协议，所有上游版权归原作者所有。

---

## 1. 上游来源与引用

- **内核源码基座**：
  - 项目：[LineageOS/android_kernel_xiaomi_sm8450](https://github.com/LineageOS/android_kernel_xiaomi_sm8450)
  - 分支：`lineage-24.0`
  - Commit：`eff4b40407a1b6f1b1ab84554cbb540bcb495175`
  - 许可：GPL-2.0
  - 配套设备树：[LineageOS/android_device_xiaomi_marble](https://github.com/LineageOS/android_device_xiaomi_marble)

- **容器运行时与 kABI 补丁**：
  - 项目：[ravindu644/Droidspaces-OSS](https://github.com/ravindu644/Droidspaces-OSS)
  - 许可：GPL-3.0
  - 补丁来源：`Documentation/resources/kernel-patches/GKI/below-kernel-6.12/`
    - `001.GKI-below-6.12-fix_sysvipc_kabi_6_7_8.patch`
    - `002.5.10_or_lower_use_android_abi_padding_for_posix_mqueue.patch`

- **内核级 Root 解决方案**：
  - 项目：[ReSukiSU/ReSukiSU](https://github.com/ReSukiSU/ReSukiSU) (Baka-SU / BakaSU)
  - 版本：`v4.2.0-rc3` (Driver Version 35171, Commit `35171baka`)
  - 许可：GPL-3.0
  - 实现方式：源码集成内置 (`drivers/kernelsu`)

- **刷机包框架**：
  - 项目：[osm0sis/AnyKernel3](https://github.com/osm0sis/AnyKernel3)
  - 许可：GPL-3.0

- **第三方 Recovery 适配**：
  - 项目：[Ctapchuk/android_device_xiaomi_marble-OFRP](https://github.com/Ctapchuk/android_device_xiaomi_marble-OFRP) (OrangeFox R11.1)

---

## 2. 协助与鸣谢

本项目在排查固件代差、GKI 5.10 kABI 结构体偏移导致开机崩溃（bootloop）、Full LTO 链接内存耗尽（OOM）调优、BakaSU UAPI 头文件依赖修复及容器验证过程中，得到了 **DeepSeek AI** 与 **Google DeepMind Antigravity AI 助理** 的全流程工程协同与深度技术协助。

---

## 3. 开源许可

本项目内核修改部分遵循 **GPL-2.0** 协议发布。所有引用组件保持其原始授权与版权声明。
