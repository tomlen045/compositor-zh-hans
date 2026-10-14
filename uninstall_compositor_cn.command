#!/bin/bash
# 从备份还原官方英文版 Compositor(卸载汉化)
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
  exit 1
fi
rm -rf "$TARGET"
cp -R "$BACKUP" "$TARGET"
echo "✅ 已还原为官方英文版。"
read -n 1 -s -r -p "按任意键关闭窗口…"
