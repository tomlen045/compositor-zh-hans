#!/bin/bash
# Compositor 汉化一键安装(macOS)
# 用法:双击 install_compositor_cn.command,或在终端 bash install_compositor_cn.command
# 原理:把 zh-Hans 语言包注入 Compositor.app(不改动任何原文件之外的东西,可随时用 restore 卸载)
set -e
cd "$(dirname "$0")"

APP_SOURCE="/Applications/Compositor.app"
APP_TARGET="/Applications/Compositor.app"   # 直接注入系统里的官方版
BACKUP="/Applications/Compositor.app.en-backup"

echo "=============================================="
echo "  Compositor 汉化安装器"
echo "=============================================="
echo

# 0) 找到官方 app
if [ ! -d "$APP_SOURCE" ]; then
  echo "❌ 未找到 /Applications/Compositor.app"
  echo "   请先从官方渠道安装 Compositor,再运行本安装器。"
  exit 1
fi

# 1) 已在运行则先退出(避免文件占用)
if pgrep -xq "Compositor"; then
  echo "→ 检测到 Compositor 正在运行,先退出它…"
  osascript -e 'tell application "Compositor" to quit' 2>/dev/null || killall Compositor 2>/dev/null || true
  sleep 2
fi

# 2) 备份原始英文版(仅第一次;保留用户可能已有的备份)
if [ ! -d "$BACKUP" ]; then
  echo "→ 备份原版到 $BACKUP …"
  cp -R "$APP_SOURCE" "$BACKUP"
fi

# 3) 注入中文语言包
echo "→ 注入 zh-Hans 语言包(570 条翻译)…"
python3 inject_l10n.py "$APP_TARGET" "Localizable.xcstrings"

# 4) 完成
echo
echo "✅ 汉化完成!"
echo "   · 打开方式:启动台/应用程序 → Compositor(界面即为简体中文)"
echo "   · 恢复英文:双击 uninstall_compositor_cn.command(从备份还原原版)"
echo "   · 注意:不要在 App 内点「安装更新」——更新会覆盖汉化,重跑本安装器即可恢复"
echo
read -n 1 -s -r -p "按任意键关闭窗口…"
