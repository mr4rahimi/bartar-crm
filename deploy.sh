#!/usr/bin/env bash
# دیپلوی به سرور از روی لوکال (سرور به گیت دسترسی ندارد)
set -e

SERVER="root@185.164.73.224"
REMOTE_DIR="/var/www/bartar-crm"
LAST_TAG="deployed"

if git rev-parse "$LAST_TAG" >/dev/null 2>&1; then
  echo "فایل‌های تغییرکرده از آخرین دیپلوی:"
  FILES=$(git diff --name-only --diff-filter=d "$LAST_TAG" HEAD)
  if [ -z "$FILES" ]; then
    echo "تغییری برای ارسال نیست."; exit 0
  fi
  echo "$FILES"
  echo "$FILES" | rsync -avz --files-from=- ./ "$SERVER:$REMOTE_DIR/"

  # فایل‌های حذف‌شده را روی سرور هم پاک کن (rsync عمداً --delete ندارد)
  DELETED=$(git diff --name-only --diff-filter=D "$LAST_TAG" HEAD)
  if [ -n "$DELETED" ]; then
    echo "حذف فایل‌های زیر روی سرور:"
    echo "$DELETED"
    RM_CMD=$(echo "$DELETED" | sed "s|^|rm -f '$REMOTE_DIR/|; s|$|'|" | tr '\n' ';')
    ssh "$SERVER" "$RM_CMD"
  fi
else
  echo "اولین دیپلوی — ارسال کل سورس (به‌جز node_modules/.next/.git/.env):"
  rsync -avz \
    --exclude node_modules --exclude .next --exclude .git \
    --exclude .env --exclude .env.local \
    ./ "$SERVER:$REMOTE_DIR/"
fi

echo "اجرای build روی سرور…"
ssh "$SERVER" "cd $REMOTE_DIR && npm install && npx prisma generate && npx prisma migrate deploy && npm run build && pm2 restart bartar-crm"

git tag -f "$LAST_TAG"
echo "✅ دیپلوی کامل شد."
