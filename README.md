# marble-droidspaces-kernel

适用于 **Redmi Note 12 Turbo / POCO F5 (`marble` / `marblein`)**，运行于 **LineageOS 24 (Android 17, GKI 5.10)** 上的自定义内核。完整补齐 [Droidspaces](https://github.com/ravindu644/Droidspaces-OSS) 容器运行时所需的内核能力，并源码级集成 **BakaSU (ReSukiSU)** 内核 Root。

提供经过严格实机验证的 **AnyKernel3 刷机包**、**Fastboot boot 镜像**、完整补丁集合以及复现构建配置。

---

## 核心特性

- **Droidspaces 容器全量支持**：
  - `droidspaces check` 必需项全部通过。
  - 原生启用 **PID**、**IPC**、**User (userns)**、**UTS**、**Net**、**Cgroup** 六大核心命名空间。
  - 开启 `CONFIG_DEVTMPFS`（硬件直通）、`CONFIG_SYSVIPC`、`CONFIG_POSIX_MQUEUE`、`CONFIG_MACVLAN`、`CONFIG_IP_SET`、`CONFIG_NF_TABLES` 等容器网络与防火墙扩展。
  - 实测运行 Alpine Linux 3.20 容器，支持多用户与完全隔离。
- **GKI 5.10 kABI 零破坏**：
  - 应用 Droidspaces 官方提供的 kABI padding 补丁，将新增结构体字段挂载至 Android ABI 预留位。
  - 严格保持 **Full LTO** 与 **KCFI** 开启，`vendor_dlkm` 厂商驱动模块加载 100% 正常，WiFi、蓝牙、触控、音频等硬件完全正常。
- **内置 BakaSU (ReSukiSU) 内核级 Root**：
  - 源码级集成 BakaSU v4.2.0-rc3 (Driver Version 35171)，开箱即用，无需依赖 LKM 运行时修补。
- **双重刷入支持**：
  - 提供 **AnyKernel3 刷机包**（支持在 Kernel Flasher 等内核管理器中免重启直刷，亦可在 Recovery 中刷入）。
  - 提供 **Fastboot `boot.img` 镜像**（可在 Bootloader 模式下直接线刷）。

---

## 适配基线与状态

| 项目 | 目标/实测值 |
|---|---|
| **设备型号** | Redmi Note 12 Turbo / POCO F5 (`marble`) |
| **底层固件** | Xiaomi HyperOS 3.0.5.0 (`OS3.0.5.0.VMRCNXM`) |
| **系统版本** | LineageOS 24.0 (Android 17, 20261027 nightly) |
| **内核版本** | `5.10.269-gki-geff4b40407a1` |
| **Recovery** | OrangeFox R11.1 / LineageOS Recovery |
| **Root 方案** | BakaSU (ReSukiSU) v4.2.0-rc3 (内置驱动 35171) |
| **Droidspaces 状态** | **[✓] All required features found!**（详见 [STATUS.md](STATUS.md)） |
| **容器实测** | Alpine Linux 3.20.3 正常运行，命名空间隔离完整 |

---

## 下载与刷入指南

### 1. 资源下载

请前往 [Releases 页面](../../releases/latest) 下载构建产物：

- **AnyKernel3 刷机包**：`LineageOS24-marble-droidspaces-ksu-AK3.zip`
  - SHA256: `a45ff660a4ae93a49042fd069d55af31c6e351ab6edc9320ad01bc13b0451b20`
- **Fastboot 线刷镜像**：`los-ksu-boot.img`
  - SHA256: `6b7ed7249ae6b52d14172f45cd5814138bd1012b3ee12d3053dfc70ad0554c51`

---

### 2. 刷入方式

#### 方式 A：使用内核管理器刷入（推荐）

1. 在手机上安装并打开 **Kernel Flasher**（或支持 AnyKernel3 规范的内核管理器）。
2. 在管理器中选择下载好的 `LineageOS24-marble-droidspaces-ksu-AK3.zip`，授予 Root 权限并执行刷入。
3. AnyKernel3 会自动在运行期就地解包当前槽位的 boot 分区，替换内核 Image 并保留原厂 Ramdisk 与上下文。
4. 刷入完成后，在管理器中点击重启系统即可生效。
*(备用方式：亦可在 OrangeFox / TWRP 等第三方 Recovery 中直接刷入该 Zip 包)*

#### 方式 B：Fastboot 线刷

1. 手机进入 Fastboot 模式（连接电脑，按住「电源键 + 音量减」）。
2. 在电脑终端执行命令刷入双槽：
   ```bash
   fastboot flash boot_a los-ksu-boot.img
   fastboot flash boot_b los-ksu-boot.img
   fastboot reboot
   ```

---

### 3. 开机后配置

1. **Root 管理器**：
   - 安装 `ReSukiSU_v4.2.0-rc3_35171-arm64-v8a-release.apk`（或兼容的 KernelSU 管理器）。
   - 打开应用，应直接显示内核集成状态（版本 35171，工作中）。
2. **Droidspaces 验证与运行**：
   - 打开 Droidspaces 应用，授予 Root 权限。
   - 前往 **设置** -> **系统要求** -> **检查要求**，所有必需项应全部为绿勾 `[✓]`。
   - 进入容器终端开始使用容器。

---

## 为什么不开启 CPU/进程限制？

在 `droidspaces check` 中，`CPU limit support` (`CONFIG_CFS_BANDWIDTH`) 与 `Process limit support` (`CONFIG_CGROUP_PIDS`) 显示为未支持。

**这是经过严谨工程权衡后的故意设计**：
- 依据 Droidspaces 官方 GKI 指南，在 5.10 GKI 内核上开启这两项配置会直接改变核心调度器结构体（`task_struct`、`cfs_rq`）的大小，导致数千个导出符号的 CRC 发生不可逆漂移。
- 手机开机加载原厂 `vendor_dlkm` 时因符号不兼容而触发崩溃重启（bootloop）。
- 保持关闭后，系统稳定性 100% 保持原生水准，代价仅是容器的 `--cpus` 与 `--pids-limit` 两个次要参数变灰，内存限制、网络隔离、设备直通、Docker 容器运行完全不受影响。

---

## 源码复现构建指南

### 1. 准备源码与工具链

```bash
# 1. 克隆 LineageOS 官方内核与配置
git clone https://github.com/LineageOS/android_kernel_xiaomi_sm8450 -b lineage-24.0 --depth=1 kernel
cd kernel

# 2. 应用 kABI 补丁与内核 Hook
patch -p1 < ../patches/001.GKI-below-6.12-fix_sysvipc_kabi_6_7_8.patch
patch -p1 < ../patches/002.5.10_or_lower_use_android_abi_padding_for_posix_mqueue.patch
patch -p1 < ../patches/003.rfcomm_clang_frame_warn.patch
patch -p1 < ../patches/004.drivers_kernelsu_hooks.patch

# 3. 集成 BakaSU 源码
git clone https://github.com/ReSukiSU/ReSukiSU -b main --depth=1 ../bakasu
cp -r ../bakasu/kernel drivers/kernelsu
cp -r ../bakasu/uapi drivers/kernelsu/include/uapi
patch -p1 -d drivers/kernelsu < ../patches/005.bakasu_kbuild_standalone.patch
```

### 2. 配置与编译

```bash
# 1. 以 LineageOS 24 原厂配置为基底，合并 Droidspaces 安全配置
mkdir -p out
cp ../configs/stock_los24_marble.config out/.config
cat ../configs/gki_droidspaces_safe.config >> out/.config
echo 'CONFIG_LOCALVERSION="-gki-geff4b40407a1"' >> out/.config
echo '# CONFIG_DEBUG_INFO is not set' >> out/.config

# 2. 刷新依赖 (必须携带 LLVM=1 确保编译器探测正确)
make O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 CC=clang olddefconfig
rm -f out/include/config/auto.conf out/include/config/auto.conf.cmd
make O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 CC=clang syncconfig

# 3. 编译 Image (启用 Full LTO 与 KCFI)
make O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 CC=clang -j$(nproc) Image
```

### 3. 打包

```bash
# 打包为 AnyKernel3 zip
../scripts/package_ak3.sh out/arch/arm64/boot/Image LineageOS24-marble-droidspaces-ksu-AK3.zip ../anykernel3
```

---

## 来源与声明 (Attribution)

- **LineageOS**：[LineageOS/android_kernel_xiaomi_sm8450](https://github.com/LineageOS/android_kernel_xiaomi_sm8450) & [android_device_xiaomi_marble](https://github.com/LineageOS/android_device_xiaomi_marble)
- **Droidspaces**：[ravindu644/Droidspaces-OSS](https://github.com/ravindu644/Droidspaces-OSS) (GPL-3.0)
- **BakaSU / ReSukiSU**：[ReSukiSU/ReSukiSU](https://github.com/ReSukiSU/ReSukiSU) (GPL-3.0)
- **AnyKernel3**：[osm0sis/AnyKernel3](https://github.com/osm0sis/AnyKernel3) (GPL-3.0)
- **OrangeFox**：[Ctapchuk/android_device_xiaomi_marble-OFRP](https://github.com/Ctapchuk/android_device_xiaomi_marble-OFRP)
- **工程协作**：本项目在固件代差适配、GKI kABI 结构体偏移排查、Full LTO 链接优化与容器验证中得到了 **Google DeepMind Antigravity AI 助理** 的协同技术协助。

---

## 许可证

本项目内核代码遵循 **GPL-2.0** 开源许可证，衍生补丁及脚本遵循相同授权。第三方组件保留其原有授权声明。
