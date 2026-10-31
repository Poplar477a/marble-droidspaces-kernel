## v1.0.0-marble

适用于 **Redmi Note 12 Turbo / POCO F5 (`marble`)**，基于 **LineageOS 24 (Android 17, 5.10.269-gki)** 的自定义内核与 AnyKernel3 刷机包。

### 核心亮点
- **Droidspaces 容器全量支持**：
  - 实测运行 Alpine Linux 3.20 容器，`droidspaces check` 必需项全部通过。
  - 补齐 PID / IPC / User / UTS / Net / Cgroup 命名空间，启用 devtmpfs、SysV IPC、POSIX mqueue、macvlan、ipset、tmpfs_xattr。
- **GKI kABI 零破坏**：
  - 打入 Droidspaces 官方 kABI 填充补丁，保留 Full LTO 与 KCFI，LineageOS `vendor_dlkm` 原厂驱动模块 100% 正常加载，不掉 WiFi、蓝牙或触摸。
- **内置 BakaSU (ReSukiSU)**：
  - 内核源码级集成 BakaSU v4.2.0-rc3 (35171)，开箱即用，无需额外修补 boot.img。

### 刷入方式
1. **AnyKernel3（推荐）**：在 OrangeFox / 第三方 Recovery 中直接刷入 `LineageOS24-marble-droidspaces-ksu-AK3.zip`。
2. **Fastboot 镜像**：手机进入 Fastboot 模式后执行：
   ```sh
   fastboot flash boot_a los-ksu-boot.img
   fastboot flash boot_b los-ksu-boot.img
   fastboot reboot
   ```

### 校验和 (SHA-256)
- `LineageOS24-marble-droidspaces-ksu-AK3.zip`: `a45ff660a4ae93a49042fd069d55af31c6e351ab6edc9320ad01bc13b0451b20`
- `los-ksu-boot.img`: `6b7ed7249ae6b52d14172f45cd5814138bd1012b3ee12d3053dfc70ad0554c51`
