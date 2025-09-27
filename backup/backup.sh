#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
export HOME=/home/ubuntu

# Параметры
BUCKET="portfolio-site-logs-from-loki"
BACKUP_DIR="/tmp/backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="/var/log/backup.log"

echo "$(date) - 🔍 Checking if backup is needed..." >> $LOG_FILE

# 1. Проверяем последний бэкап в S3
LAST_BACKUP_DATE=$(aws s3 ls s3://$BUCKET/backups/project-rsync/ | 
                   grep .tar.gz | 
                   awk '{print $1}' | 
                   sort | 
                   tail -1)

TODAY=$(date +%Y-%m-%d)

# 2. Если сегодня уже есть бэкап - выход
if [ "$LAST_BACKUP_DATE" == "$TODAY" ]; then
    echo "$(date) - ✅ Backup already exists for today: $TODAY" >> $LOG_FILE
    echo "✅ Backup already exists for today: $TODAY"
    exit 0
fi

echo "$(date) - 🚀 Starting new backup for: $TODAY" >> $LOG_FILE
echo "🚀 Creating new backup for: $TODAY"

# 3. Создание временной папку
mkdir -p $BACKUP_DIR

# 4. Копирование
rsync -av \
  /opt/portfolio-site/docker-compose.yml \
  /opt/portfolio-site/monitoring/ \
  /opt/portfolio-site/nginx/ \
  $BACKUP_DIR/project/

# 5. Копирование SSL сертификатов
sudo rsync -av /etc/letsencrypt/ $BACKUP_DIR/ssl/

# 6. Архивируем
tar -czf /tmp/backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  --exclude="ssl/live" \
  --exclude="ssl/accounts" \
  --exclude="ssl/archive" \
  -C /tmp $(basename $BACKUP_DIR)

# 7. Загрузка в S3
aws s3 cp /tmp/backup-*.tar.gz s3://$BUCKET/backups/project-rsync/

# 8. Очистка
sudo rm -rf $BACKUP_DIR
rm -f /tmp/backup-*.tar.gz

echo "$(date) - ✅ Backup completed: s3://$BUCKET/backups/project-rsync/backup-$(date +%Y%m%d-*).tar.gz" >> $LOG_FILE
echo "✅ Backup completed successfully!"