# 状态与验证记录 (STATUS & Verification)

## 1. 运行环境

| 项目 | 参数 |
|---|---|
| 目标机型 | Redmi Note 12 Turbo / POCO F5 (`marble` / `marblein`) |
| 基础固件 | Xiaomi HyperOS 3.0.5.0 (`OS3.0.5.0.VMRCNXM`) |
| 操作系统 | LineageOS 24.0 (`24.0-20261027-NIGHTLY-marble`, Android 17) |
| 内核版本 | `5.10.269-gki-geff4b40407a1` |
| 构建工具链 | Ubuntu Clang 21.1.8 / LLD 21.1.8 (`LLVM=1 LLVM_IAS=1`) |
| 构建模式 | `CONFIG_LTO_CLANG_FULL=y` + `CONFIG_CFI_CLANG=y` (严格对齐原厂 GKI ABI) |

---

## 2. Droidspaces 依赖检查

运行 `droidspaces check`（v7.0.0）实测输出：

```text
Droidspaces v7.0.0 - Checking system requirements...

[MUST HAVE]
These features are required for Droidspaces to work:

  [✓] Root privileges
  [✓] Linux version
  [✓] PID namespace
  [✓] Mount namespace
  [✓] UTS namespace
  [✓] IPC namespace
  [✓] pivot_root syscall
  [✓] /proc filesystem
  [✓] /sys filesystem
  [✓] Seccomp support

[RECOMMENDED]
These features improve functionality but are not strictly required:

  [✓] epoll support
  [✓] signalfd support
  [✓] PTY support
  [✓] devpts support
  [✓] Loop device
  [✓] ext4 filesystem
  [✓] Cgroup v2 support
  [✓] Cgroup namespace
  [✓] devtmpfs support

[OPTIONAL]
These features are optional and only used for specific functionality:

  [✓] FUSE support
  [✓] TUN/TAP support
  [✓] OverlayFS support
  [✓] Network namespace
  [✓] Bridge device support
  [✓] Veth pair support
  [✓] Macvlan support
  [✓] IPv6 NAT support
  [✓] Memory limit support
  [✗] CPU limit support
      CONFIG_CFS_BANDWIDTH, and no cgroup_disable=cpu on the kernel command line; --cpus is skipped if absent
  [✓] CPU usage accounting
  [✗] Process limit support
      CONFIG_CGROUP_PIDS, and no cgroup_disable=pids on the kernel command line; --pids-limit is skipped if absent
  [✓] Sandboxing (user namespaces)

Summary:

  [✓] All required features found!
```

> **注**：`CONFIG_CFS_BANDWIDTH` 与 `CONFIG_CGROUP_PIDS` 按 Droidspaces 官方 GKI 指南显式保持关闭，以防止破坏调度器与 Cgroup 结构体导致 `vendor_dlkm` 厂商模块 CRC 校验失败崩溃。

---

## 3. 实机容器启动测试

实机运行 Alpine Linux 3.20 容器测试：

```text
Welcome to Droidspaces v7.0.0 !

[+] Configuration persisted to /data/local/tmp/container.config
[+] Configuring host-side networking for alpine-test...
[+] Applying Android system optimizations...
[+] Container started with PID 5228 (Monitor: 5224)
[+] Ensuring /data is mounted with suid support...
[+] Hardware access disabled: using isolated tmpfs...
[+] Booting 'alpine-test' (init: /sbin/init)...

Host: Android aarch64

Container: alpine-test (RUNNING)
  PID: 5228
  OS: Alpine Linux v3.20
  Hostname: alpine-test

Features:
  Networking: none
  SELinux: Enforcing

[+] Container 'alpine-test' is running in background.
```

进入容器执行命令验证：

```sh
# /etc/alpine-release
3.20.3

# id
uid=0(root) gid=0(root) groups=1004,1007,1011,1015,1028,1078,1079,3001,3002,3003,3006,3009,3011,3012

# uname -a
Linux alpine-test 5.10.269-gki-geff4b40407a1 #2 SMP PREEMPT aarch64 Linux

# ls -1 /proc/self/ns/
cgroup
ipc
mnt
net
pid
pid_for_children
time
time_for_children
user
uts
```

---

## 4. BakaSU (ReSukiSU) 内核级 Root 日志

内核启动 dmesg 实测输出：

```text
[    0.226174] KernelSU: Initialized with driver version: 35171, full_version: v4.2.0-rc3-35171baka-dirty, ABI: aarch64, Work mode: Built-in, ksu_uapi_version: 6
[    0.226176] KernelSU: initializing symbol resolver
[    0.226684] KernelSU: feature: feature management initialized
[    0.226686] KernelSU: feature: registered handler for sulog (id=2)
[    0.226687] KernelSU: feature: registered handler for adb_root (id=3)
[    0.226688] KernelSU: feature: registered handler for selinux_hide (id=4)
```

配套 Manager APK：`ReSukiSU_v4.2.0-rc3_35171-arm64-v8a-release.apk`。

---

## 5. 关键调试与排坑复盘

1. **固件代差与跨代系统崩溃**：
   - 现象：LineageOS 24 (Android 17) 在旧版 MIUI 14 (Android 13) 固件上开机立即掉回 fastboot。
   - 根因：LineageOS 24 的硬件抽象层与引导链依赖新版 HyperOS 3.0.5.0 固件驱动。
   - 解决：先完整线刷 HyperOS 3.0.5.0 全部分区，再安装 LineageOS 24 与 OrangeFox，引导与内核环境方能完全对齐。

2. **GKI 5.10 kABI 结构体偏移（kABI Shift）**：
   - 现象：在 GKI 5.10 内核中直接开启 `CONFIG_SYSVIPC`、`CONFIG_POSIX_MQUEUE`、`CONFIG_IPC_NS` 会导致手机 bootloop。
   - 根因：这些配置会向核心结构体（如 `task_struct`、`user_struct`）追加字段，破坏厂商驱动模块加载时的结构体成员偏移。
   - 解决：应用 Droidspaces 官方提供的 `001.GKI-below-6.12-fix_sysvipc_kabi_6_7_8.patch` 与 `002.5.10_or_lower_use_android_abi_padding_for_posix_mqueue.patch`，利用 Android 官方预留的 `ANDROID_KABI_USE` 槽位实现结构体大小与偏移零变动。

3. **调度器与 Cgroup 破坏性配置**：
   - 现象：开启 `CONFIG_CFS_BANDWIDTH` 与 `CONFIG_CGROUP_PIDS` 会导致数千个导出符号 CRC 剧烈变动，导致 `vendor_dlkm` 内全部驱动符号拒绝加载。
   - 解决：严格遵守 Droidspaces 官方规避建议，保持这两项为 `is not set`。

4. **构建内存优化（Full LTO OOM 解决）**：
   - 现象：Clang Full LTO 在链接 `vmlinux.o` 阶段消耗超 8GB 内存，在 9GB RAM 环境下触发 OOM-Killer。
   - 解决：关闭非必需的 `CONFIG_DEBUG_INFO`，将链接期内存占用由 ~14GB 压缩至 ~4GB，配合 32GB Swap 与 `-j8` 并行度实现稳定收敛完成链接。
