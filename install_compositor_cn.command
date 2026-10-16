#!/bin/bash
# Compositor 汉化一键安装(macOS)
# 用法:双击 install_compositor_cn.command,或在终端 bash install_compositor_cn.command
# 原理:把 zh-Hans 语言包注入 Compositor.app(不改动程序逻辑,可随时用 uninstall 还原)
#
# v1.2: 适配 macOS 15+ App Management 保护并修掉三类真实 bug——
#   ① /Applications 内原位写入被拦(Operation not permitted)→ 一律在 /tmp 副本上注入,
#      codesign 验签通过后再原子换位,任何一步失败原版都完好;
#   ② 重装时备份槽已被占用 → mv 会把原版嵌进备份目录里,现在先还原英文再重新注入;
#   ③ 重签名失败被静默吞掉 → inject_l10n.py 现在签名失败即退出非零,坏 bundle 不再落地。
set -e
cd "$(dirname "$0")"

APP="/Applications/Compositor.app"
BAK="/Applications/Compositor.app.en-backup"
WORK="/tmp/compositor_zh_work.app"
HOLD="/tmp/compositor_zh_hold"

echo "=============================================="
echo "  Compositor 汉化安装器"
echo "=============================================="
echo

# 0) 找到官方 app
if [ ! -d "$APP" ]; then
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

# 2) 重装场景:备份槽已被占用 → 先还原英文原版(旧汉化版移到 /tmp 待清)
rm -rf "$HOLD"
mkdir -p "$HOLD"
if [ -d "$BAK" ]; then
  echo "→ 检测到已汉化的旧安装,先还原英文原版再重新注入…"
  mv "$APP" "$HOLD/prev_zh.app"
  mv "$BAK" "$APP"
fi

# 3) 一律在 /tmp 副本上注入(绕开 App Management 原位写入限制)
echo "→ 注入 zh-Hans 语言包(570 条翻译)…"
rm -rf "$WORK"
cp -R "$APP" "$WORK"
python3 inject_l10n.py "$WORK" "Localizable.xcstrings"

# 4) 原子换位:原版整目录保留为备份,汉化版一步到位
mv "$APP" "$BAK"
mv "$WORK" "$APP"

# 5) 完成
echo
echo "✅ 汉化完成!"
echo "   · 打开方式:启动台/应用程序 → Compositor(界面即为简体中文)"
echo "   · 恢复英文:双击 uninstall_compositor_cn.command(从备份还原原版)"
echo "   · 注意:不要在 App 内点「安装更新」——更新会覆盖汉化,重跑本安装器即可恢复"
echo
if [ -t 0 ]; then
  read -n 1 -s -r -p "按任意键关闭窗口…"
fi
