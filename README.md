# Compositor 简体中文汉化包

给 macOS 开源图像编辑器 [Compositor](https://github.com/robbietilton/Compositor) 打的简体中文语言包 —— **570 条界面文案全中文**，不改程序、不用 Xcode、30 秒装好、随时还原。

![zh](https://img.shields.io/badge/语言-简体中文-red) ![coverage](https://img.shields.io/badge/覆盖-570%2F571%20键-brightgreen) ![no-xcode](https://img.shields.io/badge/无需-Xcode-success) ![version](https://img.shields.io/badge/适配-Compositor%201.5.2-blue)

## 这是什么

Compositor 官方只有英文界面。本项目通过 macOS **运行时语言包**机制（`.lproj`）把 570 条界面文案汉化后注入 App：

- ✅ 菜单、工具栏、设置面板、各类对话框全中文
- ✅ 不改程序逻辑，原版完整备份可随时还原
- ✅ 不需要 Xcode，不需要编译，任何 Mac 都能装
- ✅ 查不到翻译的键自动回退英文，永不影响功能

## 安装（30 秒）

> 前提：已安装官方 Compositor（[官网下载](https://robbietilton.com/compositor) 或 `brew install --cask robbietilton-compositor`）

```bash
git clone https://github.com/tomlen045/compositor-zh-hans.git
cd compositor-zh-hans
bash install_compositor_cn.command
```

或者下载仓库 zip 解压后**双击** `install_compositor_cn.command`。

安装脚本会自动：检测并退出正在运行的 Compositor → 备份原版（`Compositor.app.en-backup`）→ 注入中文语言包 → 重签名。

完成后打开 Compositor 即为简体中文界面。

## 恢复英文原版

```bash
bash uninstall_compositor_cn.command
```

从备份完整还原，等于从未汉化过。

## 常见问题

**Q：安装后界面还是英文？**
系统语言需为简体中文（系统设置 → 通用 → 语言与地区）。

**Q：App 内提示有更新？**
点「跳过此版本」。更新会覆盖汉化，更新后重跑安装脚本即可。

**Q：会影响功能或触发安全警告吗？**
不会影响功能。首次打开若提示"无法验证开发者"：右键 App → 打开；或系统设置 → 隐私与安全性 → 仍要打开（注入后重签名为 ad-hoc 签名的正常现象）。

**Q：适配哪些版本？**
Compositor 1.5.2 实测。其他版本可尝试——键不匹配的位置自动回退英文，不会崩。

**Q：哪些位置还是英文？**
极少数运行时动态拼接的文字（如快捷键面板的组合键名、部分长提示文案的插值部分）。完整 100% 覆盖需要源码级构建，见下方"技术细节"。

## 包内容

| 文件 | 说明 |
|---|---|
| `install_compositor_cn.command` | 一键安装 |
| `uninstall_compositor_cn.command` | 一键还原 |
| `inject_l10n.py` | 注入脚本（macOS 自带 Python 即可） |
| `Localizable.xcstrings` | 翻译源文件：571 键，zh-Hans 570 条，另含 ja/de/fr/es 核心词约 180 条 |

## 技术细节

- **原理**：Xcode String Catalog（`.xcstrings`）→ 转换为运行时 `Localizable.strings` → 注入 `Contents/Resources/zh-Hans.lproj/` + 声明 `CFBundleLocalizations` + ad-hoc 重签名
- **翻译生产管线**：自研 `uil10n` 工具链（scan → catalog → merge → verify，纯 Python 跨平台），SwiftUI 字面量零改动自动生效；AppKit 侧字符串（NSMenuItem/NSSAlert/工具提示）需在渲染点包 `String(localized:)`——本包对 1.5.2 源码做了 63 处此类补丁（未包含在本包内，属于源码级构建方案）
- **键格式**：插值字面量按参数真实类型转为 `%@` / `%lld` / `%lf`（与 Swift 编译器规则一致），字面 `%` 转义为 `%%`

## Star History

如果这个汉化包帮到了你，欢迎点个 Star ⭐

[![Star History Chart](https://api.star-history.com/svg?repos=tomlen045/compositor-zh-hans&type=Date)](https://star-history.com/#tomlen045/compositor-zh-hans&Date)

## License

MIT。Compositor 版权归其作者所有，本项目仅提供语言包，不包含程序本体。
