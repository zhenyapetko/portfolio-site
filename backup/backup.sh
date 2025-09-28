#!/bin/bash
# бэкап Grafana volume в S3

# Настройки
BUCKET="portfolio-site-logs-from-loki"
DATE=$(date +%Y%m%d-%H%M%S)
VOLUME_NAME="portfolio-site_grafana_data"
LOG_FILE="/var/log/backup-grafana.log"

# Создаем бэкап volume
docker run --rm \
  -v $VOLUME_NAME:/source:ro \
  -v /tmp:/backup \
  alpine \
  tar czf /backup/grafana-$DATE.tar.gz -C /source .

# Загружаем в S3
aws s3 cp /tmp/grafana-$DATE.tar.gz s3://$BUCKET/backups/grafana/

# Очистка
rm -f /tmp/grafana-$DATE.tar.gz

# Логируем успех
echo "$(date) - Backup completed: grafana-$DATE.tar.gz" >> $LOG_FILE