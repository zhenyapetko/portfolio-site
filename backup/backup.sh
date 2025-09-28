#!/bin/bash
# Простой бэкап Grafana volume в S3 с проверкой

# Настройки
BUCKET="portfolio-site-logs-from-loki"
DATE=$(date +%Y%m%d-%H%M%S)
VOLUME_NAME="portfolio-site_grafana_data"
LOG_FILE="/var/log/backup-grafana.log"

# Проверяем последний бэкап
LAST_BACKUP=$(aws s3 ls s3://$BUCKET/backups/grafana/ 2>/dev/null | grep .tar.gz | tail -1)
TODAY=$(date +%Y-%m-%d)

# Если сегодня уже есть бэкап - выходим
if echo "$LAST_BACKUP" | grep -q "$TODAY"; then
    echo "$(date) - ✅ Backup already exists for today" >> $LOG_FILE
    exit 0
fi

echo "$(date) - 🚀 Creating new backup..." >> $LOG_FILE

# Создаем бэкап volume
docker run --rm \
  -v $VOLUME_NAME:/source:ro \
  -v /tmp:/backup \
  alpine \
  tar czf /backup/grafana-$DATE.tar.gz -C /source .

# Загружаем в S3
aws s3 cp /tmp/grafana-$DATE.tar.gz s3://$BUCKET/backups/grafana/

# Очистка
sudo rm -f /tmp/grafana-$DATE.tar.gz

echo "$(date) - ✅ Backup completed: grafana-$DATE.tar.gz" >> $LOG_FILE