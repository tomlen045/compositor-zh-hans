#!/bin/bash
# 从备份还原官方英文版 Compositor(卸载汉化)
# v1.2: 适配 macOS 15+ App Management —— 还原走 rename 原子换位(不复制),
#       汉化版整目录移到 /tmp 待系统清理;顺手清掉 /tmp 工作残留。
set -e
BACKUP="/Applications/Compositor.app.en-backup"
TARGET="/Applications/Compositor.app"

echo "→ 恢复官方英文版 Compositor…"
if pgrep -xq "Compositor"; then
  osascript -e 'tell application "Compositor" to quit' 2>/dev/null || killall Compositor 2>/dev/null || true
  sleep 2
fi
if [ ! -d "$BACKUP" ]; then
  echo "❌ 未找到备份 $BACKUP,无法还原。"
  echo "   (若从未汉化过,无需还原)"
  exit 1
fi
rm -rf /tmp/compositor_zh_hold
mv "$TARGET" /tmp/compositor_zh_hold
mv "$BACKUP" "$TARGET"
rm -rf /tmp/compositor_zh_work.app
echo "✅ 已还原为官方英文版。"
echo "   (汉化版暂存 /tmp/compositor_zh_hold,重启后自动清除;重跑安装脚本可重新汉化)"
if [ -t 0 ]; then
  read -n 1 -s -r -p "按任意键关闭窗口…"
fi
