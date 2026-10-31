# 更新日志 (Changelog)

## [v1.0.0] - 2026-11-01

### 新增与支持 (Added)
- **Droidspaces 容器完整命名空间支持**：
  - `CONFIG_NAMESPACES=y`
  - `CONFIG_PID_NS=y`
  - `CONFIG_IPC_NS=y`
  - `CONFIG_USER_NS=y`
  - `CONFIG_UTS_NS=y`
  - `CONFIG_NET_NS=y`
- **IPC 与存储/设备支持**：
  - `CONFIG_SYSVIPC=y`
  - `CONFIG_POSIX_MQUEUE=y`
  - `CONFIG_DEVTMPFS=y`
  - `CONFIG_TMPFS_POSIX_ACL=y`
  - `CONFIG_TMPFS_XATTR=y`
- **网络与防火墙支持**：
  - `CONFIG_MACVLAN=y`
  - `CONFIG_IP_SET=y` (含 `CONFIG_IP_SET_HASH_IP=y` 与 `CONFIG_IP_SET_HASH_NET=y`)
  - `CONFIG_IP6_NF_NAT=y`
  - `CONFIG_IP6_NF_TARGET_MASQUERADE=y`
  - `CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y`
  - `CONFIG_NETFILTER_XT_MATCH_RECENT=y`
  - `CONFIG_NETFILTER_XT_TARGET_LOG=y`
  - `CONFIG_IP_NF_TARGET_REJECT=y` / `CONFIG_IP6_NF_TARGET_REJECT=y`
- **内核级 Root 集成**：
  - 内置集成 **BakaSU (ReSukiSU)** `v4.2.0-rc3` (Driver 35171)
  - 开箱即用支持配套 Manager (`com.resukisu.resukisu` 35171)

### 修复与兼容性 (Compatibility & Fixes)
- **kABI 保护**：
  - 引入 Droidspaces 官方 5.10 GKI kABI padding 补丁，将 SysV IPC 与 mqueue 挂接于 Android ABI 预留槽，防止破坏模块偏移
  - 保持 `CONFIG_CFS_BANDWIDTH` 与 `CONFIG_CGROUP_PIDS` 为未开启状态，避免破坏符号校验导致 bootloop
  - 严格保持 Full LTO 与 KCFI 开启，完全对齐 LineageOS 24 `vendor_dlkm` 厂商模块
- **构建优化**：
  - 禁用无运行时效用的 `CONFIG_DEBUG_INFO`，消除 LTO 链接阶段内存暴涨 OOM 隐患

### 交付物校验 (Hashes)
- `LineageOS24-marble-droidspaces-ksu-AK3.zip`
  - SHA256: `a45ff660a4ae93a49042fd069d55af31c6e351ab6edc9320ad01bc13b0451b20`
- `los-ksu-boot.img`
  - SHA256: `6b7ed7249ae6b52d14172f45cd5814138bd1012b3ee12d3053dfc70ad0554c51`
